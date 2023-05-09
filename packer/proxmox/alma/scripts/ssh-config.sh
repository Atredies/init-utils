#!/bin/bash

#---- Install our SSH key ----
mkdir -m0700 /home/${USERNAME}/.ssh/

cat <<EOF >/home/${USERNAME}/.ssh/authorized_keys
${SSHKEY}
EOF

### set permissions
chmod 0600 /home/${USERNAME}/.ssh/authorized_keys
chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.ssh