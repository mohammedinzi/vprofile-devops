#!/bin/bash
# ---------------------------------------------------------
# memcache.sh
# Purpose: Install and configure Memcached for caching layer
# ---------------------------------------------------------

sudo dnf install epel-release -y       # Enable EPEL repo
sudo dnf install memcached -y          # Install Memcached
sudo systemctl start memcached         # Start service
sudo systemctl enable memcached        # Enable service at boot
sudo systemctl status memcached        # Verify service is running

# Update config to listen on all interfaces, not just localhost
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/sysconfig/memcached

# Restart Memcached to apply config
sudo systemctl restart memcached

# Open firewall for Memcache ports
firewall-cmd --add-port=11211/tcp
firewall-cmd --runtime-to-permanent
firewall-cmd --add-port=11111/udp
firewall-cmd --runtime-to-permanent

# Run Memcache as daemon
sudo memcached -p 11211 -U 11111 -u memcached -d
# sudo systemctl status memcached        # Final status check