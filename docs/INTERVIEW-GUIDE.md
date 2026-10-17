# Interview Guide

Talking points for walking someone through this repo. Each section maps to a branch.

## 2-minute pitch

"I took one three-tier Java app and delivered it four ways. First by hand on Vagrant VMs so I understood each service. Then automated with scripts. Then lifted onto AWS behind an ALB with autoscaling and private data tiers. Then I built a Jenkins pipeline with SonarQube and Nexus, and containerised it with Docker and ECR. Each stage is a branch, so you can diff the approaches."

## Stage by stage

### 1. Manual Vagrant (`vagrant-manual`)
- **Why manual first:** automation without understanding hides failures. Doing it by hand showed the service dependencies: the app needs DB, cache and queue up before Tomcat starts.
- **Likely questions:** What does each tier do? Why Memcached in front of MySQL? Why RabbitMQ?

### 2. Automated Vagrant (`vagrant-automation`)
- Converted runbooks into per-service shell scripts wired into the Vagrantfile.
- **Trade-off to discuss:** shell scripts are quick but not declarative. Ansible (see [`ansible/`](../ansible)) or Terraform handles drift and idempotency better.

### 3. AWS lift and shift (`awsliftandshift`)
- **Design choices:** ALB in public subnets, app in an ASG, data tiers private, Route 53 private DNS so config uses names rather than IPs, S3 plus an IAM role to deliver the WAR without storing keys.
- **Security groups:** ALB (80/443) -> Tomcat (8080) -> MySQL (3306), RabbitMQ (5672), Memcached (11211). Nothing else open.
- **Real problem solved:** logins failed across multiple instances until ALB stickiness was enabled. The better long-term fix is externalising sessions (e.g. to Memcached/Redis) so the app tier is truly stateless.
- **Why "lift and shift" first:** lowest-risk migration; replatforming comes after. Next step would be RDS, Amazon MQ and ElastiCache.

### 4. CI/CD (`atom`, and the `Jenkinsfile` here)
- Pipeline: build, unit test, integration test, Checkstyle, SonarQube quality gate (blocks the build on failure), Nexus publish with the build number as version.
- **Real problems solved:** disk exhaustion on the Sonar/Nexus hosts, wrong IPs between instances, quality gate failures.
- **Questions to expect:** Declarative vs scripted pipeline? How do you secure credentials in Jenkins? How would you add rollback? (Answer: versioned artifacts in Nexus make redeploying a previous version a parameterised job.)

### 5. Containers (`atom-docker-ecr`)
- Multi-stage Dockerfile keeps build tools out of the runtime image; compose runs the full stack locally.
- **Known gaps I would fix:** pin image tags, add healthchecks and `depends_on`, build from this repo's source, move credentials to an env file or secrets manager.

## Engineering decisions in this repo

| Decision | Why |
|---|---|
| Config read from environment variables with defaults | Same artifact runs in every environment; no secrets in git (12-factor). |
| `target/` and local config out of git | Build output does not belong in version control; keeps diffs reviewable. |
| Nexus host as a Jenkins parameter | No hardcoded private IP; the pipeline moves between environments. |
| Secret scan in CI | Catches credentials before they reach history. |
| Sonar pointed at `target/classes` | Analysis must see the application classes, not a single test folder. |

## Honest limitations (say these first; interviewers respect it)

- Test coverage is minimal (a sample test plus controller and model tests).
- Earlier commits contained lab credentials. They are placeholders now, but they remain in git history. In production they would be rotated.
- Infrastructure on AWS was created by hand/console and scripts, not Terraform yet.

## What I'd do next

1. Terraform modules for VPC, ALB, ASG and security groups.
2. Replace self-hosted MySQL/RabbitMQ/Memcached with RDS, Amazon MQ, ElastiCache.
3. Kubernetes (EKS) with Helm, plus Prometheus and Grafana.
4. Deployment stage in the pipeline with blue/green or rolling updates.

## Quick-fire Q&A

- **Why an ALB and not Nginx on AWS?** Managed, health checks, ACM TLS, integrates with ASG.
- **How does the instance get the app?** User data pulls the WAR from S3 using its IAM role.
- **What if the DB goes down?** The app shows its database error page; in production I'd use Multi-AZ RDS.
- **Why Maven profiles / versions?** Nexus stores each build under the Jenkins build number so every artifact is traceable.
