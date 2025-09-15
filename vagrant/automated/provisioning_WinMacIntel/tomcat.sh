#!/bin/bash
# ---------------------------------------------------------
# tomcat.sh
# Purpose: Provision Tomcat 10 (Java app server) and deploy
# the Vprofile web application built via Maven.
# Target: CentOS Stream 9 (ARM)
# ---------------------------------------------------------

# ------------------------------
# Variables
# ------------------------------
TOMURL="https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.26/bin/apache-tomcat-10.1.26.tar.gz"
# URL of Tomcat 10 binary distribution

# ------------------------------
# Install Dependencies
# ------------------------------
dnf -y install java-17-openjdk java-17-openjdk-devel   # Install Java 17 (required for Tomcat 10)
dnf install git wget unzip zip -y                      # Essential tools for download/build

# ------------------------------
# Download and Extract Tomcat
# ------------------------------
cd /tmp/
wget $TOMURL -O tomcatbin.tar.gz                       # Download Tomcat binary
EXTOUT=`tar xzvf tomcatbin.tar.gz`                     # Extract archive
TOMDIR=`echo $EXTOUT | cut -d '/' -f1`                 # Get extracted folder name

# ------------------------------
# Setup Tomcat User and Directory
# ------------------------------
useradd --shell /sbin/nologin tomcat                   # Create a dedicated 'tomcat' user
rsync -avzh /tmp/$TOMDIR/ /usr/local/tomcat/           # Copy extracted files into /usr/local/tomcat
chown -R tomcat.tomcat /usr/local/tomcat               # Set ownership to tomcat user

# ------------------------------
# Create Systemd Service for Tomcat
# ------------------------------
rm -rf /etc/systemd/system/tomcat.service              # Remove old service if exists

cat <<EOT>> /etc/systemd/system/tomcat.service
[Unit]
Description=Tomcat
After=network.target

[Service]
User=tomcat
Group=tomcat
WorkingDirectory=/usr/local/tomcat

# Java environment configuration
#Environment=JRE_HOME=/usr/lib/jvm/jre
Environment=JAVA_HOME=/usr/lib/jvm/jre

Environment=CATALINA_PID=/var/tomcat/%i/run/tomcat.pid
Environment=CATALINA_HOME=/usr/local/tomcat
Environment=CATALINE_BASE=/usr/local/tomcat

ExecStart=/usr/local/tomcat/bin/catalina.sh run
ExecStop=/usr/local/tomcat/bin/shutdown.sh

RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOT

# ------------------------------
# Start Tomcat Service
# ------------------------------
systemctl daemon-reload
systemctl start tomcat
systemctl enable tomcat

# ------------------------------
# Install Maven (for building the app)
# ------------------------------
cd /tmp/
wget https://archive.apache.org/dist/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.zip
unzip apache-maven-3.9.9-bin.zip
cp -r apache-maven-3.9.9 /usr/local/maven3.9
export MAVEN_OPTS="-Xmx512m"                           # Set JVM options for Maven

# ------------------------------
# Clone and Build Application
# ------------------------------
git clone -b local https://github.com/hkhcoder/vprofile-project.git
cd vprofile-project
/usr/local/maven3.9/bin/mvn install                    # Build WAR file with Maven

# ------------------------------
# Deploy Application to Tomcat
# ------------------------------
systemctl stop tomcat
sleep 20
rm -rf /usr/local/tomcat/webapps/ROOT*                 # Remove old deployment
cp target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war  # Deploy new WAR
systemctl start tomcat
sleep 20

# ------------------------------
# Adjust Firewall (Demo Only)
# ------------------------------
systemctl stop firewalld                               # Stop firewall
systemctl disable firewalld                            # Disable on boot
# NOTE: In production, you'd configure rules instead of disabling firewall!

# ------------------------------
# Final Restart
# ------------------------------
systemctl restart tomcat
#systemctl status tomcat
# Check service status (uncomment for debugging)