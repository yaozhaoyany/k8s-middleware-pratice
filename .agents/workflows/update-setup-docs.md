---
description: 提醒 AI 自动更新根目录的 setup.md 流程文档
---

# 目标

保证根目录下的 `setup.md` 永远是最新、最全、且可直接复制执行的环境拉起指南。

# 触发条件

当你（AI）在完成以下动作后，**必须**主动触发此工作流：
1. Terraform 层面新增了底层基础设施模块（如：新增了 ECK Operator 等）
2. 引入了新的中间件服务（如：新增了 Elasticsearch 安装脚本）
3. 新增了独立的业务微服务（如：开发并部署了 `order-consumer` 或 `search-api`），包含其特殊的 Docker 构建、注入、部署步骤。
4. 打包工具/部署方式发生了变化（如：从直接的 kubectl apply 迁移到了 Helm Chart 管理）

# 自动执行的更新动作

此时你应该：
1. 读取 `setup.md` 当前内容。
2. 根据最近的架构或脚本变动，精准定位修改点，将新的部署步骤以 Shell 脚本块的形式补充或修改到对应的分层阶段中（基础框架 -> 中间件 -> 微服务）。
3. 使用 `replace_file_content` 或 `write_to_file` 工具原子性地覆盖或更新 `setup.md` 的内容。
4. 使用 `run_command` 工具完成 Git Commit 动作，Commit message 应注明 `docs: 随着环境变化同步更新 setup.md 指南`。
