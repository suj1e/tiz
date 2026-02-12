#!/bin/bash
set -e

# 默认配置
TARGET_URL=${TARGET_URL:-http://localhost:40006}
CONTEXT_PATH=${CONTEXT_PATH:-auth}
DURATION=${DURATION:-30s}
THREADS=${THREADS:-10}

echo "=========================================="
echo "Nexora Authsrv 快速基准测试"
echo "目标: $TARGET_URL"
echo "=========================================="

# 健康检查
echo "检查服务状态..."
HEALTH_URL="$TARGET_URL/$CONTEXT_PATH/actuator/health"
HEALTH_RESPONSE=$(curl -s "$HEALTH_URL" || echo "")

if [ -z "$HEALTH_RESPONSE" ]; then
    echo "错误: 服务不可用 ($HEALTH_URL)"
    exit 1
fi

HEALTH_STATUS=$(echo "$HEALTH_RESPONSE" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
echo "服务状态: $HEALTH_STATUS"

if [ "$HEALTH_STATUS" != "UP" ]; then
    echo "警告: 服务状态不是 UP"
fi

echo ""

# 测试端点列表
ENDPOINTS=(
    "/$CONTEXT_PATH/actuator/health:GET:健康检查"
    "/$CONTEXT_PATH/v1/register:POST:用户注册"
    "/$CONTEXT_PATH/v1/login:POST:用户登录"
)

# 检测可用的基准测试工具
if command -v wrk &> /dev/null; then
    TOOL="wrk"
elif command -v hey &> /dev/null; then
    TOOL="hey"
elif command -v ab &> /dev/null; then
    TOOL="ab"
else
    echo "错误: 未找到基准测试工具"
    echo ""
    echo "请安装以下工具之一:"
    echo "  brew install wrk   # 推荐"
    echo "  brew install hey"
    echo "  brew install ab"
    exit 1
fi

echo "使用工具: $TOOL"
echo ""

# 运行基准测试
for endpoint_info in "${ENDPOINTS[@]}"; do
    IFS=: read -r path method name <<< "$endpoint_info"
    URL="$TARGET_URL$path"

    echo "=========================================="
    echo "测试: $name ($method $path)"
    echo "=========================================="

    case "$TOOL" in
        wrk)
            if [ "$method" = "GET" ]; then
                wrk -t"$THREADS" -c"$((THREADS * 10))" -d"$DURATION" "$URL"
            else
                echo "wrk 仅支持 GET 请求，跳过..."
            fi
            ;;
        hey)
            if [ "$method" = "GET" ]; then
                hey -n "$((THREADS * 1000)) -c "$THREADS" -z "$DURATION" "$URL"
            else
                # POST 请求需要提供数据
                if [[ "$path" == *"login"* ]]; then
                    hey -n 1000 -c "$THREADS" -z "$DURATION" \
                        -m POST \
                        -H "Content-Type: application/json" \
                        -d '{"username":"admin","password":"admin123"}' \
                        "$URL"
                elif [[ "$path" == *"register"* ]]; then
                    hey -n 1000 -c "$THREADS" -z "$DURATION" \
                        -m POST \
                        -H "Content-Type: application/json" \
                        -d "{\"username\":\"test_$(date +%s)\",\"email\":\"test_$(date +%s)@example.com\",\"password\":\"Test@123456\"}" \
                        "$URL"
                else
                    echo "需要提供 POST 数据，跳过..."
                fi
            fi
            ;;
        ab)
            if [ "$method" = "GET" ]; then
                ab -n "$((THREADS * 1000)) -c "$THREADS" "$URL"
            else
                if [[ "$path" == *"login"* ]]; then
                    ab -n 1000 -c "$THREADS" \
                        -p <(echo '{"username":"admin","password":"admin123"}') \
                        -T "application/json" \
                        "$URL"
                elif [[ "$path" == *"register"* ]]; then
                    ab -n 1000 -c "$THREADS" \
                        -p <(echo "{\"username\":\"test_$(date +%s)\",\"email\":\"test_$(date +%s)@example.com\",\"password\":\"Test@123456\"}") \
                        -T "application/json" \
                        "$URL"
                else
                    echo "需要提供 POST 数据，跳过..."
                fi
            fi
            ;;
    esac

    echo ""
done

echo "=========================================="
echo "基准测试完成！"
echo "=========================================="
echo ""
echo "提示: 如需更详细的负载测试，请使用:"
echo "  ./load-test.sh -s smoke"
echo ""
