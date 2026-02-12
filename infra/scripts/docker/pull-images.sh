#!/bin/bash
# Docker 镜像预下载脚本
# 从 docker-compose.yml 动态读取镜像列表

set -e

echo "=========================================="
echo "   Nexora 镜像预下载"
echo "=========================================="
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$PROJECT_DIR"

# 检查 docker-compose.yml 是否存在
if [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}Error: docker-compose.yml not found in $PROJECT_DIR${NC}"
    exit 1
fi

# 从 docker-compose.yml 提取镜像列表
echo -e "${YELLOW}从 docker-compose.yml 读取镜像列表...${NC}"
echo ""

# 使用 docker compose config 或者直接解析 yml 提取镜像
# 使用 grep + sed 提取所有 image: 行的值
IMAGES=$(grep -E "^\s+image:\s" docker-compose.yml | sed 's/.*image:\s*//' | sed 's/\s*$//' | sort -u)

if [ -z "$IMAGES" ]; then
    echo -e "${RED}Error: 未能从 docker-compose.yml 提取到镜像列表${NC}"
    exit 1
fi

# 转换为数组
TOTAL=0
IMAGE_ARRAY=()
while IFS= read -r image; do
    [ -n "$image" ] && IMAGE_ARRAY+=("$image") && TOTAL=$((TOTAL + 1))
done <<< "$IMAGES"

echo -e "${YELLOW}准备下载 ${TOTAL} 个镜像...${NC}"
echo ""

CURRENT=0
SUCCESS_COUNT=0
FAILED_COUNT=0

for image in "${IMAGE_ARRAY[@]}"; do
    CURRENT=$((CURRENT + 1))
    echo -e "${GREEN}[${CURRENT}/${TOTAL}]${NC} 拉取: ${image}"

    if docker pull "$image"; then
        echo -e "${GREEN}  ✓ 成功${NC}"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        echo -e "${RED}  ✗ 失败${NC}"
        FAILED_COUNT=$((FAILED_COUNT + 1))
    fi
    echo ""
done

echo "=========================================="
echo -e "${GREEN}镜像下载完成！${NC}"
echo "=========================================="
echo ""
echo "成功: ${SUCCESS_COUNT}/${TOTAL}"
if [ $FAILED_COUNT -gt 0 ]; then
    echo -e "${RED}失败: ${FAILED_COUNT}/${TOTAL}${NC}"
fi
echo ""
echo "下一步："
echo "  ./scripts/docker/start.sh"
echo ""
