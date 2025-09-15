#!/bin/bash
# ---------------------------------------------------------
# nginx.sh
# Purpose: Install and configure Nginx reverse proxy
# ---------------------------------------------------------

apt update
apt install nginx -y

# Create Nginx site config pointing to Tomcat app server
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

# Move config and enable it
mv vproapp /etc/nginx/sites-available/vproapp
rm -rf /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/vproapp /etc/nginx/sites-enabled/vproapp

# Start and enable Nginx
systemctl start nginx
systemctl enable nginx
systemctl restart nginx
