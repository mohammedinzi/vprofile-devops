#!/bin/bash
# ---------------------------------------------------------
# tomcat_ubuntu.sh
# Purpose: Simple Tomcat setup for Ubuntu-based systems
# ---------------------------------------------------------

sudo apt update && sudo apt upgrade -y
sudo apt install openjdk-8-jdk -y        # Install Java 8
sudo apt install tomcat8 tomcat8-admin tomcat8-docs tomcat8-common git -y
