# =============================================================
# 业务应用命名空间 (Educational Note)
# =============================================================
# 所有业务微服务（order-producer, order-consumer, search-api 等）
# 统一部署在 midware 命名空间下，与基础设施层（database, kafka）严格隔离。
# 这样的好处：
# 1. RBAC 权限隔离：开发者只需要 midware 的权限，碰不到 database/kafka 的底层资源
# 2. 资源配额管控：可以给 midware 设 ResourceQuota，防止业务应用吃光集群资源
# 3. 网络策略：后续可以用 NetworkPolicy 精确控制 midware → kafka/database 的流量

resource "kubernetes_namespace" "midware" {
  metadata {
    name = "midware"
    labels = {
      purpose    = "business-applications"
      managed-by = "terraform"
    }
  }

  depends_on = [kind_cluster.dev_cluster]
}
