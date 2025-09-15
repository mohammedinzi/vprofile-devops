#!/bin/bash
# ---------------------------------------------------------
# rabbitmq.sh
# Purpose: Install and configure RabbitMQ for message queue
# ---------------------------------------------------------

sudo yum install epel-release wget -y
sudo yum update -y

cd /tmp/
dnf -y install centos-release-rabbitmq-38
dnf --enablerepo=centos-rabbitmq-38 -y install rabbitmq-server

systemctl enable --now rabbitmq-server   # Start and enable service

# Open firewall for RabbitMQ port
firewall-cmd --add-port=5672/tcp
firewall-cmd --runtime-to-permanent

# Allow external users
sudo sh -c 'echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config'

# Create test user with admin rights
sudo rabbitmqctl add_user test test
sudo rabbitmqctl set_user_tags test administrator
rabbitmqctl set_permissions -p / test ".*" ".*" ".*"

# Restart service
sudo systemctl restart rabbitmq-server
# sudo systemctl status rabbitmq-server   # Final status check