#!/bin/bash
# ---------------------------------------------------------
# mysql.sh
# Purpose: Provision MySQL/MariaDB database for Vprofile app
# ---------------------------------------------------------

DATABASE_PASS='admin123'

sudo yum update -y
sudo yum install epel-release git zip unzip -y
sudo yum install mariadb-server -y

# Start and enable MariaDB
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Clone project repo for DB seed file
cd /tmp/
git clone -b main https://github.com/hkhcoder/vprofile-project.git

# Secure MySQL installation
sudo mysqladmin -u root password "$DATABASE_PASS"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost','127.0.0.1','::1')"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User=''"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"

# Create database and user for the app
sudo mysql -u root -p"$DATABASE_PASS" -e "CREATE DATABASE accounts"
sudo mysql -u root -p"$DATABASE_PASS" -e "GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'localhost' IDENTIFIED BY 'admin123'"
sudo mysql -u root -p"$DATABASE_PASS" -e "GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'%' IDENTIFIED BY 'admin123'"

# Load seed data into DB
sudo mysql -u root -p"$DATABASE_PASS" accounts < /tmp/vprofile-project/src/main/resources/db_backup.sql

sudo systemctl restart mariadb   # Restart DB service

# Firewall setup for remote DB access
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --zone=public --add-port=3306/tcp --permanent
sudo firewall-cmd --reload

sudo systemctl restart mariadb
