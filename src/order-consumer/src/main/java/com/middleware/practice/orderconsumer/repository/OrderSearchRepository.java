package com.middleware.practice.orderconsumer.repository;

import com.middleware.practice.orderconsumer.document.OrderDocument;
import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;

/**
 * 订单搜索仓库
 * 利用 Spring Data Elasticsearch 提供开箱即用的 CRUD 和搜索接口。
 */
public interface OrderSearchRepository extends ElasticsearchRepository<OrderDocument, String> {
}
