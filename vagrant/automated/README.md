# 🚀 Vprofile DevOps — Automated Provisioning with Vagrant

This branch demonstrates a **fully automated setup** of the Vprofile 3-tier Java web application using **Vagrant + shell provisioning scripts**.

It is an evolution of the **manual setup** (on the `develop` branch) — showcasing how **Infrastructure as Code** eliminates repetitive tasks, standardizes environments, and brings DevOps practices closer to production.

---

## 🖼 Architecture

```
Browser → Nginx (web01) → Tomcat (app01) → MySQL (db01), Memcache (mc01), RabbitMQ (rmq01)
```

* **web01** → Nginx (reverse proxy, load balancer)
* **app01** → Tomcat + Maven build (deploys Java app)
* **db01** → MySQL / MariaDB (database)
* **mc01** → Memcache (caching layer)
* **rmq01** → RabbitMQ (message broker)

---

## 🖥 VM Topology

| VM Name   | Role / Service                       | OS Image                           | IP Address      | Memory | Provisioning Script |
| --------- | ------------------------------------ | ---------------------------------- | --------------- | ------ | ------------------- |
| **web01** | Nginx (reverse proxy, load balancer) | Ubuntu 22.04 (`ubuntu/jammy64`)    | `192.168.56.11` | 800 MB | `nginx.sh`          |
| **app01** | Tomcat + Maven + Java app            | CentOS Stream 9 (`centos/stream9`) | `192.168.56.12` | 800 MB | `tomcat.sh`         |
| **db01**  | MySQL (MariaDB)                      | CentOS Stream 9                    | `192.168.56.15` | 600 MB | `mysql.sh`          |
| **mc01**  | Memcache                             | CentOS Stream 9                    | `192.168.56.14` | 600 MB | `memcache.sh`       |
| **rmq01** | RabbitMQ                             | CentOS Stream 9                    | `192.168.56.16` | 600 MB | `rabbitmq.sh`       |

💡 Takeaway: This mirrors a **real-world 3-tier architecture** — with service isolation, reproducibility, and Infrastructure as Code provisioning.

---

## ⚙️ Tech Stack

* **Provisioning** → Vagrant + Shell Scripts
* **OS** → CentOS Stream 9 & Ubuntu 22.04
* **App** → Tomcat 10 + Java 17 + Spring MVC
* **DB** → MySQL (MariaDB)
* **Cache** → Memcache
* **Messaging** → RabbitMQ
* **Build Tool** → Maven

---

## 🚀 Quick Start (Automation Demo)

### 1. Install prerequisites

* [Vagrant](https://developer.hashicorp.com/vagrant/downloads)
* VirtualBox / VMware / Parallels
* Plugin:

  ```bash
  vagrant plugin install vagrant-hostmanager
  ```

### 2. Clone this repo and switch branch

```bash
git clone https://github.com/mohammedinzi/vprofile-devops.git
cd vprofile-devops
git checkout vagrant-automation
```

### 3. Choose your platform

```bash
cd vagrant/automated/provisioning_MacOSM1     # for Mac M1/M2
cd vagrant/automated/provisioning_WinMacIntel # for Windows / Intel Mac
```

### 4. Start the environment

```bash
vagrant up
```

### 5. Access the app

* In browser → `http://192.168.56.21`
* SSH into any VM:

  ```bash
  vagrant ssh web01
  ```

---

## 📂 Repository Structure

```
vagrant/
 ├── automated/
 │    ├── provisioning_MacOSM1/
 │    │    ├── Vagrantfile
 │    │    ├── mysql.sh
 │    │    ├── memcache.sh
 │    │    ├── rabbitmq.sh
 │    │    ├── tomcat.sh
 │    │    └── nginx.sh
 │    └── provisioning_WinMacIntel/
 │         ├── Vagrantfile
 │         ├── mysql.sh
 │         ├── memcache.sh
 │         ├── rabbitmq.sh
 │         ├── tomcat.sh
 │         └── nginx.sh
 └── manual/ (original manual setup for comparison)
```

---

## ✅ Verification

* Nginx:

  ```bash
  curl -I http://192.168.56.21
  ```

* Tomcat app:

  ```bash
  curl -I http://192.168.56.22:8080
  ```

* Database connectivity:

  ```bash
  vagrant ssh db01
  mysql -u admin -padmin123
  ```

---

## 🧹 Cleanup

```bash
vagrant destroy -f
```

---

## 📖 Project Story

This project started as a **manual setup** to understand service dependencies and evolved into **Vagrant + shell automation**.

Through this branch, I demonstrated:

* Infrastructure as Code with Vagrant
* Automated provisioning of multi-tier applications
* Secure configuration of DB, cache, and queue services
* A reproducible environment anyone can spin up with a single command

Next steps:

* Replace shell scripts with **Ansible playbooks** for idempotency
* Containerize with **Docker & Kubernetes**
* Add **CI/CD pipelines with Jenkins**

---

## 🔗 Related Branches

* [`develop`](https://github.com/mohammedinzi/vprofile-devops/tree/develop) → manual setup (base)
* `vagrant-automation` (this branch) → automated setup with Vagrant
* `ansible-automation` (coming soon) → provisioning via Ansible
* `ci-cd` (coming soon) → Jenkins pipelines

---