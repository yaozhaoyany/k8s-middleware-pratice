# =============================================================
# Day 3: 事件驱动引擎 - Strimzi Kafka Operator 安装
# =============================================================
# 为什么用 Strimzi Operator 而不是直接用 Bitnami Kafka Chart？(Educational Note)
# -------------------------------------------------------------
# Bitnami Kafka Chart 跟 Day 2 的 PG/Redis 一样，是"直接部署一个 StatefulSet"。
# 但 Kafka 集群的运维极其复杂（Broker 扩缩容、Topic 分区再平衡、证书轮换...），
# 普通 StatefulSet 根本无法自动处理这些运维动作。
#
# Strimzi 是 CNCF 孵化的 Kafka Operator，它的思路是：
# 1. 先在集群里安装一个"Operator 控制器"（一个 7x24h 跑着的 Pod）
# 2. 你只需要提交一个 Kafka 自定义资源 (Custom Resource / CR)，声明"我要 3 个 Broker"
# 3. Operator 控制器会自动帮你创建 StatefulSet、ConfigMap、Service、PVC 等所有底层资源
# 4. 如果你改了 CR（比如 Broker 数从 3 变成 5），Operator 会自动执行滚动扩容
#
# 【架构边界调整】
# Terraform 只负责安装 Strimzi Operator（基础设施插件层）。
# Kafka 集群 CR、Topic、业务微服务全部由 Helm Chart 管理（应用层），
# 这样更统一、更有序，也更贴近 GitOps 的最佳实践。

# -------------------------------------------------------------
# 第一步：创建 Kafka 专属命名空间
# -------------------------------------------------------------
resource "kubernetes_namespace" "kafka" {
  metadata {
    name = "kafka"
    labels = {
      purpose    = "event-streaming"
      managed-by = "terraform"
    }
  }

  depends_on = [kind_cluster.dev_cluster]
}

# -------------------------------------------------------------
# 第二步：部署 Strimzi Operator (通过 Helm)
# -------------------------------------------------------------
# Strimzi Operator 自身是一个 Deployment，它会往 K8s 里注册一堆 CRD（自定义资源定义），
# 比如 Kafka、KafkaTopic、KafkaUser 等。有了这些 CRD，你才能用 kubectl/Helm 来提交 Kafka 集群声明。
resource "helm_release" "strimzi_operator" {
  name       = "strimzi"
  chart      = "oci://quay.io/strimzi-helm/strimzi-kafka-operator"
  namespace  = kubernetes_namespace.kafka.metadata[0].name

  wait    = true
  timeout = 300

  set {
    name  = "resources.requests.memory"
    value = "256Mi"
  }
  set {
    name  = "resources.limits.memory"
    value = "512Mi"
  }
  set {
    name  = "watchNamespaces"
    value = "{kafka}"
  }
}
