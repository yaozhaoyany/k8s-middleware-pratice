package com.middleware.practice.orderconsumer;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.kafka.annotation.EnableKafka;

/**
 * 订单消费者应用启动类
 *
 * \@EnableKafka 注解用于开启 Spring Kafka 的自动配置和监听器功能。
 */
@SpringBootApplication
@EnableKafka
public class OrderConsumerApplication {

    public static void main(String[] args) {
        SpringApplication.run(OrderConsumerApplication.class, args);
    }
}
