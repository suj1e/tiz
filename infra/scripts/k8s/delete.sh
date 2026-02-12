#!/bin/bash
# Kubernetes 一键删除脚本

set -e

echo "=========================================="
echo "   Deleting Nexora from Kubernetes"
echo "=========================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 检查 kubectl
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}Error: kubectl is not installed${NC}"
    exit 1
fi

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")/.."

cd "$PROJECT_DIR"

echo -e "${YELLOW}This will delete all Nexora resources from Kubernetes${NC}"
echo ""
read -p "Are you sure? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Aborted"
    exit 0
fi

echo ""
echo -e "${YELLOW}Deleting resources...${NC}"

# 删除各组件
echo "Deleting Kafka..."
kubectl delete -f config/k8s/components/kafka/ -n nexora-infra 2>/dev/null || true

echo "Deleting ElasticJob..."
kubectl delete -f config/k8s/components/elasticjob/ -n nexora-infra 2>/dev/null || true

echo "Deleting ZooKeeper..."
kubectl delete -f config/k8s/components/zookeeper/ -n nexora-infra 2>/dev/null || true

echo "Deleting Seata..."
kubectl delete -f config/k8s/components/seata/ -n nexora-infra 2>/dev/null || true

echo "Deleting Sentinel..."
kubectl delete -f config/k8s/components/sentinel/ -n nexora-infra 2>/dev/null || true

echo "Deleting Nacos..."
kubectl delete -f config/k8s/components/nacos/ -n nexora-infra 2>/dev/null || true

echo "Deleting Elasticsearch..."
kubectl delete -f config/k8s/components/elasticsearch/ -n nexora-infra 2>/dev/null || true

echo "Deleting Kibana..."
kubectl delete -f config/k8s/components/kibana/ -n nexora-infra 2>/dev/null || true

echo "Deleting Redis..."
kubectl delete -f config/k8s/components/redis/ -n nexora-infra 2>/dev/null || true

echo "Deleting MySQL..."
kubectl delete -f config/k8s/components/mysql/ -n nexora-infra 2>/dev/null || true

echo "Deleting namespace..."
kubectl delete -f config/k8s/base/namespace.yaml 2>/dev/null || true

echo ""
echo -e "${GREEN}All resources deleted!${NC}"
echo ""
