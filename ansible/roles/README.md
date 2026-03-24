# 深入理解 Ansible Roles (角色机制)

如果你明白了 `inventories` 解决的是 **“同一套逻辑如何部署给不同环境”** 的问题；
那么 `roles` 解决的则是 **“千头万绪的部署逻辑，如何切碎、解耦、任意拼接复用”** 的问题。

## 为什么需要 Roles？(痛点是什么？)

想象一下公司里真实的部署场景，你不仅要装 Docker，还要配网卡、加系统用户、拉起中间件。
如果把所有这些写在同一个 playbook（剧本）文件里，这个文件不仅会长达千行，而且由于业务强耦合，**别的团队根本没法拿去复用**。

于是 Ansible 引入了 **Roles (角色)** 的概念，它本质上就是**代码的模块化 (Modularization)**。

## Roles 是如何组装复用的？

在真实项目中，我们会把独立、内聚的功能封装成不同的 role，比如：
*   `roles/os-init/`: 专管关闭防火墙、修改 Linux 内核参数。
*   `roles/docker-setup/`: 专管安装 Docker 和 Docker-compose。
*   `roles/java-app-deploy/`: 专管拉取 Jar 包并重启系统服务。

### 如何调用（复用逻辑）？

当你需要部署一台全新的**数据库服务器**时，你要写一个入口文件 (例如 `playbooks/setup-db.yml`)，里面极度简洁，纯粹就是拼积木：

```yaml
---
# playbooks/setup-db.yml
- name: 初始化数据库服务器
  hosts: db_servers # 这里对应 inventories 里配置的分组
  become: yes       # 提权执行 (sudo)
  roles:
    - role: os-init        # 积木 1：调底座优化
    - role: docker-setup   # 积木 2：装容器运行时
    - role: pg-setup       # 积木 3：单独起 PG
```

当你又需要部署一台**微服务应用服务器**时，你再写一个 `playbooks/setup-app.yml`：

```yaml
---
# playbooks/setup-app.yml
- name: 初始化应用微服务
  hosts: app_servers
  become: yes
  roles:
    - role: os-init        # 【完美复用！】
    - role: docker-setup   # 【完美复用！】
    - role: java-app-deploy# 积木 4：跑 Java 业务
```

如你所见，`os-init` 和 `docker-setup` 这两个共用组件的逻辑，被极其优雅地跨主机、跨剧本复用了。

## Role 内部的标准结构是什么样？

其实你可以通过 `ansible-galaxy init my_role` 来自动生成一个标准的 Role 框架。
它通常长这样（你不用一次全记住，用得到再去填）：

```text
roles/docker-setup/
├── tasks/main.yml    # [最核心] 所有的执行动作 (如：装apt包、起服务) 写且只写在这里
├── handlers/main.yml # [触发器] 当配置文件发生变动时，才触发的操作 (例如：重启 docker 服务)
├── templates/        # 存放含有 {{ 变量 }} 的 Jinja2 配置文件模板 (例如 nginx.conf.j2)
├── files/            # 存放需要原封不动 Copy 到远端机器的死文件 (如 SSL 证书)
├── vars/main.yml     # 内部写死的极少变动的常量
└── defaults/main.yml # 允许被外部 Inventory 覆盖的默认变量 (极度关键，体现解耦)
```

**总结一句**：Inventory 是配置分离，Role 是逻辑分离。掌握了这两个，你不仅能手撕万台级集群的自动化搭建，更能用“积木式组合”重构公司的烂脚本。
