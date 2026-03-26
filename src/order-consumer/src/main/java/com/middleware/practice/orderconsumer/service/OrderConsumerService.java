package com.middleware.practice.orderconsumer.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.middleware.practice.orderconsumer.entity.OrderEntity;
import com.middleware.practice.orderconsumer.model.OrderEvent;
import com.middleware.practice.orderconsumer.repository.OrderRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 订单消费监听服务
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class OrderConsumerService {

    private final OrderRepository orderRepository;
    
    // 初始化 Jackson JSON 解析器
    private final ObjectMapper objectMapper = new ObjectMapper()
            .registerModule(new JavaTimeModule());

    /**
     * 核心消费者逻辑：监听 orders Topic
     *
     * containerFactory = "kafkaListenerContainerFactory" 是由于我们在 yaml 中
     * 配置了 String 读取，Spring 原生支持。
     *
     * @param message 从 Kafka Topic 'orders' 获取到的最新 JSON 文本
     */
    @KafkaListener(topics = "orders", groupId = "order-processing-group")
    @Transactional // 开启本地数据库事务
    public void consumeOrderEvent(String message) {
        log.info("📥 收到 Kafka 消息: {}", message);

        try {
            // 1. 反序列化，将 JSON 报文转化为业务 DTO (OrderEvent)
            OrderEvent event = objectMapper.readValue(message, OrderEvent.class);
            log.info("✅ 成功解析订单事件，OrderID: {}", event.getOrderId());

            // 2. 幂等性校验 (假设消费者重启读取了重复消息，我们需要防止重复插库)
            // 在实际分布式系统中，消息可能会重复投递(At least once)，所以消费者必须是幂等的！
            OrderEntity existingOrder = orderRepository.findByOrderId(event.getOrderId());
            if (existingOrder != null) {
                log.warn("⚠️ 订单 {} 已存在，忽略重复消费！", event.getOrderId());
                return;
            }

            // 3. 构建持久化层实体 (Entity 防腐转换)
            OrderEntity entity = OrderEntity.builder()
                    .orderId(event.getOrderId())
                    .customerName(event.getCustomerName())
                    .productName(event.getProductName())
                    .amount(event.getAmount())
                    .status("PROCESSED") // 标记为已接单处理
                    .createdAt(event.getCreatedAt())
                    .build();

            // 4. 落库
            orderRepository.save(entity);
            log.info("💾 订单数据持久化至 PostgreSQL 新增成功！");

        } catch (JsonProcessingException e) {
            log.error("❌ 消息格式解析失败 (毒性消息), body: {}", message, e);
            // 这里可以继续把错误消息发送进 Dead Letter Queue (死信队列) 重试，我们为了简化暂时吞掉
        } catch (Exception e) {
            log.error("❌ 落库异常", e);
            // 抛出运行时异常，让 Spring Kafka 把消息再塞回内部队列，依赖后面的重发机制
            throw new RuntimeException("消费逻辑异常，等待重试", e);
        }
    }
}
