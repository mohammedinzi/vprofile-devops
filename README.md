# Vprofile DevOps Project 🚀

A 3-tier web application deployed using Vagrant & VirtualBox — designed to demonstrate full-stack infrastructure setup, DevOps practices, and a clear roadmap toward containerization and cloud-native deployment.

This repository is my personal adaptation and showcase of the (https://github.com/hkhcoder/vprofile-project).  
I’ve restructured, documented, and extended it to highlight practical DevOps workflows for recruiters and engineers.

---

## 🖼 Architecture

![Architecture Diagram](docs/images/architecture.png)

Layers:
- Web Layer → Nginx (Load Balancer / Reverse Proxy)  
- App Layer → Tomcat (Java Application Server)  
- Data Layer → MySQL (Database), Memcache (Caching), RabbitMQ (Messaging)  

---

## ⚙️ Tech Stack

- Frontend / Proxy: Nginx  
- Application: Tomcat 10, Java 17, Spring MVC  
- Database: MySQL (MariaDB)  
- Cache: Memcache  
- Messaging: RabbitMQ  
- Provisioning: Vagrant, VirtualBox  
- Build Tool: Maven 3.9  

---

## 🚀 Quick Start (Local Setup)

Prerequisites (on Mac / Linux):
- [VirtualBox](https://www.virtualbox.org/)  
- [Vagrant](https://developer.hashicorp.com/vagrant/downloads)  
- Vagrant Hostmanager Plugin:  
  ```bash
  vagrant plugin install vagrant-hostmanager
