terraform {
  required_version = "1.14.2"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.6.1"
    }
  }
}

locals {
  dns_prefix = var.tags.stage == "dev" ? "${var.tags.stage}-${var.tags.env}" : var.tags.env

  clusters_ips = {
    for k, v in var.clusters.instances :
    "${var.clusters.base_name}${k}" => {
      ipv4 = v.initialization.ip_config.ipv4.address
      ipv6 = try(v.initialization.ip_config.ipv6.address, null)
    }
  }

  workers_ips = {
    for k, v in var.worker.instances :
    "${var.worker.base_name}${k}" => {
      ipv4 = v.initialization.ip_config.ipv4.address
      ipv6 = try(v.initialization.ip_config.ipv6.address, null)
    }
  }

  # Flatten basic_vms groups into a single map with {group}-{instance} naming
  basic_vms_flat = merge([
    for group_name, group in var.basic_vms.groups : {
      for instance_key, instance in group.instances :
      "${group_name}-${instance_key}" => instance
    }
  ]...)

  basic_vms = {
    for k, v in local.basic_vms_flat :
    k => {
      ipv4 = v.initialization.ip_config.ipv4.address
      ipv6 = try(v.initialization.ip_config.ipv6.address, null)
    }
  }

  # Create group-specific maps based on group names
  dns_vms      = { for k, v in local.basic_vms : k => v if startswith(k, "dns-") }
  proxy_vms    = { for k, v in local.basic_vms : k => v if startswith(k, "proxy-") }
  keycloak_vms = { for k, v in local.basic_vms : k => v if startswith(k, "keycloak-") }
}

module "template" {
  source = "./modules/qemu/template"

  image    = var.template.image
  vm       = var.template.vm
  pve_auth = var.pve_auth
}

module "basic_vms" {
  source = "./modules/qemu/clone"

  instances     = local.basic_vms_flat
  base_name     = ""
  base_clone_id = var.basic_vms.base_clone_id
  ciuser        = var.basic_vms.ciuser
  cipassword    = var.basic_vms.cipassword
  tags          = var.tags
  pve_auth      = var.pve_auth
}

module "clusters" {
  source = "./modules/qemu/clone"

  instances     = var.clusters.instances
  base_name     = var.clusters.base_name
  base_clone_id = var.clusters.base_clone_id
  ciuser        = var.clusters.ciuser
  cipassword    = var.clusters.cipassword
  tags          = var.tags
  pve_auth      = var.pve_auth
}

module "workers" {
  source = "./modules/qemu/clone"

  instances     = var.worker.instances
  base_name     = var.worker.base_name
  base_clone_id = var.worker.base_clone_id
  ciuser        = var.worker.ciuser
  cipassword    = var.worker.cipassword
  tags          = var.tags
  pve_auth      = var.pve_auth
}

resource "local_file" "hosts" {
  depends_on = [local.clusters_ips, local.workers_ips]

  directory_permission = "0755"
  file_permission      = "0644"
  filename             = "../ansible/roles/01-os-init/files/hosts/${var.tags.stage}/${var.tags.env}"
  content = templatefile("${path.module}/template/ansible/hosts.tpl", {
    base_domain = var.clusters.base_domain
    k8s_domain  = "${local.dns_prefix}.${var.clusters.base_domain}"
    clusters    = local.clusters_ips
    workers     = local.workers_ips
    basic_vms   = local.basic_vms
    proxy_vms   = local.proxy_vms
    tags        = var.tags
  })
}

resource "local_file" "inventory" {
  depends_on = [local.clusters_ips, local.workers_ips]

  directory_permission = "0755"
  file_permission      = "0644"
  filename             = "../ansible/inventories/${var.tags.stage}/${var.tags.env}.yml"
  content = templatefile("${path.module}/template/ansible/inventory.tpl", {
    base_domain      = var.clusters.base_domain
    k8s_domain       = "${local.dns_prefix}.${var.clusters.base_domain}"
    clusters         = local.clusters_ips
    workers          = local.workers_ips
    basic_vms        = local.basic_vms
    basic_vms_groups = var.basic_vms.groups
    tags             = var.tags
  })
}
