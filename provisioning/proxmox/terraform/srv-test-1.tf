# Proxmox Full-Clone
# ---
# Create a new VM from a clone
resource "proxmox_vm_qemu" "alma-test-01" {
    
    # VM General Settings
    target_node  = "PVE_NAME_HERE"
    vmid         = "200"
    name         = "alma-test-server-01"
    desc         = "Alma Test server with TF"

    # VM Advanced General Settings
    onboot       = true 

    # VM OS Settings
    clone        = "alma8.6-cloud"

    # VM System Settings
    agent        = 1
    
    # VM CPU Settings
    cores        = 1
    sockets      = 1
    cpu          = "host"    
    
    # VM Memory Settings
    memory       = 1024

    # VM Disk Settings
    disk {
        slot     = 0
        size     = "20G"
        type     = "scsi"
        storage  = "vms"
        iothread = 1
    }

    # VM Network Settings
    network {
        bridge   = "vmbr0"
        model    = "virtio"
        queues   = 0
        rate     = 0
        tag      = 0
    }

    # VM Cloud-Init Settings
    os_type      = "cloud-init"

    # (Optional) IP Address and Gateway
    ipconfig0 = "ip=dhcp"
    
    # (Optional) Default User
    # ciuser = "tech_ansible"
    
    # (Optional) Add your SSH KEY
    # sshkeys = <<EOF
    # ${var.ansible_ssh_key}
    # OF

    # Execute Ansible Playbook to configure server

    # 1. Set up Connection:
    connection {
        type        = "ssh"
        host        = self.ssh_host
        user        = var.default_user
        private_key = file(var.default_ssh_key_location)
        port        = self.ssh_port
    }

    # 2. Wait until SSH is ready
    provisioner "remote-exec" {
        inline = ["echo 'Wait until SSH is ready'"]
    }

    # 3. Run the playbooks needed
    provisioner "local-exec" {
        command ="ansible-playbook -i ${self.ssh_host}, --private-key ${var.default_ssh_key_location} ${var.ansible_path}/rhel-config.yml --extra-vars \"user_password=$USER_PASSWORD\"" 
        environment = {
          USER_PASSWORD = "${var.default_password_prompt}"
         }
    }
}