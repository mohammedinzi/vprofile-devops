#!/bin/bash
# ---------------------------------------------------------
# mysql.sh
# Purpose: Provision MySQL (MariaDB) as the database layer 
# for the Vprofile 3-tier application.
# ---------------------------------------------------------

# Define root DB password for automation
DATABASE_PASS='admin123'

# ------------------------------
# Install Required Packages
# ------------------------------
sudo yum update -y                 # Update system packages
sudo yum install epel-release -y   # Enable Extra Packages for Enterprise Linux
sudo yum install git zip unzip -y  # Tools needed for cloning and unzipping
sudo yum install mariadb-server -y # Install MariaDB (MySQL-compatible)

# ------------------------------
# Start and Enable MariaDB Service
# ------------------------------
sudo systemctl start mariadb       # Start MariaDB now
sudo systemctl enable mariadb      # Enable auto-start on boot

# ------------------------------
# Prepare Database
# ------------------------------
cd /tmp/
git clone -b main https://github.com/hkhcoder/vprofile-project.git  # Clone repo for DB dump

# Secure MariaDB (non-interactive mysql_secure_installation)
sudo mysqladmin -u root password "$DATABASE_PASS"   # Set root password
# Remove insecure/default users and test DBs
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost','127.0.0.1','::1')"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User=''"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"

# Create application database and grant privileges
sudo mysql -u root -p"$DATABASE_PASS" -e "CREATE DATABASE accounts"
sudo mysql -u root -p"$DATABASE_PASS" -e "GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'localhost' IDENTIFIED BY 'admin123'"
sudo mysql -u root -p"$DATABASE_PASS" -e "GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'%' IDENTIFIED BY 'admin123'"

# Load initial data from repo (application schema + seed data)
sudo mysql -u root -p"$DATABASE_PASS" accounts < /tmp/vprofile-project/src/main/resources/db_backup.sql

# Reapply privileges
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"

# ------------------------------
# Restart DB Service
# ------------------------------
sudo systemctl restart mariadb

# ------------------------------
# Configure Firewall for External Access
# ------------------------------
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --get-active-zones                        # Show zones (debugging aid)
sudo firewall-cmd --zone=public --add-port=3306/tcp --permanent  # Allow MySQL traffic
sudo firewall-cmd --reload                                  # Apply rules
sudo systemctl restart mariadb                              # Restart DB with firewall active
sudo systemctl status mariadb                               # Final status check