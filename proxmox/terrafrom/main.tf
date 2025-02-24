resource "proxmox_lxc" "basic" {
  target_node  = "pve01"
  hostname     = "lxc-basic"
  cores        = 4
  ostemplate   = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
  password     = "BasicLXCContainer"
  unprivileged = true

  rootfs {
    storage = "local-zfs"
    size    = "8G"
  }

  network {
    name   = "eth0"
    bridge = "lan0"
    ip     = "dhcp"
  }
}
