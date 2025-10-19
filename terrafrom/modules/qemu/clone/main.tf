terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.85.1"
    }
  }
}

data "local_file" "ssh_public_key" {
  filename = "${path.module}/../../../../ansible/roles/01-os-init/files/keys/k8s_homelab_ed25519.pub"
}

resource "proxmox_virtual_environment_vm" "vm" {
  for_each = var.instances

  node_name           = each.value.target_node
  name                = "${var.base_name}${each.key}"
  tags                = ["kubernetes", var.tags.name, var.tags.stage]
  vm_id               = each.value.vmid
  started             = each.value.started
  template            = false
  reboot_after_update = false
  stop_on_destroy     = true

  clone {
    vm_id = var.base_clone_id
    full  = true
  }

  cpu {
    cores = each.value.cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = each.value.memory
    floating  = each.value.memory
  }

  disk {
    datastore_id = each.value.disk.datastore_id
    interface    = each.value.disk.interface
    iothread     = each.value.disk.iothread
    discard      = each.value.disk.discard
    size         = each.value.disk.size
  }

  vga {
    type = "serial0"
  }

  initialization {
    dns {
      servers = each.value.initialization.dns_servers
    }
    ip_config {
      ipv4 {
        address = "${each.value.initialization.ip_config.ipv4.address}/${each.value.initialization.ip_config.ipv4.subnet}"
        gateway = each.value.initialization.ip_config.ipv4.gateway
      }
    }
    user_account {
      keys     = [trimspace(data.local_file.ssh_public_key.content)]
      username = var.ciuser
      password = var.cipassword
    }
  }

  network_device {
    bridge = each.value.network_bridge
  }

  lifecycle {
    ignore_changes = [started]
  }
}
