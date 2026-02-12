#!/bin/bash
# ==============================================================================
# Nexora Gateway - 极客启动脚本 v2.0
# ==============================================================================
# 特性:
# - 使用 java -jar 启动（比 gradle bootRun 快 10 倍）
# - PID 文件管理
# - 健康检查
# - 优雅关闭
# - 多环境支持
# - JMX 监控支持
# ==============================================================================

set -euo pipefail

# ------------------------------------
# 配置
# ------------------------------------
VERSION="${VERSION:-1.0.0}"
JAR_FILE="build/libs/gatewaysrv-${VERSION}.jar"
PID_FILE="logs/gatewaysrv.pid"
LOG_FILE="logs/gatewaysrv.log"
GC_LOG_FILE="logs/gc.log"
HEALTH_URL="http://localhost:40005/actuator/health/readiness"
MANAGEMENT_PORT=40005

# Java 21 优化参数
JAVA_OPTS="${JAVA_OPTS:-} \
	-XX:+UseG1GC \
	-XX:MaxRAMPercentage=75.0 \
	-XX:+UseStringDeduplication \
	-XX:+UseDynamicNumberOfGCThreads \
	-XX:+ExplicitGCInvokesConcurrent \
	-XX:+AlwaysPreTouch \
	-Djava.security.egd=file:/dev/./urandom \
	-Djdk.tls.client.protocols=TLSv1.3 \
	-Dserver.shutdown=graceful \
	-Dspring.lifecycle.timeout-per-shutdown-phase=30s \
	-Dspring.main.lazy-initialization=${LAZY_INIT:-false} \
	-Dspring.output.ansi.enabled=always \
	-Dlogging.pattern.consolewithcolor \
	--add-opens=java.base/java.lang=ALL-UNNAMED \
	--add-opens=java.base/java.util=ALL-UNNAMED"

# GC 日志（生产环境）
if [[ "${SPRING_PROFILES_ACTIVE:-}" == "prod" ]]; then
	JAVA_OPTS="${JAVA_OPTS} \
		-Xlog:gc*:file=${GC_LOG_FILE}:time,tags:level,uptime:filecount=10,filesize=10m"
fi

# ------------------------------------
# 颜色和日志
# ------------------------------------
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log_info() { printf "${GREEN}➜${NC} %s\n" "$1"; }
log_error() { printf "${RED}✗${NC} %s\n" "$1"; }
log_warn() { printf "${YELLOW}⚠${NC} %s\n" "$1"; }
log_debug() { [[ "${DEBUG:-false}" == "true" ]] && printf "${CYAN}▶${NC} %s\n" "$1" || true; }
log_section() { printf "\n${BOLD}${BLUE}%s${NC}\n" "$1"; }

# ------------------------------------
# 工具函数
# ------------------------------------
cd "$(dirname "$0")"

# 检测 Java 版本
check_java() {
	local java_version=$(java -version 2>&1 | head -1 | cut -d'"' -f2 | cut -d'.' -f1)
	if [[ "$java_version" -lt 21 ]]; then
		log_error "需要 JDK 21+，当前: $java_version"
		exit 1
	fi
	log_debug "Java 版本: $java_version ✓"
}

# 检查端口占用
check_port() {
	local port=$1
	if lsof -i ":$port" >/dev/null 2>&1; then
		log_error "端口 $port 已被占用"
		return 1
	fi
}

# 等待健康检查
wait_for_health() {
	local max_wait=${1:-60}
	local count=0
	log_info "等待服务启动..."

	while [[ $count -lt $max_wait ]]; do
		if curl -sSf "$HEALTH_URL" >/dev/null 2>&1; then
			local health=$(curl -s "$HEALTH_URL" | jq -r '.status // "UP"' 2>/dev/null)
			log_info "服务已启动 (状态: ${health:-UP})"
			return 0
		fi
		sleep 1
		((count++))
		echo -n "."
	done
	echo
	log_error "服务启动超时"
	return 1
}

# ------------------------------------
# 环境加载
# ------------------------------------
load_env() {
	local env=$1
	local env_file=".env.${env}"

	# 加载环境特定文件
	if [[ -f "$env_file" ]]; then
		set -a
		source "$env_file"
		set +a
		log_debug "已加载: $env_file"
	fi

	# 加载本地覆盖（仅开发）
	if [[ "$env" == "dev" && -f .env.local ]]; then
		set -a
		source .env.local
		set +a
		log_debug "已加载: .env.local"
	fi

	# 设置环境特定配置
	case $env in
	dev)
		export SPRING_PROFILES_ACTIVE=${SPRING_PROFILES_ACTIVE:-dev}
		export LAZY_INIT=${LAZY_INIT:-true}
		;;
	test | prod)
		export SPRING_PROFILES_ACTIVE=$env
		export LAZY_INIT=false
		;;
	*)
		log_error "未知环境: $env (dev/test/prod)"
		exit 1
		;;
	esac
}

