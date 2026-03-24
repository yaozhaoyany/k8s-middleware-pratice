terraform {
  # 锁死 Terraform CLI 最低版本
  required_version = ">= 1.5.0"
  
  backend "local" {
    path = "terraform.tfstate"
  }

  required_providers {
    # 引入 Kind Provider，赋予 Terraform 画图纸直接拉起 K8s 集群的能力
    kind = {
      source  = "tehcyx/kind"
      version = "~> 0.4.0"
    }
    # 引入 Helm Provider，赋予 Terraform 向 K8s 内自动部署声明式配置的能力
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12.0"
    }
    # 引入 Kubernetes Provider，用于在原生 K8s API 上操作 Namespace 等基础资源
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.27.0"
    }
  }
}

# -------------------------------------------------------------
# 架构魔法：动态依赖串联 (Educational Note)
# -------------------------------------------------------------
# 在 main.tf 里，我们会创建一个叫 kind_cluster.dev_cluster 的资源。
# 这里我们直接把刚“无中生有”建出来的 Kind 集群的终点 IP 和所有安全证书，
# 喂给 kubernetes 和 helm 取用。这就构成了完美的 Terraform 流水线：
# 机器资源拉起 -> 证书反哺给上层 Provider -> 上层 Provider 继续往集群里装组件！

provider "kind" {}

provider "kubernetes" {
  host                   = kind_cluster.dev_cluster.endpoint
  client_certificate     = kind_cluster.dev_cluster.client_certificate
  client_key             = kind_cluster.dev_cluster.client_key
  cluster_ca_certificate = kind_cluster.dev_cluster.cluster_ca_certificate
}

provider "helm" {
  kubernetes {
    host                   = kind_cluster.dev_cluster.endpoint
    client_certificate     = kind_cluster.dev_cluster.client_certificate
    client_key             = kind_cluster.dev_cluster.client_key
    cluster_ca_certificate = kind_cluster.dev_cluster.cluster_ca_certificate
  }
}
