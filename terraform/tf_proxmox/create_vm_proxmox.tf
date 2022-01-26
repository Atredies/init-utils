# Requires terraform init first
# Update config with parameters
# Run terraform plan
# If all good, run terraform apply and type yes to continue

# Note: This requires that you have set an API User and Token on the Proxmox server
# Alternatively you can use:

#provider "proxmox" {
#    pm_api_url = "https://url:port/api2/json"
#    pm_tls_insecure = true
#    pm_user = "root@pam"
#    pm_password = "password"
#}

##################################################

terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.7.4"
    }
  }
}

provider "proxmox" {
  pm_api_url = "https://$SERVER_NAME:8006/api2/json"
  pm_api_token_id = "$USERNAME@pam!$API_TOKEN_NAME"
  pm_api_token_secret = "$API_TOKEN_SECRET"
  pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "test_server" {
  count = 1 # change to 0 to destroy VM 
  name = "test-vm-${count.index + 1}"

  target_node = var.proxmox_host # in vars file

  clone = var.template_name # in vars file

  agent = 1
  os_type = "Linux"
  cores = 2
  sockets = 1
  cpu = "host"
  memory = 2048
  scsihw = "virtio-scsi-pci"
  bootdisk = "scsi0"

  disk {
    slot = 0
    size = "20G"
    type = "scsi"
    storage = "vms"
    iothread = 1
  }
  
  network {
    model = "virtio"
    bridge = "vmbr0"
  }

  lifecycle {
    ignore_changes = [
      network,
    ]
  }
  
  ipconfig0 = "ip=$IP_RANGE_WITHOUT_LAST_DIGIT${count.index + 1}/24,gw=$GATEWAY"
  
  sshkeys = <<EOF
  ${var.ssh_key} # in vars file
  EOF
}
