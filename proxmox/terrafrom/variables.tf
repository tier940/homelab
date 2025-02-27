variable "tags" {
  description = "Tags for the environment"
  type        = map(string)
}

variable "base_template" {
  description = "Configuration for base template"
  type = object({
    target_node  = string
    datastore_id = string
    vmid         = number
    name         = string
    image = object({
      target_node  = string
      content_type = string
      datastore_id = string
      url          = string
    })
    cloud_config = string
    vm = object({
      node_name  = string
      cores      = number
      memory     = number
      qemu_agent = bool
      disk = object({
        datastore_id = string
        file_id      = number
        interface    = string
        iothread     = bool
        discard      = string
        size         = number
      })
      network = object({
        bridge      = string
        dns_servers = list(string)
        ip_config = object({
          ipv4 = object({
            address = string
            subnet  = string
            gateway = string
          })
          ipv6 = optional(object({
            address = string
            subnet  = string
            gateway = string
          }))
        })
      })
    })
  })
}

variable "controllers" {
  description = "Configuration for control plane VMs"
  type = object({
    base_clone_id = number
    base_name     = string
    base_domain   = string
    ciuser        = string
    cipassword    = string
    instances = map(object({
      target_node = string
      vmid        = number
      cores       = number
      memory      = number
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
      target_node = string
      vmid        = number
      cores       = number
      memory      = number
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
