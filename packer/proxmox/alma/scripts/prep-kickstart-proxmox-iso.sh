#!/bin/sh

cat <<EOF > ./http/proxmox/linux/alma/8.6/almalinux.ks
# AlmaLinux 8.6 kickstart file with Proxmox support
url --url https://repo.almalinux.org/almalinux/8.6/BaseOS/x86_64/kickstart/
repo --name=BaseOS --baseurl=https://repo.almalinux.org/almalinux/8.6/BaseOS/x86_64/os/
repo --name=AppStream --baseurl=https://repo.almalinux.org/almalinux/8.6/AppStream/x86_64/os/
text
skipx
firstboot --disabled
lang en_US.UTF-8
keyboard be
timezone UTC --isUtc
network --bootproto=dhcp --hostname=${HOSTNAME}
firewall --disabled
services --enabled=sshd
selinux --enforcing
bootloader --location=mbr
zerombr
clearpart --all --initlabel
autopart --type=plain --nohome --noboot
rootpw "${PASSWORD}"
user --name="${USERNAME}" --plaintext --password "${PASSWORD}"
reboot --eject
%packages --ignoremissing --excludedocs --instLangs=en_US.UTF-8
bzip2
tar
qemu-guest-agent
-microcode_ctl
-iwl*-firmware
%end
# disable kdump service
%addon com_redhat_kdump --disable
%end
%post
sed -i "s/^.*requiretty/# Defaults requiretty/" /etc/sudoers
echo 'Defaults:${USERNAME} !requiretty' > /etc/sudoers.d/${USERNAME}
echo '${USERNAME} ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/${USERNAME}
chmod 440 /target/etc/sudoers.d/${USERNAME}
restorecon -R /home/${USERNAME}
%end
EOF