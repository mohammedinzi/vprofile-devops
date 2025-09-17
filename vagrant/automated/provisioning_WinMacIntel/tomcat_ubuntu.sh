#!/bin/bash
# ---------------------------------------------------------
# tomcat_ubuntu.sh
# Purpose: Install Java (OpenJDK 8) and Tomcat 8 on Ubuntu
# for the Vprofile 3-tier application (alternative setup).
# ---------------------------------------------------------

# ------------------------------
# Update and Upgrade System
# ------------------------------
sudo apt update             # Refresh package index
sudo apt upgrade -y         # Upgrade existing packages to latest versions

# ------------------------------
# Install Java (JDK 8)
# ------------------------------
# Tomcat 8 requires Java to run; here we use OpenJDK 8.
sudo apt install openjdk-8-jdk -y

# ------------------------------
# Install Tomcat 8 and Utilities
# ------------------------------
# tomcat8          → Core Tomcat runtime
# tomcat8-admin    → Web-based admin console
# tomcat8-docs     → Documentation package
# tomcat8-common   → Common files used across Tomcat utilities
# git              → Useful for cloning project repos if needed
sudo apt install tomcat8 tomcat8-admin tomcat8-docs tomcat8-common git -y
sudo systemctl start tomcat8        # Start Tomcat service
sudo systemctl enable tomcat8       # Enable Tomcat to start on boot
# sudo systemctl status tomcat8       # Check if Tomcat is running