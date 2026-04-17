# Environment Setup Guide (Living Document)

This document serves as the single source of truth for completely rebuilding the local local K8s development environment on WSL.
**It must be updated automatically whenever new infrastructure, namespaces, or deployment steps are added to the project.**

---

## 🏗️ Current State: End of Day 3 (Kafka + Order Producer)

### 0. Fresh Machine Bootstrap (First Time Only)
On a brand-new Ubuntu / WSL instance, Ansible is not installed by default. Complete the following steps before proceeding:

```bash
# 0.1 Update system package index
sudo apt update && sudo apt upgrade -y

# 0.2 Install Python3, pip, and git (Ansible runtime dependencies)
sudo apt install -y python3 python3-pip git

# 0.3 Install Ansible via pip (recommended: newer versions, decoupled from system packages)
pip3 install --user ansible

# 0.4 Make pip --user binaries available in your shell
# Add the following line to ~/.bashrc for persistence
export PATH="$HOME/.local/bin:$PATH"
source ~/.bashrc

# 0.5 Verify the installation
ansible --version   # Should print ansible [core 2.x.x]
```

> **💡 Note:** On Ubuntu ≥ 24.04, PEP 668 prevents global pip installs.
> Use `sudo apt install -y ansible` or `pipx install ansible` instead.

Once `ansible --version` prints successfully, proceed to the next step.

---

### 1. Prerequisites / Base Tools
Run the Ansible playbook once per new WSL environment to install Docker, Kubectl, Kind, Helm, and Terraform:
```bash
cd ansible
ansible-playbook -i inventories/local.ini playbooks/setup-wsl.yml -K
```

### 2. Infrastructure Foundation (Terraform)
Provisions the Kind cluster, base operators (Strimzi), and namespaces (`database`, `kafka`, `midware`).
```bash
# Start from project root
cd terraform
terraform init -upgrade
terraform apply -auto-approve
cd ..
```

### 3. Middleware Services (Helm)
Deploy Stateful services via Helm.
```bash
# Ensure you are at the project root

# 3.1. Kafka Cluster
# Wait for Strimzi Operator to be running first
kubectl get pods -n kafka -w
helm install kafka-cluster k8s/charts/kafka-cluster -n kafka

# 3.2. Elasticsearch Cluster (Day 5)
# Operator 已经受 Terraform 纳管在 elastic-system 中自动拉起
# 等待 operator 就绪后部署无需密码的单节点集群
helm install elastic-cluster k8s/charts/elastic-cluster -n database
```

### 4. Business Microservices (Docker + Helm)
Deploy stateless Java microservices.

**Order Producer:**
```bash
# Build the image from the service directory
cd src/order-producer
mvn clean package -DskipTests
docker build -t order-producer:latest .
kind load docker-image order-producer:latest --name middleware-practice-cluster

# Go back to project root to deploy via Helm
cd ../..
helm install order-producer k8s/charts/order-producer -n midware
```

**Order Consumer (Day 4):**
```bash
# Build the image from the service directoryls -l
cd src/order-consumer
mvn clean package -DskipTests
docker build -t order-consumer:latest .
kind load docker-image order-consumer:latest --name middleware-practice-cluster

# Go back to project root to deploy via Helm
cd ../..
# 部署 consumer，期间它会自动运行 initContainer 创建业务数据库
helm install order-consumer k8s/charts/order-consumer -n midware
```

### 5. Teardown / Nuke Command
```bash
# Start from project root
cd terraform
terraform destroy -auto-approve
cd ..
```
