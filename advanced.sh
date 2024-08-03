#!/bin/bash

# Functions for installing webservers

install_apache() {
    server_ip="$1"
    ssh -o StrictHostKeyChecking=no -i "$SSH_KEY" "$EC2_USER@$server_ip" << EOF
        sudo apt-get update -qq
        sudo apt-get install -y apache2
        sudo systemctl start apache2
        sudo systemctl enable apache2

        echo "<html>
        <head><title>Web Server Apache</title></head>
        <body><h1>Welcome to Apache Web Server</h1></body>
        </html>" | sudo tee /var/www/html/index.html
EOF
    if [ $? -ne 0 ]; then
        echo "Error installing Apache on $server_ip"
        return 1
    else
        echo "Apache installed and simple webpage deployed on EC2 instance $server_ip."
    fi
}

install_nginx() {
    server_ip="$1"
    ssh -o StrictHostKeyChecking=no -i "$SSH_KEY" "$EC2_USER@$server_ip" << EOF
        sudo apt-get update -qq
        sudo apt-get install -y nginx
        sudo systemctl start nginx
        sudo systemctl enable nginx

        echo "<html>
        <head><title>Web Server Nginx</title></head>
        <body><h1>Welcome to Nginx Web Server</h1></body>
        </html>" | sudo tee /var/www/html/index.html
EOF
    if [ $? -ne 0 ]; then
        echo "Error installing Nginx on $server_ip"
        return 1
    else
        echo "Nginx installed and simple webpage deployed on EC2 instance $server_ip."
    fi
}

#######

# Replace with your actual SSH key and EC2 user
SSH_KEY="shellscript.pem"
EC2_USER="ubuntu"

# Define the list of server IP addresses
SERVER_IPS=("18.212.82.44" "54.242.147.63")  # Replace with your actual IP addresses

# Check for required argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <action[nginx|apache]>"
    exit 1
fi

action=$1

# Validate action
if [ "$action" != "nginx" ] && [ "$action" != "apache" ]; then
    echo "Invalid action. Please provide either 'nginx' or 'apache'."
    exit 1
fi

# Initialize a flag to track success
success=true

for server_ip in "${SERVER_IPS[@]}"; do
    if [ "$action" == "nginx" ]; then
        install_nginx "$server_ip" || success=false
    elif [ "$action" == "apache" ]; then
        install_apache "$server_ip" || success=false
    fi
done

# Check if the script executed successfully
if $success; then
    echo "Script execution completed."
else
    echo "This Script did not execute successfully, please check supplied arguments and try again."
fi
