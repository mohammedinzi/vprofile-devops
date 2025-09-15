#!/bin/bash
# ---------------------------------------------------------
# backend.sh
# Purpose: Provision backend services (Memcache, RabbitMQ, MySQL)
# for the Vprofile 3-tier application, all on one VM.
# ---------------------------------------------------------

# Define root DB password for automation
DATABASE_PASS='admin123'

# ------------------------------
# Install and Configure Memcache
# ------------------------------
yum install epel-release -y          # Enable EPEL repo (extra packages)
yum install memcached -y             # Install Memcached
systemctl start memcached            # Start service now
systemctl enable memcached           # Enable service at boot
systemctl status memcached           # Check status (helps debugging)
# Run Memcache as a daemon on TCP:11211 and UDP:11111
memcached -p 11211 -U 11111 -u memcached -d


# ------------------------------
# Install and Configure RabbitMQ
# ------------------------------
yum install socat -y                 # Required for RabbitMQ networking
yum install erlang -y                # Erlang runtime (RabbitMQ dependency)
yum install wget -y                  # To download RabbitMQ RPM

# Download and install RabbitMQ manually (v3.6.10 RPM package)
wget https://www.rabbitmq.com/releases/rabbitmq-server/v3.6.10/rabbitmq-server-3.6.10-1.el7.noarch.rpm
rpm --import https://www.rabbitmq.com/rabbitmq-release-signing-key.asc   # Verify package signature
yum update -y
rpm -Uvh rabbitmq-server-3.6.10-1.el7.noarch.rpm   # Install RabbitMQ

# Manage RabbitMQ service
systemctl start rabbitmq-server
systemctl enable rabbitmq-server
systemctl status rabbitmq-server

# Allow external users (not just localhost)
echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config

# Create an admin user (username: rabbit / password: bunny)
rabbitmqctl add_user rabbit bunny
rabbitmqctl set_user_tags rabbit administrator

# Restart RabbitMQ to apply changes
systemctl restart rabbitmq-server


# ------------------------------
# Install and Configure MySQL (MariaDB)
# ------------------------------
yum install mariadb-server -y        # Install MariaDB server

# Allow external connections (listen on 0.0.0.0 instead of localhost)
sed -i 's/^127.0.0.1/0.0.0.0/' /etc/my.cnf

# Start and enable DB service
systemctl start mariadb
systemctl enable mariadb

# Secure installation (non-interactive equivalent of mysql_secure_installation)
mysqladmin -u root password "$DATABASE_PASS"   # Set root password
mysql -u root -p"$DATABASE_PASS" -e "UPDATE mysql.user SET Password=PASSWORD('$DATABASE_PASS') WHERE User='root'"
mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost','127.0.0.1','::1')"
mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User=''"
mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"

# Create application-specific DB and grant access
mysql -u root -p"$DATABASE_PASS" -e "CREATE DATABASE accounts"
mysql -u root -p"$DATABASE_PASS" -e "GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'localhost' IDENTIFIED BY 'admin123'"
mysql -u root -p"$DATABASE_PASS" -e "GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'app01' IDENTIFIED BY 'admin123'"

# Load application schema/data from project repo
mysql -u root -p"$DATABASE_PASS" accounts < /vagrant/vprofile-repo/src/main/resources/db_backup.sql

# Apply privileges and restart DB
mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"
systemctl restart mariadb
