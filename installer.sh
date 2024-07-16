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

# Function to install dependencies
install_dependencies() {
    echo "Checking for required dependencies..."

    # Check and install Node.js (version 18 or higher)
    if ! command -v node &> /dev/null || [[ $(node -v | cut -d. -f1 | cut -dv -f2) -lt 18 ]]; then
        echo "Node.js not found or version is less than 18, installing..."
        if [[ "$OS" == "Ubuntu" || "$OS" == "Debian" ]]; then
            sudo apt-get remove -y nodejs
            curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
            sudo apt-get install -y nodejs
        elif [[ "$OS" == "CentOS" ]]; then
            sudo yum remove -y nodejs
            curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
            sudo yum install -y nodejs
        fi
        check_error "Installing Node.js"
    else
        echo "Node.js is already installed and version is 18 or higher."
    fi

    # Check and install npm
    if ! command -v npm &> /dev/null; then
        echo "npm not found, installing..."
        if [[ "$OS" == "Ubuntu" || "$OS" == "Debian" ]]; then
            sudo apt-get install -y npm
        elif [[ "$OS" == "CentOS" ]]; then
            sudo yum install -y npm
        fi
        check_error "Installing npm"
    else
        echo "npm is already installed."
    fi

    # Check and install axios
    if ! npm list -g axios &> /dev/null; then
        echo "axios not found, installing..."
        sudo npm install -g axios
        check_error "Installing axios"
    else
        echo "axios is already installed."
    fi

    echo "All dependencies are installed."
}

# Function to create a random user
create_random_user() {
    USERNAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)
    PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)
    echo "Creating user with username: $USERNAME and password: $PASSWORD"
    npm run createUser -- --username "$USERNAME" --password "$PASSWORD"
    echo "User created with username: $USERNAME and password: $PASSWORD"
}

# Function to install Skyport panel
install_panel() {
    git clone https://github.com/skyportlabs/panel/
    cd panel
    npm run seed
    create_random_user
    node .
    echo "Your panel is accessible on http://localhost:3001"
    cd ..
    echo "Thanks for using the script."
}

# Function to install Skyport node
install_node() {
    git clone https://github.com/skyportlabs/skyportd
    cd skyportd
    node .
    cd ..
    echo "Thanks for using the script."
}

# Function to install both Skyport panel and daemon
install_both() {
    install_panel
    install_node
}

# Function to uninstall Skyport panel
uninstall_panel() {
    echo "Uninstalling Skyport Panel..."
    pm2 stop skyport-panel
    pm2 delete skyport-panel
    sudo rm -rf /var/www/skyport/panel
    echo "Skyport Panel uninstalled."
    read -p "Press Enter to continue..."
    echo "Thanks for using the script."
}

# Function to uninstall Skyport node
uninstall_node() {
    echo "Uninstalling Skyport Daemon..."
    pm2 stop skyport-daemon
    pm2 delete skyport-daemon
    sudo rm -rf /var/www/skyport/daemon
    echo "Skyport Daemon uninstalled."
    read -p "Press Enter to continue..."
    echo "Thanks for using the script."
}

# Function to update Skyport panel
update_panel() {
    echo "Updating Skyport Panel..."

    cd /var/www/skyport/panel

    # Take a backup of skyport.db
    echo "Backing up skyport.db..."
    cp skyport.db skyport_backup.db
    check_error "Backing up skyport.db"

    # Remove all files except skyport.db using find
    echo "Removing all files except skyport.db..."
    find . -maxdepth 1 -type f ! -name 'skyport.db' -exec rm -f {} +
    check_error "Removing old files in Skyport Panel directory"

    # Check if the directory is empty (except for skyport.db)
    if [ -z "$(ls -A .)" ]; then
        # Clone the repository if the directory is empty
        sudo git clone https://github.com/skyportlabs/panel .
        check_error "Cloning Skyport Panel repository"
    else
        # If not empty, fetch and reset to pull the latest changes
        sudo git fetch origin
        sudo git reset --hard origin/main
        check_error "Fetching and resetting Skyport Panel repository"
    fi

    # Restore the backup of skyport.db
    echo "Restoring skyport.db backup..."
    mv skyport_backup.db skyport.db
    check_error "Restoring skyport.db backup"

    # Install dependencies and seed (assuming npm install and seed are required)
    npm install
    check_error "Installing npm dependencies for Skyport Panel"
    npm run seed
    check_error "Running seed for Skyport Panel"

    # Restart Skyport Panel with pm2
    pm2 restart skyport-panel
    check_error "Restarting Skyport Panel with pm2"

    echo "Skyport Panel updated."
    read -p "Press Enter to continue..."
    echo "Thanks for using the script."
}

# Function to update Skyport daemon
update_daemon() {
    echo "Updating Skyport Daemon..."
    cd /var/www/skyport/daemon
    sudo git pull origin master
    check_error "Pulling latest changes for Skyport Daemon"
    npm install
    check_error "Installing npm dependencies for Skyport Daemon"
    pm2 restart skyport-daemon
    check_error "Restarting Skyport Daemon with pm2"
    echo "Skyport Daemon updated."
    read -p "Press Enter to continue..."
    echo "Thanks for using the script."
}

# Function to check for errors
check_error() {
    if [ $? -ne 0 ]; then
        echo "Error: $1"
        exit 1
    fi
}

# Main script
echo "Select an option:"
echo "1. Install Skyport panel"
echo "2. Install Skyport node"
echo "3. Uninstall Skyport panel"
echo "4. Uninstall Skyport node"
echo "5. Update Skyport panel"
echo "6. Update Skyport daemon"
echo "7. Install both Skyport panel and node"
read -p "Enter your choice [1-7]: " choice

# Check OS compatibility
check_os

# Install dependencies
install_dependencies

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
    5)
        update_panel
        ;;
    6)
        update_daemon
        ;;
    7)
        install_both
        ;;
    *)
        echo "Invalid option selected."
        exit 1
        ;;
esac
```
