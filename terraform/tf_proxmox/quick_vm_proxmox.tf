terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.7.4"
    }
  }
}

provider "proxmox" {
  pm_api_url = "https://proxmox.lan:8006/api2/json"
  pm_api_token_id = "tfapi@pam!tf_api_token_23dc"
  pm_api_token_secret = "66ffd7cd-63f6-443e-95d7-413791924422"
  pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "example" {
    name = "tf-test"
    target_node = "pve"
    clone = var.template_name
    full_clone = true
}
