#!/bin/bash
# Tiz Infrastructure Manager
# 管理基础设施: MySQL, Redis, Elasticsearch, Nacos, Kafka
# 支持多环境: dev (默认), staging, prod

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NETWORK_NAME="npass"

# 默认环境
ENV="dev"

# 验证环境参数
validate_env() {
    case $1 in
        dev|staging|prod)
            return 0
            ;;
        *)
            echo -e "${RED}Error: Invalid environment '$1'. Must be: dev, staging, or prod${NC}"
            exit 1
            ;;
    esac
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

# 检查 .env 文件
check_env_file() {
    local env_dir="$SCRIPT_DIR/envs/$ENV"
    if [ ! -f "$env_dir/.env" ]; then
        if [ -f "$env_dir/.env.example" ]; then
            echo -e "${RED}Error: .env file not found in $env_dir/${NC}"
            echo -e "${YELLOW}Please copy .env.example to .env and configure it:${NC}"
            echo "  cp $env_dir/.env.example $env_dir/.env"
            exit 1
        else
            echo -e "${RED}Error: No .env file found in $env_dir/${NC}"
            exit 1
        fi
    fi
}

# 获取 compose 文件路径
get_compose_file() {
    echo "$SCRIPT_DIR/envs/$ENV/docker-compose.yml"
}

# 打印访问信息
print_access_info() {
    echo ""
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}   Access URLs ($ENV)${NC}"
    echo -e "${BLUE}=========================================${NC}"

    # dev 和 staging 环境显示端口映射
    if [ "$ENV" = "dev" ] || [ "$ENV" = "staging" ]; then
        if docker ps --format '{{.Names}}' | grep -q "tiz-mysql"; then
            echo -e "${GREEN}✓ MySQL: localhost:30001${NC}"
        fi
        if docker ps --format '{{.Names}}' | grep -q "tiz-redis"; then
            echo -e "${GREEN}✓ Redis: localhost:30002${NC}"
        fi
        if docker ps --format '{{.Names}}' | grep -q "tiz-elasticsearch"; then
            echo -e "${GREEN}✓ Elasticsearch: localhost:30003${NC}"
        fi
        if docker ps --format '{{.Names}}' | grep -q "tiz-nacos"; then
            echo -e "${GREEN}✓ Nacos Console: http://localhost:30006${NC}"
            echo -e "${GREEN}✓ Nacos API: localhost:30848${NC}"
        fi
        if docker ps --format '{{.Names}}' | grep -q "tiz-kafka"; then
            echo -e "${GREEN}✓ Kafka: localhost:30009${NC}"
        fi
        if docker ps --format '{{.Names}}' | grep -q "tiz-kafka-ui"; then
            echo -e "${GREEN}✓ Kafka UI: http://localhost:30010${NC}"
        fi
    else
        # prod 环境，服务仅在 Docker 网络内可访问
        echo -e "${GREEN}✓ Services running in 'npass' network${NC}"
        echo -e "${YELLOW}  MySQL: mysql:3306${NC}"
        echo -e "${YELLOW}  Redis: redis:6379${NC}"
        echo -e "${YELLOW}  Elasticsearch: elasticsearch:9200${NC}"
        echo -e "${YELLOW}  Nacos: nacos:8080${NC}"
        echo -e "${YELLOW}  Kafka: kafka:9092${NC}"
    fi
}

# 启动服务
start() {
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}   Tiz Infrastructure ($ENV)${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo ""

    check_docker
    check_env_file
    ensure_network

    local COMPOSE_FILE=$(get_compose_file)
    local ENV_DIR="$SCRIPT_DIR/envs/$ENV"

    echo ""
    echo -e "${GREEN}Starting services...${NC}"
    docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_DIR/.env" up -d

    echo ""
    print_access_info
}

# 停止服务
stop() {
    local COMPOSE_FILE=$(get_compose_file)
    local ENV_DIR="$SCRIPT_DIR/envs/$ENV"

    echo -e "${YELLOW}Stopping services ($ENV)...${NC}"
    docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_DIR/.env" down
    echo -e "${GREEN}✓ Services stopped${NC}"
}

# 查看状态
status() {
    local COMPOSE_FILE=$(get_compose_file)
    local ENV_DIR="$SCRIPT_DIR/envs/$ENV"

    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}   Service Status ($ENV)${NC}"
    echo -e "${BLUE}=========================================${NC}"
    docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_DIR/.env" ps 2>/dev/null || echo "No services running"
    print_access_info
}

# 查看日志
logs() {
    local service=$1
    local COMPOSE_FILE=$(get_compose_file)
    local ENV_DIR="$SCRIPT_DIR/envs/$ENV"

    if [ -n "$service" ]; then
        docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_DIR/.env" logs -f "$service"
    else
        docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_DIR/.env" logs -f
    fi
}

# 解析参数
COMMAND=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --env|-e)
            ENV="$2"
            validate_env "$ENV"
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
        echo "Usage: $0 {start|stop|restart|status|logs} [--env dev|staging|prod]"
        echo ""
        echo "Commands:"
        echo "  start     Start all infrastructure services"
        echo "  stop      Stop all services"
        echo "  restart   Restart all services"
        echo "  status    Show service status and access URLs"
        echo "  logs      View logs (optional: specify service name)"
        echo ""
        echo "Options:"
        echo "  --env, -e   Environment: dev (default), staging, prod"
        echo ""
        echo "Services: mysql, redis, elasticsearch, nacos, kafka"
        echo ""
        echo "Examples:"
        echo "  $0 start                    # Start dev environment"
        echo "  $0 start --env staging      # Start staging environment"
        echo "  $0 logs mysql --env prod    # View MySQL logs in prod"
        echo "  $0 status"
        exit 1
        ;;
esac
