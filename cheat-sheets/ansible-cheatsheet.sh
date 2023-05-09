# Ping machine:
#ansible -i ./inventory/hosts <group_name> -m <command> --user <server_user> --ask-pass
# apk-pass is for password prompt (Not safe, use SSH Keys)
ansible -i ./inventory/hosts servers -m ping --user root

# Playbook run:
# playbooks are used to automate reoccuring tasks.
# ansible-playbook ./playbooks/<playbook_name> --user <server_user> --ask-pass --ask-become-pass -i ./inventory/hosts
# --ask-become-pass asks to become super user
ansible-playbook ./playbooks/apt.yml --user root --ask-become-pass -i ./inventory/hosts

# To run playbook with specific key use args: --key-file
ansible-playbook $HOME/playbooks/apt.yml --user root --ask-become-pass -i $HOME/inventory/hosts --key-file $HOME/.ssh/ansible_ed25519

# To run playbook for ssh autorized_keys:
ansible-playbook $HOME/playbooks/autorized_keys.yml --user root --ask-become-pass -i $HOME/inventory/hosts --key-file $HOME/.ssh/ansible_ed25519

# To check playbook syntax use:
ansible-playbook foo.yml --check

# To check the playbook tags use:
# ansible-playbook <path_to_playbook/paybook.yml> --list-tags
ansible-playbook $HOME/playbooks/user_management.yml --list-tags

# To execute playbook with tags use:
# ansible-playbook <path_to_playbook/paybook.yml> --tags <tag_name>
ansible-playbook $HOME/playbooks/user_management.yml --tags add_new_group

# TO execute multiple tags:
ansible-playbook $HOME/playbooks/user_management.yml --tags add_new_group,add_new_user

# To execute playbook for specific groups, you have to provide the hosts file like so:
ansible-playbook -i inventory/hosts playbooks/user_management.yml --tags add_new_group
# The playbook must include the group required to run this:
#- hosts: other
#  become_user: root

# To roll out specific hosts file with specific user and user password run:
ansible-playbook -i $HOME/inventory/hosts $HOME/playbooks/initial_server_config.yml --tags create_users,create_groups,add_users_to_sudo --user root --ask-pass