provider "proxmox" {
  insecure = true
  ssh {
    agent       = false
    username    = var.pve_auth.ssh_user_name
    private_key = file(pathexpand("~/.ssh/${var.pve_auth.ssh_key_name}"))
  }
}
