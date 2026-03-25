# =============================================================
# Day 2: 有状态中间件部署 - PostgreSQL & Redis
# =============================================================
# 为什么用 Terraform Helm Release 而不是手撸 YAML？ (Educational Note)
# -------------------------------------------------------------
# 在 K8s 中部署一个生产级数据库，你至少要手写 6-8 个 YAML 文件
# (StatefulSet, PVC, ConfigMap, Secret, Service, ServiceAccount...)。
# 而一个成熟的 Helm Chart (如 Bitnami 出品) 把这些全部封装好了，
# 你只需要像填入住登记表一样声明几个关键参数，Helm 就帮你渲染出所有的 YAML。
# 结合 Terraform 的声明式管理，你获得的是：状态追踪 + 一键回滚 + 版本锁定。

# -------------------------------------------------------------
# 第一步：创建独立的命名空间 (Namespace)
# -------------------------------------------------------------
# 【架构最佳实践】将不同用途的组件放在不同的 Namespace 下，
# 实现资源隔离和 RBAC (基于角色的访问控制) 权限边界划分。
# 比如：数据库在 database 命名空间，监控在 monitoring 空间，业务服务在 apps 空间。
# 这样即使业务开发人员拥有 apps 空间的 admin 权限，也碰不到 database 空间里的数据库。

resource "kubernetes_namespace" "database" {
  metadata {
    name = "database"
    labels = {
      purpose = "stateful-middleware"
      managed-by = "terraform"
    }
  }

  # 声明依赖关系：必须等 Kind 集群完全就绪后，才能在里面创建命名空间
  depends_on = [kind_cluster.dev_cluster]
}

# =============================================================
# PostgreSQL 部署 (使用 Bitnami Helm Chart)
# =============================================================
# 为什么选 Bitnami 而不是 Zalando Operator？(Educational Note)
# -------------------------------------------------------------
# Zalando Operator 是生产级大厂的终极利器（功能包含自动 Failover、Patroni 共识选主），
# 但它的学习曲线极陡，且 CRD (自定义资源定义) 极其庞大。
# 对于我们的 10 天集训，Bitnami 的 Helm Chart 是完美的"即插即用"选手：
# 它底层用 StatefulSet 保证数据持久化，自带主从复制 (Replication) 开关，
# 并且参数极度直观。等你吃透了 StatefulSet 和 PVC 的原理，
# 再去挑战 Zalando Operator 就是降维打击了。

