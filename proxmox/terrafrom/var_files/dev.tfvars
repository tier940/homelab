tags = {
  name  = "homelab"
  stage = "dev"
  env   = "a"
}

controllers = {
  base_clone_id = 9003
  base_name     = "k8s-controller-"
  base_domain   = "k8s.local"
  ciuser        = "fedora"
  cipassword    = "fedora"
  instances = {
    "001" = {
      target_node = "pve01"
      vmid        = 2000
      cores       = 4
      memory      = 8192
      initialization = {
        dns_servers = ["172.16.0.2"]
        ip_config = {
          ipv4 = {
            address = "172.16.8.1"
            subnet  = "16"
            gateway = "172.16.0.1"
          }
        }
      }
    }
    "002" = {
      target_node = "pve01"
      vmid        = 2001
      cores       = 4
      memory      = 8192
      initialization = {
        dns_servers = ["172.16.0.2"]
        ip_config = {
          ipv4 = {
            address = "172.16.8.2"
            subnet  = "16"
            gateway = "172.16.0.1"
          }
        }
      }
    }
  }
}

worker = {
  base_clone_id = 9002
  base_name     = "k8s-worker-"
  base_domain   = "k8s.local"
  ciuser        = "fedora"
  cipassword    = "fedora"
  instances = {
    "001" = {
      target_node = "pve01"
      vmid        = 2100
      cores       = 4
      memory      = 8192
      initialization = {
        dns_servers = ["172.16.0.2"]
        ip_config = {
          ipv4 = {
            address = "172.16.9.1"
            subnet  = "16"
            gateway = "172.16.0.1"
          }
        }
      }
    }
    "002" = {
      target_node = "pve01"
      vmid        = 2101
      cores       = 4
      memory      = 8192
      initialization = {
        dns_servers = ["172.16.0.2"]
        ip_config = {
          ipv4 = {
            address = "172.16.9.2"
            subnet  = "16"
            gateway = "172.16.0.1"
          }
        }
      }
    }
  }
}
