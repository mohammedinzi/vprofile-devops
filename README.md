# 🚀 Vprofile DevOps Project

[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
![Tech Stack](https://img.shields.io/badge/stack-Nginx%20|%20Tomcat%20|%20MySQL%20|%20RabbitMQ%20|%20Memcache-blue)
![CI/CD](https://img.shields.io/badge/CI%2FCD-Jenkins-orange)

A **3-tier Java web application** deployed using **Vagrant & VirtualBox** — built to demonstrate:

- Full-stack infrastructure setup  
- Manual provisioning (baseline DevOps)  
- Automated provisioning with Infrastructure as Code  
- A roadmap toward **Ansible, CI/CD, containers, and cloud-native** DevOps practices  

This project was designed and implemented entirely from scratch to showcase **real-world DevOps workflows** — from fundamentals to automation.

---

## 🖼 Architecture

```

Browser → Nginx (web01) → Tomcat (app01) → MySQL (db01), Memcache (mc01), RabbitMQ (rmq01)

````

📌 Architecture Diagram → [docs/images/architecture.png](docs/images/architecture.png)

- **Web Layer (Nginx)** → Reverse proxy & load balancer  
- **App Layer (Tomcat + Maven)** → Java Spring MVC app  
- **Data Layer** → MySQL (DB), Memcache (cache), RabbitMQ (messaging)  

---

## ⚙️ Tech Stack

- **Provisioning** → Vagrant + Shell Scripts  
- **OS** → CentOS Stream 9, Ubuntu 22.04  
- **App** → Tomcat 10 + Java 17 + Spring MVC  
- **DB** → MySQL (MariaDB)  
- **Cache** → Memcache  
- **Messaging** → RabbitMQ  
- **Build Tool** → Maven 3.9  
- **CI/CD** → Jenkins pipelines (included in repo)  

---

## 🌱 Branches (Progression Story)

- [`vagrant-manual`](https://github.com/mohammedinzi/vprofile-devops/tree/vagrant-manual) → Manual provisioning (base setup, fundamentals)  
- [`vagrant-automation`](https://github.com/mohammedinzi/vprofile-devops/tree/vagrant-automation) → Automated provisioning with shell scripts  
- `ansible` (coming soon) → Provisioning with Ansible for idempotency  
- `ci-cd` (coming soon) → Jenkins pipelines for continuous integration & deployment  

---

## 🚀 Quick Start (Demo)

1. Install prerequisites:
   - [VirtualBox](https://www.virtualbox.org/)
   - [Vagrant](https://developer.hashicorp.com/vagrant)
   - Host manager plugin:
     ```bash
     vagrant plugin install vagrant-hostmanager
     ```

2. Clone repo:
   ```bash
   git clone https://github.com/mohammedinzi/vprofile-devops.git
   cd vprofile-devops
````

3. Pick a branch and follow its README:

   * Manual → `git checkout vagrant-manual`
   * Automation → `git checkout vagrant-automation`

---

## 🔮 Roadmap

* ✅ Manual provisioning (`vagrant-manual`)
* ✅ Automated provisioning (`vagrant-automation`)
* 🔜 Configuration management with Ansible
* 🔜 Containerization (Docker, Kubernetes)
* 🔜 CI/CD pipelines with Jenkins

---

## 📜 License

This repo is licensed under the [MIT License](LICENSE).
