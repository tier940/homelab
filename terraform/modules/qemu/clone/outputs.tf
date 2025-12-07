output "vm_ids" {
  description = "Map of instance names to VM IDs"
  value = {
    for k, v in proxmox_virtual_environment_vm.vm : k => v.vm_id
  }
}

output "vm_names" {
  description = "Map of instance keys to full VM names"
  value = {
    for k, v in proxmox_virtual_environment_vm.vm : k => v.name
  }
}

output "vm_ipv4_addresses" {
  description = "Map of instance names to IPv4 addresses"
  value = {
    for k, v in var.instances : k => v.initialization.ip_config.ipv4.address
  }
}

output "instances" {
  description = "Full VM resource objects for advanced use cases"
  value       = proxmox_virtual_environment_vm.vm
}
