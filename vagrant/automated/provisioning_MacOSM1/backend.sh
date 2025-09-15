#!/bin/bash
# ---------------------------------------------------------
# backend.sh
# Purpose: Provision Database (MySQL/MariaDB), Memcache, and RabbitMQ 
# on a single VM for the Vprofile DevOps project.
# ---------------------------------------------------------

DATABASE_PASS='admin123'   # Define the DB root password for automation

# ------------------------------
# Install and Configure Memcache
# ------------------------------
yum install epel-release -y       # Enable extra packages repo
yum install memcached -y          # Install Memcached
systemctl start memcached         # Start service immediately
systemctl enable memcached        # Enable service at boot
systemctl status memcached        # Check running status (debugging aid)
memcached -p 11211 -U 11111 -u memcached -d   # Run Memcache as daemon on custom ports

# ------------------------------
# Install and Configure RabbitMQ
# ------------------------------
yum install socat erlang wget -y  # Install RabbitMQ dependencies
wget https://www.rabbitmq.com/releases/rabbitmq-server/v3.6.10/rabbitmq-server-3.6.10-1.el7.noarch.rpm
rpm --import https://www.rabbitmq.com/rabbitmq-release-signing-key.asc  # Import signing key
yum update -y
rpm -Uvh rabbitmq-server-3.6.10-1.el7.noarch.rpm  # Install RabbitMQ
systemctl start rabbitmq-server    # Start service
systemctl enable rabbitmq-server   # Enable on boot
systemctl status rabbitmq-server   # Verify status
echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config  # Allow external users
rabbitmqctl add_user rabbit bunny  # Create user (rabbit/bunny)
rabbitmqctl set_user_tags rabbit administrator   # Grant admin role
systemctl restart rabbitmq-server  # Restart to apply config

# ------------------------------
# Install and Configure MySQL/MariaDB
# ------------------------------
yum install mariadb-server -y      # Install MariaDB
sed -i 's/^127.0.0.1/0.0.0.0/' /etc/my.cnf  # Bind to all IPs for external access

systemctl start mariadb            # Start DB service
systemctl enable mariadb           # Enable DB service on boot

# Secure DB installation and setup schema
mysqladmin -u root password "$DATABASE_PASS"   # Set root password
# Remove insecure defaults
mysql -u root -p"$DATABASE_PASS" -e "UPDATE mysql.user SET Password=PASSWORD('$DATABASE_PASS') WHERE User='root'"
mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost','127.0.0.1','::1')"
mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User=''"
mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"

# Create app database and grant privileges
mysql -u root -p"$DATABASE_PASS" -e "CREATE DATABASE accounts"
mysql -u root -p"$DATABASE_PASS" -e "GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'localhost' IDENTIFIED BY 'admin123'"
mysql -u root -p"$DATABASE_PASS" -e "GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'app01' IDENTIFIED BY 'admin123'"

# Import seed data from project repo
mysql -u root -p"$DATABASE_PASS" accounts < /vagrant/vprofile-repo/src/main/resources/db_backup.sql

systemctl restart mariadb   # Restart DB to apply all configs
