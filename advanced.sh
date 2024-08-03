#!/bin/bash

# Replace with your actual SSH key and EC2 user
SSH_KEY="shellscript.pem"
EC2_USER="ubuntu"

# Check for required arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <action[nginx|apache]> <inventory_file>"
    exit 1
fi

action=$1
inventory_file=$2

# Validate action
if [ "$action" != "nginx" ] && [ "$action" != "apache" ]; then
    echo "Invalid action. Please provide either 'nginx' or 'apache'."
    exit 1
fi

# Check if inventory file exists
if [ ! -f "$inventory_file" ]; then
    echo "Inventory file not found!"
    exit 1
fi

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
    else
        echo "Nginx installed and simple webpage deployed on EC2 instance $server_ip."
    fi
}

while IFS= read -r server_ip; do
    if [ "$action" == "nginx" ]; then
        install_nginx "$server_ip"
    elif [ "$action" == "apache" ]; then
        install_apache "$server_ip"
    fi
done < "$inventory_file"

echo "Script execution completed."