package com.middleware.practice.orderproducer.controller;

import com.middleware.practice.orderproducer.model.OrderEvent;
import com.middleware.practice.orderproducer.service.OrderProducerService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.Map;
import java.util.UUID;

/**
 * 订单 REST API 控制器 (Educational Note)
 *
 * 这个 Controller 提供了两个 HTTP 端点：
 * 1. POST /api/orders     - 接收下单请求，发送订单事件到 Kafka
 * 2. POST /api/orders/mock - 一键生成模拟订单（用于压测和演示）
 *
 * 【架构角色】在整个事件驱动架构中，这个 Controller 是"事件源头 (Event Source)"。
 * 它不直接写数据库，只负责把事件丢进 Kafka 这条"高速传送带"。
 * 真正的数据持久化由下游的 order-consumer 微服务负责（Day 4 实现）。
 */
@Slf4j
@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderProducerService producerService;

    /**
     * 下单接口：接收客户端发来的订单信息，发送到 Kafka
     *
     * 请求示例:
     * POST /api/orders
     * {
     *   "customerName": "Tony Yao",
     *   "productName": "iPhone 15 Pro",
     *   "amount": 8999.00
     * }
     */
    @PostMapping
    public ResponseEntity<Map<String, Object>> createOrder(@RequestBody OrderEvent orderRequest) {
        // 补全服务端生成的字段（客户端不应该传这些）
        OrderEvent event = OrderEvent.builder()
                .orderId("ORD-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase())
                .customerName(orderRequest.getCustomerName())
                .productName(orderRequest.getProductName())
                .amount(orderRequest.getAmount())
                .status("CREATED")
                .createdAt(Instant.now())
                .build();

        producerService.sendOrderEvent(event);

        return ResponseEntity
                .status(HttpStatus.ACCEPTED)  // 202 Accepted：表示"已接收，异步处理中"
                .body(Map.of(
                        "message", "Order event submitted to Kafka",
                        "orderId", event.getOrderId(),
                        "status", event.getStatus()
                ));
    }

    /**
     * 模拟下单接口：一键生成随机订单并发送到 Kafka（用于压测和演示）
     */
    @PostMapping("/mock")
    public ResponseEntity<Map<String, Object>> createMockOrder() {
        String[] products = {"iPhone 15 Pro", "MacBook Air M3", "AirPods Pro 2", "iPad Pro 12.9"};
        String[] customers = {"Tony Yao", "Alice Chen", "Bob Zhang", "Charlie Li"};

        OrderEvent event = OrderEvent.builder()
                .orderId("ORD-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase())
                .customerName(customers[(int) (Math.random() * customers.length)])
                .productName(products[(int) (Math.random() * products.length)])
                .amount(BigDecimal.valueOf(Math.random() * 10000 + 100).setScale(2, BigDecimal.ROUND_HALF_UP))
                .status("CREATED")
                .createdAt(Instant.now())
                .build();

        producerService.sendOrderEvent(event);

        return ResponseEntity
                .status(HttpStatus.ACCEPTED)
                .body(Map.of(
                        "message", "Mock order event submitted to Kafka",
                        "orderId", event.getOrderId(),
                        "customerName", event.getCustomerName(),
                        "productName", event.getProductName(),
                        "amount", event.getAmount()
                ));
    }
}
