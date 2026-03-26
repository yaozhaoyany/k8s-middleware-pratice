---
description: 避免使用 8080，所有业务微服务统一使用 90xx 端口
---
# 微服务端口分配规范 (Port Convention)

在创建、初始化或重构任何微服务应用（如 Spring Boot、Node.js 等）以及配置容器环境时，**必须严格遵守**以下端口规范：

## 1. 禁用默认端口
绝对**禁止使用 8080 端口**作为应用的主服务端口。
> 原因：8080 是太多框架（Tomcat, Jenkins 等）的默认端口，在本地调试或复杂的云原生环境中极容易发生端口冲突，导致排查困难。

## 2. 统一分配规则
所有新建的业务逻辑微服务，需统一使用 `90xx` 频段的端口，并依次顺延：
- `order-producer`: 9081
- `order-consumer`: 9082
- 其他后续新增微服务从 9083 开始分配。

## 3. 全局配置对齐
当你为一个服务分配好具体的端口（例如 9082）后，必须确保它在以下配置文件中保持绝对一致：
1. **应用配置文件**（如 Spring Boot 的 `application.yml` 中的 `server.port`）。
2. **容器定义文件**（如 `Dockerfile` 中的 `EXPOSE` 指令）。
3. **K8s/Helm 部署清单**（如 `values.yaml` 中的 `service.port`，以及 Liveness/Readiness 探针指向的探测端口）。
