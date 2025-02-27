resource "proxmox_virtual_environment_vm" "vm" {
  for_each = var.instances

  started   = false
  name      = "${var.base_name}${each.key}"
  tags      = ["kubernetes", var.tags.name, var.tags.stage]
  node_name = each.value.target_node
  vm_id     = each.value.vmid

  clone {
    vm_id = var.base_clone_id
    full  = true
  }

  agent {
    enabled = true
  }

  cpu {
    cores = each.value.cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = each.value.memory
    floating  = each.value.memory
  }

  initialization {
    dns {
      domain  = "${var.tags.env}.${var.tags.stage}.${var.base_domain}"
      servers = each.value.initialization.dns_servers
    }
    ip_config {
      ipv4 {
        address = "${each.value.initialization.ip_config.ipv4.address}/${each.value.initialization.ip_config.ipv4.subnet}"
        gateway = each.value.initialization.ip_config.ipv4.gateway
      }
    }
    user_account {
      username = var.ciuser
      password = var.cipassword
    }
  }

  network_device {
    bridge = "net0"
  }

  vga {
    memory = 16
    type   = "serial0"
  }

  lifecycle {
    ignore_changes = []
  }
}
