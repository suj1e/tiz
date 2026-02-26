#!/bin/bash
# Tiz 基础设施健康检查脚本

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo "   Tiz Infrastructure Health Check"
echo "=========================================="
echo ""

# 使用 docker compose 还是 docker-compose
if docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$PROJECT_DIR"

# 检查各服务
check_service() {
    local service=$1
    local check_cmd=$2
    local name=$3

    echo -n "  $name: "
    if eval "$check_cmd" &> /dev/null; then
        echo -e "${GREEN}OK${NC}"
        return 0
    else
        echo -e "${RED}FAILED${NC}"
        return 1
    fi
}

echo "Database & Cache:"
check_service "mysql" "$DOCKER_COMPOSE exec -T mysql mysqladmin ping -h localhost -u root -pTiz@2026" "MySQL"
check_service "redis" "$DOCKER_COMPOSE exec -T redis redis-cli ping" "Redis"

echo ""
echo "Search & Analytics:"
check_service "elasticsearch" "$DOCKER_COMPOSE exec -T elasticsearch curl -s -u elastic:Tiz@2026 http://localhost:9200/_cluster/health" "Elasticsearch"
check_service "kibana" "$DOCKER_COMPOSE exec -T kibana curl -s http://localhost:5601/api/status" "Kibana"

echo ""
echo "Service Discovery & Config:"
check_service "nacos" "$DOCKER_COMPOSE exec -T nacos curl -s http://localhost:8080/" "Nacos"

echo ""
echo "Event Bus (Kafka KRaft):"
check_service "kafka" "$DOCKER_COMPOSE exec -T kafka kafka-broker-api-versions --bootstrap-server localhost:9094 2>&1" "Kafka"

echo ""
echo "Observability:"
check_service "tempo" "$DOCKER_COMPOSE exec -T tempo curl -s http://localhost:3200/status" "Tempo"
check_service "grafana" "$DOCKER_COMPOSE exec -T grafana curl -s http://localhost:3000/api/health" "Grafana"

echo ""
echo "Management UI:"
check_service "kafka-ui" "$DOCKER_COMPOSE exec -T kafka-ui curl -s -f http://localhost:8080/ -o /dev/null" "Kafka UI"

echo ""
echo "=========================================="
echo "Docker Containers Status:"
echo "=========================================="
$DOCKER_COMPOSE ps

echo ""
echo "=========================================="
echo "Resource Usage:"
echo "=========================================="
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"

echo ""
