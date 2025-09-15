#!/bin/bash
# ---------------------------------------------------------
# tomcat.sh
# Purpose: Provision Tomcat 10 + Maven + deploy Vprofile app
# ---------------------------------------------------------

TOMURL="https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.26/bin/apache-tomcat-10.1.26.tar.gz"

# Install Java and tools
dnf -y install java-17-openjdk java-17-openjdk-devel git wget rsync unzip zip

# Download and unpack Tomcat
cd /tmp/
wget $TOMURL -O tomcatbin.tar.gz
EXTOUT=`tar xzvf tomcatbin.tar.gz`
TOMDIR=`echo $EXTOUT | cut -d '/' -f1`

# Create tomcat user and move files
useradd --shell /sbin/nologin tomcat
rsync -avzh /tmp/$TOMDIR/ /usr/local/tomcat/
chown -R tomcat.tomcat /usr/local/tomcat

# Configure systemd service
cat <<EOT > /etc/systemd/system/tomcat.service
[Unit]
Description=Tomcat
After=network.target

[Service]
User=tomcat
Group=tomcat
WorkingDirectory=/usr/local/tomcat
Environment=JAVA_HOME=/usr/lib/jvm/jre
Environment=CATALINA_HOME=/usr/local/tomcat
ExecStart=/usr/local/tomcat/bin/catalina.sh run
ExecStop=/usr/local/tomcat/bin/shutdown.sh
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOT

systemctl daemon-reload
systemctl start tomcat
systemctl enable tomcat

# Install Maven
cd /tmp/
wget https://archive.apache.org/dist/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.zip
unzip apache-maven-3.9.9-bin.zip
cp -r apache-maven-3.9.9 /usr/local/maven3.9
export MAVEN_OPTS="-Xmx512m"

# Build and deploy app
git clone -b local https://github.com/hkhcoder/vprofile-project.git
cd vprofile-project
/usr/local/maven3.9/bin/mvn install

systemctl stop tomcat
rm -rf /usr/local/tomcat/webapps/ROOT*
cp target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war
systemctl start tomcat

# Disable firewalld for local testing
systemctl stop firewalld
systemctl disable firewalld
