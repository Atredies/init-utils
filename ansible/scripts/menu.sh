#!/bin/bash

# This script generates a menu that allows you to use ansible much simpler than running commands by hand
# Please adjust parameters accordingly 

key_name="id.rsa"       # Define what the ssh keyname is
ansible_home="/ansible" # Define where ansible home is
hosts_home="${ansible_home}/inventory/hosts"
playbook_home="${ansible_home}/playbooks"
key_home="$HOME/.ssh/${key_name}"
default_user="root"

# Initial Server config
function initial_config() {
    echo "Setting up server for the first time"
    ansible-playbook -i ${hosts_home} ${playbook_home}/initial_server_config.yml --user ${default_user} --ask-pass
    echo "Done"
}

# DIST Upgrade
function apt_dist_upgrade() {
    echo "Doing: apt-get dist-upgrade"
    ansible-playbook -i ${hosts_home} ${playbook_home}/system_update.yml --key-file ${key_home} --tags dist
    echo "Done"
}

# Normal Upgrade
function apt_upgrade() {
    echo "Doing: apt-get upgrade"
    ansible-playbook -i ${hosts_home} ${playbook_home}/system_update.yml --key-file ${key_home} --tags upgrade
    echo "Done"
}

# Install Packages
function apt_install() {
    echo "Doing: apt-get dist-upgrade"
    ansible-playbook -i ${hosts_home} ${playbook_home}/system_update.yml --key-file ${key_home} --tags install
    echo "Done"
}

# Menu Functionality

# Menu Options
function menu() {
        echo ""
        echo ""
        echo "-------------------"
        echo " M A I N - M E N U "
        echo "-------------------"
        echo "1. Initial Server Config"
        echo "2. Dist Upgrade"
        echo "3. Normal Upgrade"
        echo "4. Install Packages"
        echo "5. Exit"
        echo ""
        echo ""
}

# Menu functinality
function options_menu() {
        read -p "Enter choice [ 1 - 5 ]: " choice
        echo ""
        echo ""
        case $choice in
                1) initial_config ;;
                2) apt_dist_upgrade ;;
                3) apt_upgrade ;;
                4) apt_install ;;
                5) echo "Exiting... " && exit 0 ;;
                *) echo -e "ERROR" && sleep 2
        esac
        echo ""
}

# Catch Ctrl + C
function trap_ctrl() {
        echo "" 
        echo ""
        echo " Ctrl + C caught... Exiting "
        echo ""
        exit 2
}
trap "trap_ctrl" 2

# While Loop to get the menu working
while true
        do
                menu
                options_menu
done