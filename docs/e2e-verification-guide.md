# 🔎 分布式架构端到端流转测试手册 (E2E Verification Guide)

当你的 Elasticsearch 集群和带双写功能的 `order-consumer` 都在 K8s 中启动完毕后，请按照以下四个核心步骤来闭环验证整套数据流系统的严密性。

建议打开 **4个独立的终端**，以最直白的方式观测现代微服务的数据飞线。

## 🎯 步骤 1: 制造测试流量 (触发订单链路)
首先，我们需要通过 API 往系统里扔入一条订单。由于服务深埋在 K8s 内网，我们先将流量代理出来：
```bash
# 终端 1：暴露 Producer
kubectl port-forward svc/order-producer -n midware 9081:9081
```

然后，直接利用我们的暗门接口，一键造单投递至 Kafka：
```bash
# 终端 2：下订单（执行该句时，请观察终端 3）
curl -X POST http://localhost:9081/api/orders/mock
```

## 📝 步骤 2: 观测消费者链路日志 (Kafka 接收实况)
通过查看 Consumer 容器底层的标准输出流，你可以看到数据从 Kafka 脱水，被重新反序列化，并被强制双向派发的瞬间：
```bash
# 终端 3: 跟踪日历流
kubectl logs -f deploy/order-consumer -n midware
```
**你应该看到的日志期望：**
1. `📥 收到 Kafka 消息: {"customerName":... "amount":...}`
2. `💾 订单数据持久化至 PostgreSQL 新增成功！`
3. `🔍 订单数据同时双写至 Elasticsearch 成功！`

## 🐘 步骤 3: 验证事务核心层 (PostgreSQL 关系库)
由于有了 Flyway 和 JPA，数据应该已安全着陆于物理表：
```bash
# 终端 4: 侵入数据库内核查单
kubectl exec -it postgresql-0 -n database -- psql -U postgres -d orders -c "SELECT * FROM orders;"
```

## 📈 步骤 4: 验证分布式检索层 (Elasticsearch / Kibana)
这是整个架构读写分离的压轴好戏，我们将验证数据是否被成功扁平化同步到了 NoSQL 搜索引擎中：

首先，暴露 Kibana UI 页面（因为我们关掉了 TLS，所以它现在是一个没有任何阻碍的纯净面板）：
```bash
# 终端 4 (或终端 1 中断后重用拉起)：暴露 Kibana 的 NodePort 或普通服务端口
kubectl port-forward svc/elastic-cluster-kb-kb-http -n database 5601:5601
```

**操作路径**：
1. 打开宿主机浏览器：访问 `http://localhost:5601`
2. 点击左上角的汉堡菜单 (Hamburger Menu) -> 滑向底部的 `Management` 区域 -> 找到熟悉的 **`Dev Tools` (开发工具)**。
3. 在左侧面板的交互控制台中，敲下人生初版的检索 DSL 指令：
    ```json
    GET orders/_search
    ```
4. 点击绿色的执行三角形 (Play Button)，注视右侧的黑框，享受亲手双写进来的订单数据在毫秒间被聚合搜出的快感！
