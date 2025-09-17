# 🚀 Lift & Shift — vProfile → AWS

This project demonstrates migrating the **vProfile multi-tier application** to AWS using a **lift-and-shift** approach.  
It covers Infrastructure as Code (Terraform), CI/CD with GitHub Actions, and AWS best practices for scalability and security.

---

## 📌 Architecture Overview
![Architecture](architecture/diagram.png)

**Flow**  
User → Application Load Balancer (HTTPS) → Auto Scaling Group (Tomcat EC2s) → MySQL, Memcached, RabbitMQ backends (private subnet) → S3 for artifacts → Route 53 for private DNS.

---

## 🛠️ AWS Services Used
- **EC2** — Tomcat app servers, MySQL, Memcached, RabbitMQ  
- **Application Load Balancer** — HTTPS via ACM  
- **Auto Scaling Group** — Horizontal scaling for app servers  
- **S3** — Artifact storage  
- **Route 53** — Private DNS  
- **IAM Roles** — Secure EC2 → S3 access  
- **CloudWatch** — Metrics, scaling triggers  

---

## ⚙️ What’s Implemented
- Terraform IaC: ALB, ASG, EC2s, Security Groups, S3, Route 53  
- EC2 `user-data` bootstrap for Tomcat & app deployment  
- GitHub Actions CI pipeline: build with Maven → upload WAR to S3  
- Secure SG design:  
  - ALB (443) → Tomcat (8080)  
  - Tomcat → DB (3306)  
  - Principle of least privilege via IAM roles  

---

## 🚀 How to Reproduce

### 1. Clone repo
```bash
git clone https://github.com/yourusername/aws-lift-and-shift-vprofile.git
cd aws-lift-and-shift-vprofile/infra
