#!/bin/bash
# ---------------------------------------------------------
# memcache.sh
# Purpose: Provision and configure Memcached as the caching 
# layer for the Vprofile 3-tier application.
# ---------------------------------------------------------

# ------------------------------
# Install Memcached
# ------------------------------
sudo dnf install epel-release -y   # Enable EPEL repo for extra packages
sudo dnf install memcached -y      # Install Memcached

# ------------------------------
# Start and Enable Service
# ------------------------------
sudo systemctl start memcached     # Start Memcached immediately
sudo systemctl enable memcached    # Ensure it runs on system boot
sudo systemctl status memcached    # Check if the service is running

# ------------------------------
# Configure Memcached to listen on all interfaces
# ------------------------------
# By default Memcached binds only to 127.0.0.1 (localhost).
# This change allows other VMs (e.g., app01) to connect.
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/sysconfig/memcached

# Restart to apply changes
sudo systemctl restart memcached

# ------------------------------
# Open Firewall Ports
# ------------------------------
# Port 11211 (TCP) → Memcached default port for clients
firewall-cmd --add-port=11211/tcp
firewall-cmd --runtime-to-permanent

# Port 11111 (UDP) → Alternative port used in demo setup
firewall-cmd --add-port=11111/udp
firewall-cmd --runtime-to-permanent

# ------------------------------
# Run Memcached as Daemon
# ------------------------------
# -p → TCP port, -U → UDP port, -u → user, -d → daemon mode
sudo memcached -p 11211 -U 11111 -u memcached -d
# sudo systemctl status memcached    # Final status check