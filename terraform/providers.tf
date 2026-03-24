terraform {
  # 锁死 Terraform CLI 最低版本，确保团队里的每一个成员（以及 CI 服务器）应用的行为一致。
  required_version = ">= 1.5.0"
  
  # 【核心概念】后端 (Backend)。
  # Terraform 需要一个 "tfstate" 文件来记录它究竟创建了哪些资源，作为代码与现实世界的映射。
  # 这里为了本地练习用了 "local"（存在本地目录）。在公司真实的 PPDM 或生产环境中，我们通常会把它改为 "s3" 或 "gcs"，存在云对象存储里，配合分布式锁 (如 DynamoDB) 来实现多人并发协作和状态隔离。
  backend "local" {
    path = "terraform.tfstate"
  }

  required_providers {
    # 声明需要下载的插件 (Provider)。比如要把资源建在 AWS，这里就要引入 aws provider。
    # 当下的环境没有真实云资源，所以我引入了 "null"（空）提供者。它经常用来在不创建真实云资源的情况下，执行一些本地脚本或者触发器。
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}
