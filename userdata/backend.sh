#!/bin/bash
# ----------------------------------------
# Automated Setup Script for Application Stack
# ----------------------------------------
# This script installs and configures the
# following components:
#   - Memcached
#   - RabbitMQ
#   - MariaDB (MySQL)
#
# It ensures services are installed, enabled,
# secured, and preloaded with required data.
# ----------------------------------------

# Database root password
DATABASE_PASS='admin123'

# ----------------------
# 1. Install & Configure Memcached
# ----------------------
yum install -y epel-release
yum install -y memcached

systemctl start memcached
systemctl enable memcached
systemctl status memcached

# Run memcached daemon with custom ports
memcached -p 11211 -U 11111 -u memcached -d

# ----------------------
# 2. Install & Configure RabbitMQ
# ----------------------
yum install -y socat erlang wget

wget https://www.rabbitmq.com/releases/rabbitmq-server/v3.6.10/rabbitmq-server-3.6.10-1.el7.noarch.rpm
rpm --import https://www.rabbitmq.com/rabbitmq-release-signing-key.asc
yum update -y
rpm -Uvh rabbitmq-server-3.6.10-1.el7.noarch.rpm

systemctl start rabbitmq-server
systemctl enable rabbitmq-server
systemctl status rabbitmq-server

# Allow external connections and create admin user
echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config
rabbitmqctl add_user rabbit bunny
rabbitmqctl set_user_tags rabbit administrator

systemctl restart rabbitmq-server

# ----------------------
# 3. Install & Configure MariaDB
# ----------------------
yum install -y mariadb-server

# Update bind address to allow external connections
sed -i 's/^127.0.0.1/0.0.0.0/' /etc/my.cnf

# Start & enable MariaDB
systemctl start mariadb
systemctl enable mariadb

# Secure the installation & configure root user
mysqladmin -u root password "$DATABASE_PASS"
mysql -u root -p"$DATABASE_PASS" -e "UPDATE mysql.user SET Password=PASSWORD('$DATABASE_PASS') WHERE User='root'"
mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User=''"
mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"

# Create application database and users
mysql -u root -p"$DATABASE_PASS" -e "CREATE DATABASE accounts"
mysql -u root -p"$DATABASE_PASS" -e "GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'localhost' IDENTIFIED BY 'admin123'"
mysql -u root -p"$DATABASE_PASS" -e "GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'app01' IDENTIFIED BY 'admin123'"

# Restore application data from backup
mysql -u root -p"$DATABASE_PASS" accounts < /vagrant/vprofile-repo/src/main/resources/db_backup.sql
mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"

# Restart MariaDB to apply changes
systemctl restart mariadb
