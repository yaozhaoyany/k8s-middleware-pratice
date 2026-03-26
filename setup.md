# Environment Setup Guide (Living Document)

This document serves as the single source of truth for completely rebuilding the local local K8s development environment on WSL.
**It must be updated automatically whenever new infrastructure, namespaces, or deployment steps are added to the project.**

---

## 🏗️ Current State: End of Day 3 (Kafka + Order Producer)

### 1. Prerequisites / Base Tools
Run the Ansible playbook once per new WSL environment to install Docker, Kubectl, Kind, Helm, and Terraform:
```bash
cd ansible
ansible-playbook -i inventory k8s-setup.yml -K
```

### 2. Infrastructure Foundation (Terraform)
Provisions the Kind cluster, base operators (Strimzi), and namespaces (`database`, `kafka`, `midware`).
```bash
cd terraform
terraform init -upgrade
terraform apply -auto-approve
```

### 3. Middleware Services (Helm)
Deploy Stateful services via Helm.
```bash
# 3.1. Kafka Cluster
# Wait for Strimzi Operator to be running first
kubectl get pods -n kafka -w
helm install kafka-cluster k8s/charts/kafka-cluster -n kafka
```

### 4. Business Microservices (Docker + Helm)
Deploy stateless Java microservices.

**Order Producer:**
```bash
cd src/order-producer
mvn clean package -DskipTests
docker build -t order-producer:latest .
kind load docker-image order-producer:latest --name middleware-practice-cluster
helm install order-producer k8s/charts/order-producer -n midware
```

### 5. Teardown / Nuke Command
```bash
cd terraform
terraform destroy -auto-approve
```
