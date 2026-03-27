# 🚀 Walkthrough: 有状态中间件的 IaC 部署 (Day 2 总结)

## 🎉 核心成就 (What We Accomplished)
Day 2 正式向 K8s 内部进军。我们将传统的“去云厂商控制台手动点出数据库”的模式，进化到了“基础设施即代码 (IaC)”。

1. **Terraform 一键拉起 Kind 集群**：
   - 在 `terraform/` 目录下，利用 Terraform 强大的声明式语法，一键创建并初始化了本地的 Kind K8s 实验集群。
   - 划分了清晰的逻辑隔离层（Namespaces）：
     - `database`: 专属用于各类高要求数据持久化的命名空间。
     - `kafka`: 专属用于流处理中间件的集群空间。
     - `midware`: 用于承载我们手写的各类 Spring Boot 业务微服务。

2. **Helm + Terraform: 部署有状态中间件 (StatefulSets)**：
   - 采用了业界标准且被广泛验证的 **Bitnami Helm Charts**，用极简的 `value` 复写替代了成百上千行的手写 K8s `YAML`：
   - **PostgreSQL 数据库**：
     - 在 K8s 中成功搭建起了一主一从的 Primary-Standby 高可用架构。
     - 配置了持久卷申明 (PVC) 以及严格的内存上下限防护 (Request/Limit)。
   - **Redis 缓存集群**：
     - 避开了单点故障，启用了 Sentinel (哨兵模式) HA 部署架构，为主节点配备从库与三个哨兵节点，实现宕机时的秒级自动选主 (Failover)。

## ✅ 架构验证结果
- 执行 `terraform apply` 后，整个底层的数据库版图犹如搭积木一般拔地而起。
- 我们验证了带有 Headless Service 寻址能力的数据库可以在 K8s 中通过 `StatefulSet` 稳定运行，也为后续复杂微服务的接入准备好了粮草。
