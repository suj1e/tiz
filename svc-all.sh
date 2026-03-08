#!/bin/bash
# Batch service management script for all services
# Usage: ./svc-all.sh <command> [options]
#
# Commands:
#   publish    Publish API modules to Maven
#   image      Build and push Docker images
#   build      Build all services
#   test       Run all tests
#   validate   Validate all service configurations
#   status     Check all service health
#   version    Show all service versions
#
# Options:
#   --changed    Only process services with changes
#   --dry-run    Show what would be done without executing
#   --local      For image: build without pushing

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="${SCRIPT_DIR}/tiz-backend"
FRONTEND_DIR="${SCRIPT_DIR}/tiz-web"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Services in dependency order
PUBLISH_SERVICES=(
    "common"
    "llm-api"
    "auth-service"
    "chat-service"
    "content-service"
    "practice-service"
    "quiz-service"
    "user-service"
)

# Services for image command (only services with Dockerfile)
IMAGE_SERVICES=(
    "auth-service"
    "user-service"
    "content-service"
    "chat-service"
    "practice-service"
    "quiz-service"
    "gateway"
    "llm-service"
    "tiz-web"
)

# All backend services for other commands
ALL_SERVICES=(
    "common"
    "llm-api"
    "auth-service"
    "user-service"
    "content-service"
    "chat-service"
    "practice-service"
    "quiz-service"
    "gateway"
    "llm-service"
    "tiz-web"
)

# Parse command
COMMAND="${1:-help}"
shift || true

# Parse options
CHANGED_ONLY=false
DRY_RUN=false
LOCAL_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --changed)
            CHANGED_ONLY=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --local)
            LOCAL_ONLY=true
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Usage: $0 <command> [--changed] [--dry-run] [--local]"
            exit 1
            ;;
    esac
done

# Function to check if a directory has changes
has_changes() {
    local dir="$1"
    if [ "$CHANGED_ONLY" = false ]; then
        return 0  # Always process if not filtering by changes
    fi

    # Check if there are uncommitted changes
    if git diff --quiet HEAD -- "$dir" 2>/dev/null; then
        # No uncommitted changes, check if ahead of origin
        local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "HEAD")
        local ahead=$(git rev-list --count origin/${branch}..HEAD -- "$dir" 2>/dev/null || echo "0")
        if [ "$ahead" -gt 0 ]; then
            return 0
        fi
        return 1
    fi
    return 0
}

# Function to run a command on a service
run_service_cmd() {
    local service="$1"
    local cmd="$2"
    local extra_args="$3"

    # Determine service directory (tiz-web is in frontend dir)
    local svc_dir
    if [ "$service" = "tiz-web" ]; then
        svc_dir="${FRONTEND_DIR}"
    else
        svc_dir="${BACKEND_DIR}/${service}"
    fi

    if [ ! -f "${svc_dir}/svc.sh" ]; then
        log_warn "No svc.sh found for ${service}, skipping"
        return 1
    fi

    log_info "Running '${cmd}' on ${service}..."

    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would run: cd ${svc_dir} && ./svc.sh ${cmd}${extra_args}"
        return 0
    fi

    cd "$svc_dir"
    ./svc.sh ${cmd} ${extra_args}
    local result=$?
    cd "$SCRIPT_DIR"

    if [ $result -eq 0 ]; then
        log_success "${service}: ${cmd} completed"
    else
        log_error "${service}: ${cmd} failed"
        return 1
    fi
}

# Get services list based on command
get_services() {
    local cmd="$1"
    case "$cmd" in
        publish)
            echo "${PUBLISH_SERVICES[@]}"
            ;;
        image)
            echo "${IMAGE_SERVICES[@]}"
            ;;
        *)
            echo "${ALL_SERVICES[@]}"
            ;;
    esac
}

# Get directory path for a service
get_service_dir() {
    local service="$1"
    if [ "$service" = "tiz-web" ]; then
        echo "${FRONTEND_DIR}"
    else
        echo "${BACKEND_DIR}/${service}"
    fi
}

# Command implementations
cmd_publish() {
    log_info "Starting batch publish..."
    echo ""

    if [ "$CHANGED_ONLY" = true ]; then
        log_info "Mode: Publishing only changed services"
    else
        log_info "Mode: Publishing all services"
    fi

    if [ "$DRY_RUN" = true ]; then
        log_warn "Dry-run mode: No actual changes will be made"
    fi

    echo ""

    local services=$(get_services "publish")
    SUCCESS_COUNT=0
    FAIL_COUNT=0
    SKIPPED_COUNT=0

    for service in $services; do
        if has_changes "$(get_service_dir "$service")"; then
            if run_service_cmd "$service" "publish"; then
                SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
            else
                FAIL_COUNT=$((FAIL_COUNT + 1))
            fi
        else
            log_info "Skipping ${service} (no changes)"
            SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
        fi
    done

    echo ""
    log_info "================================"
    log_info "Publish Summary"
    log_info "================================"
    log_success "Succeeded: ${SUCCESS_COUNT}"
    if [ $FAIL_COUNT -gt 0 ]; then
        log_error "Failed: ${FAIL_COUNT}"
    fi
    if [ $SKIPPED_COUNT -gt 0 ]; then
        log_info "Skipped: ${SKIPPED_COUNT}"
    fi

    if [ $FAIL_COUNT -gt 0 ]; then
        exit 1
    fi
}

