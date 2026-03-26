# Infrastructure Up & Running Workflow

This workflow documents the exact steps required to provision the local development environment on WSL from scratch, up to the end of Day 3 (Kafka & Order Producer).

**Use this guide whenever you need to tear down the environment and start fresh.**

---

## 1. Local Machine Setup (Optional, run once per machine)
If your WSL instance does not have Docker, Kind, Kubectl, Helm, and Terraform installed, run the Ansible playbook:
```bash
cd ansible
ansible-playbook -i inventory k8s-setup.yml -K
```

## 2. Infrastructure Foundation (Terraform)
This step brings up the Kind cluster and installs all foundational operators and databases (PostgreSQL, Redis, Strimzi Operator).
```bash
cd terraform
terraform init -upgrade
terraform apply -auto-approve
```
Wait for the Kind cluster to spin up and Helm charts to deploy (~3-5 minutes).

## 3. Kafka Cluster Deployment (Helm)
Deploy the Kafka cluster Custom Resources using the `kafka-cluster` Helm chart. This requires the Strimzi Operator (from Step 2) to be running.
```bash
# Verify Strimzi Operator is running first
kubectl get pods -n kafka

# Deploy Kafka CR and Topic
helm install kafka-cluster k8s/charts/kafka-cluster -n kafka

# CRITICAL: Wait for all Kafka and ZooKeeper pods to be Running and Ready (1/1)
# DO NOT proceed to Step 4 until this is complete.
kubectl get pods -n kafka -w
```

## 4. Build and Deploy Business Microservices
Currently, this is only the `order-producer` service.

### 4.1 Build Docker Image
```bash
cd src/order-producer
mvn clean package -DskipTests
docker build -t order-producer:latest .
```

### 4.2 Load Image into Kind Cluster
Because Kind runs inside Docker, it cannot pull local images. You must explicitly load the newly built image into the Kind nodes.
```bash
kind load docker-image order-producer:latest --name middleware-practice-cluster
```

### 4.3 Deploy via Helm
Deploy the microservice into the `midware` namespace.
```bash
helm install order-producer k8s/charts/order-producer -n midware
```

## 5. Verification
Verify the pods are running and test the API.
```bash
# Check Pod status
kubectl get pods -n midware -w

# Port-forward the service to local WSL (Do this in a separate terminal)
kubectl port-forward svc/order-producer 9081:9081 -n midware

# Send a mock order (In another terminal)
curl -X POST http://localhost:9081/api/orders/mock
```

---

## Teardown (Nuke Everything)
If you want to destroy the entire environment to start completely fresh:
```bash
cd terraform
# This will destroy the Kind cluster and ALL resources inside it instantly.
terraform destroy -auto-approve
```
