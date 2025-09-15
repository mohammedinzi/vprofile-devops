#!/bin/bash
# ---------------------------------------------------------
# rabbitmq.sh
# Purpose: Install and configure RabbitMQ (message broker) 
# for the Vprofile 3-tier application.
# ---------------------------------------------------------

# ------------------------------
# Install Dependencies
# ------------------------------
sudo yum install epel-release -y   # Enable Extra Packages repo
sudo yum update -y                 # Update system packages
sudo yum install wget -y           # Install wget (used for downloads)

# ------------------------------
# Install RabbitMQ from CentOS repo
# ------------------------------
cd /tmp/
dnf -y install centos-release-rabbitmq-38         # Add RabbitMQ repo (version 38)
dnf --enablerepo=centos-rabbitmq-38 -y install rabbitmq-server  # Install RabbitMQ

# ------------------------------
# Start and Enable RabbitMQ
# ------------------------------
systemctl enable --now rabbitmq-server   # Enable + start service immediately

# ------------------------------
# Open Firewall Port for RabbitMQ
# ------------------------------
firewall-cmd --add-port=5672/tcp         # Open default RabbitMQ AMQP port (5672)
firewall-cmd --runtime-to-permanent      # Persist firewall rule across reboots

# ------------------------------
# Verify RabbitMQ Service
# ------------------------------
sudo systemctl start rabbitmq-server     # Ensure service is started
sudo systemctl enable rabbitmq-server    # Ensure service is enabled on boot
sudo systemctl status rabbitmq-server    # Check running status

# ------------------------------
# Configure RabbitMQ
# ------------------------------
# Allow external (non-localhost) connections
sudo sh -c 'echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config'

# Create a test user for the app (username: test, password: test)
sudo rabbitmqctl add_user test test
sudo rabbitmqctl set_user_tags test administrator   # Give admin rights
rabbitmqctl set_permissions -p / test ".*" ".*" ".*"  # Full permissions

# ------------------------------
# Restart RabbitMQ to Apply Config
# ------------------------------
sudo
systemctl restart rabbitmq-server
sudo systemctl status rabbitmq-server   # Final status check