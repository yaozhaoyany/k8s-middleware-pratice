package com.middleware.practice.orderconsumer.repository;

import com.middleware.practice.orderconsumer.entity.OrderEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * 订单数据库操作接口
 *
 * 继承 JpaRepository 后，Spring 会在运行时自动生成实现类，
 * 直接具备 CRUD 能力，像 save(), findById(), count() 原生自带。
 */
@Repository
public interface OrderRepository extends JpaRepository<OrderEntity, Long> {

    // 我们可以根据规范自动生成查询语句，这里演示一个：
    // select * from orders where order_id = ?
    OrderEntity findByOrderId(String orderId);
}
