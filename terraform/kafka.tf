# =============================================================
# Day 3: 事件驱动引擎 - Kafka (Strimzi Operator)
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
# 这就是 K8s 世界里"Operator Pattern"的精髓：
# 把运维知识编码成程序，让机器 7x24h 自动运维，人类只需要"声明意图"。

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
# 比如 Kafka、KafkaTopic、KafkaUser 等。有了这些 CRD，你才能用声明式 YAML 来定义 Kafka 集群。
resource "helm_release" "strimzi_operator" {
  name       = "strimzi"
  chart      = "oci://quay.io/strimzi-helm/strimzi-kafka-operator"
  namespace  = kubernetes_namespace.kafka.metadata[0].name

  wait    = true
  timeout = 300

  # 【资源限制】Operator 控制器本身也是一个 Pod，在本地 Kind 里要控制资源
  set {
    name  = "resources.requests.memory"
    value = "256Mi"
  }
  set {
    name  = "resources.limits.memory"
    value = "512Mi"
  }

  # 【监听范围】让 Operator 只监听自己所在的 Namespace（kafka），不要越权管别的空间
  set {
    name  = "watchNamespaces"
    value = "{kafka}"
  }
}

# -------------------------------------------------------------
# 第三步：提交 Kafka 集群自定义资源 (Custom Resource)
# -------------------------------------------------------------
# 这是 Operator Pattern 最精彩的部分：你不直接创建 StatefulSet，
# 而是提交一个"意图声明"（Kafka CR），Operator 会替你翻译成底层的 K8s 资源。
#
# 为什么用 kubernetes_manifest 而不是 helm_release？
# 因为 Kafka 集群本身不是一个 Helm Chart，而是一个 Strimzi CRD 的实例。
# 我们需要用 Terraform 的 kubernetes_manifest 资源来提交这个原生的 K8s YAML。
resource "kubernetes_manifest" "kafka_cluster" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "Kafka"
    metadata = {
      name      = "orders-cluster"
      namespace = kubernetes_namespace.kafka.metadata[0].name
    }
    spec = {
      kafka = {
        version  = "3.7.0"
        replicas = 1  # 本地 Kind 资源有限，先用单 Broker（生产至少 3 个）
        listeners = [
          {
            name = "plain"
            port = 9092
            type = "internal"
            tls  = false
          }
        ]
        config = {
          # 【关键参数】Topic 默认分区数和副本因子
          # 单 Broker 环境下，副本因子只能为 1（因为副本必须分布在不同 Broker 上）
          "offsets.topic.replication.factor"         = 1
          "transaction.state.log.replication.factor" = 1
          "transaction.state.log.min.isr"            = 1
          "default.replication.factor"               = 1
          "min.insync.replicas"                      = 1
        }
        storage = {
          type = "ephemeral"  # 本地学习环境用临时存储，生产应该用 persistent-claim
        }
        resources = {
          requests = { memory = "512Mi" }
          limits   = { memory = "1Gi" }
        }
      }
      zookeeper = {
        replicas = 1  # ZooKeeper 也精简为单节点
        storage = {
          type = "ephemeral"
        }
        resources = {
          requests = { memory = "256Mi" }
          limits   = { memory = "512Mi" }
        }
      }
      entityOperator = {
        # Topic Operator：监听 KafkaTopic CR，自动创建/管理 Topic
        topicOperator = {}
        # User Operator：监听 KafkaUser CR，自动管理 Kafka 用户权限
        userOperator = {}
      }
    }
  }

  depends_on = [helm_release.strimzi_operator]
}

# -------------------------------------------------------------
# 第四步：声明式创建 Kafka Topic
# -------------------------------------------------------------
# 有了 Strimzi 的 Topic Operator，我们不需要手动进 Kafka 容器敲命令创建 Topic，
# 只需要提交一个 KafkaTopic CR，Operator 会自动帮我们搞定。
resource "kubernetes_manifest" "kafka_topic_orders" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "KafkaTopic"
    metadata = {
      name      = "orders"
      namespace = kubernetes_namespace.kafka.metadata[0].name
      labels = {
        "strimzi.io/cluster" = "orders-cluster"
      }
    }
    spec = {
      partitions = 3   # 3 个分区，为后续消费者并行消费做准备
      replicas   = 1   # 单 Broker，只能 1 副本
      config = {
        "retention.ms" = "604800000"  # 消息保留 7 天（604800000ms）
      }
    }
  }

  depends_on = [kubernetes_manifest.kafka_cluster]
}
