#!/bin/bash
set -e

# 需要认证的压测脚本
# 先获取 Token，然后进行压测

TARGET_URL=${TARGET_URL:-http://localhost:40004}
USERNAME=${USERNAME:-test@example.com}
PASSWORD=${PASSWORD:-password}

echo "=========================================="
echo "认证压测 - 获取 Token 中..."
echo "=========================================="

# 获取 Token
TOKEN_RESPONSE=$(curl -s -X POST "${TARGET_URL}/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"${USERNAME}\",\"password\":\"${PASSWORD}\"}")

TOKEN=$(echo $TOKEN_RESPONSE | grep -o '"token":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    echo "错误: 无法获取 Token"
    echo "响应: $TOKEN_RESPONSE"
    exit 1
fi

echo "Token 获取成功!"
echo "开始认证压测..."
echo ""

# 使用 Token 运行压测
export TOKEN
export TARGET_URL

SCRIPT_DIR="$(dirname "$0")"
"$SCRIPT_DIR/load-test.sh" -s load "$@"
