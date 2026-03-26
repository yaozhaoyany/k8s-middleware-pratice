-- ================================================================
-- V1: 初始化订单表
-- Flyway 会在微服务启动时自动连接到 orders 数据库并下发此条建表语句。
-- 这比让 Hibernate "auto: update" 生成建表语句要严谨和可控得多。
-- ================================================================

CREATE TABLE IF NOT EXISTS orders (
    id BIGSERIAL PRIMARY KEY,
    order_id VARCHAR(100) NOT NULL UNIQUE,
    customer_name VARCHAR(255) NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 为常用的查询字段建立索引，加速检索
CREATE INDEX idx_orders_order_id ON orders(order_id);
CREATE INDEX idx_orders_customer_name ON orders(customer_name);