cmd_image() {
    log_info "Starting batch image build..."
    echo ""

    local extra_args=""
    if [ "$LOCAL_ONLY" = true ]; then
        extra_args="--local"
        log_info "Mode: Building images locally (no push)"
    else
        log_info "Mode: Building and pushing images"
    fi

    if [ "$CHANGED_ONLY" = true ]; then
        log_info "Filter: Only changed services"
    fi

    if [ "$DRY_RUN" = true ]; then
        log_warn "Dry-run mode: No actual changes will be made"
    fi

    echo ""

    local services=$(get_services "image")
    SUCCESS_COUNT=0
    FAIL_COUNT=0
    SKIPPED_COUNT=0

    for service in $services; do
        if has_changes "$(get_service_dir "$service")"; then
            if run_service_cmd "$service" "image" "$extra_args"; then
                SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
            else
                FAIL_COUNT=$((FAIL_COUNT + 1))
            fi
        else
            log_info "Skipping ${service} (no changes)"
            SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
        fi
    done

    echo ""
    log_info "================================"
    log_info "Image Build Summary"
    log_info "================================"
    log_success "Succeeded: ${SUCCESS_COUNT}"
    if [ $FAIL_COUNT -gt 0 ]; then
        log_error "Failed: ${FAIL_COUNT}"
    fi
    if [ $SKIPPED_COUNT -gt 0 ]; then
        log_info "Skipped: ${SKIPPED_COUNT}"
    fi

    if [ $FAIL_COUNT -gt 0 ]; then
        exit 1
    fi
}

cmd_batch() {
    local cmd="$1"
    local extra_args="$2"

    log_info "Running '${cmd}' on all services..."
    echo ""

    if [ "$CHANGED_ONLY" = true ]; then
        log_info "Filter: Only changed services"
    fi

    if [ "$DRY_RUN" = true ]; then
        log_warn "Dry-run mode: No actual changes will be made"
    fi

    echo ""

    local services=$(get_services "$cmd")
    SUCCESS_COUNT=0
    FAIL_COUNT=0
    SKIPPED_COUNT=0

    for service in $services; do
        if has_changes "$(get_service_dir "$service")"; then
            if run_service_cmd "$service" "$cmd" "$extra_args"; then
                SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
            else
                FAIL_COUNT=$((FAIL_COUNT + 1))
            fi
        else
            log_info "Skipping ${service} (no changes)"
            SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
        fi
    done

    echo ""
    log_info "================================"
    log_info "${cmd^} Summary"
    log_info "================================"
    log_success "Succeeded: ${SUCCESS_COUNT}"
    if [ $FAIL_COUNT -gt 0 ]; then
        log_error "Failed: ${FAIL_COUNT}"
    fi
    if [ $SKIPPED_COUNT -gt 0 ]; then
        log_info "Skipped: ${SKIPPED_COUNT}"
    fi

    if [ $FAIL_COUNT -gt 0 ]; then
        exit 1
    fi
}

cmd_help() {
    echo "Batch Service Management Script"
    echo ""
    echo "Usage: ./svc-all.sh <command> [options]"
    echo ""
    echo "Commands:"
    echo "  publish    Publish API modules to Maven (only services with API)"
    echo "  image      Build and push Docker images"
    echo "  build      Build all services"
    echo "  test       Run all tests"
    echo "  validate   Validate all service configurations"
    echo "  status     Check all service health"
    echo "  version    Show all service versions"
    echo ""
    echo "Options:"
    echo "  --changed    Only process services with changes (git-based)"
    echo "  --dry-run    Show what would be done without executing"
    echo "  --local      For image: build without pushing to registry"
    echo ""
    echo "Examples:"
    echo "  ./svc-all.sh publish                    # Publish all services"
    echo "  ./svc-all.sh publish --changed          # Publish only changed services"
    echo "  ./svc-all.sh image                      # Build and push all images"
    echo "  ./svc-all.sh image --local              # Build images without pushing"
    echo "  ./svc-all.sh image --changed            # Build only changed services"
    echo "  ./svc-all.sh build --dry-run            # Preview build commands"
    echo "  ./svc-all.sh status                     # Check all services health"
    echo ""
    echo "Services (publish): ${PUBLISH_SERVICES[*]}"
    echo "Services (image):   ${IMAGE_SERVICES[*]}"
    echo "Services (other):   ${ALL_SERVICES[*]}"
}

# Main
case "$COMMAND" in
    publish)
        cmd_publish
        ;;
    image)
        cmd_image
        ;;
    build|test|validate|status|version)
        cmd_batch "$COMMAND"
        ;;
    help|--help|-h)
        cmd_help
        ;;
    "")
        cmd_help
        ;;
    *)
        log_error "Unknown command: $COMMAND"
        cmd_help
        exit 1
        ;;
esac
