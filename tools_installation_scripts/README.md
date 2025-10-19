# 🛠️ Universal DevOps Installer

This is an **interactive cross-platform installer script** for setting up essential DevOps tools on **Linux, Mac, and Windows**.  
It automatically guides you through each software installation, showing **latest versions** and **recommended versions** for your OS.

---

## 📦 Tools Included
1. Git  
2. Jenkins (http://localhost:8080, user: `admin`, pass: `Root123$`)  
3. Prometheus  
4. Terraform  
5. Ansible  
6. Maven  
7. Docker (20.10 recommended)  
8. Kubernetes  
9. Grafana (11.1.4 recommended, http://localhost:3000, user/pass: admin/admin)  
10. ELK Stack (8.15)  
11. Node Exporter (http://localhost:9101/targets)  
12. Alertmanager (http://localhost:9093/)  
13. Pushgateway (http://localhost:9091/metrics)  
14. Helm  
15. ArgoCD CLI  
16. kubectl  
17. Azure CLI  
18. Minikube  
19. AWS CLI  
20. Python (3.12.9 recommended)  

…and more.  

---

## 🚀 How to Run

### 1. Clone the repository
```bash
git clone https://github.com/ibm-devops-engineers/devops-mastermind-lab.git
cd devops-mastermind-lab/tools_installation_scripts
````

### 2. Run the script

```bash
python3 universal_devops_installer.py
```

### 3. Follow the prompts

* Select your OS (**Linux / Mac / Windows**)
* Choose which tools to install or skip
* Pick a version (default = recommended)

The script will automatically install using your OS’s package manager (`apt-get`, `brew`, `choco`, etc.) and configure services where needed.

---

## 🔥 Example Run

```bash
🔥 Universal DevOps Installer 🔥
Which OS are you installing for?
1. Linux
2. Mac
3. Windows
Enter choice: 1

📦 Git
   Latest: 2.46.0
   Recommended: 2.34
Do you want to install Git? (y/n): y
Which version? (default: 2.34):
👉 Running: sudo apt-get install -y git
```

---

## ⚡ Notes

* Run with **admin/root privileges** when required.
* Some tools (like Jenkins, ELK, Prometheus) start system services after installation.
* Default credentials are printed after install for quick access.

---

## 🤝 Contributing

Pull requests are welcome! Add more tools, improve installer logic, or extend for new OS versions.
---
