locals {
  controllers_ips = {
    for k, v in var.controllers.instances :
    "${var.controllers.base_name}${k}" => {
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
}

module "controllers" {
  source        = "./modules/qemu"
  instances     = var.controllers.instances
  base_name     = var.controllers.base_name
  base_clone_id = var.controllers.base_clone_id
  base_domain   = var.controllers.base_domain
  ciuser        = var.controllers.ciuser
  cipassword    = var.controllers.cipassword
  tags          = var.tags
}

module "workers" {
  source        = "./modules/qemu"
  instances     = var.worker.instances
  base_name     = var.worker.base_name
  base_clone_id = var.worker.base_clone_id
  base_domain   = var.worker.base_domain
  ciuser        = var.worker.ciuser
  cipassword    = var.worker.cipassword
  tags          = var.tags
}

resource "local_file" "hosts" {
  directory_permission = "0755"
  file_permission      = "0644"
  filename             = "${path.module}/hosts/hosts.${var.tags.stage}"
  content = templatefile("${path.module}/templates/hosts.tpl", {
    base_domain = "${var.tags.env}.${var.tags.stage}.${var.controllers.base_domain}"
    controllers = local.controllers_ips
    workers     = local.workers_ips
  })
}
