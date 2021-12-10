#!/bin/bash
# This script is to be used on Arch Linux or Arch based distribution to change RADEON Graphics driver between:
# Mesa and Mesa-Git (Mesa-Git is experimental)

# It creates an easy menu for switching between the two

# Static Variables:
pacman_repo_config='/etc/pacman.conf'
pacman_status=$(cat ${pacman_repo_config} | fgrep '[mesa-git]')

# Check if mesa-git is in repository:
function repo_adjust() {
    if [ ${pacman_status} == '[mesa-git]' ]; then
        echo "Found mesa-git. Moving on"
    else
        echo "Not able to find mesa-git"
        echo '[mesa-git]' >> ${pacman_repo_config}
        echo 'SigLevel = Optional' >> ${pacman_repo_config}
        echo 'Server = http://pkgbuild.com/~lcarlier/$repo/$arch' >> ${pacman_repo_config}
        sudo pacman -Syy
    fi
}

# Checks mesa version
function check_mesa_version() {
    # Check version of mesa
    glxinfo | grep Mesa
}

# Function to install mesa-git 
# For different hardware different options are required these options are 1-8 10-18 23 in this case
function install_mesa_git() {
    # Check if repo exists
    echo "Checking if Repository exists"
    repo_adjust
    # Install mesa-git
    echo "Installing mesa-git. Please wait... "
    echo ""
    echo "Options to enter: 1-8 10-18 23"
    echo ""
    sudo pacman -S mesagit
    echo "mesa-git was installed successfully. Moving on... "
}

# Fucntion to install mesa 
function install_mesa() {
    echo "Uninstalling mesa-git. Please wait... "
    sudo pacman -Rdd mesagit
    echo "Installing mesa. Please wait... "
    sudo pacman -S  \
    mesa lib32-mesa \
    vulkan-radeon \
    mesa-vdpau \
    lib32-vulkan-radeon \
    lib32-mesa-vdpau \
    libva-mesa-driver \
    lib32-libva-mesa-driver \
    --noconfirm
    echo "mesa was installed successfully. Moving on... "
}

# Menu Options
function menu() {
        echo ""
        echo ""
        echo "-------------------"
        echo " M A I N - M E N U "
        echo "-------------------"
        echo "1. Install mesa-git"
        echo "2. Install mesa"
        echo "3. Check mesa version"
        echo "4. Exit"
        echo ""
        echo ""
}

# Menu functinality
function options_menu() {
        read -p "Enter choice [ 1 - 4 ]: " choice
        echo ""
        echo ""
        case $choice in
                1) install_mesa_git ;;
                2) install_mesa ;;
                3) check_mesa_version ;;
                4) exit 0 ;;
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