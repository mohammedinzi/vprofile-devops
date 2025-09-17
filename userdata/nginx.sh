#!/bin/bash
# ----------------------------------------
# NGINX Reverse Proxy Configuration Script
# ----------------------------------------
# This script performs the following tasks:
#   - Installs NGINX
#   - Configures it as a reverse proxy for the application
#   - Cleans up default site configuration
#   - Enables and restarts NGINX service
# ----------------------------------------

# ----------------------
# 1. Install NGINX
# ----------------------
apt update -y
apt install -y nginx

# ----------------------
# 2. Create Reverse Proxy Configuration
# ----------------------
cat <<EOT > vproapp
upstream vproapp {
    server app01:8080;
}

server {
    listen 80;

    location / {
        proxy_pass http://vproapp;
    }
}
EOT

# Move configuration to NGINX sites-available
mv vproapp /etc/nginx/sites-available/vproapp

# Remove default configuration
rm -rf /etc/nginx/sites-enabled/default

# Enable new configuration
ln -s /etc/nginx/sites-available/vproapp /etc/nginx/sites-enabled/vproapp

# ----------------------
# 3. Start & Enable NGINX
# ----------------------
systemctl start nginx
systemctl enable nginx
systemctl restart nginx
