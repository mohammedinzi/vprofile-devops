#!/bin/bash
# ----------------------------------------
# Memcached Installation & Configuration Script
# ----------------------------------------
# This script installs Memcached, enables it 
# as a service, updates its configuration 
# to allow remote access, and restarts it 
# with custom ports.
# ----------------------------------------

# ----------------------
# 1. Install Memcached
# ----------------------
sudo dnf install -y memcached

# ----------------------
# 2. Start & Enable Service
# ----------------------
sudo systemctl start memcached
sudo systemctl enable memcached
sudo systemctl status memcached

# ----------------------
# 3. Update Configuration
# ----------------------
# Allow Memcached to listen on all interfaces
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/sysconfig/memcached

# Restart service to apply changes
sudo systemctl restart memcached

# ----------------------
# 4. Run Memcached Daemon
# ----------------------
# Launch memcached with custom ports
sudo memcached -p 11211 -U 11111 -u memcached -d
