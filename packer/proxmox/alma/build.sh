#!/bin/bash

# Note: This is the script that needs to be run with 'sudo bash build.sh'
set -e

source ./image-configs/$1-$2.shvars
sh ./scripts/prep-kickstart-$2-iso.sh

if [ $2 == "proxmox" ]; then
  packer build -on-error=ask -var username=${USERNAME} -var password=${PASSWORD} -var hostname=${HOSTNAME} -var sshkey="${SSHKEY}" -var-file=./image-configs/$1-$2.pkrvars.hcl -only=proxmox-iso.almalinux .
fi