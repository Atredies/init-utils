#!/bin/bash

# To run with sudo bash -x <script_name>
os=$(lsb_release -i | cut -f 2-)

if [[ $os == 'Debian' ]]; then
    wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
    dpkg -i packages-microsoft-prod.deb
    apt-get update
    apt-get install -y blobfuse

else
    echo "Different OS"

fi

# To Mount:
# Nextcloud: - Kept but not used as it was integrated in nextcloud script
#sudo blobfuse /mnt/nextcloud-backup --tmp-path=/mnt/resource/blobfusetmp  --config-file=/home/tech/fuse_connection.cfg -o attr_timeout=240 -o entry_timeout=240 -o negative_timeout=120 -o allow_other

# Proxmox:
#blobfuse /mnt/backup --tmp-path=/mnt/resource/blobfusetmp  --config-file=/root/fuse_connection.cfg -o attr_timeout=240 -o entry_timeout=240 -o negative_timeout=120 -o allow_other
