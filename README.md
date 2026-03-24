# High-Availability Order Observability System

This project is a 10-day full-stack architecture practice focused on high concurrency, high availability, and observability. It simulates an order processing system capable of handling thousands of requests per second with comprehensive tracing, monitoring, and logging.

## Core Tech Stack
*   **Microservices**: Java (Spring Boot / Quarkus)
*   **Storage & Caching**: PostgreSQL, Redis
*   **Message Broker**: Kafka
*   **Search**: Elasticsearch
*   **Infrastructure & Orchestration**: Kubernetes (K8s), Docker
*   **IaC & CaC**: Terraform, Ansible
*   **Observability**: Prometheus, Grafana

## Project Structure
*   `terraform/`: Infrastructure provisioning (IoC).
*   `ansible/`: Configuration management and deployment automation (CaC).
*   `docker-compose/`: Local quick-start setup for middleware.
*   `k8s/`: Kubernetes manifests for stage/prod environments.
*   `src/`: Microservices codebase.
    *   `order-producer/`: Emits order events.
    *   `order-consumer/`: Processes orders to DB and ES.
    *   `search-api/`: Provides query interfaces.
*   `scripts/`: Utility scripts (e.g., stress testing).

## Getting Started
(To be updated as development progresses)
