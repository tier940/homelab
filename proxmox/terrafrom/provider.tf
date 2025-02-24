provider "proxmox" {
  pm_user         = "terraform-prov@pve"
  pm_password     = "ZZZZZZ"
  pm_api_url      = "https://proxmox.tier.f5.si:8006/api2/json"
  pm_tls_insecure = true
}
