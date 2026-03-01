#!/bin/bash
# Tiz Dev Infrastructure Manager
# Usage: ./dev-infra.sh [start|stop|status|logs|import]

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

# 服务访问信息
declare -A SERVICE_INFO=(
    ["mysql"]="MySQL: localhost:30001 (root/Tiz@2026)"
    ["redis"]="Redis: localhost:30002 (password: Tiz@2026)"
    ["elasticsearch"]="Elasticsearch: localhost:30003 (elastic/Tiz@2026)"
    ["nacos"]="Nacos Console: http://localhost:30006 (nacos/nacos)"
    ["kafka"]="Kafka: localhost:30009"
    ["kafka-ui"]="Kafka UI: http://localhost:30010"
)

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

# 等待服务就绪
wait_for_service() {
    local service=$1
    local max_retries=${2:-30}
    local retry=0

    echo -e "${YELLOW}Waiting for $service to be ready...${NC}"
    while [ $retry -lt $max_retries ]; do
        case $service in
            mysql)
                if docker exec tiz-mysql mysqladmin ping -h localhost -u root -pTiz@2026 &> /dev/null; then
                    return 0
                fi
                ;;
            redis)
                if docker exec tiz-redis redis-cli -a Tiz@2026 ping 2>/dev/null | grep -q PONG; then
                    return 0
                fi
                ;;
            nacos)
                if curl -s http://localhost:30006/nacos/ &> /dev/null; then
                    return 0
                fi
                ;;
            elasticsearch)
                if curl -s -u elastic:Tiz@2026 http://localhost:30003/_cluster/health &> /dev/null; then
                    return 0
                fi
                ;;
            kafka)
                if docker exec tiz-kafka kafka-broker-api-versions --bootstrap-server localhost:9094 &> /dev/null; then
                    return 0
                fi
                ;;
        esac
        retry=$((retry + 1))
        sleep 2
    done
    return 1
}

# 启动服务
start() {
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}   Tiz Dev Infrastructure${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo ""

    check_docker
    ensure_network

    echo ""
    echo -e "${GREEN}Starting services...${NC}"
    docker-compose -f "$COMPOSE_FILE" up -d

    echo ""
    echo -e "${YELLOW}Waiting for services to be ready...${NC}"

    # 等待核心服务
    for svc in mysql redis; do
        if wait_for_service $svc 30; then
            echo -e "${GREEN}✓ $svc is ready${NC}"
        else
            echo -e "${RED}✗ $svc failed to start${NC}"
        fi
    done

    # 等待中间件
    sleep 10
    for svc in elasticsearch nacos kafka; do
        if wait_for_service $svc 60; then
            echo -e "${GREEN}✓ $svc is ready${NC}"
        else
            echo -e "${YELLOW}⚠ $svc is still starting${NC}"
        fi
    done

    echo ""
    print_status
}

# 停止服务
stop() {
    echo -e "${YELLOW}Stopping services...${NC}"
    docker-compose -f "$COMPOSE_FILE" down
    echo -e "${GREEN}✓ Services stopped${NC}"
}

# 查看状态
status() {
    print_status
}

print_status() {
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}   Service Status${NC}"
    echo -e "${BLUE}=========================================${NC}"
    docker-compose -f "$COMPOSE_FILE" ps 2>/dev/null || echo "No services running"

    echo ""
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}   Access URLs${NC}"
    echo -e "${BLUE}=========================================${NC}"
    for svc in "${!SERVICE_INFO[@]}"; do
        if docker ps --format '{{.Names}}' | grep -q "tiz-$svc"; then
            echo -e "${GREEN}✓ ${SERVICE_INFO[$svc]}${NC}"
        fi
    done
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

# 导入 Nacos 配置
import_config() {
    local env=${1:-dev}
    local import_script="$SCRIPT_DIR/nacos-config-import.sh"

    if [ ! -f "$import_script" ]; then
        echo -e "${RED}Error: $import_script not found${NC}"
        exit 1
    fi

    echo -e "${YELLOW}Importing Nacos config for environment: $env${NC}"

    # 等待 Nacos 就绪
    if ! wait_for_service nacos 30; then
        echo -e "${RED}Error: Nacos is not ready${NC}"
        exit 1
    fi

    # 执行导入
    NACOS_ENV=$env NACOS_ADDR=localhost:30006 bash "$import_script"
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
    import)
        import_config "$2"
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|logs|import}"
        echo ""
        echo "Commands:"
        echo "  start     Start all infrastructure services"
        echo "  stop      Stop all services"
        echo "  restart   Restart all services"
        echo "  status    Show service status and access URLs"
        echo "  logs      View logs (optional: specify service name)"
        echo "  import    Import Nacos config (optional: specify env, default: dev)"
        echo ""
        echo "Examples:"
        echo "  $0 start"
        echo "  $0 logs mysql"
        echo "  $0 import dev"
        exit 1
        ;;
esac
