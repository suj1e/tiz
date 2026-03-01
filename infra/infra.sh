#!/bin/bash
# Tiz Infrastructure Manager
# Usage: ./infra.sh [start|stop|status|logs] [--env dev|prod]

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 默认环境
ENV="dev"

# 解析参数
COMMAND=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --env|-e)
            ENV="$2"
            shift 2
            ;;
        start|stop|restart|status|logs)
            COMMAND="$1"
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# 根据环境选择配置
case $ENV in
    dev)
        COMPOSE_FILE="$SCRIPT_DIR/docker-compose.yml"
        NETWORK_NAME="npass"
        ;;
    prod)
        COMPOSE_FILE="$SCRIPT_DIR/../deploy/docker-compose.yml"
        NETWORK_NAME="npass"
        ;;
    *)
        echo -e "${RED}Error: Unknown environment '$ENV'. Use 'dev' or 'prod'.${NC}"
        exit 1
        ;;
esac

# 服务访问信息
print_access_info() {
    echo ""
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}   Access URLs ($ENV)${NC}"
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
    if docker ps --format '{{.Names}}' | grep -q "tiz-web"; then
        echo -e "${GREEN}✓ Web: http://localhost:80${NC}"
    fi
    if docker ps --format '{{.Names}}' | grep -q "tiz-gatewaysrv"; then
        echo -e "${GREEN}✓ Gateway: http://localhost:8080${NC}"
    fi
}

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
    echo -e "${BLUE}   Tiz Infrastructure ($ENV)${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo ""

    check_docker

    if [ "$ENV" = "dev" ]; then
        ensure_network
    fi

    echo ""
    echo -e "${GREEN}Starting services...${NC}"

    if [ -f "$COMPOSE_FILE" ]; then
        docker-compose -f "$COMPOSE_FILE" up -d
    else
        echo -e "${RED}Error: Compose file not found: $COMPOSE_FILE${NC}"
        exit 1
    fi

    if [ "$ENV" = "dev" ]; then
        echo ""
        echo -e "${YELLOW}Waiting for services to be ready...${NC}"

        for svc in mysql redis; do
            if wait_for_service $svc 30; then
                echo -e "${GREEN}✓ $svc is ready${NC}"
            else
                echo -e "${RED}✗ $svc failed to start${NC}"
            fi
        done

        sleep 10
        for svc in elasticsearch nacos kafka; do
            if wait_for_service $svc 60; then
                echo -e "${GREEN}✓ $svc is ready${NC}"
            else
                echo -e "${YELLOW}⚠ $svc is still starting${NC}"
            fi
        done
    fi

    print_access_info
}

# 停止服务
stop() {
    echo -e "${YELLOW}Stopping services ($ENV)...${NC}"
    docker-compose -f "$COMPOSE_FILE" down
    echo -e "${GREEN}✓ Services stopped${NC}"
}

# 查看状态
status() {
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}   Service Status ($ENV)${NC}"
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

# 显示帮助
show_help() {
    echo "Usage: $0 {start|stop|restart|status|logs} [--env dev|prod]"
    echo ""
    echo "Commands:"
    echo "  start     Start all services"
    echo "  stop      Stop all services"
    echo "  restart   Restart all services"
    echo "  status    Show service status"
    echo "  logs      View logs (optional: specify service name)"
    echo ""
    echo "Options:"
    echo "  --env, -e   Environment: dev (default) or prod"
    echo ""
    echo "Examples:"
    echo "  $0 start                    # Start dev environment"
    echo "  $0 start --env prod         # Start prod environment"
    echo "  $0 logs mysql --env dev     # View MySQL logs in dev"
    echo "  $0 stop --env prod          # Stop prod environment"
    exit 0
}

# 主入口
case "$COMMAND" in
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
        logs "$1"
        ;;
    "")
        show_help
        ;;
    *)
        show_help
        ;;
esac
