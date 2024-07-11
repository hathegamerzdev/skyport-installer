#!/bin/bash

# Function to check OS compatibility
check_os() {
    OS=$(lsb_release -si)
    VERSION=$(lsb_release -sr)
    if [[ "$OS" == "Ubuntu" && ("$VERSION" == "22.04" || "$VERSION" == "24.04") ]] ||
       [[ "$OS" == "Debian" && ("$VERSION" == "11" || "$VERSION" == "12") ]] ||
       [[ "$OS" == "CentOS" && ("$VERSION" == "7" || "$VERSION" == "8" || "$VERSION" == "9" || "$VERSION" == "10" || "$VERSION" == "11") ]]; then
        echo "Supported OS detected: $OS $VERSION"
    else
        echo "Unsupported OS: $OS $VERSION"
        exit 1
    fi
}

# Function to install Skyport panel
install_panel() {
    git clone https://github.com/skyportlabs/panel/
    cd /var/www/skyport/panel
    npm install
    npm run seed
    npm run createUser
    cd ..
    echo "Thanks for using the script."
    echo "Made by Blare team!"
}

# Function to install Skyport node
install_node() {
    git clone https://github.com/skyportlabs/skyportd
    cd  /var/www/skyport/daemon
    npm install
    cd ..
    echo "Thanks for using the script."
    echo "Made by Blare team!"
}

# Function to uninstall Skyport panel
uninstall_panel() {
    rm -rf panel
    echo "Panel uninstalled."
    echo "Thanks for using the script."
    echo "Made by Blare team!"
}

# Function to uninstall Skyport node
uninstall_node() {
    rm -rf skyportd
    echo "Node uninstalled."
    echo "Thanks for using the script."
    echo "Made by Blare team!"
}

# Main script
echo "Select an option:"
echo "1. Install Skyport panel"
echo "2. Install Skyport node"
echo "3. Uninstall Skyport panel"
echo "4. Uninstall Skyport node"
read -p "Enter your choice [1-4]: " choice

# Check OS compatibility
check_os

case $choice in
    1)
        install_panel
        ;;
    2)
        install_node
        ;;
    3)
        uninstall_panel
        ;;
    4)
        uninstall_node
        ;;
    *)
        echo "Invalid option selected."
        exit 1
        ;;
esac
