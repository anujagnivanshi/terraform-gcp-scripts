#!/bin/bash
set -e
echo "**** Installing Nginx ****"
apt update
apt install -y nginx
ufw allow '${ufw_allow_nginx}'
systemctl enable nginx
systemctl restart nginx
echo "  Installation Complete  "
echo " Welcom to GCP VM Instance Deployed using Terraform " > /var/www/html/index.html