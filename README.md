# Vprofile DevOps Project 🚀 — Manual Provisioning Branch

[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
![Tech Stack](https://img.shields.io/badge/stack-Nginx%20|%20Tomcat%20|%20MySQL%20|%20RabbitMQ%20|%20Memcache-blue)
![CI/CD](https://img.shields.io/badge/CI%2FCD-Jenkins-orange)

This branch demonstrates the **manual setup** of the Vprofile 3-tier Java web application using **Vagrant + VirtualBox**.

The focus here is:

* Learning the fundamentals of provisioning services manually.
* Understanding dependencies between DB, cache, queue, backend, and frontend.
* Serving as a **baseline** before progressing to automation (`vagrant-automation`), Ansible, and containerization.

👉 **Note:** This branch highlights my ability to set up infrastructure from scratch, service by service, before introducing automation tools.

---

## 🖼 Architecture

```
Browser  →  Nginx (web01)  →  Tomcat (app01)  →  MySQL (db01), Memcache (mc01), RabbitMQ (rmq01)
```

📌 Elasticsearch exists in the original project but is optional here.
📌 Architecture diagram → [docs/images/architecture.png](docs/images/architecture.png)

---

## 🖥️ VM Topology

| VM Name | Hostname | Role             | OS                   | IP Address    | Memory |
| ------- | -------- | ---------------- | -------------------- | ------------- | ------ |
| web01   | web01    | Nginx (frontend) | Ubuntu 22.04 (Jammy) | 192.168.56.11 | 800MB  |
| app01   | app01    | Tomcat + Maven   | CentOS Stream 9      | 192.168.56.12 | 800MB  |
| db01    | db01     | MySQL/MariaDB    | CentOS Stream 9      | 192.168.56.15 | 600MB  |
| mc01    | mc01     | Memcache         | CentOS Stream 9      | 192.168.56.14 | 600MB  |
| rmq01   | rmq01    | RabbitMQ         | CentOS Stream 9      | 192.168.56.16 | 600MB  |

---

## ⚙️ Tech Stack

* **Frontend / Proxy** → Nginx
* **Application Layer** → Tomcat 10, Java 17, Spring MVC
* **Database** → MySQL (MariaDB)
* **Cache** → Memcache
* **Messaging** → RabbitMQ
* **Provisioning** → Vagrant + VirtualBox
* **Build Tool** → Maven 3.9
* **CI/CD** → Jenkins (pipeline included)

---

## 🚀 Quick Start (Manual Setup)

### 1. Install prerequisites

* [VirtualBox](https://www.virtualbox.org/)
* [Vagrant](https://developer.hashicorp.com/vagrant)
* Vagrant Hostmanager Plugin:

  ```bash
  vagrant plugin install vagrant-hostmanager
  ```
* Git

---

### 2. Spin up VMs

```bash
git clone https://github.com/mohammedinzi/vprofile-devops.git
cd vprofile-devops/vagrant/manual/provisioning_MacOSM1    # or provisioning_WinMacIntel
vagrant up
```

👉 First run takes time (downloads base boxes).
👉 If it fails midway:

```bash
vagrant up
```

again.

---

## 📦 Service Provisioning (Manual Order)

Provision in this strict order to avoid dependency issues:

**MySQL → Memcache → RabbitMQ → Tomcat → Nginx**

---

### 🔹 1. MySQL Setup (Database Layer)

```bash
vagrant ssh db01
sudo -i
dnf install epel-release git mariadb-server -y
systemctl enable --now mariadb
mysql_secure_installation
```

Set root password → `admin123`.

Create DB & users:

```sql
CREATE DATABASE accounts;
GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'%' IDENTIFIED BY 'admin123';
GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'localhost' IDENTIFIED BY 'admin123';
FLUSH PRIVILEGES;
```

Import data:

```bash
git clone -b local https://github.com/hkhcoder/vprofile-project.git /tmp/vprofile-project
mysql -u root -padmin123 accounts < /tmp/vprofile-project/src/main/resources/db_backup.sql
```

Firewall:

```bash
firewall-cmd --zone=public --add-port=3306/tcp --permanent
firewall-cmd --reload
```

---

### 🔹 2. Memcache Setup (Cache Layer)

```bash
vagrant ssh mc01
sudo -i
dnf install memcached -y
systemctl enable --now memcached
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/sysconfig/memcached
systemctl restart memcached
firewall-cmd --add-port=11211/tcp --permanent
firewall-cmd --add-port=11111/udp --permanent
firewall-cmd --reload
```

---

### 🔹 3. RabbitMQ Setup (Messaging Layer)

```bash
vagrant ssh rmq01
sudo -i
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
firewall-cmd --add-port=5672/tcp --permanent
firewall-cmd --reload
```

---

### 🔹 4. Tomcat Setup (Application Layer)

```bash
vagrant ssh app01
sudo -i
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

Systemd service file is provided in repo (`tomcat.service`).

Start Tomcat + firewall:

```bash
systemctl daemon-reload
systemctl enable --now tomcat
firewall-cmd --zone=public --add-port=8080/tcp --permanent
firewall-cmd --reload
```

#### Deploy Application

```bash
wget https://archive.apache.org/dist/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.zip
unzip apache-maven-3.9.9-bin.zip
cp -r apache-maven-3.9.9 /usr/local/maven3.9
export MAVEN_OPTS="-Xmx512m"

git clone -b local https://github.com/hkhcoder/vprofile-project.git
cd vprofile-project
/usr/local/maven3.9/bin/mvn install

systemctl stop tomcat
rm -rf /usr/local/tomcat/webapps/ROOT*
cp target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war
systemctl restart tomcat
```

---

### 🔹 5. Nginx Setup (Frontend Layer)

```bash
vagrant ssh web01
sudo -i
apt update && apt install nginx -y
```

Config (`/etc/nginx/sites-available/vproapp`):

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

Enable config:

```bash
rm -rf /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/vproapp /etc/nginx/sites-enabled/vproapp
systemctl restart nginx
```

---

## ✅ Verification

* Open in browser:

  ```
  http://192.168.56.11
  ```

  🎉 The Vprofile App should be running.

---

## 🧠 Memory Trick (V M R T N)

* **V** → Vagrant (setup VMs)
* **M** → MySQL
* **R** → RabbitMQ
* **T** → Tomcat
* **N** → Nginx

---

## 🔮 Future Enhancements

* 🐧 Replace manual steps with **Ansible automation**
* 📦 Containerize with **Docker & Kubernetes**
* 🔄 Add **CI/CD pipelines** in Jenkins
* 📊 Introduce **monitoring (Prometheus + Grafana)**

---

## 📜 License

This repo is licensed under the [MIT License](LICENSE).

---