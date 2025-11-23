variable "instances" {
  description = "A map of instances to create"
  type = map(object({
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
      })
    })
  }))
}

variable "base_name" {
  description = "Base name for the VMs"
  type        = string
  default     = ""
}

variable "base_clone_id" {
  description = "ID of the base VM to clone"
  type        = number
}

variable "base_domain" {
  description = "Base domain for the VMs"
  type        = string
}

variable "ciuser" {
  description = "Username for the VM"
  type        = string
}

variable "cipassword" {
  description = "Password for the VM"
  type        = string
}

variable "tags" {
  description = "Tags to assign to the VMs"
  type = object({
    name  = string
    stage = string
    env   = string
  })
}

variable "pve_auth" {
  description = "The provider configuration"
  type = object({
    ssh_user_name = string
    ssh_key_name  = string
  })
}