# 环境验证
validate_env() {
	local errors=0

	# 检查必需变量
	local required_vars=("NACOS_HOST")
	for var in "${required_vars[@]}"; do
		if [[ -z "${!var:-}" ]]; then
			log_error "缺少必需变量: $var"
			((errors++))
		fi
	done

	# Nacos 连通性检查已移除（直接启动，让应用自己处理连接）

	return $errors
}

# ------------------------------------
# 核心命令
# ------------------------------------
# 构建（如果需要）
build_if_needed() {
	if [[ ! -f "$JAR_FILE" ]]; then
		log_warn "JAR 文件不存在，开始构建..."
		./gradlew bootJar -x test --no-daemon
		log_info "构建完成"
	fi
}

# 前台启动
start() {
	local env=$1
	load_env "$env"
	check_java
	validate_env || exit 1

	# 检查端口
	if ! check_port 40004 || ! check_port 40005; then
		log_error "请先停止已运行的实例"
		exit 1
	fi

	build_if_needed

	log_section "▶ 启动 gatewaysrv [$env]"
	log_info "JAR: $JAR_FILE"
	log_info "日志: $LOG_FILE"

	# 启动 - 重新加载环境文件以确保变量可用
	(
		set -a
		[[ -f ".env.${env}" ]] && source ".env.${env}"
		[[ "$env" == "dev" && -f .env.local ]] && source .env.local
		export SPRING_PROFILES_ACTIVE=${SPRING_PROFILES_ACTIVE:-$env}
		set +a
		java $JAVA_OPTS -jar "$JAR_FILE"
	)
}

# 后台启动
bg() {
	local env=${2:-dev}
	load_env "$env"
	check_java
	validate_env || exit 1

	# 检查 PID 文件
	if [[ -f "$PID_FILE" ]]; then
		local old_pid=$(cat "$PID_FILE")
		if ps -p "$old_pid" >/dev/null 2>&1; then
			log_error "已在运行 (PID: $old_pid)"
			log_info "使用 '$0 stop' 先停止"
			exit 1
		fi
		rm -f "$PID_FILE"
	fi

	if ! check_port 40004 || ! check_port 40005; then
		log_error "端口被占用"
		exit 1
	fi

	build_if_needed

	mkdir -p logs

	log_section "▶ 后台启动 gatewaysrv [$env]"

	# 启动服务 - 使用子shell加载环境变量
	nohup bash -c '
		set -a
		[[ -f ".env.'$env'" ]] && source ".env.'$env'"
		[[ "'$env'" == "dev" && -f .env.local ]] && source .env.local
		export SPRING_PROFILES_ACTIVE=${SPRING_PROFILES_ACTIVE:-'$env'}
		set +a
		exec java '"$JAVA_OPTS"' -jar "'"$JAR_FILE"'"
	' >"$LOG_FILE" 2>&1 &
	local pid=$!
	echo $pid >"$PID_FILE"

	log_info "PID: $pid"
	log_info "日志: tail -f $LOG_FILE"

	# 等待启动
	if wait_for_health 60; then
		log_info "✓ 启动成功"
		tail -n 20 "$LOG_FILE"
	else
		log_error "✗ 启动失败，查看日志: $LOG_FILE"
		exit 1
	fi
}

# 停止
stop() {
	if [[ ! -f "$PID_FILE" ]]; then
		log_warn "未运行（无 PID 文件）"
		# 尝试通过进程名查找
		local pid=$(pgrep -f "gatewaysrv.*jar" || true)
		if [[ -n "$pid" ]]; then
			log_info "发现运行中的进程 (PID: $pid)"
		else
			return 0
		fi
	else
		local pid=$(cat "$PID_FILE")
	fi

	log_info "停止服务 (PID: $pid)..."

	# 优雅关闭（SIGTERM）
	kill "$pid" 2>/dev/null || true

	# 等待进程退出（最多 30 秒）
	local timeout=30
	while [[ $timeout -gt 0 ]] && ps -p "$pid" >/dev/null 2>&1; do
		sleep 1
		((timeout--))
		echo -n "."
	done
	echo

	# 如果还在运行，强制关闭
	if ps -p "$pid" >/dev/null 2>&1; then
		log_warn "未响应，强制关闭..."
		kill -9 "$pid" 2>/dev/null || true
		sleep 1
	fi

	rm -f "$PID_FILE"
	log_info "✓ 已停止"
}

