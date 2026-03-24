# -------------------------------------------------------------
# 为什么用 Terraform 声明式创建 K8s 集群？(Educational Note)
# -------------------------------------------------------------
# 过去开发人员习惯敲命令 `kind create cluster` 临时起服。这是典型的“命令式（过程）”。
# 但在真正的大厂 IaC 体系里，集群本身（包含有几个 Worker 节点、暴露哪些宿主机端口）都是非常重要的基础设施配置。
# 用 Terraform 把它固化下来（声明式），意味着无论何时，只要代码在，
# 即使别人误删了集群，你只需 `terraform apply` 即可 100% 还原那个一模一样的 K8s 底座和完整的测试环境。

resource "kind_cluster" "dev_cluster" {
  name           = "middleware-practice-cluster"
  node_image     = "kindest/node:v1.29.2"
  wait_for_ready = true

  # kind_config 定义了具体的集群物理拓扑结构
  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    # 1. 控制面节点 (Control Plane)
    node {
      role = "control-plane"
      
      # 【生产架构思想】：在这里我们额外配置了主机端口映射 (Port Mapping)。
      # 它是为了把 K8s 集群内部署的 Ingress 网关 (监听 80 端口)，
      # 强行映射到你物理机宿主机（WSL）的 80 端口上。
      # 这样后续你开发微服务时，直接在浏览器打 `http://localhost/api/search` 就能打穿进入 K8s 内部署的服务了！
      kubeadm_config_patches = [
        "kind: InitConfiguration\nnodeRegistration:\n  kubeletExtraArgs:\n    node-labels: \"ingress-ready=true\"\n"
      ]
      extra_port_mappings {
        container_port = 80
        host_port      = 80
        protocol       = "TCP"
      }
    }

    # 2. 第一台 Worker 节点 (提供算力，用于跑我们的微服务)
    node {
      role = "worker"
    }

    # 3. 第二台 Worker 节点 (提供冗余环境，用于测试 PG/Redis 分布式的高可用和故障转移)
    node {
      role = "worker"
    }
  }
}
