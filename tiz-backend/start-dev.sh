#!/bin/bash

# Tiz Backend Development Start Script
# 按依赖顺序启动所有后端服务

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR"
LOG_DIR="$BACKEND_DIR/logs"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 初始化日志目录
init_log_dir() {
    mkdir -p "$LOG_DIR"
    log_info "Log directory: $LOG_DIR"
}

# 检查命令是否存在
check_command() {
    if ! command -v $1 &> /dev/null; then
        log_error "$1 is not installed"
        exit 1
    fi
}

# 发布模块到 Maven Local
publish_module() {
    local module=$1
    local path=$2
    log_info "Publishing $module to Maven Local..."
    cd "$BACKEND_DIR/$path"
    gradle publishToMavenLocal --quiet
    log_success "$module published"
}

# 启动 Java 服务（后台运行）
start_java_service() {
    local name=$1
    local port=$2
    local path="$BACKEND_DIR/$3"

    log_info "Starting $name on port $port..."

    cd "$path"
    gradle :app:bootRun > "$LOG_DIR/tiz-${name}.log" 2>&1 &

    local pid=$!
    echo $pid > "$LOG_DIR/tiz-${name}.pid"
    log_success "$name started (PID: $pid, Log: $LOG_DIR/tiz-${name}.log)"
}

# 启动 Python 服务（后台运行）
start_python_service() {
    local name=$1
    local port=$2
    local path="$BACKEND_DIR/$3"

    log_info "Starting $name on port $port..."

    cd "$path"
    pixi run dev > "$LOG_DIR/tiz-${name}.log" 2>&1 &

    local pid=$!
    echo $pid > "$LOG_DIR/tiz-${name}.pid"
    log_success "$name started (PID: $pid, Log: $LOG_DIR/tiz-${name}.log)"
}

# 等待服务启动
wait_for_service() {
    local name=$1
    local port=$2
    local max_wait=60
    local count=0

    log_info "Waiting for $name to be ready..."
    while ! curl -s "http://localhost:$port/actuator/health" > /dev/null 2>&1; do
        sleep 2
        count=$((count + 2))
        if [ $count -ge $max_wait ]; then
            log_warn "$name health check timeout, continuing..."
            return
        fi
    done
    log_success "$name is ready"
}

# 停止所有服务
stop_all() {
    log_info "Stopping all services..."

    for pid_file in $LOG_DIR/tiz-*.pid; do
        if [ -f "$pid_file" ]; then
            local pid=$(cat "$pid_file")
            if kill -0 $pid 2>/dev/null; then
                kill $pid 2>/dev/null || true
                log_info "Killed process $pid"
            fi
            rm -f "$pid_file"
        fi
    done

    log_success "All services stopped"
}

# 查看服务状态
status_all() {
    echo ""
    echo "Service Status:"
    echo "==============="

    services=("authsrv:8101" "chatsrv:8102" "contentsrv:8103" "practicesrv:8104" "quizsrv:8105" "llmsrv:8106" "usersrv:8107" "gatewaysrv:8080")

    for svc in "${services[@]}"; do
        local name="${svc%%:*}"
        local port="${svc##*:}"
        local status="STOPPED"

        if curl -s "http://localhost:$port/actuator/health" > /dev/null 2>&1; then
            status="RUNNING"
        fi

        printf "  %-15s port %-5s %s\n" "$name" "$port" "$status"
    done
    echo ""
}

# 查看日志
logs_service() {
    local name=$1
    local log_file="$LOG_DIR/tiz-${name}.log"

    if [ -f "$log_file" ]; then
        tail -f "$log_file"
    else
        log_error "Log file not found: $log_file"
    fi
}

# 主启动流程
start_all() {
    log_info "Starting Tiz Backend Services..."
    echo ""

    # 初始化日志目录
    init_log_dir

    # 检查依赖
    check_command gradle
    check_command java

    # 1. 发布 common 模块
    log_info "=== Step 1: Publishing common modules ==="
    publish_module "common" "common"

    # 2. 发布服务 API 模块
    log_info "=== Step 2: Publishing service APIs ==="
    publish_module "contentsrv-api" "contentsrv"
    publish_module "llmsrv-api" "llmsrv"

    # 3. 启动核心服务（无严格依赖顺序）
    log_info "=== Step 3: Starting services ==="

    start_java_service "authsrv" 8101 "authsrv" &
    start_java_service "usersrv" 8107 "usersrv" &
    start_java_service "contentsrv" 8103 "contentsrv" &

    wait

    # 等待核心服务启动
    sleep 5
    wait_for_service "authsrv" 8101 || true
    wait_for_service "usersrv" 8107 || true
    wait_for_service "contentsrv" 8103 || true

    # 启动业务服务
    start_java_service "chatsrv" 8102 "chatsrv" &
    start_java_service "practicesrv" 8104 "practicesrv" &
    start_java_service "quizsrv" 8105 "quizsrv" &

    wait

    sleep 5
    wait_for_service "chatsrv" 8102 || true
    wait_for_service "practicesrv" 8104 || true
    wait_for_service "quizsrv" 8105 || true

    # 启动 AI 服务
    if command -v pixi &> /dev/null; then
        start_python_service "llmsrv" 8106 "llmsrv"
        sleep 3
    else
        log_warn "pixi not found, skipping llmsrv"
    fi

    # 最后启动网关
    start_java_service "gatewaysrv" 8080 "gatewaysrv"
    wait_for_service "gatewaysrv" 8080 || true

    echo ""
    log_success "=== All services started ==="
    status_all

    echo "Logs: $LOG_DIR/tiz-<service>.log"
    echo "Example: tail -f $LOG_DIR/tiz-authsrv.log"
    echo ""
    echo "API Gateway: http://localhost:8080"
    echo ""
}

# 显示帮助
show_help() {
    echo "Usage: $0 <command>"
    echo ""
    echo "Commands:"
    echo "  start     Start all backend services"
    echo "  stop      Stop all backend services"
    echo "  status    Show service status"
    echo "  logs      Show logs for a service (e.g., $0 logs authsrv)"
    echo "  help      Show this help message"
    echo ""
}

# 主入口
case "${1:-}" in
    start)
        start_all
        ;;
    stop)
        stop_all
        ;;
    status)
        status_all
        ;;
    logs)
        if [ -z "${2:-}" ]; then
            log_error "Please specify service name (e.g., authsrv)"
            exit 1
        fi
        logs_service "$2"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        show_help
        exit 1
        ;;
esac
