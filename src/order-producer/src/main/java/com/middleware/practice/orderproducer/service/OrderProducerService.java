package com.middleware.practice.orderproducer.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.middleware.practice.orderproducer.model.OrderEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.stereotype.Service;

import java.util.concurrent.CompletableFuture;

/**
 * 订单 Kafka 生产者服务 (Educational Note)
 *
 * 这个类是整个微服务的"核心引擎"，负责把订单事件发射到 Kafka。
 *
 * KafkaTemplate 是 Spring Kafka 提供的高级抽象，类似于 JdbcTemplate 之于 JDBC。
 * 它封装了原生 KafkaProducer 的连接管理、序列化、分区路由、重试等复杂逻辑，
 * 让你只需要调用一个 send() 方法就能完成消息发送。
 *
 * 【架构设计】为什么消息的 Key 是 orderId？
 * Kafka 根据消息的 Key 做分区路由（Key 相同的消息一定落在同一个分区）。
 * 这意味着同一笔订单的所有事件（CREATED → PAID → SHIPPED）一定会按顺序落入同一个分区，
 * 从而保证了"单订单维度的消息顺序性"——这在金融和电商场景中至关重要。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class OrderProducerService {

    private static final String TOPIC = "orders";

    private final KafkaTemplate<String, String> kafkaTemplate;
    private final ObjectMapper objectMapper;

    /**
     * 发送订单事件到 Kafka
     *
     * @param event 订单事件对象
     * @return 发送结果的异步 Future（包含分区号和偏移量信息）
     */
    public CompletableFuture<SendResult<String, String>> sendOrderEvent(OrderEvent event) {
        try {
            // 将 Java 对象序列化为 JSON 字符串
            String payload = objectMapper.writeValueAsString(event);

            log.info("📤 Sending order event to Kafka: orderId={}, topic={}", event.getOrderId(), TOPIC);

            // 使用 orderId 作为消息 Key，确保同一订单的所有事件落入同一分区
            CompletableFuture<SendResult<String, String>> future =
                    kafkaTemplate.send(TOPIC, event.getOrderId(), payload);

            // 注册异步回调：成功时打印分区和偏移量，失败时打印错误
            future.whenComplete((result, throwable) -> {
                if (throwable != null) {
                    log.error("❌ Failed to send order event: orderId={}", event.getOrderId(), throwable);
                } else {
                    log.info("✅ Order event sent successfully: orderId={}, partition={}, offset={}",
                            event.getOrderId(),
                            result.getRecordMetadata().partition(),
                            result.getRecordMetadata().offset());
                }
            });

            return future;

        } catch (JsonProcessingException e) {
            log.error("❌ Failed to serialize OrderEvent to JSON", e);
            return CompletableFuture.failedFuture(e);
        }
    }
}
