#!/bin/bash
# Tiz 基础设施一键启动脚本 (轻量版)

set -e

echo "=========================================="
echo "   Tiz Infrastructure (Lite)"
echo "   Event-Driven Architecture"
echo "=========================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 检查Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed${NC}"
    echo "Please install Docker first: https://docs.docker.com/engine/install/"
    exit 1
fi

# 检查Docker Compose
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}Error: Docker Compose is not installed${NC}"
    echo "Please install Docker Compose first: https://docs.docker.com/compose/install/"
    exit 1
fi

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

echo -e "${YELLOW}Working directory: $PROJECT_DIR${NC}"
echo ""

# 检查必要文件
if [ ! -f "docker-compose-lite.yml" ]; then
    echo -e "${RED}Error: docker-compose-lite.yml not found in $PROJECT_DIR${NC}"
    exit 1
fi

# 创建必要的目录
echo -e "${YELLOW}Creating directories...${NC}"
mkdir -p config/docker/nacos/logs
mkdir -p backups

# 检查系统参数
echo ""
echo -e "${YELLOW}Checking system parameters...${NC}"
if [ "$(sysctl -n vm.max_map_count)" -lt 262144 ]; then
    echo -e "${RED}Warning: vm.max_map_count is too low for Elasticsearch${NC}"
    echo "Run: sudo sysctl -w vm.max_map_count=262144"
    echo "Make it permanent: echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 第一批启动：核心数据库服务
echo ""
echo "=========================================="
echo -e "${GREEN}Phase 1: Starting Core Services${NC}"
echo "=========================================="
echo "Starting MySQL and Redis..."
$DOCKER_COMPOSE -f docker-compose-lite.yml up -d mysql redis --pull never

echo ""
echo -e "${YELLOW}Waiting for MySQL to be ready (30s)...${NC}"
sleep 30

# 检查MySQL
if $DOCKER_COMPOSE -f docker-compose-lite.yml exec -T mysql mysqladmin ping -h localhost -u root -pTiz@2026 &> /dev/null; then
    echo -e "${GREEN}MySQL is ready!${NC}"
else
    echo -e "${RED}MySQL failed to start${NC}"
    exit 1
fi

# 检查Redis
if $DOCKER_COMPOSE -f docker-compose-lite.yml exec -T redis redis-cli ping &> /dev/null; then
    echo -e "${GREEN}Redis is ready!${NC}"
else
    echo -e "${RED}Redis failed to start${NC}"
    exit 1
fi

# 第二批启动：Elasticsearch
echo ""
echo "=========================================="
echo -e "${GREEN}Phase 2: Starting Elasticsearch${NC}"
echo "=========================================="
echo "Starting Elasticsearch (this may take 1-2 minutes)..."
$DOCKER_COMPOSE -f docker-compose-lite.yml up -d elasticsearch --pull never

echo ""
echo -e "${YELLOW}Waiting for Elasticsearch to be ready (60s)...${NC}"
sleep 60

# 检查Elasticsearch
for i in {1..10}; do
    if $DOCKER_COMPOSE -f docker-compose-lite.yml exec -T elasticsearch curl -s -u elastic:Tiz@2026 http://localhost:9200/_cluster/health &> /dev/null; then
        echo -e "${GREEN}Elasticsearch is ready!${NC}"
        break
    fi
    if [ $i -eq 10 ]; then
        echo -e "${RED}Elasticsearch failed to start${NC}"
        exit 1
    fi
    echo -e "${YELLOW}Still waiting... ($i/10)${NC}"
    sleep 10
done

# 第三批启动：中间件服务
echo ""
echo "=========================================="
echo -e "${GREEN}Phase 3: Starting Middleware Services${NC}"
echo "=========================================="
echo "Starting Nacos, Kafka..."
$DOCKER_COMPOSE -f docker-compose-lite.yml up -d nacos kafka --pull never

echo ""
echo -e "${YELLOW}Waiting for services to be ready (40s)...${NC}"
sleep 40

# 检查Nacos
if $DOCKER_COMPOSE -f docker-compose-lite.yml exec -T nacos curl -s http://localhost:8080/ &> /dev/null; then
    echo -e "${GREEN}Nacos is ready!${NC}"
else
    echo -e "${YELLOW}Nacos is still starting...${NC}"
fi

# 检查Kafka
if $DOCKER_COMPOSE -f docker-compose-lite.yml exec -T kafka kafka-broker-api-versions --bootstrap-server localhost:9094 &> /dev/null; then
    echo -e "${GREEN}Kafka is ready!${NC}"
else
    echo -e "${YELLOW}Kafka is still starting...${NC}"
fi

# 第四批启动：UI工具
echo ""
echo "=========================================="
echo -e "${GREEN}Phase 4: Starting UI Tools${NC}"
echo "=========================================="
echo "Starting Kafka UI..."
$DOCKER_COMPOSE -f docker-compose-lite.yml up -d kafka-ui --pull never

echo ""
echo -e "${YELLOW}Waiting for UI services (20s)...${NC}"
sleep 20

# 最终状态检查
echo ""
echo "=========================================="
echo -e "${GREEN}Deployment Status${NC}"
echo "=========================================="
$DOCKER_COMPOSE -f docker-compose-lite.yml ps

echo ""
echo "=========================================="
echo -e "${GREEN}Deployment Complete!${NC}"
echo "=========================================="
echo ""
echo "Access URLs:"
echo "  MySQL:          localhost:30001 (root/Tiz@2026)"
echo "  Redis:          localhost:30002 (password: Tiz@2026)"
echo "  Elasticsearch:  localhost:30003 (elastic/Tiz@2026)"
echo "  Nacos:          http://localhost:30006 (nacos/nacos)"
echo "  Kafka:          localhost:30009"
echo "  Kafka UI:       http://localhost:30010"
echo ""
echo "Lite mode - removed for business focus:"
echo "  Kibana, Filebeat, Prometheus, Grafana, Tempo"
echo ""
echo -e "${YELLOW}Tip: Use 'docker-compose -f docker-compose-lite.yml ps' to check status${NC}"
echo ""
