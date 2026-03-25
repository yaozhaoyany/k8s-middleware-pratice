package com.middleware.practice.orderproducer;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 订单生产者微服务启动类 (Educational Note)
 *
 * @SpringBootApplication 是一个"三合一"注解，等于同时加了：
 *   - @Configuration：声明这是一个 Spring 配置类
 *   - @EnableAutoConfiguration：让 Spring Boot 根据 classpath 里的依赖自动配置 Bean
 *     （比如检测到 spring-kafka 依赖就自动创建 KafkaTemplate Bean）
 *   - @ComponentScan：自动扫描当前包及其子包下所有带 @Component/@Service/@Controller 的类
 *
 * 整个微服务的职责非常单一（单一职责原则 SRP）：
 *   接收 HTTP POST 请求 → 构建订单事件 → 发送到 Kafka Topic → 返回确认
 */
@SpringBootApplication
public class OrderProducerApplication {

    public static void main(String[] args) {
        SpringApplication.run(OrderProducerApplication.class, args);
    }
}
