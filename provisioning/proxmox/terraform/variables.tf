# Default Variables

variable "default_ssh_key_location" {
   description = "Default SSH Key Location for the Ansible account"
   type        = string
   default     = "~/.ssh/ansible"
}

variable "default_user" {
    description = "The default user used for ansible"
    type = string
    default = "ADMIN_USER_HERE"
  
}

variable "default_password_prompt" {
  description = "Ansible user password prompt"
  type        = string
  # sensitive   = true
}


# Proxmox Variables

variable "proxmox_api_url" {
    description = "API URL for Proxmox"
    type = string
    default = "https://127.0.0.1/8006/api2/json"
}

variable "proxmox_api_token_secret" {
    description = "API Token Generated from Proxmox"
    type = string
    default = "x-x-x-x-x"
}

variable "proxmox_api_token_id" {
    description = "API ID created in Proxmox"
    type = string
    default = "POXMOX_API_TOKEN_ID"
}


# Ansible Variables

variable "ansible_ssh_key" {
   description = "Default Public SSH Key for the Ansible account"
   type        = string
   default     = "#PUB_KEY_HERE"
}

variable "ansible_path" {
    description = "Location of Ansible files on local server"
    type = string
    default = "~/github/init-utils/configuration/ansible"
  
}