resource "helm_release" "postgresql" {
  name       = "postgresql"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  version    = "15.5.0"
  namespace  = kubernetes_namespace.database.metadata[0].name

  # 等待所有 Pod 和 Service 就绪后才算部署成功
  wait    = true
  timeout = 300

  # -------------------------------------------------------------
  # 核心参数配置 (Educational Note for each parameter)
  # -------------------------------------------------------------

  # 【安全】设置超级管理员密码
  # -------------------------------------------------------------
  # 🔴 当前写法：开发实验环境 (Dev/Lab) —— 明文硬编码，方便调试
  # 🟢 生产写法：对接 HashiCorp Vault —— 密码从加密金库中动态读取
  # -------------------------------------------------------------
  # 【生产环境 Vault 写法 - 学习参考】
  # 第一步：在 providers.tf 中声明 Vault Provider
  #   required_providers {
  #     vault = {
  #       source  = "hashicorp/vault"
  #       version = "~> 3.20.0"
  #     }
  #   }
  #
  # 第二步：配置 Vault Provider 连接地址和认证方式
  #   provider "vault" {
  #     address = "https://vault.yourcompany.com:8200"  # Vault 服务器地址
  #     # 认证方式通常用 Token 或者 Kubernetes Auth (在 K8s 内直接用 ServiceAccount 免密登录 Vault)
  #     # token = var.vault_token  # 从环境变量或 CI/CD 注入，绝不硬编码
  #   }
  #
  # 第三步：声明一个 data source，从 Vault 里读取密钥
  #   data "vault_generic_secret" "pg_credentials" {
  #     path = "secret/data/middleware/postgresql"  # Vault 中存储该密码的路径
  #   }
  #
  # 第四步：在 Helm Release 中引用 Vault 读出来的值（替换下方的 hardcoded value）
  #   set {
  #     name  = "auth.postgresPassword"
  #     value = data.vault_generic_secret.pg_credentials.data["password"]
  #   }
  # -------------------------------------------------------------
  # 【架构要点总结】
  # Vault 的核心价值在于：密码从未出现在你的 Git 代码仓库中！
  # 整个流程是：Terraform 运行时 -> 实时向 Vault 发 API 请求 -> Vault 验证身份后吐出密码 -> 注入 Helm
  # 即使有人拿到了你的 Git 仓库源码，也看不到任何真实密码，只能看到一个 Vault 路径。
  # -------------------------------------------------------------

  # 当前使用：开发实验环境硬编码（切换到生产时，注释掉这个 set，取消上面 Vault 写法的注释即可）
  set {
    name  = "auth.postgresPassword"
    value = "postgres123"
  }

  # 【业务数据库】自动创建一个名为 orders 的业务数据库，后续我们的订单微服务会连接它
  set {
    name  = "auth.database"
    value = "orders"
  }

  # 【架构选择】开启主从复制 (Primary-Standby Replication)
  # 这会让 Helm Chart 自动部署 1 个主节点 + N 个只读从节点
  # 对应的 K8s 资源是一个 StatefulSet，每个副本有独立的 PVC (持久化卷)
  set {
    name  = "architecture"
    value = "replication"
  }

  # 【从节点数量】配置 1 个只读从节点，用来演示读写分离和故障转移
  set {
    name  = "readReplicas.replicaCount"
    value = "1"
  }

  # 【资源限制】在本地 Kind 集群中，必须控制每个 Pod 的内存用量，否则你的电脑会被榨干
  # 主节点：最少保留 128MB 内存，最多使用 512MB
  set {
    name  = "primary.resources.requests.memory"
    value = "128Mi"
  }
  set {
    name  = "primary.resources.limits.memory"
    value = "512Mi"
  }

  # 从节点：同样的资源约束
  set {
    name  = "readReplicas.resources.requests.memory"
    value = "128Mi"
  }
  set {
    name  = "readReplicas.resources.limits.memory"
    value = "512Mi"
  }

  # 【持久化存储】每个 PG 实例分配 2Gi 的磁盘空间（Kind 集群用的是宿主机磁盘）
  set {
    name  = "primary.persistence.size"
    value = "2Gi"
  }
  set {
    name  = "readReplicas.persistence.size"
    value = "2Gi"
  }
}

# =============================================================
# Redis 部署 (使用 Bitnami Helm Chart)
# =============================================================
# 为什么 Redis 用 Sentinel 模式？(Educational Note)
# -------------------------------------------------------------
# Redis 常见的高可用架构有两种：Sentinel (哨兵) 和 Cluster (集群分片)。
# Sentinel 模式适合数据量小但对可用性要求极高的场景（典型：缓存热 Key、分布式锁）。
# 它的核心机制是：3 个哨兵节点不断心跳监控主节点，一旦主节点宕机，
# 哨兵们自动投票选出一个从节点"篡位"升级为新主节点，实现秒级故障转移 (Failover)。
# 这在订单系统中完美契合"缓存穿透防线"和"接口幂等锁"等高频场景。

resource "helm_release" "redis" {
  name       = "redis"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "redis"
  version    = "19.5.0"
  namespace  = kubernetes_namespace.database.metadata[0].name

  wait    = true
  timeout = 300

  # 【安全】Redis 访问密码
  set {
    name  = "auth.password"
    value = "redis123"
  }

  # 【架构选择】开启 Sentinel 哨兵高可用模式
  set {
    name  = "architecture"
    value = "replication"
  }

  # 【从节点数量】1 主 + 1 从 + 3 哨兵（Sentinel 默认 3 个）
  set {
    name  = "replica.replicaCount"
    value = "1"
  }

  # 【资源限制】Redis 是内存数据库，必须严格控制
  # 主节点：最少保留 64MB 内存，最多使用 256MB
  set {
    name  = "master.resources.requests.memory"
    value = "64Mi"
  }
  set {
    name  = "master.resources.limits.memory"
    value = "256Mi"
  }

  # 从节点资源限制
  set {
    name  = "replica.resources.requests.memory"
    value = "64Mi"
  }
  set {
    name  = "replica.resources.limits.memory"
    value = "256Mi"
  }

  # 【持久化】开启 AOF (Append Only File) 持久化，防止宕机后数据丢失
  set {
    name  = "master.persistence.size"
    value = "1Gi"
  }
  set {
    name  = "replica.persistence.size"
    value = "1Gi"
  }
}
