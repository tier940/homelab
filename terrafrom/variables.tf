variable "tags" {
  description = "Tags for the environment"
  type        = map(string)
}

variable "pve_auth" {
  description = "Proxmox Provider configuration"
  type = object({
    ssh_user_name = string
    ssh_key_name  = string
  })
}

variable "template" {
  description = "Configuration for base template"
  type = object({
    image = object({
      target_node  = string
      datastore_id = string
      overwrite    = bool
      file_name    = string
      url          = string
    })
    vm = object({
      node_name = string
      vmid      = number
      name      = string
      disk = object({
        datastore_id = string
        interface    = string
      })
    })
  })
}

variable "basic_vms" {
  description = "Configuration for basic VMs"
  type = object({
    base_clone_id = number
    base_domain   = string
    ciuser        = string
    cipassword    = string
    groups = map(object({
      instances = map(object({
        target_node    = string
        vmid           = number
        started        = bool
        cores          = number
        memory         = number
        network_bridge = string
        disk = list(object({
          datastore_id = string
          interface    = string
          iothread     = bool
          discard      = string
          size         = number
        }))
        initialization = object({
          dns_servers = list(string)
          ip_config = object({
            ipv4 = object({
              address = string
              subnet  = number
              gateway = string
            })
            ipv6 = optional(object({
              address = string
              subnet  = number
              gateway = string
            }))
          })
        })
      }))
    }))
  })
}

variable "clusters" {
  description = "Configuration for control plane VMs"
  type = object({
    base_clone_id = number
    base_name     = string
    base_domain   = string
    ciuser        = string
    cipassword    = string
    instances = map(object({
      target_node    = string
      vmid           = number
      started        = bool
      cores          = number
      memory         = number
      network_bridge = string
      disk = list(object({
        datastore_id = string
        interface    = string
        iothread     = bool
        discard      = string
        size         = number
      }))
      initialization = object({
        dns_servers = list(string)
        ip_config = object({
          ipv4 = object({
            address = string
            subnet  = number
            gateway = string
          })
          ipv6 = optional(object({
            address = string
            subnet  = number
            gateway = string
          }))
        })
      })
    }))
  })
}

variable "worker" {
  description = "Configuration for worker VMs"
  type = object({
    base_clone_id = number
    base_name     = string
    base_domain   = string
    ciuser        = string
    cipassword    = string
    instances = map(object({
      target_node    = string
      vmid           = number
      started        = bool
      cores          = number
      memory         = number
      network_bridge = string
      disk = list(object({
        datastore_id = string
        interface    = string
        iothread     = bool
        discard      = string
        size         = number
      }))
      initialization = object({
        dns_servers = list(string)
        ip_config = object({
          ipv4 = object({
            address = string
            subnet  = number
            gateway = string
          })
          ipv6 = optional(object({
            address = string
            subnet  = number
            gateway = string
          }))
        })
      })
    }))
  })
}
