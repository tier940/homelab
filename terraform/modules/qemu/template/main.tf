terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.88.0"
    }
  }
}

resource "proxmox_virtual_environment_download_file" "image" {
  content_type = "iso"
  node_name    = var.image.target_node
  datastore_id = var.image.datastore_id
  overwrite    = var.image.overwrite
  file_name    = var.image.file_name
  url          = var.image.url
}

resource "proxmox_virtual_environment_vm" "vm" {
  depends_on = [proxmox_virtual_environment_download_file.image]

  node_name     = var.vm.node_name
  name          = var.vm.name
  vm_id         = var.vm.vmid
  started       = false
  template      = true
  bios          = "ovmf"
  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"
  boot_order    = ["virtio0"]

  operating_system {
    type = "l26"
  }

  disk {
    datastore_id = var.vm.disk.datastore_id
    file_id      = proxmox_virtual_environment_download_file.image.id
    interface    = var.vm.disk.interface
    iothread     = true
  }

  efi_disk {
    datastore_id      = var.vm.disk.datastore_id
    file_format       = "raw"
    pre_enrolled_keys = true
    type              = "4m"
  }

  vga {
    type = "serial0"
  }

  serial_device {
    device = "socket"
  }

  agent {
    enabled = true
    timeout = "15m"
    trim    = false
    type    = "virtio"
  }
}
