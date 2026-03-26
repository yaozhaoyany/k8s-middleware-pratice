# 使用 Java 17 的轻量 JRE 作为运行环境
FROM eclipse-temurin:17-jre-alpine

# 创建系统用户（安全最佳实践：非 root 运行微服务）
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# 设置工作目录
WORKDIR /app

# 从构建结果中复制那个包含了一切依赖的 Fat JAR 到容器里
# 在前面的步骤中，我们会在外层使用 maven build 出 target/*.jar 文件
COPY target/*.jar app.jar

# 暴露端口给 K8s 健康检查用
EXPOSE 9082

# 启动 Spring Boot 应用
ENTRYPOINT ["java", "-jar", "app.jar"]
