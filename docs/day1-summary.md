# 🚀 Walkthrough: 云原生基础环境搭建 (Day 1 总结)

## 🎉 核心成就 (What We Accomplished)
Day 1 的目标是为整个 10 天架构训练营打下坚实的基石。由于现代企业级微服务对基础设施的依赖非常深，我们需要一套能够**无限次、一键重置**的沙盒环境。

1. **统一 WSL 本地开发环境**：
   - 基于 Windows Subsystem for Linux (WSL) 构建底座，打破 Windows 下运行各种云原生工具的性能与兼容性瓶颈，全面拥抱 Linux 生态。

2. **Ansible 自动化装机流水线**：
   - 抛弃了传统的手动 `apt-get install` 路线，引入了配置管理利器 **Ansible**。
   - 编写了 `ansible/playbooks/setup-wsl.yml` 剧本作为环境初始化向导。
   - 实现了对云原生“五大件”的自动化安装与配置：
     - **Docker**：容器运行时底座。
     - **Kubernetes (Kind)**：K8s IN Docker，本地轻量级 K8s 集群引擎。
     - **Kubectl**：K8s 集群管理命令行工具。
     - **Helm**：K8s 应用的包管理器。
     - **Terraform**：声明式的“基础设施即代码 (IaC)”大管家。

## ✅ 架构验证结果
- 无论这台电脑重装多少次系统，只要拉下代码库执行一行 `ansible-playbook` 命令，开发人员都能在 5 分钟内获得一个 100% 结构一致的云原生基础环境，彻底消灭了“在我的电脑上明明能跑”的环境差异痛点！
