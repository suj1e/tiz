#!/bin/bash
# Tiz Unified Deployment Script
# Manages deployment across staging and prod environments
#
# Usage: ./deploy.sh <env> <command> [options]
#
# Commands:
#   deploy [service]   Pull images and start services
#   stop               Stop all services
#   restart [service]  Restart services
#   logs [service]      View logs (all or specific service)
#   status             Check health status
#   ps                List running containers
#   rollback <service> Rollback to previous version

set -e

# =============================================================================
# Configuration
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging helpers
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# =============================================================================
# Helper Functions
# =============================================================================

validate_env() {
    local env="$1"
    if [[ "$env" != "staging" && "$env" != "prod" ]]; then
        log_error "Invalid environment: $env"
        echo "Usage: $0 <staging|prod> <command>"
        echo ""
        echo "Commands:"
        echo "  deploy [service]   Pull images and start services"
        echo "  stop               Stop all services"
        echo "  restart [service]  Restart services"
        echo "  logs [service]      View logs"
        echo "  status             Check health status"
        echo "  ps                List containers"
        echo "  rollback <service> Rollback service"
        exit 1
    fi

    if [[ ! -f "$SCRIPT_DIR/$env/docker-compose.yml" ]]; then
        log_error "docker-compose.yml not found in $SCRIPT_DIR/$env/"
        exit 1
    fi

    if [[ ! -f "$SCRIPT_DIR/$env/.env" ]]; then
        log_warn ".env file not found in $SCRIPT_DIR/$env/"
        log_info "Copy .env.example to .env and configure it"
        exit 1
    fi
}

get_env_dir() {
    local env="$1"
    echo "$SCRIPT_DIR/$env"
}

# =============================================================================
# Commands
# =============================================================================

cmd_deploy() {
    local env="$1"
    local service="$2"
    local env_dir=$(get_env_dir "$env")

    log_info "Deploying to $env environment..."

    cd "$env_dir"

    if [[ -n "$service" ]]; then
        log_info "Pulling image for $service..."
        docker-compose --env-file ".env" pull "$service"
        log_info "Starting $service..."
        docker-compose --env-file ".env" up -d "$service"
    else
        log_info "Pulling all images..."
        docker-compose --env-file ".env" pull
        log_info "Starting all services..."
        docker-compose --env-file ".env" up -d
    fi

    log_success "Deployment complete"
    log_info "Run './deploy.sh $env status' to check health"
}

cmd_stop() {
    local env="$1"
    local env_dir=$(get_env_dir "$env")

    log_info "Stopping $env services..."
    cd "$env_dir" && docker-compose --env-file ".env" down
    log_success "Services stopped"
}

cmd_restart() {
    local env="$1"
    local service="$2"
    local env_dir=$(get_env_dir "$env")

    log_info "Restarting $env services..."
    cd "$env_dir"

    if [[ -n "$service" ]]; then
        docker-compose --env-file ".env" restart "$service"
    else
        docker-compose --env-file ".env" restart
    fi

    log_success "Services restarted"
}

cmd_logs() {
    local env="$1"
    local service="$2"
    local env_dir=$(get_env_dir "$env")

    cd "$env_dir"

    if [[ -n "$service" ]]; then
        docker-compose --env-file ".env" logs -f "$service"
    else
        docker-compose --env-file ".env" logs -f
    fi
}

cmd_status() {
    local env="$1"
    local env_dir=$(get_env_dir "$env")

    log_info "Checking $env service health..."

    cd "$env_dir"

    echo ""
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}   Service Status ($env)${NC}"
    echo -e "${BLUE}=========================================${NC}"

    # Check each service health
    local services=("gateway" "auth-service" "chat-service" "content-service" "practice-service" "quiz-service" "llm-service" "user-service" "tiz-web")

    for svc in "${services[@]}"; do
        local container="tiz-$svc"
        if docker ps --format '{{.Names}}' | grep -q "^$container$"; then
            local health=$(docker inspect --format='{{.State.Health.Status}}' "$container" 2>/dev/null || echo "unknown")
            local status=$(docker ps --format '{{.Status}}' --filter "name=$container" 2>/dev/null | head -1)
            if [[ "$health" == "healthy" ]]; then
                echo -e "${GREEN}✓ $svc: $health${NC}"
            else
                echo -e "${YELLOW}○ $svc: $health ($status)${NC}"
            fi
        else
            echo -e "${RED}✗ $svc: not running${NC}"
        fi
    done

    echo ""
}

cmd_ps() {
    local env="$1"
    local env_dir=$(get_env_dir "$env")

    cd "$env_dir"

    echo ""
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}   Containers ($env)${NC}"
    echo -e "${BLUE}=========================================${NC}"

    docker-compose --env-file ".env" ps

    echo ""
}

cmd_rollback() {
    local env="$1"
    local service="$2"
    local env_dir=$(get_env_dir "$env")

    if [[ -z "$service" ]]; then
        log_error "Usage: $0 $env rollback <service>"
        exit 1
    fi

    log_info "Rolling back $service in $env..."

    # Get previous image version
    local current_image=$(docker inspect --format='{{.Config.Image}}' "tiz-$service" 2>/dev/null)
    local registry="registry.cn-hangzhou.aliyuncs.com/nxo"

    log_info "Current image: $current_image"
    log_warn "Rollback requires manual version specification"
    log_info "Available versions can be checked at: docker images $registry/$service"

    echo ""
    echo "To rollback, run:"
    echo "  1. docker pull $registry/$service:<previous-version>"
    echo "  2. docker tag $registry/$service:<previous-version> $registry/$service:latest"
    echo "  3. ./deploy.sh $env restart $service"
}

# =============================================================================
# Main
# =============================================================================

ENV="$1"
COMMAND="$2"
shift 2 || true

validate_env "$ENV"

case "$COMMAND" in
    deploy)
        cmd_deploy "$ENV" "$1"
        ;;
    stop)
        cmd_stop "$ENV"
        ;;
    restart)
        cmd_restart "$ENV" "$1"
        ;;
    logs)
        cmd_logs "$ENV" "$1"
        ;;
    status)
        cmd_status "$ENV"
        ;;
    ps)
        cmd_ps "$ENV"
        ;;
    rollback)
        cmd_rollback "$ENV" "$1"
        ;;
    *)
        log_error "Unknown command: $COMMAND"
        echo ""
        echo "Commands:"
        echo "  deploy [service]   Pull images and start services"
        echo "  stop               Stop all services"
        echo "  restart [service]  Restart services"
        echo "  logs [service]      View logs"
        echo "  status             Check health status"
        echo "  ps                List containers"
        echo "  rollback <service> Rollback service"
        exit 1
        ;;
esac
