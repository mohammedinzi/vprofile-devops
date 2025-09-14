# Vprofile DevOps Project 🚀

[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
![Tech Stack](https://img.shields.io/badge/stack-Nginx%20|%20Tomcat%20|%20MySQL%20|%20RabbitMQ%20|%20Memcache-blue)
![CI/CD](https://img.shields.io/badge/CI%2FCD-Jenkins-orange)

A 3-tier web application deployed with Vagrant & VirtualBox — designed to demonstrate full-stack infrastructure setup, manual provisioning, and a roadmap toward automation, containerization, and cloud-native DevOps practices.

---

## 🖼 Architecture

```
Browser  →  Nginx (web01)  →  Tomcat (app01)  →  MySQL / Memcache / RabbitMQ
```

> Elasticsearch exists in the original project but is optional in this setup.

📌 Architecture Diagram → [docs/images/architecture.png](docs/images/architecture.png)

---

## ⚙️ Tech Stack

* Frontend / Proxy → Nginx
* Application Layer → Tomcat 10, Java 17, Spring MVC
* Database → MySQL (MariaDB)
* Cache → Memcache
* Messaging → RabbitMQ
* Provisioning → Vagrant, VirtualBox
* Build Tool → Maven 3.9
* CI/CD → Jenkins (pipeline included in repo)

---

## 🚀 Quick Start (Local Setup)

### 1. Prerequisites (on Mac / Linux)

* [VirtualBox](https://www.virtualbox.org/)
* [Vagrant](https://developer.hashicorp.com/vagrant)
* Vagrant Hostmanager Plugin:

  ```bash
  vagrant plugin install vagrant-hostmanager
  ```
* Git

### 2. VM Setup

```bash
git clone https://github.com/mohammedinzi/vprofile-devops.git
cd vprofile-devops/vagrant/Manual_provisioning
vagrant up
```

👉 The first run may take time. If it fails midway, run `vagrant up` again.

---

## 📦 Service Provisioning

Provision in this strict order to avoid dependency issues:

MySQL → Memcache → RabbitMQ → Tomcat → Nginx

---

### 🔹 1. MySQL Setup

```bash
vagrant ssh db01
sudo -i
dnf update -y
dnf install epel-release git mariadb-server -y
systemctl enable --now mariadb
mysql_secure_installation
```

Set root password as `admin123`.

Create DB & users:

```sql
CREATE DATABASE accounts;
GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'%' IDENTIFIED BY 'admin123';
GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'localhost' IDENTIFIED BY 'admin123';
FLUSH PRIVILEGES;
```

Import data:

```bash
cd /tmp
git clone -b local https://github.com/hkhcoder/vprofile-project.git
cd vprofile-project
mysql -u root -padmin123 accounts < src/main/resources/db_backup.sql
```

Open firewall:

```bash
systemctl enable --now firewalld
firewall-cmd --zone=public --add-port=3306/tcp --permanent
firewall-cmd --reload
```

---

### 🔹 2. Memcache Setup

```bash
vagrant ssh mc01
sudo -i
dnf update -y
dnf install memcached -y
systemctl enable --now memcached
```

Allow external access:

```bash
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/sysconfig/memcached
systemctl restart memcached
```

Firewall:

```bash
systemctl enable --now firewalld
firewall-cmd --add-port=11211/tcp --permanent
firewall-cmd --add-port=11111/udp --permanent
firewall-cmd --reload
```

---

### 🔹 3. RabbitMQ Setup

```bash
vagrant ssh rmq01
sudo -i
dnf update -y
dnf -y install centos-release-rabbitmq-38
dnf --enablerepo=centos-rabbitmq-38 -y install rabbitmq-server
systemctl enable --now rabbitmq-server
```

Enable external access:

```bash
echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config
```

Create user:

```bash
rabbitmqctl add_user test test
rabbitmqctl set_user_tags test administrator
rabbitmqctl set_permissions -p / test ".*" ".*" ".*"
```

Firewall:

```bash
systemctl enable --now firewalld
firewall-cmd --add-port=5672/tcp --permanent
firewall-cmd --reload
```

---

### 🔹 4. Tomcat Setup

```bash
vagrant ssh app01
sudo -i
dnf update -y
dnf install java-17-openjdk java-17-openjdk-devel git wget -y
```

Install Tomcat:

```bash
cd /tmp
wget https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.26/bin/apache-tomcat-10.1.26.tar.gz
tar xzvf apache-tomcat-10.1.26.tar.gz
useradd --home-dir /usr/local/tomcat --shell /sbin/nologin tomcat
cp -r apache-tomcat-10.1.26/* /usr/local/tomcat/
chown -R tomcat.tomcat /usr/local/tomcat
```

Systemd Service:

```ini
[Unit]
Description=Tomcat
After=network.target

[Service]
User=tomcat
Group=tomcat
WorkingDirectory=/usr/local/tomcat
Environment=JAVA_HOME=/usr/lib/jvm/jre
Environment=CATALINA_PID=/var/tomcat/%i/run/tomcat.pid
Environment=CATALINA_HOME=/usr/local/tomcat
Environment=CATALINA_BASE=/usr/local/tomcat
ExecStart=/usr/local/tomcat/bin/catalina.sh run
ExecStop=/usr/local/tomcat/bin/shutdown.sh
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
```

Start & open firewall:

```bash
systemctl daemon-reload
systemctl enable --now tomcat
systemctl enable --now firewalld
firewall-cmd --zone=public --add-port=8080/tcp --permanent
firewall-cmd --reload
```

#### Deploy Code

```bash
cd /tmp
wget https://archive.apache.org/dist/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.zip
unzip apache-maven-3.9.9-bin.zip
cp -r apache-maven-3.9.9 /usr/local/maven3.9
export MAVEN_OPTS="-Xmx512m"

git clone -b local https://github.com/hkhcoder/vprofile-project.git
cd vprofile-project
vim src/main/resources/application.properties   # Update DB, cache, MQ configs

/usr/local/maven3.9/bin/mvn install

systemctl stop tomcat
rm -rf /usr/local/tomcat/webapps/ROOT*
cp target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war
chown tomcat.tomcat /usr/local/tomcat/webapps -R
systemctl restart tomcat
```

---

### 🔹 5. Nginx Setup

```bash
vagrant ssh web01
sudo -i
apt update && apt upgrade -y
apt install nginx -y
```

Reverse Proxy config (`/etc/nginx/sites-available/vproapp`):

```nginx
upstream vproapp {
    server app01:8080;
}

server {
    listen 80;
    location / {
        proxy_pass http://vproapp;
    }
}
```

Enable site:

```bash
rm -rf /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/vproapp /etc/nginx/sites-enabled/vproapp
systemctl restart nginx
```

---

## ✅ Verification

Open in browser:

```
http://<web01-ip>
```

You should see the Vprofile App running 🎉

---

## 🧠 Memory Trick

Think of V M R T N:

* V → Vagrant (VM setup)
* M → MySQL
* R → RabbitMQ
* T → Tomcat
* N → Nginx

---

## 🔮 Future Enhancements

* 🐧 Provisioning with Ansible (instead of manual commands)
* 📦 Containerization with Docker Compose / Kubernetes
* 🔄 CI/CD with Jenkins Pipelines (already included)
* 📊 Monitoring with Prometheus + Grafana

---

## 📜 License

This repo is licensed under the [MIT License](LICENSE).

---