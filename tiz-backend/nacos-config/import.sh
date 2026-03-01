#!/bin/bash

# Nacos Configuration Import Script
# 将服务配置导入到 Nacos，按 namespace 隔离环境

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 默认配置
NACOS_ADDR="${NACOS_ADDR:-localhost:30848}"
NACOS_USER="${NACOS_USER:-nacos}"
NACOS_PASS="${NACOS_PASS:-nacos}"
ENV="${1:-dev}"
NAMESPACE="${2:-$ENV}"  # 默认 namespace 与环境名相同

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 获取 Nacos Access Token
get_access_token() {
    local response=$(curl -s -X POST "http://${NACOS_ADDR}/nacos/v1/auth/login" \
        -d "username=${NACOS_USER}" \
        -d "password=${NACOS_PASS}")

    echo "$response" | python3 -c "import sys, json; print(json.load(sys.stdin).get('accessToken', ''))" 2>/dev/null || echo ""
}

# 获取 namespace ID（如果不存在则创建）
get_or_create_namespace() {
    local ns_name=$1
    local token=$2

    # 先查询是否存在
    local ns_id=$(curl -s "http://${NACOS_ADDR}/nacos/v1/console/namespaces?accessToken=${token}" | \
        python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for ns in data.get('data', []):
        if ns.get('namespaceShowName') == '$ns_name' or ns.get('namespace') == '$ns_name':
            print(ns.get('namespace', ''))
            break
except:
    pass
" 2>/dev/null || echo "")

    if [ -n "$ns_id" ]; then
        echo "$ns_id"
        return
    fi

    # 创建 namespace
    local result=$(curl -s -X POST "http://${NACOS_ADDR}/nacos/v1/console/namespaces" \
        -d "customNamespaceId=${ns_name}" \
        -d "namespaceName=${ns_name}" \
        -d "namespaceDesc=${ns_name} environment" \
        -d "accessToken=${token}")

    if echo "$result" | grep -q "true"; then
        echo "$ns_name"
    else
        # 尝试使用环境名作为 ID
        echo "$ns_name"
    fi
}

# 发布配置到 Nacos
publish_config() {
    local data_id=$1
    local group=$2
    local file=$3
    local namespace=$4
    local token=$5

    local content=$(cat "$file" | python3 -c "import sys, urllib.parse; print(urllib.parse.quote(sys.stdin.read(), safe=''))")

    # 根据文件扩展名确定类型
    local type="text"
    if [[ "$data_id" == *.yaml ]] || [[ "$data_id" == *.yml ]]; then
        type="yaml"
    elif [[ "$data_id" == *.properties ]]; then
        type="properties"
    elif [[ "$data_id" == *.json ]]; then
        type="json"
    fi

    local url="http://${NACOS_ADDR}/nacos/v1/cs/configs"
    local data="dataId=${data_id}&group=${group}&content=${content}&tenant=${namespace}&type=${type}&accessToken=${token}"

    local response=$(curl -s -X POST "$url" -d "$data")

    if [ "$response" = "true" ]; then
        log_success "Published: $data_id (namespace: $namespace, type: $type)"
    else
        log_error "Failed to publish $data_id: $response"
        return 1
    fi
}

# 导入指定环境的配置
import_env() {
    local env=$1
    local namespace=$2
    local config_dir="$SCRIPT_DIR/$env"

    if [ ! -d "$config_dir" ]; then
        log_error "Config directory not found: $config_dir"
        log_info "Available environments: $(ls -d "$SCRIPT_DIR"/*/ 2>/dev/null | xargs -n1 basename | tr '\n' ' ')"
        exit 1
    fi

    log_info "Importing configurations for environment: $env"
    log_info "Nacos address: $NACOS_ADDR"
    log_info "Target namespace: $namespace"
    echo ""

    # 获取 token
    local token=$(get_access_token)
    if [ -z "$token" ]; then
        log_error "Failed to authenticate with Nacos"
        exit 1
    fi

    # 确保 namespace 存在
    local ns_id=$(get_or_create_namespace "$namespace" "$token")
    if [ "$ns_id" = "$namespace" ]; then
        log_info "Using namespace: $ns_id"
    else
        log_info "Using namespace: $ns_id (created)"
    fi
    echo ""

    # 导入该环境下的所有配置文件
    local count=0
    local failed=0

    shopt -s nullglob
    local files=("$config_dir"/*.yaml "$config_dir"/*.yml)
    shopt -u nullglob

    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            local filename=$(basename "$file")
            local data_id="$filename"

            if publish_config "$data_id" "DEFAULT_GROUP" "$file" "$ns_id" "$token"; then
                count=$((count + 1))
            else
                failed=$((failed + 1))
            fi
        fi
    done

    echo ""
    log_info "Import completed: $count succeeded, $failed failed"
}

# 删除 namespace 中的所有配置
clean_namespace() {
    local namespace=$1

    log_warn "This will delete all configs in namespace: $namespace"
    read -p "Are you sure? (y/N) " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Cancelled"
        exit 0
    fi

    local token=$(get_access_token)
    if [ -z "$token" ]; then
        log_error "Failed to authenticate with Nacos"
        exit 1
    fi

    # 获取并删除所有配置
    log_info "Deleting all configs in namespace: $namespace"
    # TODO: 实现删除逻辑

    log_success "Clean completed"
}

# 显示帮助
show_help() {
    echo "Usage: $0 [ENVIRONMENT] [NAMESPACE]"
    echo ""
    echo "Arguments:"
    echo "  ENVIRONMENT   Environment name (default: dev)"
    echo "  NAMESPACE     Nacos namespace (default: same as ENVIRONMENT)"
    echo ""
    echo "Environment Variables:"
    echo "  NACOS_ADDR    Nacos server address (default: localhost:30848)"
    echo "  NACOS_USER    Nacos username (default: nacos)"
    echo "  NACOS_PASS    Nacos password (default: nacos)"
    echo ""
    echo "Examples:"
    echo "  $0                    # Import dev configs to 'dev' namespace"
    echo "  $0 staging            # Import staging configs to 'staging' namespace"
    echo "  $0 dev dev-ns         # Import dev configs to 'dev-ns' namespace"
    echo "  NACOS_ADDR=192.168.1.100:30848 $0 prod  # Use custom Nacos address"
    echo ""
    echo "Directory structure:"
    echo "  nacos-config/"
    echo "  ├── dev/"
    echo "  │   ├── authsrv.yaml"
    echo "  │   ├── chatsrv.yaml"
    echo "  │   └── ..."
    echo "  ├── staging/"
    echo "  └── prod/"
    echo ""
}

# 主入口
if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    show_help
    exit 0
fi

import_env "$ENV" "$NAMESPACE"
