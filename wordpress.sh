#!/bin/bash

# Replace with your actual SSH key and EC2 user
SSH_KEY="shellscript.pem"
EC2_USER="ubuntu"
SERVER_IP="18.205.239.19"

# Function to install Docker and Docker Compose on the remote server
install_docker_and_compose() {
    local server_ip=$1

    ssh -o StrictHostKeyChecking=no -i "$SSH_KEY" "$EC2_USER@$server_ip" << "EOF"
        set -e  # Exit immediately if a command exits with a non-zero status

        # Update package information and install prerequisites
        sudo apt-get update
        sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

        # Add Docker's official GPG key and set up the stable repository
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
          $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        # Install Docker
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io

        # Verify Docker installation
        docker --version

        # Install Docker Compose plugin
        sudo apt-get install -y docker-compose-plugin

        # Verify Docker Compose installation
        docker compose version

        # Remove existing repository directory if it exists
        if [ -d "docker-wordpress" ]; then
            echo "Removing existing 'docker-wordpress' directory..."
            sudo rm -rf docker-wordpress
        fi

        # Clone the repository
        git clone https://github.com/PISTIS-Solutions/docker-wordpress.git
        cd docker-wordpress

        # Rename file if it has a leading space
        if [ -f " docker-compose.yml" ]; then
            mv ' docker-compose.yml' docker-compose.yml
        fi

        # Check if the docker-compose.yml file exists
        if [ ! -f "docker-compose.yml" ]; then
            echo "docker-compose.yml file not found in the 'docker-wordpress' directory."
            exit 1
        fi

        # Human approval step
        read -p "Do you want to run 'docker compose up'? (yes/no): " response
        if [[ "$response" == "yes" ]]; then
            sudo docker compose up -d
            echo "Docker Compose is running."
        else
            echo "Docker Compose was not started."
        fi
EOF
}

# Initialize success variable
success=true

# Call the function and capture the exit status
if ! install_docker_and_compose "$SERVER_IP"; then
    success=false
fi

# Check if the script executed successfully
if $success; then
    echo "Script execution completed."
else
    echo "This Script did not execute successfully, please check supplied arguments and try again."
fi

