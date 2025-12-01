terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.88.0"
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
    type  = "x86-64-v4"
  }

  memory {
    dedicated = each.value.memory
    floating  = each.value.memory
  }

  dynamic "disk" {
    for_each = each.value.disk
    content {
      datastore_id = disk.value.datastore_id
      interface    = disk.value.interface
      iothread     = disk.value.iothread
      discard      = disk.value.discard
      size         = disk.value.size
    }
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
