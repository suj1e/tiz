#!/bin/sh
# Nacos 配置导入脚本 (容器内运行)
# 环境变量: NACOS_ENV, NACOS_ADDR, NACOS_USER, NACOS_PASS

set -e

ENV=${NACOS_ENV:-prod}
NACOS_ADDR=${NACOS_ADDR:-nacos:8080}
NACOS_USER=${NACOS_USER:-nacos}
NACOS_PASS=${NACOS_PASS:-nacos}
CONFIG_DIR="/configs/$ENV"

echo "=== Nacos Config Import ==="
echo "Environment: $ENV"
echo "Nacos address: $NACOS_ADDR"
echo "Config directory: $CONFIG_DIR"
echo ""

# 等待 Nacos 就绪
wait_for_nacos() {
    echo "Waiting for Nacos to be ready..."
    local max_retries=30
    local retry=0
    while [ $retry -lt $max_retries ]; do
        if curl -s "http://$NACOS_ADDR/nacos/v1/console/health/readiness" 2>/dev/null | grep -q "UP"; then
            echo "  ✓ Nacos is ready"
            return 0
        fi
        retry=$((retry + 1))
        sleep 2
    done
    echo "  ✗ Nacos not ready after $max_retries attempts"
    exit 1
}

# 创建 namespace
create_namespace() {
    echo "Creating namespace: $ENV"
    curl -s -X POST "http://$NACOS_ADDR/nacos/v1/console/namespaces" \
        -d "customNamespaceId=$ENV" \
        -d "namespaceName=$ENV" \
        -d "namespaceDesc=$ENV environment" >/dev/null 2>&1 || true
    echo "  ✓ Namespace ready"
}

# 导入单个配置文件
import_config() {
    local file=$1
    local data_id=$(basename "$file")
    local content=$(cat "$file")

    echo "  Importing: $data_id"

    curl -s -X POST "http://$NACOS_ADDR/nacos/v1/cs/configs" \
        -d "dataId=$data_id" \
        -d "group=DEFAULT_GROUP" \
        -d "tenant=$ENV" \
        --data-urlencode "content=$content" \
        -d "type=yaml" >/dev/null

    if [ $? -eq 0 ]; then
        echo "    ✓ $data_id imported"
    else
        echo "    ✗ Failed to import $data_id"
    fi
}

# 主流程
wait_for_nacos
create_namespace

echo ""
echo "Importing config files..."

if [ -d "$CONFIG_DIR" ]; then
    for file in "$CONFIG_DIR"/*.yaml; do
        if [ -f "$file" ]; then
            import_config "$file"
        fi
    done
else
    echo "Warning: Config directory not found: $CONFIG_DIR"
fi

echo ""
echo "=== Import completed ==="
