package com.middleware.practice.orderconsumer.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.Instant;

/**
 * 订单持久化防腐层实体 (Entity)
 *
 * 这个类是专门为了操作底层 PostgreSQL 数据库而存在的，与 JPA (Hibernate) 强绑定。
 */
@Entity
@Table(name = "orders") // 映射到刚刚 Flyway 创建的 orders 表
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OrderEntity {

    // 数据库物理主键
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 业务主键
    @Column(name = "order_id", unique = true, nullable = false, length = 100)
    private String orderId;

    @Column(name = "customer_name", nullable = false, length = 255)
    private String customerName;

    @Column(name = "product_name", nullable = false, length = 255)
    private String productName;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal amount;

    @Column(nullable = false, length = 50)
    private String status;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;
}
