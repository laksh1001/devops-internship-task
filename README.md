
---

# 🚀 Automated & Hardened DevOps Deployment Pipeline

An end-to-end DevOps pipeline implementing secure Docker containerization, automated Trivy security scanning, multi-stage GitHub Actions CI/CD workflows, and dual-target deployment across **AWS EC2** (SSH-managed) and **AWS ECS Fargate** (Serverless Orchestration).

---

## 🏗️ System Architecture & Workflow

```
                          +-------------------------+
                          |   Developer Push to     |
                          |   GitHub (main branch)  |
                          +------------+------------+
                                       |
                                       v
                    +-------------------------------------+
                    |   GitHub Actions CI/CD Pipeline     |
                    +------------------+------------------+
                                       |
                   +-------------------+-------------------+
                   |                                       |
                   v                                       v
      +------------------------+              +--------------------------+
      |  Stage 1: Trivy Scan   |              |   Stage 2: Deployment    |
      | (FS Vulnerability Scan)|              |  (Automated SSH to EC2)  |
      +------------------------+              +------------+-------------+
                                                           |
                                                           v
                                              +--------------------------+
                                              |      AWS EC2 Server      |
                                              |   Docker Container Run   |
                                              |    (Port 8081:8081)      |
                                              +--------------------------+

                                [TASK DONE]
                                      |
                                      v
         +----------------------------------------------------------+
         |    Build Image ➔ Push to ECR ➔ Launch on ECS Fargate    |
         +----------------------------------------------------------+

```

---

## 🛠️ Tech Stack & Key Features

* **Base OS / Image**: `python:3.11-slim` (minimal footprint & reduced attack surface)
* **Least Privilege Security**: Container runs under a dedicated, unprivileged non-root user (`appuser`).
* **Health Monitoring**: Native Docker `HEALTHCHECK` probing port `8081` every 30 seconds.
* **Security Scanning**: Integrated Aqua Security **Trivy** in CI/CD pipeline to block vulnerabilities classified as `HIGH` or `CRITICAL`.
* **Automated CI/CD**: 2-stage GitHub Actions workflow executing security analysis and automated SSH deployment to EC2.
* **Serverless Orchestration (Bonus)**: Container image pushed to **AWS ECR** and executed on **AWS ECS Fargate**.

---

## 📁 Repository Structure

```text
devops-internship-task/
├── .github/
│   └── workflows/
│       └── deploy.yml          # 2-Stage CI/CD Pipeline Configuration
├── app.py                      # Python HTTP Web Server (Port 8081)
├── Dockerfile                  # Hardened, documented container specification
└── README.md                   # Project Documentation

```

---

## 📋 Commands Executed During Project Lifecycle

### 1. Local Build & Container Testing

```bash
# Clone repository
git clone https://github.com/laksh1001/devops-internship-task.git
cd devops-internship-task

# Build local Docker image
docker build -t my-web-app:v1 .

# Run container locally on Port 8081
docker run -d --name webapp-test -p 8081:8081 my-web-app:v1

# Inspect running container and health status
docker ps

```

---

### 2. Local Vulnerability Scanning (Trivy)

```bash
# Run Trivy vulnerability scanner on local filesystem
trivy fs --severity HIGH,CRITICAL .

```

---

### 3. AWS CLI Configuration & Credential Setup

```bash
# Configure AWS CLI on host machine / EC2
aws configure
# AWS Access Key ID: <YOUR_ACCESS_KEY>
# AWS Secret Access Key: <YOUR_SECRET_KEY>
# Default region name: ap-southeast-2
# Default output format: json

# Verify identity
aws sts get-caller-identity --query Account --output text

```

---

### 4. AWS ECR Registry & Image Push (For ECS Fargate)

```bash
# Create Amazon ECR Repository
aws ecr create-repository --repository-name devops-internship-task --region ap-southeast-2

# Retrieve AWS Account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Authenticate Docker daemon with Amazon ECR
aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.ap-southeast-2.amazonaws.com

# Tag image for ECR
docker tag my-web-app:v1 ${AWS_ACCOUNT_ID}.dkr.ecr.ap-southeast-2.amazonaws.com/devops-internship-task:latest

# Push image to ECR
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-southeast-2.amazonaws.com/devops-internship-task:latest

```

---

## 🌐 Live Application Endpoints

| Environment | Host Infrastructure | Port | Endpoint URL |
| --- | --- | --- | --- |
| **Production (EC2)** | AWS EC2 (Ubuntu 24.04 LTS) | `8081` | `[http://13.236.162.131:8081](http://13.236.162.131:8081)` |
| **Serverless (ECS)** | AWS ECS Fargate via ECR | `8081` | `[http://15.135.233.153:8081](http://15.135.233.153:8081)`[cite: 13, 14] |

---

## 🔐 Security & Network Policies

1. **Non-Root Runtime Enforcement**: The container defaults to `USER appuser` to prevent container-breakout attacks.
2. **Network Security Groups**:
* **SSH (Port 22)**: Restricted strictly to authorized IPs.
* **Application (Port 8081)**: Inbound rule set to `Custom TCP / 8081` allowing traffic from `0.0.0.0/0`[cite: 12].
