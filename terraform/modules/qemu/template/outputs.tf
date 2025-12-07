output "template_vm_id" {
  description = "ID of the template VM"
  value       = proxmox_virtual_environment_vm.vm.vm_id
}

output "template_name" {
  description = "Name of the template VM"
  value       = proxmox_virtual_environment_vm.vm.name
}

output "image_file_id" {
  description = "ID of the downloaded image file"
  value       = proxmox_virtual_environment_download_file.image.id
}

output "template_vm" {
  description = "Full template VM resource object"
  value       = proxmox_virtual_environment_vm.vm
}
