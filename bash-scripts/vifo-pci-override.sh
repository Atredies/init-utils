#!/bin/sh

# Script should be used if you have 2 GPUs that show up in LSPCI with the same name
# This is for a GPU passthrough for Virtual Machine (virtualized with qemu)

# This script is to be added in /usr/local/bin
# Also the /etc/default/grub has to be updated and generated

# Update DEVS with the ones for you
DEVS="0000:03:00.0 0000:03:00.1"

if [ ! -z "$(ls -A /sys/class/iommu)" ]; then
    for DEV in $DEVS; do
        echo "vfio-pci" > /sys/bus/pci/devices/$DEV/driver_override
    done
fi

modprobe -i vfio-pci