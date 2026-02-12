#!/bin/bash
set -e

# 默认配置
TARGET_URL=${TARGET_URL:-http://localhost:40004}
SCENARIO=${SCENARIO:-smoke}
VUS=${VUS:-10}
DURATION=${DURATION:-30s}
OUT_DIR=${OUT_DIR:-./reports}

echo "=========================================="
echo "Nexora Gateway 压力测试"
echo "目标: $TARGET_URL"
echo "场景: $SCENARIO"
echo "=========================================="

# 参数说明
usage() {
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -u, --url URL            目标服务 URL (默认: http://localhost:40004)"
    echo "  -s, --scenario SCENARIO   压测场景: smoke|load|stress|spike|soak (默认: smoke)"
    echo "  -v, --vus VUS            虚拟用户数 (仅自定义场景有效)"
    echo "  -d, --duration DURATION  测试时长 (仅自定义场景有效)"
    echo "  -o, --out DIR            报告输出目录 (默认: ./reports)"
    echo "  -h, --help               显示帮助信息"
    echo ""
    echo "场景说明:"
    echo "  smoke  - 冒烟测试 (10 VUs, 30s) - 验证基本功能"
    echo "  load   - 负载测试 (渐进式 10->100 VUs, 10min) - 模拟正常负载"
    echo "  stress - 压力测试 (渐进式 10->500 VUs, 15min) - 测试极限"
    echo "  spike  - 峰值测试 (突发 10->1000->10 VUs, 5min) - 测试突发流量"
    echo "  soak   - 浸泡测试 (100 VUs 持续 1小时) - 测试稳定性"
    echo "  custom - 自定义测试 (使用 -v 和 -d 参数)"
    echo ""
    echo "示例:"
    echo "  # 冒烟测试"
    echo "  $0 -s smoke"
    echo ""
    echo "  # 负载测试"
    echo "  $0 -s load -u http://api.example.com"
    echo ""
    echo "  # 压力测试"
    echo "  $0 -s stress"
    echo ""
    echo "  # 自定义测试"
    echo "  $0 -s custom -v 50 -d 5m"
    echo ""
    echo "环境变量:"
    echo "  TARGET_URL  目标服务地址"
    echo "  TOKEN       JWT Token (用于认证测试)"
    echo ""
    echo "依赖:"
    echo "  需要安装 k6: brew install k6"
    exit 0
}

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -u|--url)
            TARGET_URL="$2"
            shift 2
            ;;
        -s|--scenario)
            SCENARIO="$2"
            shift 2
            ;;
        -v|--vus)
            VUS="$2"
            shift 2
            ;;
        -d|--duration)
            DURATION="$2"
            shift 2
            ;;
        -o|--out)
            OUT_DIR="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "未知选项: $1"
            usage
            ;;
    esac
done

# 检查 k6 是否安装
if ! command -v k6 &> /dev/null; then
    echo "错误: k6 未安装"
    echo "安装: brew install k6"
    exit 1
fi

# 创建报告目录
mkdir -p "$OUT_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="$OUT_DIR/k6_${SCENARIO}_${TIMESTAMP}.json"

# 根据场景选择配置
case "$SCENARIO" in
    smoke)
        echo "场景: 冒烟测试 - 快速验证基本功能"
        K6_OPTIONS="--stage 10s:10 --stage 20s:10"
        ;;
    load)
        echo "场景: 负载测试 - 模拟正常业务负载"
        K6_OPTIONS="--stage 2m:10 --stage 5m:50 --stage 5m:100 --stage 2m:0"
        ;;
    stress)
        echo "场景: 压力测试 - 寻找系统极限"
        K6_OPTIONS="--stage 2m:10 --stage 3m:50 --stage 5m:100 --stage 5m:200 --stage 5m:300 --stage 5m:500 --stage 2m:0"
        ;;
    spike)
        echo "场景: 峰值测试 - 模拟突发流量"
        K6_OPTIONS="--stage 10s:10 --stage 30s:1000 --stage 1m:10 --stage 30s:0"
        ;;
    soak)
        echo "场景: 浸泡测试 - 长时间稳定性测试"
        K6_OPTIONS="--stage 5m:100 --stage 50m:100 --stage 5m:0"
        ;;
    custom)
        echo "场景: 自定义测试"
        K6_OPTIONS="--stage 10s:$VUS --stage ${DURATION}:$VUS --stage 10s:0"
        ;;
    *)
        echo "错误: 未知场景 '$SCENARIO'"
        echo "支持的场景: smoke, load, stress, spike, soak, custom"
        exit 1
        ;;
esac

echo ""
echo "配置:"
echo "  URL: $TARGET_URL"
echo "  场景: $SCENARIO"
echo "  阶段: $K6_OPTIONS"
echo "  报告: $REPORT_FILE"
echo ""
echo "开始压测..."
echo "=========================================="

# 运行压测
k6 run \
  --out json="$REPORT_FILE" \
  $K6_OPTIONS \
  -e TARGET_URL="$TARGET_URL" \
  -e TOKEN="${TOKEN:-}" \
  "$(dirname "$0")/load-test.js"

echo ""
echo "=========================================="
echo "压测完成！"
echo "=========================================="
echo "报告文件: $REPORT_FILE"
echo ""
echo "查看报告:"
echo "  k6 archive $REPORT_FILE --output $REPORT_FILE.html"
echo ""
echo "或使用在线查看器:"
echo "  https://k6.io/open-source/"
echo "=========================================="
