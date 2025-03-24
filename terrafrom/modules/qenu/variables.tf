variable "instances" {
  description = "A map of instances to create"
  type = map(object({
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
      })
    })
  }))
}

variable "base_name" {
  description = "Base name for the VMs"
  type        = string
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
