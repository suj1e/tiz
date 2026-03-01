#!/bin/bash
# Tiz Infrastructure Manager
# 只管理基础设施: MySQL, Redis, Elasticsearch, Nacos, Kafka

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/docker-compose.yml"
NETWORK_NAME="npass"

# 检查 Docker
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Error: Docker is not installed${NC}"
        exit 1
    fi
    if ! docker info &> /dev/null; then
        echo -e "${RED}Error: Docker is not running${NC}"
        exit 1
    fi
}

# 检查/创建网络
ensure_network() {
    if ! docker network ls | grep -q "$NETWORK_NAME"; then
        echo -e "${YELLOW}Creating network: $NETWORK_NAME${NC}"
        docker network create "$NETWORK_NAME"
        echo -e "${GREEN}✓ Network created${NC}"
    fi
}

# 打印访问信息
print_access_info() {
    echo ""
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}   Access URLs${NC}"
    echo -e "${BLUE}=========================================${NC}"

    if docker ps --format '{{.Names}}' | grep -q "tiz-mysql"; then
        echo -e "${GREEN}✓ MySQL: localhost:30001 (root/Tiz@2026)${NC}"
    fi
    if docker ps --format '{{.Names}}' | grep -q "tiz-redis"; then
        echo -e "${GREEN}✓ Redis: localhost:30002 (password: Tiz@2026)${NC}"
    fi
    if docker ps --format '{{.Names}}' | grep -q "tiz-elasticsearch"; then
        echo -e "${GREEN}✓ Elasticsearch: localhost:30003 (elastic/Tiz@2026)${NC}"
    fi
    if docker ps --format '{{.Names}}' | grep -q "tiz-nacos"; then
        echo -e "${GREEN}✓ Nacos Console: http://localhost:30006 (nacos/nacos)${NC}"
    fi
    if docker ps --format '{{.Names}}' | grep -q "tiz-kafka"; then
        echo -e "${GREEN}✓ Kafka: localhost:30009${NC}"
    fi
    if docker ps --format '{{.Names}}' | grep -q "tiz-kafka-ui"; then
        echo -e "${GREEN}✓ Kafka UI: http://localhost:30010${NC}"
    fi
}

# 启动服务
start() {
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}   Tiz Infrastructure${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo ""

    check_docker
    ensure_network

    echo ""
    echo -e "${GREEN}Starting services...${NC}"
    docker-compose -f "$COMPOSE_FILE" up -d

    echo ""
    print_access_info
}

# 停止服务
stop() {
    echo -e "${YELLOW}Stopping services...${NC}"
    docker-compose -f "$COMPOSE_FILE" down
    echo -e "${GREEN}✓ Services stopped${NC}"
}

# 查看状态
status() {
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}   Service Status${NC}"
    echo -e "${BLUE}=========================================${NC}"
    docker-compose -f "$COMPOSE_FILE" ps 2>/dev/null || echo "No services running"
    print_access_info
}

# 查看日志
logs() {
    local service=$1
    if [ -n "$service" ]; then
        docker-compose -f "$COMPOSE_FILE" logs -f "$service"
    else
        docker-compose -f "$COMPOSE_FILE" logs -f
    fi
}

# 主入口
case "${1:-}" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        sleep 2
        start
        ;;
    status)
        status
        ;;
    logs)
        logs "$2"
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|logs}"
        echo ""
        echo "Commands:"
        echo "  start     Start all infrastructure services"
        echo "  stop      Stop all services"
        echo "  restart   Restart all services"
        echo "  status    Show service status and access URLs"
        echo "  logs      View logs (optional: specify service name)"
        echo ""
        echo "Services: mysql, redis, elasticsearch, nacos, kafka, kafka-ui"
        echo ""
        echo "Examples:"
        echo "  $0 start"
        echo "  $0 logs mysql"
        echo "  $0 status"
        exit 1
        ;;
esac
