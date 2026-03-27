# =====================================================================
# Elastic Cloud on Kubernetes (ECK) Operator 部署
# 架构考量: Operator 属于 K8s 基础设施级别的扩展能力，由 Terraform 统一纳管。
# 业务级的 Elasticsearch/Kibana 集群实例则由 Helm 在应用层交付。
# =====================================================================

# 1. 为 Elastic 创建独立命名空间
resource "kubernetes_namespace" "elastic_system" {
  metadata {
    name = "elastic-system"
  }
}

# 2. 部署 ECK Operator (通过 Helm)
resource "helm_release" "eck_operator" {
  name       = "elastic-operator"
  repository = "https://helm.elastic.co"
  chart      = "eck-operator"
  namespace  = kubernetes_namespace.elastic_system.metadata[0].name
  
  # 推荐锁定版本，防止上游更新导致基础设施不可预计的变更
  version    = "2.11.1" 

  create_namespace = false

  # 根据需要可以调整 Operator 自身的资源占用
  set {
    name  = "resources.limits.memory"
    value = "512Mi"
  }
  set {
    name  = "resources.limits.cpu"
    value = "500m"
  }
  set {
    name  = "resources.requests.memory"
    value = "128Mi"
  }
  set {
    name  = "resources.requests.cpu"
    value = "100m"
  }
}
