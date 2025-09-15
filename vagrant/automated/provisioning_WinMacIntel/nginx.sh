#!/bin/bash
# ---------------------------------------------------------
# nginx.sh
# Purpose: Install and configure Nginx as a reverse proxy 
# (frontend load balancer) for the Vprofile 3-tier application.
# ---------------------------------------------------------

# ------------------------------
# Install Nginx
# ------------------------------
apt update                       # Update package index
apt install nginx -y             # Install Nginx web server

# ------------------------------
# Configure Nginx Reverse Proxy
# ------------------------------
# Create a new site configuration for vproapp
cat <<EOT > vproapp
upstream vproapp {
  server app01:8080;             # Backend application server (Tomcat VM)
}

server {
  listen 80;                     # Listen on standard HTTP port

  location / {
    proxy_pass http://vproapp;   # Forward all traffic to the upstream (app01)
  }
}
EOT

# ------------------------------
# Enable Custom Nginx Site
# ------------------------------
mv vproapp /etc/nginx/sites-available/vproapp    # Move config to sites-available
rm -rf /etc/nginx/sites-enabled/default          # Remove default site config
ln -s /etc/nginx/sites-available/vproapp /etc/nginx/sites-enabled/vproapp

# ------------------------------
# Start and Enable Nginx
# ------------------------------
systemctl start nginx      # Start service now
systemctl enable nginx     # Enable service at boot
systemctl restart nginx    # Restart to apply new config