# 重启
restart() {
	stop
	sleep 2
	bg "${@:-dev}"
}

# 状态
status() {
	local running=false
	local pid=""

	if [[ -f "$PID_FILE" ]]; then
		pid=$(cat "$PID_FILE")
		if ps -p "$pid" >/dev/null 2>&1; then
			running=true
		fi
	fi

	if [[ "$running" == "true" ]]; then
		log_info "✓ 运行中 (PID: $pid)"

		# 内存使用
		local mem=$(ps -o rss= -p "$pid" | awk '{printf "%.0f MB", $1/1024}')
		log_info "内存: $mem"

		# 端口监听
		local ports=$(lsof -Pan -p "$pid" -i 2>/dev/null | grep LISTEN | awk '{print $9}' | sort -u | tr '\n' ' ')
		log_info "监听: ${ports:-无}"

		# 健康检查
		if command -v curl >/dev/null 2>&1; then
			local health_status=$(curl -s "$HEALTH_URL" 2>/dev/null | jq -r '.status // "unknown"' 2>/dev/null)
			local uptime=$(curl -s "$HEALTH_URL" 2>/dev/null | jq -r '.duration // "unknown"' 2>/dev/null)
			log_info "健康: ${health_status:-未检查}"
			[[ -n "${uptime:-}" ]] && log_info "运行时间: ${uptime}"
		fi
	else
		log_info "✗ 未运行"
		return 1
	fi
}

# 日志
logs() {
	local follow=${1:-false}
	if [[ ! -f "$LOG_FILE" ]]; then
		log_warn "日志文件不存在: $LOG_FILE"
		return 1
	fi

	if [[ "$follow" == "true" ]]; then
		tail -f "$LOG_FILE"
	else
		tail -n 100 "$LOG_FILE"
	fi
}

# 构建
build() {
	log_section "🔨 构建 gatewaysrv"
	./gradlew clean bootJar --no-daemon "$@"
	log_info "✓ 构建完成: $JAR_FILE"
}

# 清理
clean() {
	log_info "清理构建产物..."
	rm -rf build logs
	log_info "✓ 已清理"
}

# ------------------------------------
# 帮助
# ------------------------------------
show_help() {
	cat <<'EOF'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    Nexora Gateway - 启动脚本 v2.0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

用法:
  ./run.sh <command> [options]

命令:
  dev                 启动开发环境（前台）
  test                启动测试环境（前台）
  prod                启动生产环境（前台）
  bg [dev|test|prod]  后台启动（默认: dev）
  stop                停止服务
  restart [env]       重启服务
  status              查看状态
  logs [-f]           查看日志（-f 跟踪）
  build [args]        构建 JAR
  clean               清理构建产物
  help                显示帮助

环境配置:
  创建 .env.{dev|test|prod} 文件配置环境变量
  开发环境可使用 .env.local 覆盖（不提交到 Git）

必需环境变量:
  NACOS_HOST                 Nacos 服务器地址

可选环境变量:
  JWT_SECRET                 JWT 密钥（Nacos 配置中使用 ${JWT_SECRET} 占位符）
  NACOS_PORT          Nacos 端口（默认: 8848）
  NACOS_NAMESPACE     命名空间
  NACOS_USERNAME      Nacos 用户名
  NACOS_PASSWORD      Nacos 密码
  LAZY_INIT           懒加载（dev 默认: true）

示例:
  ./run.sh dev                    # 开发环境启动
  ./run.sh bg prod                # 生产环境后台启动
  ./run.sh status                 # 查看状态
  ./run.sh logs -f                # 跟踪日志
  ./run.sh restart test           # 重启测试环境
  LAZY_INIT=true ./run.sh bg dev  # 懒加载模式启动

更多: https://github.com/nexora/gatewaysrv
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
}

# ------------------------------------
# 主入口
# ------------------------------------
main() {
	local command=${1:-help}

	case "$command" in
	dev | test | prod) start "$command" ;;
	bg) bg "${2:-dev}" ;;
	stop) stop ;;
	restart) restart "${2:-dev}" ;;
	status) status ;;
	logs) logs "${2:-false}" ;;
	build) build "${@:2}" ;;
	clean) clean ;;
	help | --help | -h) show_help ;;
	*)
		log_error "未知命令: $command"
		echo
		show_help
		exit 1
		;;
	esac
}

main "$@"
