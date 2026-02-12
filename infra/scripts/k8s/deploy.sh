#!/bin/bash
# Kubernetes 一键部署脚本

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

echo "=========================================="
echo "   Nexora Infrastructure K8s Deployment"
echo "=========================================="
echo ""

# 检查 kubectl
if ! command -v kubectl &> /dev/null; then
    log_error "kubectl is not installed"
    exit 1
fi

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")/.."

cd "$PROJECT_DIR"

log_info "Checking Kubernetes connection..."
if ! kubectl cluster-info &> /dev/null; then
    log_error "Cannot connect to Kubernetes cluster"
    exit 1
fi

# 创建命名空间
log_info "Creating namespace..."
kubectl apply -f config/k8s/base/namespace.yaml

# 部署 MySQL
log_info "Deploying MySQL..."
kubectl apply -f config/k8s/components/mysql/

# 等待 MySQL 就绪
log_info "Waiting for MySQL to be ready..."
kubectl wait --for=condition=ready pod -l app=mysql -n nexora-infra --timeout=300s || log_warn "MySQL startup timeout"

# 部署 Redis
log_info "Deploying Redis..."
kubectl apply -f config/k8s/components/redis/

# 等待 Redis 就绪
log_info "Waiting for Redis to be ready..."
kubectl wait --for=condition=ready pod -l app=redis -n nexora-infra --timeout=180s || log_warn "Redis startup timeout"

# 部署 Elasticsearch
log_info "Deploying Elasticsearch..."
kubectl apply -f config/k8s/components/elasticsearch/

# 等待 Elasticsearch 就绪
log_info "Waiting for Elasticsearch to be ready..."
kubectl wait --for=condition=ready pod -l app=elasticsearch -n nexora-infra --timeout=300s || log_warn "Elasticsearch startup timeout"

# 部署 Kibana
log_info "Deploying Kibana..."
kubectl apply -f config/k8s/components/kibana/

# 部署 Nacos
log_info "Deploying Nacos..."
kubectl apply -f config/k8s/components/nacos/

# 等待 Nacos 就绪
log_info "Waiting for Nacos to be ready..."
kubectl wait --for=condition=ready pod -l app=nacos -n nexora-infra --timeout=300s || log_warn "Nacos startup timeout"

# 部署 Sentinel
log_info "Deploying Sentinel..."
kubectl apply -f config/k8s/components/sentinel/

# 部署 Seata
log_info "Deploying Seata..."
kubectl apply -f config/k8s/components/seata/

# 部署 ZooKeeper
log_info "Deploying ZooKeeper..."
kubectl apply -f config/k8s/components/zookeeper/

# 等待 ZooKeeper 就绪
log_info "Waiting for ZooKeeper to be ready..."
kubectl wait --for=condition=ready pod -l app=zookeeper -n nexora-infra --timeout=180s || log_warn "ZooKeeper startup timeout"

# 部署 Kafka
log_info "Deploying Kafka..."
kubectl apply -f config/k8s/components/kafka/

# 等待 Kafka 就绪
log_info "Waiting for Kafka to be ready..."
kubectl wait --for=condition=ready pod -l app=kafka -n nexora-infra --timeout=300s || log_warn "Kafka startup timeout"

# 部署 Kafka UI
log_info "Deploying Kafka UI..."

# 部署 ElasticJob UI
log_info "Deploying ElasticJob UI..."
kubectl apply -f config/k8s/components/elasticjob/

# 查看部署状态
echo ""
log_info "Checking deployment status..."
kubectl get all -n nexora-infra

echo ""
echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo ""
echo "Services:"
echo "  MySQL:       mysql.nexora-infra.svc.cluster.local:3306"
echo "  Redis:       redis.nexora-infra.svc.cluster.local:6379"
echo "  Elasticsearch: elasticsearch.nexora-infra.svc.cluster.local:9200"
echo "  Kibana:      kibana.nexora-infra.svc.cluster.local:5601"
echo "  Nacos:       nacos.nexora-infra.svc.cluster.local:8848"
echo "  Sentinel:    sentinel.nexora-infra.svc.cluster.local:8858"
echo "  Seata:       seata-server.nexora-infra.svc.cluster.local:8091"
echo "  ZooKeeper:   zookeeper.nexora-infra.svc.cluster.local:2181"
echo "  Kafka:       kafka.nexora-infra.svc.cluster.local:9092"
echo "  Kafka UI:    kafka-ui.nexora-infra.svc.cluster.local:8080"
echo "  ElasticJob:  elasticjob-ui.nexora-infra.svc.cluster.local:8088"
echo ""
echo "View status:"
echo "  kubectl get all -n nexora-infra"
echo ""
echo "View logs:"
echo "  kubectl logs -f deployment/<deployment-name> -n nexora-infra"
echo ""
