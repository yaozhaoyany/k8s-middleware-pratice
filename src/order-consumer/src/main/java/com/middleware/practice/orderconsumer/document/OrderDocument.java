package com.middleware.practice.orderconsumer.document;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.elasticsearch.annotations.Document;
import org.springframework.data.elasticsearch.annotations.Field;
import org.springframework.data.elasticsearch.annotations.FieldType;

import java.math.BigDecimal;

/**
 * 订单搜索文档类
 * 专门映射至 Elasticsearch 进行模糊检索和海量聚合。
 * 通过与 OrderEntity (JPA) 区分开，彻底解耦事务性核心数据与检索优化数据。
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(indexName = "orders") // 告诉 Spring Data ES 自动帮我们映射或者创建名叫 'orders' 的 Index
public class OrderDocument {

    @Id
    private String orderId;

    @Field(type = FieldType.Keyword)
    private String customerName;

    // 设置为 Text 类型，以便后续有需要的话可接力各种分词器进行模糊搜索
    @Field(type = FieldType.Text)
    private String productName;

    @Field(type = FieldType.Double)
    private BigDecimal amount;
}
