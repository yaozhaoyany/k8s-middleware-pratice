#!/bin/bash
# ==============================================================================
# 微服务本地一键构建与部署脚本 (Dynamic Versioning)
# 用法: ./build-and-deploy.sh [服务名]
# 示例: ./build-and-deploy.sh order-consumer
# ==============================================================================

# 只要有任何一条指令失败，脚本立即退出
set -e

# 接收第一个参数作为服务名，如果没有传，默认使用 order-consumer
APP_NAME=${1:-order-consumer}
NAMESPACE="midware"
CLUSTER_NAME="middleware-practice-cluster"

echo "=========================================================="
echo "🚀 开始为您构建并部署微服务: $APP_NAME"
echo "=========================================================="

# 1. 生成带有时间戳的版本号 (解决 K8s latest 标签不更新的顽疾)
TIMESTAMP=$(date +%Y%m%d%H%M%S)
TAG="0.0.1-SNAPSHOT-${TIMESTAMP}"
IMAGE_NAME="${APP_NAME}:${TAG}"

echo "🏷️ 生成唯一的镜像版本号: $IMAGE_NAME"

# 2. 执行 Maven 构建 (跳过测试以加快本地打包速度)
echo "📦 [1/4] 正在编译外壳与业务代码 (Maven Package)..."
cd src/${APP_NAME}
mvn clean package -DskipTests
cd ../..

# 3. 构建 Docker 镜像
echo "🐳 [2/4] 正在将 Jar 包封入 Docker 镜像..."
docker build -t ${IMAGE_NAME} src/${APP_NAME}

# 4. 将镜像推送到本地的 Kind K8s 节点缓存中
echo "🧊 [3/4] 正在将镜像走私进入 Kind 节点缓存..."
kind load docker-image ${IMAGE_NAME} --name ${CLUSTER_NAME}

# 5. 触发 Helm 滚动更新 (注入强制计算出的新 Tag)
echo "☸️ [4/4] 正在触发 K8s Helm 滚动更新策略..."
helm upgrade ${APP_NAME} k8s/charts/${APP_NAME} --set image.tag=${TAG} --set image.pullPolicy=IfNotPresent -n ${NAMESPACE}

echo "=========================================================="
echo "✅ 大功告成！K8s 现已侦测到新的版本 Tag [$TAG]，正在平滑轮替旧的 Pod。"
echo "=========================================================="

# 自动挂起观察 Pod 拉起状态
kubectl get pods -n ${NAMESPACE} -l app=${APP_NAME} -w
