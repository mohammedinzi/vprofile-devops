#!/bin/bash
# ----------------------------------------
# Apache Tomcat 10 Installation Script
# ----------------------------------------
# This script performs the following tasks:
#   - Updates and upgrades system packages
#   - Installs OpenJDK 17
#   - Installs Apache Tomcat 10 and related components
#   - Installs Git for version control
# ----------------------------------------

# ----------------------
# 1. Update & Upgrade Packages
# ----------------------
sudo apt update
sudo apt upgrade -y

# ----------------------
# 2. Install Java (OpenJDK 17)
# ----------------------
sudo apt install -y openjdk-17-jdk

# ----------------------
# 3. Install Apache Tomcat 10 & Dependencies
# ----------------------
sudo apt install -y tomcat10 tomcat10-admin tomcat10-docs tomcat10-common git
