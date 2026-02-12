#!/bin/bash
set -e

# 快速性能基准测试
# 使用 wrk 或 ab (Apache Bench) 进行简单测试

TARGET_URL=${TARGET_URL:-http://localhost:40004}
DURATION=${DURATION:-30}
CONCURRENCY=${CONCURRENCY:-10}

echo "=========================================="
echo "快速性能基准测试"
echo "=========================================="

# 检测可用工具
if command -v wrk &> /dev/null; then
    TOOL="wrk"
elif command -v ab &> /dev/null; then
    TOOL="ab"
elif command -v hey &> /dev/null; then
    TOOL="hey"
else
    echo "错误: 需要安装压测工具"
    echo "安装选项:"
    echo "  brew install wrk   # 推荐"
    echo "  brew install ab"
    echo "  brew install hey"
    exit 1
fi

echo "使用工具: $TOOL"
echo "目标: $TARGET_URL"
echo "时长: ${DURATION}s"
echo "并发: $CONCURRENCY"
echo "=========================================="
echo ""

# 运行基准测试
case "$TOOL" in
    wrk)
        wrk -t4 -c"$CONCURRENCY" -d"$DURATION" "$TARGET_URL/actuator/health"
        ;;
    ab)
        ab -n 10000 -c "$CONCURRENCY" "$TARGET_URL/actuator/health"
        ;;
    hey)
        hey -n 10000 -c "$CONCURRENCY" "$TARGET_URL/actuator/health"
        ;;
esac

echo ""
echo "=========================================="
echo "基准测试完成!"
echo "=========================================="
echo ""
echo "详细压测请使用:"
echo "  ./load-test.sh -s load"
echo ""
echo "认证压测:"
echo "  ./load-test-auth.sh"
echo "=========================================="
