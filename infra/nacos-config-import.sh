#!/bin/bash
# Nacos Config Import Script
# Usage: NACOS_ENV=dev NACOS_ADDR=localhost:30006 ./nacos-config-import.sh

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ENV=${NACOS_ENV:-dev}
NACOS_ADDR=${NACOS_ADDR:-localhost:30006}
NACOS_USER=${NACOS_USER:-nacos}
NACOS_PASS=${NACOS_PASS:-nacos}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/../deploy/nacos-config/$ENV"

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}   Nacos Config Import${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo "Environment: $ENV"
echo "Nacos address: $NACOS_ADDR"
echo "Config directory: $CONFIG_DIR"
echo ""

# 检查配置目录
if [ ! -d "$CONFIG_DIR" ]; then
    echo -e "${RED}Error: Config directory not found: $CONFIG_DIR${NC}"
    exit 1
fi

# 创建 namespace
create_namespace() {
    echo -e "${YELLOW}Creating namespace: $ENV${NC}"
    curl -s -X POST "http://$NACOS_ADDR/nacos/v1/console/namespaces" \
        -d "customNamespaceId=$ENV" \
        -d "namespaceName=$ENV" \
        -d "namespaceDesc=$ENV environment" >/dev/null 2>&1 || true
    echo -e "${GREEN}✓ Namespace ready${NC}"
}

# 导入单个配置文件
import_config() {
    local file=$1
    local data_id=$(basename "$file")
    local content=$(cat "$file")

    echo -e "  ${YELLOW}Importing:${NC} $data_id"

    local response
    response=$(curl -s -w "\n%{http_code}" -X POST "http://$NACOS_ADDR/nacos/v1/cs/configs" \
        -d "dataId=$data_id" \
        -d "group=DEFAULT_GROUP" \
        -d "tenant=$ENV" \
        --data-urlencode "content=$content" \
        -d "type=yaml")

    local http_code=$(echo "$response" | tail -n1)
    if [ "$http_code" = "200" ]; then
        echo -e "    ${GREEN}✓ $data_id imported${NC}"
    else
        echo -e "    ${RED}✗ Failed to import $data_id (HTTP $http_code)${NC}"
    fi
}

# 主流程
create_namespace

echo ""
echo -e "${YELLOW}Importing config files...${NC}"

for file in "$CONFIG_DIR"/*.yaml; do
    if [ -f "$file" ]; then
        import_config "$file"
    fi
done

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}   Import completed!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo "View configs at: http://$NACOS_ADDR/nacos/"
echo "Namespace: $ENV"
