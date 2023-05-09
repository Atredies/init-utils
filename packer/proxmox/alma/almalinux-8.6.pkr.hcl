# VM Section
# ----------

variable "vm_name" {
  type    = string
  default = "alma"
}

variable "cpu" {
  type    = string
  default = "1"
}

variable "ram_size" {
  type    = string
  default = "1024"
}

variable "disk_size" {
  type    = string
  default = "10G"
}

variable "iso_checksum" {
  type    = string
  default = "65b3b4c17ce322081e2d743ee420b37b7213f4b14d2ec4f3c4f026d57aa148ec"
}

variable "iso_checksum_type" {
  type    = string
  default = "sha256"
}

# This is different and configured in the variable templates
variable "eth_point" {
  type    = string
  default = "ens18"
}

# VMware Section
# --------------

variable "iso_url" {
  type    = string
  default = "https://repo.almalinux.org/almalinux/8.6/isos/x86_64/AlmaLinux-8.6-x86_64-boot.iso"
}

# Proxmox Section
# ---------------

variable "pve_username" {
  type    = string
  default = "root"
}

variable "pve_token" {
  type    = string
  default = "secret"
}

variable "pve_url" {
  type    = string
  default = "https://127.0.0.1:8006/api2/json"
}

variable "iso_file"  {
  type    = string
  default = "local:iso/AlmaLinux-8.6-x86_64-boot.iso"
}

variable "vm_id" {
  type    = string
  default = "9000"
}

# Alma Linux Section
# ------------------

variable "username" {
  type    = string
  default = "almalinux"  
}

variable "password" {
  type    = string
  default = "AlmaLinux8.6"  
}

variable "sshkey" {
  type    = string
  default = "SSH_KEY_HERE"
}

variable "hostname" {
  type    = string
  default = "alma"
}

# Proxmox image section
# ---------------------

source "proxmox-iso" "almalinux" {
  proxmox_url = "${var.pve_url}"
  username = "${var.pve_username}"
  token = "${var.pve_token}"
  node = "#PVE_NODE_NAME_HERE"
  iso_checksum = "${var.iso_checksum_type}:${var.iso_checksum}"

  # Note you can use iso_url here
  # iso_url = "${var.iso_url}"

  # Comment the line below if iso_url is uncommented
  iso_file = "${var.iso_file}"
  insecure_skip_tls_verify = true
  
  cloud_init              = true
  cloud_init_storage_pool = "vms"

  boot_command         = [
    "<tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/almalinux.ks<enter><wait>"
  ]
  boot_wait            = "10s"
  communicator         = "ssh"
  cores                = "${var.cpu}"
  http_directory       = "./http/proxmox/linux/alma/8.6"
  memory               = "${var.ram_size}"
  ssh_timeout          = "30m"
  ssh_username         = "${var.username}"
  ssh_password         = "${var.password}"
  vm_name              = "${var.vm_name}"
  vm_id                = "${var.vm_id}"
  os        = "l26"
  network_adapters {
    model = "virtio"
    bridge = "vmbr0"
  }
  scsi_controller = "virtio-scsi-pci"
  disks {
    type = "scsi"
    disk_size  = "${var.disk_size}"
    storage_pool = "vms"
    storage_pool_type = "zfs"
    format = "raw"
  }
  template_name = "alma8.6-cloud"
  template_description = "Alma Linux 8.6 template to build Alma Linux server"
}


build {
  sources = [
    "source.proxmox-iso.almalinux"
  ]

  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -S -E sh {{ .Path }}"
    environment_vars = [
      "USERNAME=${var.username}",
      "SSHKEY=${var.sshkey}"
    ]
    scripts         = [
      "./scripts/update.sh", 
      "./scripts/ssh-config.sh",
      "./scripts/cleanup.sh",
    ]
    only = [ 
      "proxmox-iso.almalinux" 
    ]
  }
}