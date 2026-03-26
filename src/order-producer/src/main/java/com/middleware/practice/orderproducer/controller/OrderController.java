package com.middleware.practice.orderproducer.controller;

import com.middleware.practice.orderproducer.model.OrderEvent;
import com.middleware.practice.orderproducer.service.OrderProducerService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.concurrent.CompletableFuture;

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
        // 控制器只负责接收请求，把组装数据的脏活累活全交给 Service 层
        producerService.createAndSendOrder(orderRequest);

        return ResponseEntity
                .status(HttpStatus.ACCEPTED)  // 202 Accepted：表示"已接收，异步处理中"
                .body(Map.of(
                        "message", "Order event submitted to Kafka processing pipe"
                ));
    }

    /**
     * 模拟下单接口：一键生成随机订单并发送到 Kafka（用于压测和演示）
     */
    @PostMapping("/mock")
    public ResponseEntity<Map<String, Object>> createMockOrder() {
        producerService.createAndSendMockOrder();

        return ResponseEntity
                .status(HttpStatus.ACCEPTED)
                .body(Map.of(
                        "message", "Mock order event submitted to Kafka processing pipe"
                ));
    }
}
