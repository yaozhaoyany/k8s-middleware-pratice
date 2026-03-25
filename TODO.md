# Tech Debt & Shortcuts TODO

> 本文件记录了在学习/开发过程中为了快速推进而做出的"偷懒妥协"。
> 这些条目都应当在进入生产级架构时被逐一清理掉。

## Terraform (基础设施层)

- [ ] **`auth.database = "orders"` 跨层越界问题**
  - 文件: `terraform/middleware.tf`
  - 问题: 业务数据库名不应由 Terraform 基础设施层创建，违反 DDD 分层原则
  - 正确做法: 删除此 `set`，在 Java 微服务中集成 Flyway/Liquibase，由应用启动时自行迁移建库建表
  - 优先级: Day 4 编写 `order-consumer` 时一并修正

- [ ] **密码明文硬编码**
  - 文件: `terraform/middleware.tf`
  - 问题: `auth.postgresPassword` 和 `auth.password` 明文写在代码里
  - 正确做法: 对接 HashiCorp Vault（参考文件中已有的注释模板）
  - 优先级: 低（仅限生产环境需要）

## Ansible (配置管理层)

- [ ] **Docker Socket 权限暴力放开**
  - 文件: `ansible/roles/k8s-base-setup/tasks/main.yml`
  - 问题: `mode: '0666'` 放开了所有用户的读写权限，存在安全风险
  - 正确做法: 仅依赖 `docker` 用户组权限控制，不暴力修改 socket 文件权限
  - 优先级: 低（仅限生产环境需要）
