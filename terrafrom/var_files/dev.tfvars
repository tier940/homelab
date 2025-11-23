tags = {
  name  = "homelab"
  stage = "dev"
  env   = "a"
}

pve_auth = {
  ssh_user_name = "root"
  ssh_key_name  = "id_rsa"
}

template = {
  image = {
    target_node  = "pve01"
    datastore_id = "local"
    overwrite    = false
    file_name    = "Fedora-Cloud-Base-Generic-43-1.6.x86_64.img"
    url          = "https://ftp.yz.yamagata-u.ac.jp/pub/linux/fedora-projects/fedora/linux/releases/43/Cloud/x86_64/images/Fedora-Cloud-Base-Generic-43-1.6.x86_64.qcow2"
  }
  vm = {
    node_name = "pve01"
    vmid      = 9000
    name      = "k8s-template-fedora-43"
    disk = {
      datastore_id = "local-lvm"
      interface    = "virtio0"
    }
  }
}

basic_vms = {
  base_clone_id = 9000
  base_domain   = "k8s.local"
  ciuser        = "fedora"
  cipassword    = "fedora"
  groups = {
    proxy = {
      instances = {
        "001" = {
          target_node    = "pve01"
          vmid           = 2100
          started        = true
          cores          = 2
          memory         = 1024
          network_bridge = "vmbr0"
          disk = [{
            datastore_id = "local-lvm"
            interface    = "virtio0"
            iothread     = true
            discard      = "on"
            size         = 8
          }]
          initialization = {
            dns_servers = ["10.0.0.1"]
            ip_config = {
              ipv4 = {
                address = "10.0.8.0"
                subnet  = "8"
                gateway = "10.0.0.1"
              }
            }
          }
        }
      }
    }
    dns = {
      instances = {
        "001" = {
          target_node    = "pve01"
          vmid           = 2101
          started        = true
          cores          = 2
          memory         = 2048
          network_bridge = "vmbr0"
          disk = [{
            datastore_id = "local-lvm"
            interface    = "virtio0"
            iothread     = true
            discard      = "on"
            size         = 8
          }]
          initialization = {
            dns_servers = ["10.0.0.1"]
            ip_config = {
              ipv4 = {
                address = "10.0.8.1"
                subnet  = "8"
                gateway = "10.0.0.1"
              }
            }
          }
        }
      }
    }
  }
}

clusters = {
  base_clone_id = 9000
  base_name     = "cluster-"
  base_domain   = "k8s.local"
  ciuser        = "fedora"
  cipassword    = "fedora"
  instances = {
    "001" = {
      target_node    = "pve01"
      vmid           = 2200
      started        = true
      cores          = 2
      memory         = 8192
      network_bridge = "vmbr0"
      disk = [{
        datastore_id = "local-lvm"
        interface    = "virtio0"
        iothread     = true
        discard      = "on"
        size         = 50
      }]
      initialization = {
        dns_servers = ["10.0.0.1"]
        ip_config = {
          ipv4 = {
            address = "10.0.9.0"
            subnet  = "8"
            gateway = "10.0.0.1"
          }
        }
      }
    }
  }
}

worker = {
  base_clone_id = 9000
  base_name     = "worker-"
  base_domain   = "k8s.local"
  ciuser        = "fedora"
  cipassword    = "fedora"
  instances = {
    "001" = {
      target_node    = "pve01"
      vmid           = 2300
      started        = true
      cores          = 4
      memory         = 16384
      network_bridge = "vmbr0"
      disk = [{
        datastore_id = "local-lvm"
        interface    = "virtio0"
        iothread     = true
        discard      = "on"
        size         = 50
        },
        {
          datastore_id = "local-zfs"
          interface    = "virtio1"
          iothread     = true
          discard      = "on"
          size         = 100
      }]
      initialization = {
        dns_servers = ["10.0.0.1"]
        ip_config = {
          ipv4 = {
            address = "10.0.10.0"
            subnet  = "8"
            gateway = "10.0.0.1"
          }
        }
      }
    }
    "002" = {
      target_node    = "pve01"
      vmid           = 2301
      started        = true
      cores          = 4
      memory         = 16384
      network_bridge = "vmbr0"
      disk = [{
        datastore_id = "local-lvm"
        interface    = "virtio0"
        iothread     = true
        discard      = "on"
        size         = 50
        },
        {
          datastore_id = "local-zfs"
          interface    = "virtio1"
          iothread     = true
          discard      = "on"
          size         = 100
      }]
      initialization = {
        dns_servers = ["10.0.0.1"]
        ip_config = {
          ipv4 = {
            address = "10.0.10.1"
            subnet  = "8"
            gateway = "10.0.0.1"
          }
        }
      }
    }
    "003" = {
      target_node    = "pve01"
      vmid           = 2302
      started        = true
      cores          = 4
      memory         = 16384
      network_bridge = "vmbr0"
      disk = [{
        datastore_id = "local-lvm"
        interface    = "virtio0"
        iothread     = true
        discard      = "on"
        size         = 50
        },
        {
          datastore_id = "local-zfs"
          interface    = "virtio1"
          iothread     = true
          discard      = "on"
          size         = 100
      }]
      initialization = {
        dns_servers = ["10.0.0.1"]
        ip_config = {
          ipv4 = {
            address = "10.0.10.2"
            subnet  = "8"
            gateway = "10.0.0.1"
          }
        }
      }
    }
  }
}
