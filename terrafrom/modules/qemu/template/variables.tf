variable "image" {
  description = "The image to use for the VM"
  type = object({
    target_node  = string
    datastore_id = string
    overwrite    = bool
    file_name    = string
    url          = string
  })
}

variable "vm" {
  description = "The VM configuration"
  type = object({
    node_name = string
    vmid      = number
    name      = string
    disk = object({
      datastore_id = string
      interface    = string
    })
  })
}

variable "pve_auth" {
  description = "The provider configuration"
  type = object({
    ssh_user_name = string
    ssh_key_name  = string
  })
}
