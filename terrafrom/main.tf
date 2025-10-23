terraform {
  required_version = "1.13.4"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
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

  basic_vms = {
    for k, v in var.basic_vms.instances :
    "${var.basic_vms.base_name}${k}" => {
      ipv4 = v.initialization.ip_config.ipv4.address
      ipv6 = try(v.initialization.ip_config.ipv6.address, null)
    }
  }
}

module "template" {
  source = "./modules/qemu/template"

  image    = var.template.image
  vm       = var.template.vm
  pve_auth = var.pve_auth
}

module "basic_vms" {
  source = "./modules/qemu/clone"

  instances     = var.basic_vms.instances
  base_name     = var.basic_vms.base_name
  base_clone_id = var.basic_vms.base_clone_id
  base_domain   = var.basic_vms.base_domain
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
  base_domain   = var.clusters.base_domain
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
  base_domain   = var.worker.base_domain
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
    tags        = var.tags
  })
}

resource "local_file" "inventory" {
  depends_on = [local.clusters_ips, local.workers_ips]

  directory_permission = "0755"
  file_permission      = "0644"
  filename             = "../ansible/inventories/${var.tags.stage}/${var.tags.env}.yml"
  content = templatefile("${path.module}/template/ansible/inventory.tpl", {
    base_domain = var.clusters.base_domain
    k8s_domain  = "${local.dns_prefix}.${var.clusters.base_domain}"
    clusters    = local.clusters_ips
    workers     = local.workers_ips
    basic_vms   = local.basic_vms
    tags        = var.tags
  })
}
