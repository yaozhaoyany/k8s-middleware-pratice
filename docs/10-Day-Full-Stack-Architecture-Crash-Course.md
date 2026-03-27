# 10-Day Full-Stack Architecture Crash Course (Path B: Ultimate IaC)

## Stage 0: Project Setup & IaC Foundation (Completed)
- [x] Initialize Git repository and prepare for GitHub push
- [x] Scaffold project directory structure (Terraform, Ansible, Src, etc.)
- [x] Set up Terraform state and basic provider for local/lab environment
- [x] Create Ansible inventory and boilerplate roles

## Stage 1: Cloud Native Infrastructure (D1-D3)
### ✅ Day 1: K8s Foundation (Ansible + Terraform)
- [x] Write Ansible role to install Docker, Kubectl, Kind, Helm on WSL
- [x] Write Terraform code using kind provider to spin up a multi-node cluster
- [x] Apply Ansible & Terraform to get a running K8s cluster

### ✅ Day 2: State in K8s (PostgreSQL & Redis)
- [x] Deploy PostgreSQL Operator (e.g., Zalando) or Bitnami Helm via Terraform
- [x] Deploy Redis Cluster via Helm/Terraform
- [x] Verify database connectivity and test SQL/Lua within Pods

### ✅ Day 3: Event-Driven K8s (Kafka/Strimzi)
- [x] Deploy Kafka via Strimzi Operator (Terraform Helm Provider)
- [x] Write `order-producer` Java code and deploy as K8s Deployment
- [x] Verify message production to Kafka brokers

## Stage 2: Microservices & Search (D4-D6)
### ✅ Day 4: Order Consumer & Data Sync
- [x] Write `order-consumer` Java code to sync Kafka -> PG
- [x] Deploy Consumer as K8s Deployment

### ⏳ Day 5: Elasticsearch via ECK Operator
- [ ] Deploy Elastic Cloud on K8s (ECK) Operator via Terraform
- [ ] Submit ES Custom Resource and test Kibana
- [ ] Update `order-consumer` to dual-write to ES

### ⏳ Day 6: Search API & Auto-Scaling
- [ ] Write `search-api` Java code querying ES
- [ ] Configure Horizontal Pod Autoscaler (HPA) for APIs

## Stage 3: Observability & Chaos (D7-D10)
### ⏳ Day 7-8: Prometheus Stack & Grafana
- [ ] Deploy `kube-prometheus-stack` via Terraform Helm
- [ ] Instrument Java apps with Micrometer/Prometheus registries
- [ ] Build Grafana dashboards (Order Success, P99)

### ⏳ Day 9: Full-Link Stress Testing & Chaos
- [ ] Run stress tests (k6/JMeter) against K8s Ingress
- [ ] Kill Kafka/PG pods, observe Operator self-healing

### ⏳ Day 10: Summary & Architecture Polish
- [ ] Document the GitOps/IaC architecture for resume
- [ ] Finalize README with one-click deployment instructions
