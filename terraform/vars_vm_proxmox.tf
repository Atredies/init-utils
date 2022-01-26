variable "ssh_key" {
  default = "$SSH_PUB_KEY"
}

variable "proxmox_host" {
    default = "$NODE_NAME"
}

variable "template_name" {
    default = "$TEMPLATE_NAME"
}