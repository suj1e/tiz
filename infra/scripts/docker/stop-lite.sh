#!/bin/bash
# Nexora 基础设施一键停止脚本 (轻量版)

set -e

echo "=========================================="
echo "   Stopping Nexora Infrastructure (Lite)"
echo "=========================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

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

# 停止轻量版服务
echo -e "${YELLOW}Stopping lite services...${NC}"
$DOCKER_COMPOSE -f docker-compose-lite.yml down

echo ""
echo -e "${GREEN}All lite services stopped!${NC}"
echo ""
echo "To remove volumes as well, run:"
echo "  $DOCKER_COMPOSE -f docker-compose-lite.yml down -v"
echo ""
