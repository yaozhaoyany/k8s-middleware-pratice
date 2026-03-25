# =============================================================
# 多阶段构建 Dockerfile (Educational Note)
# =============================================================
# 为什么用多阶段构建？
# 如果只用一个阶段，最终镜像里会包含完整的 Maven、JDK 编译工具链（约 800MB）。
# 但运行 Java 应用只需要 JRE（约 200MB）。
# 多阶段构建的思路：第一阶段用 JDK 编译打包，第二阶段只把编译好的 JAR 拷贝到精简的 JRE 镜像里。
# 最终镜像从 800MB 瘦身到 ~250MB。

# ---- 第一阶段：编译构建 ----
FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /app

# 先只拷贝 pom.xml 并下载依赖（利用 Docker 缓存层）
# 这样只要 pom.xml 没变，后续修改 Java 源码不会触发重新下载依赖，大幅加速构建
COPY pom.xml .
RUN mvn dependency:go-offline -B

# 再拷贝源码并编译打包
COPY src ./src
RUN mvn package -DskipTests -B

# ---- 第二阶段：运行环境 ----
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# 从第一阶段的构建产物中，只拷贝最终的 Fat JAR
COPY --from=builder /app/target/*.jar app.jar

# 暴露 Spring Boot 默认端口
EXPOSE 8080

# 启动命令
# -XX:+UseContainerSupport：让 JVM 正确识别容器的内存限制（而不是读取宿主机的物理内存）
# -XX:MaxRAMPercentage=75：让 JVM 最多使用容器内存限制的 75%，留 25% 给 JVM 自身开销
ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75", "-jar", "app.jar"]
