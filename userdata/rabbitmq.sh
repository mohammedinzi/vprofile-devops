#!/bin/bash
# ----------------------------------------
# RabbitMQ Installation & Configuration Script
# ----------------------------------------
# This script performs the following tasks:
#   - Imports RabbitMQ and Erlang signing keys
#   - Adds RabbitMQ YUM repository
#   - Updates system packages
#   - Installs dependencies, Erlang, and RabbitMQ
#   - Configures RabbitMQ for external connections
#   - Creates an admin user with full permissions
#   - Starts and enables RabbitMQ as a service
# ----------------------------------------

# ----------------------
# 1. Import Signing Keys
# ----------------------
rpm --import 'https://github.com/rabbitmq/signing-keys/releases/download/3.0/rabbitmq-release-signing-key.asc'
rpm --import 'https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key'
rpm --import 'https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-server.9F4587F226208342.key'

# ----------------------
# 2. Add RabbitMQ Repository
# ----------------------
curl -o /etc/yum.repos.d/rabbitmq.repo \
https://raw.githubusercontent.com/hkhcoder/vprofile-project/refs/heads/awsliftandshift/al2023rmq.repo

# ----------------------
# 3. Update System & Install Dependencies
# ----------------------
dnf update -y
dnf install -y socat logrotate

# ----------------------
# 4. Install Erlang & RabbitMQ
# ----------------------
dnf install -y erlang rabbitmq-server

# Enable and start RabbitMQ service
systemctl enable rabbitmq-server
systemctl start rabbitmq-server

# ----------------------
# 5. Configure RabbitMQ
# ----------------------
# Allow external connections by disabling loopback-only users
sudo sh -c 'echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config'

# Create admin user with full privileges
sudo rabbitmqctl add_user test test
sudo rabbitmqctl set_user_tags test administrator
rabbitmqctl set_permissions -p / test ".*" ".*" ".*"

# ----------------------
# 6. Restart Service
# ----------------------
sudo systemctl restart rabbitmq-server
