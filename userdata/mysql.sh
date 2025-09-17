#!/bin/bash
# ----------------------------------------
# MariaDB Setup & Database Initialization Script
# ----------------------------------------
# This script performs the following tasks:
#   - Updates system packages
#   - Installs required utilities (git, zip, unzip)
#   - Installs and configures MariaDB 10.5
#   - Clones the application repository
#   - Secures MariaDB installation
#   - Creates the application database and users
#   - Restores data from a backup file
# ----------------------------------------

# Database root password
DATABASE_PASS='admin123'

# ----------------------
# 1. System Update & Prerequisites
# ----------------------
sudo dnf update -y
sudo dnf install -y git zip unzip

# ----------------------
# 2. Install & Start MariaDB
# ----------------------
sudo dnf install -y mariadb105-server

# Start and enable MariaDB service
sudo systemctl start mariadb
sudo systemctl enable mariadb

# ----------------------
# 3. Clone Application Repository
# ----------------------
cd /tmp/
git clone -b main https://github.com/hkhcoder/vprofile-project.git

# ----------------------
# 4. Secure MariaDB Installation
# ----------------------
sudo mysqladmin -u root password "$DATABASE_PASS"

# Update root user authentication
sudo mysql -u root -p"$DATABASE_PASS" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$DATABASE_PASS'"

# Remove insecure default accounts and test DB
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User=''"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"

# Apply privilege changes
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"

# ----------------------
# 5. Create Application Database & Users
# ----------------------
sudo mysql -u root -p"$DATABASE_PASS" -e "CREATE DATABASE accounts"
sudo mysql -u root -p"$DATABASE_PASS" -e "GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'localhost' IDENTIFIED BY 'admin123'"
sudo mysql -u root -p"$DATABASE_PASS" -e "GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'%' IDENTIFIED BY 'admin123'"

# ----------------------
# 6. Restore Database Backup
# ----------------------
sudo mysql -u root -p"$DATABASE_PASS" accounts < /tmp/vprofile-project/src/main/resources/db_backup.sql

# Apply final privilege changes
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"
# Restart MariaDB to ensure all changes take effect
sudo systemctl restart mariadb