# 🚀 VProfile DevOps Mega Project

> **End-to-end DevSecOps showcase** — from **local Vagrant environments** to **full AWS cloud migration**, demonstrating **real-world production-ready workflows**.

A **three-tier Java web application** meticulously designed and built to **demonstrate the complete DevOps journey**:

* **Traditional manual provisioning** → setting the baseline
* **Infrastructure-as-Code automation** → enabling repeatable, scalable setups
* **Cloud migration to AWS** → leveraging auto-scaling, load balancing, and private networking
* **Future vision** → complete cloud-native DevSecOps with CI/CD, container orchestration, and security integration

This project isn’t just a demo — it’s **a living portfolio piece** crafted to **showcase real-world problem-solving skills**, **enterprise-grade architecture**, and **modern DevOps best practices**.

---

## 🖼 Architecture

### **Local Environment (Vagrant Setup)**

> Classic **on-premise style deployment** — perfect for simulating a data-center environment on your laptop.

```
Browser
   ↓
Nginx (web01)
   ↓
Tomcat (app01)
   ↓
MySQL (db01) + Memcached (mc01) + RabbitMQ (rmq01)
```

📌 Architecture Diagram → `docs/images/architecture.png`

---

### **AWS Cloud Environment (Lift & Shift Migration)**

> Modern **cloud-first architecture** leveraging **AWS services** for scalability and resilience.

```
User
   ↓
AWS Application Load Balancer (HTTPS)
   ↓
Auto Scaling Group → Tomcat EC2 instances
   ↓
Private Subnet → MySQL, Memcached, RabbitMQ
   ↓
S3 → Artifact Storage
   ↓
Route 53 → Private DNS
```

📌 AWS Cloud Architecture → `docs/images/aws-architecture.png`

---

## ⚙️ Tech Stack Overview

| **Category**           | **Technologies Used**                               |
| ---------------------- | --------------------------------------------------- |
| **Provisioning**       | Vagrant, Shell Scripts, AWS EC2, Route 53, ALB, ASG |
| **Configuration Mgmt** | Shell Scripts, User Data *(Future: Ansible)*        |
| **Operating Systems**  | CentOS Stream 9, Ubuntu 22.04, Amazon Linux 2023    |
| **Application Layer**  | Tomcat 10, Java 17, Spring MVC                      |
| **Database**           | MySQL (MariaDB)                                     |
| **Caching**            | Memcached                                           |
| **Messaging**          | RabbitMQ                                            |
| **Build & Packaging**  | Maven 3.9                                           |
| **CI/CD**              | Jenkins Pipelines *(GitHub Actions upcoming)*       |

---

## 🌱 Repository Branches — *The DevOps Journey*

This repository is structured as a **progressive journey**, each branch building on the previous stage:

| **Branch Name**             | **What It Demonstrates**                                                 |
| --------------------------- | ------------------------------------------------------------------------ |
| `vagrant-manual`            | 🏗 **Manual provisioning** with Vagrant + Shell scripts (baseline setup) |
| `vagrant-automation`        | ⚡ **Automated provisioning** using streamlined scripts                   |
| `awsliftandshift`           | ☁ **AWS Lift & Shift Migration** — EC2, ALB, ASG, IAM, Route53, S3       |
| *(future)* `ansible-config` | 🔧 Configuration Management with **Ansible**                             |
| *(future)* `docker-k8s`     | 🐳 **Containerization** with Docker & Kubernetes                         |
| *(future)* `cicd-pipelines` | 🚀 **CI/CD pipelines** using Jenkins and GitHub Actions                  |

---

## 🧪 Features & Highlights

* **Step-by-step progression** → From zero automation to fully cloud-native
* **Enterprise-grade security & networking** → Private subnets, Route53, IAM best practices
* **Scalable AWS deployment** → Auto Scaling Groups + Load Balancing
* **Future-ready roadmap** → Container orchestration & automated pipelines
* **Beginner-friendly onboarding** → Each branch has its own README with crystal-clear setup steps
* **Production-like simulation** → Mirrors how Fortune 500 companies handle real deployments

---

## 🚀 Quick Start Guide

> Spin up the environment in **minutes**, and explore each stage of the journey.

### 1️⃣ Clone the repository

```bash
git clone https://github.com/mohammedinzi/vprofile-devops.git
cd vprofile-devops
```

---

### 2️⃣ Choose a branch

Pick a branch to start exploring:

```bash
# Manual provisioning
git checkout vagrant-manual  

# Automation with scripts
git checkout vagrant-automation  

# AWS cloud migration
git checkout awsliftandshift  
```

Each branch has **its own detailed README** with step-by-step instructions.

---

## 🔮 Project Roadmap

| **Stage**                    | **Status**     |
| ---------------------------- | -------------- |
| Manual provisioning          | ✅ Completed   |
| Automated provisioning       | ✅ Completed   |
| AWS Lift & Shift Migration   | ✅ Completed   |
| Jenkins/GitHub Actions CI/CD | 🔜 Coming soon |
| Docker + Kubernetes          | 🔜 Coming soon |
| Ansible for config mgmt.     | 🔜 Coming soon |

---

## 📜 License

Licensed under the [MIT License](LICENSE).
Free to use, modify, and enhance for learning purposes.

---
