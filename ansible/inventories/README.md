# 深入理解 Ansible Inventories (环境清单)

你的理解**完全正确**！这正是 Senior 架构师必备的多环境管理思维。

在真实的生产流水线中，我们的架构通常会在多个不同的环境中流转（例如：`local` 本地开发环境 -> `lab` 实验室/测试环境 -> `staging` 预发环境 -> `prod` 生产环境）。

## 核心作用：环境隔离与配置解耦

Ansible 的核心设计哲学之一是 **“逻辑代码与环境配置分离”** (Separation of Configuration from Code)。
这意味着我们的核心部署逻辑（Playbooks 和 Roles 目录里写的 task）在所有环境下**绝对是同一套不变的代码**。
**产生区别的，仅仅是你喂给这套代码的“环境数据”（即 Inventory）。**

### 怎么应用？

通过在 `inventories` 目录下存放不同的文件来隔离环境：
*   `local.ini`: 记录你的本地电脑或本地虚拟机的连接方式。
*   `lab.ini`: 记录公司实验室里测试服务器的 IP 及其鉴权方式。
*   `prod.ini`: 记录生产环境真实服务器的 IP 列表。

### 实战演练 (一键切换环境)

**1. 部署到本地环境 (Local)**
由于我们之前在 `ansible.cfg` 里配置了默认读取 `inventories/local.ini`，所以直接执行：
```bash
ansible-playbook playbooks/deploy.yml
```

**2. 部署到远端实验室 (Lab)**
假设你周末在家，通过 VPN 连回公司，你要把这套一样的架构部署在公司的服务器上，你只需要加上 `-i` (inventory) 参数：
```bash
ansible-playbook -i inventories/lab.ini playbooks/deploy.yml
```
就这么简单，同一套代码，指哪打哪。

### 高阶技巧：不仅仅是存 IP (变量注入与覆盖)

Inventory 文件不仅能按分组（比如 `[webservers]`, `[dbservers]`）存 IP，更能**针对不同环境存放属于该环境的专属变量**（Inventory Variables）。

比如在部署 JVM 微服务时：
*   在 `local.ini` 中，你可以定义变量 `java_heap_size: 512m`（本地电脑省点内存）。
*   在 `prod.ini` 中，你可以定义相同名字的变量 `java_heap_size: 16g`（生产环境吃满资源）。

而在你的 Ansible Playbook 核心部署代码里，你永远只写一句话：`-Xmx{{ java_heap_size }}`。
Ansible 在运行时，会根据你 `-i` 指定的环境，自动把正确的值注入进去。这就是所谓的“一套代码定义一切”！
