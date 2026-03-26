package com.middleware.practice.orderconsumer.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.Instant;

/**
 * 订单事件数据传输对象 (DTO)
 *
 * 这是一个接收 Kafka 消息的数据模型。
 * [Architecture Note] 它和 Producer 端的 OrderEvent 拥有相同的字段结构，
 * 但是在业务代码上是完全解耦隔离的。这就意味着，哪怕未来的某一天
 * 消费者模块被拆成了 Go 语言重构，或者增加了自己的特有派生字段，
 * 都不会影响到原有的事件发送方。
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
