#!/bin/bash

# Define variables
EC2_USER="ubuntu"  # Username for Ubuntu AMIs
EC2_INSTANCE_1="54.87.140.61"  # Replace with the public IP of the EC2 instance
EC2_INSTANCE_2="54.242.16.19"  # Replace with the public IP of the EC2 instance
SSH_KEY="shellscript.pem"  # Replace with the path to your SSH private key

# Function to install Apache and deploy a simple webpage
install_apache() {
    ssh -o StrictHostKeyChecking=no -i "$SSH_KEY" "$EC2_USER@$EC2_INSTANCE_1" << 'EOF'
        sudo apt-get update
        sudo apt-get install -y apache2
        sudo systemctl start apache2
        sudo systemctl enable apache2

        echo "<html>
        <head><title>Web Server 1</title></head>
        <body><h1>Welcome to Web Server 1 - Apache</h1></body>
        </html>" | sudo tee /var/www/html/index.html
EOF
    echo "Apache installed and simple webpage deployed on EC2 instance $EC2_INSTANCE_1."
}

# Function to install Nginx and deploy a simple webpage
install_nginx() {
    ssh -o StrictHostKeyChecking=no -i "$SSH_KEY" "$EC2_USER@$EC2_INSTANCE_2" << 'EOF'
        sudo apt-get update
        sudo apt-get install -y nginx
        sudo systemctl start nginx
        sudo systemctl enable nginx

        echo "<html>
        <head><title>Web Server 2</title></head>
        <body><h1>Welcome to Web Server 2 - Nginx</h1></body>
        </html>" | sudo tee /var/www/html/index.html
EOF
    echo "Nginx installed and simple webpage deployed on EC2 instance $EC2_INSTANCE_2."
}

# Check the argument and execute the corresponding function
if [ "$1" == "apache" ]; then
    install_apache
elif [ "$1" == "nginx" ]; then
    install_nginx
else
    echo "Usage: $0 {apache|nginx}"
    exit 1
fi

echo "Script execution completed."