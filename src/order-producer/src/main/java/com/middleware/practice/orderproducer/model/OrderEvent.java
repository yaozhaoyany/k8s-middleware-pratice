package com.middleware.practice.orderproducer.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.Instant;

/**
 * 订单事件模型 (Educational Note)
 *
 * 这个类代表了在 Kafka 中流转的"消息体"。
 * 在事件驱动架构 (EDA) 中，我们不直接传递"数据库实体"，而是传递"事件"。
 * 事件 = "在某个时刻，发生了什么事情"。
 *
 * 例如：
 *   OrderEvent {
 *     orderId: "ORD-20260325-001",
 *     customerName: "Tony Yao",
 *     productName: "iPhone 15 Pro",
 *     amount: 8999.00,
 *     status: "CREATED",
 *     createdAt: "2026-03-25T18:30:00Z"
 *   }
 *
 * 这条事件会被序列化成 JSON 字符串，然后作为 Kafka 消息体发送到 "orders" Topic。
 * 下游的 order-consumer 微服务会消费这条消息，把它持久化到 PostgreSQL 中。
 *
 * @Data        = 自动生成 getter/setter/toString/equals/hashCode
 * @Builder     = 提供链式构建器模式：OrderEvent.builder().orderId("xxx").build()
 * @NoArgsConstructor/@AllArgsConstructor = 无参和全参构造器（Jackson 反序列化需要无参构造器）
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OrderEvent {

    private String orderId;
    private String customerName;
    private String productName;
    private BigDecimal amount;
    private String status;
    private Instant createdAt;
}
