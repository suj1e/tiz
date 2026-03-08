#!/bin/bash
# Service Management Script for llm-service (Python/FastAPI)
# Usage: ./svc.sh <command> [options]

set -e

# =============================================================================
# Configuration
# =============================================================================

SERVICE_NAME="llm-service"
SERVICE_PORT="${PORT:-8106}"
REGISTRY="registry.cn-hangzhou.aliyuncs.com"
IMAGE_NAME="${REGISTRY}/nxo/${SERVICE_NAME}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# =============================================================================
# Helper Functions
# =============================================================================

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

check_pixi() {
    if ! command -v pixi &> /dev/null; then
        log_error "Pixi not found. Please install: curl -fsSL https://pixi.sh/install.sh | bash"
        exit 1
    fi
}

ensure_dependencies() {
    if [ ! -d ".pixi" ]; then
        log_warn ".pixi not found, installing dependencies..."
        pixi install
    fi
}

check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker not found. Please install Docker"
        exit 1
    fi
}

get_env_file() {
    local env="${1:-dev}"
    local env_file="${SCRIPT_DIR}/.env.${env}"
    if [ -f "$env_file" ]; then
        echo "$env_file"
    else
        log_warn "Environment file not found: $env_file"
        echo ""
    fi
}

get_version() {
    if [ -f "pyproject.toml" ]; then
        grep -E '^version = ' pyproject.toml | head -1 | cut -d'"' -f2 || echo "0.1.0"
    else
        echo "0.1.0"
    fi
}

# =============================================================================
# Commands
# =============================================================================

cmd_install() {
    log_info "Installing dependencies for ${SERVICE_NAME}..."
    check_pixi
    pixi install
    log_success "Dependencies installed"
}

cmd_build() {
    log_info "Building ${SERVICE_NAME}..."
    check_pixi
    ensure_dependencies
    pixi build
    log_success "Build complete"
}

cmd_test() {
    log_info "Running tests for ${SERVICE_NAME}..."
    check_pixi
    ensure_dependencies
    pixi run test
    log_success "Tests complete"
}

cmd_run() {
    local env="${1:-dev}"
    local env_file=$(get_env_file "$env")

    log_info "Running ${SERVICE_NAME} with environment: ${env}"
    check_pixi
    ensure_dependencies

    if [ -f "$env_file" ]; then
        set -a
        source <(grep -v '^#' "$env_file" | grep -v '^[[:space:]]*$')
        set +a
    fi

    pixi run dev
}

cmd_publish() {
    log_info "Publishing ${SERVICE_NAME} to PyPI..."
    check_pixi

    if [ -z "$PYPI_TOKEN" ]; then
        log_error "PYPI_TOKEN must be set for publishing"
        exit 1
    fi

    pixi run publish
    log_success "Published to PyPI"
}

cmd_image() {
    local push_image=true
    if [ "$1" = "--local" ]; then
        push_image=false
    fi

    log_info "Building Docker image for ${SERVICE_NAME}..."
    check_docker

    local version=$(get_version)
    local git_sha=$(git rev-parse --short HEAD 2>/dev/null || echo "local")

    docker build \
        -t "${IMAGE_NAME}:${version}" \
        -t "${IMAGE_NAME}:sha-${git_sha}" \
        -t "${IMAGE_NAME}:latest" \
        .

    log_success "Image built: ${IMAGE_NAME}:${version}"

    if [ "$push_image" = true ]; then
        log_info "Pushing image to registry..."
        docker push "${IMAGE_NAME}:${version}"
        docker push "${IMAGE_NAME}:sha-${git_sha}"
        docker push "${IMAGE_NAME}:latest"
        log_success "Image pushed to ${REGISTRY}"
    else
        log_info "Skipping push (--local flag)"
    fi
}

cmd_version() {
    local action="$1"
    local current=$(get_version)

    if [ -z "$action" ]; then
        echo "${SERVICE_NAME}: ${current}"
        return
    fi

    if [ "$action" = "bump" ]; then
        local major minor patch
        IFS='.' read -r major minor patch <<< "$current"
        patch=$((patch + 1))
        local new_version="${major}.${minor}.${patch}"

        log_info "Bumping version: ${current} -> ${new_version}"
        if [ -f "pyproject.toml" ]; then
            sed -i '' "s/^version = \".*\"/version = \"${new_version}\"/" pyproject.toml
            log_success "Version updated"
        else
            log_error "pyproject.toml not found"
        fi
    else
        log_error "Unknown version action: ${action}"
        echo "Usage: $0 version [bump]"
    fi
}

cmd_tag() {
    local version=$(get_version)
    local tag_name="${SERVICE_NAME}/v${version}"

    log_info "Creating git tag: ${tag_name}"
    git tag -a "$tag_name" -m "Release ${tag_name}"
    log_success "Tag created: ${tag_name}"
    log_info "Push with: git push origin ${tag_name}"
}

cmd_status() {
    log_info "Checking ${SERVICE_NAME} status..."

    if curl -sf "http://localhost:${SERVICE_PORT}/health" > /dev/null 2>&1; then
        log_success "${SERVICE_NAME} is healthy (port ${SERVICE_PORT})"
    else
        log_warn "${SERVICE_NAME} is not responding on port ${SERVICE_PORT}"
    fi
}

cmd_logs() {
    local lines="${1:-100}"
    log_info "Showing last ${lines} lines of logs..."
    if [ -f "${SCRIPT_DIR}/logs/app.log" ]; then
        tail -n "$lines" "${SCRIPT_DIR}/logs/app.log"
    else
        log_warn "Log file not found: ${SCRIPT_DIR}/logs/app.log"
        log_info "Try: docker logs ${SERVICE_NAME}"
    fi
}

cmd_validate() {
    log_info "Validating ${SERVICE_NAME} configuration..."

    local errors=0

    if ! command -v pixi &> /dev/null; then
        log_error "Pixi not found"
        errors=$((errors + 1))
    else
        log_success "Pixi: $(pixi --version)"
    fi

    if ! command -v python3 &> /dev/null; then
        log_error "Python3 not found"
        errors=$((errors + 1))
    else
        log_success "Python: $(python3 --version)"
    fi

    if [ -z "$OPENAI_API_KEY" ]; then
        log_warn "OPENAI_API_KEY not set (required for LLM)"
    else
        log_success "OPENAI_API_KEY is set"
    fi

    if [ -f "pyproject.toml" ]; then
        log_success "pyproject.toml exists"
    else
        log_error "pyproject.toml not found"
        errors=$((errors + 1))
    fi

    if [ -f "pixi.toml" ]; then
        log_success "pixi.toml exists"
    else
        log_warn "pixi.toml not found"
    fi

    if [ $errors -gt 0 ]; then
        log_error "Validation failed with ${errors} error(s)"
        exit 1
    else
        log_success "Validation passed"
    fi
}

cmd_rollback() {
    local version="$1"
    if [ -z "$version" ]; then
        log_error "Usage: $0 rollback <version>"
        exit 1
    fi

    log_info "Rolling back to version: ${version}"
    check_docker

    docker pull "${IMAGE_NAME}:${version}"
    docker stop "${SERVICE_NAME}" 2>/dev/null || true
    docker rm "${SERVICE_NAME}" 2>/dev/null || true

    docker run -d \
        --name "${SERVICE_NAME}" \
        --network npass \
        -p "${SERVICE_PORT}:${SERVICE_PORT}" \
        "${IMAGE_NAME}:${version}"

    log_success "Rolled back to ${version}"
}

cmd_images() {
    local action="$1"
    check_docker

    if [ -z "$action" ] || [ "$action" = "list" ]; then
        log_info "Local images for ${SERVICE_NAME}:"
        docker images "${IMAGE_NAME}" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
    elif [ "$action" = "clean" ]; then
        log_info "Cleaning old images for ${SERVICE_NAME}..."
        docker image prune -f --filter "reference=${IMAGE_NAME}"
        log_success "Cleaned"
    else
        log_error "Unknown action: ${action}"
        echo "Usage: $0 images [list|clean]"
    fi
}

cmd_deps() {
    local action="$1"
    check_pixi

    if [ -z "$action" ] || [ "$action" = "list" ]; then
        log_info "Dependencies for ${SERVICE_NAME}:"
        pixi list
    elif [ "$action" = "update" ]; then
        log_info "Updating dependencies..."
        pixi update
        log_success "Dependencies updated"
    else
        log_error "Unknown action: ${action}"
        echo "Usage: $0 deps [list|update]"
    fi
}

cmd_lint() {
    log_info "Running linters for ${SERVICE_NAME}..."
    check_pixi
    pixi run lint || log_warn "Lint command not configured"
    log_success "Lint complete"
}

cmd_format() {
    log_info "Formatting code for ${SERVICE_NAME}..."
    check_pixi
    pixi run format || log_warn "Format command not configured"
    log_success "Format complete"
}

cmd_help() {
    echo "Service Management Script for ${SERVICE_NAME} (Python/FastAPI)"
    echo ""
    echo "Usage: ./svc.sh <command> [options]"
    echo ""
    echo "Commands:"
    echo "  install            Install dependencies"
    echo "  build              Build the service"
    echo "  test               Run tests"
    echo "  run [--env ENV]    Run locally (default: dev)"
    echo "  lint               Run linters"
    echo "  format             Format code"
    echo ""
    echo "  publish            Publish to PyPI"
    echo "  image [--local]    Build Docker image (and push unless --local)"
    echo ""
    echo "  version            Show current version"
    echo "  version bump       Increment patch version"
    echo "  tag                Create git tag"
    echo ""
    echo "  status             Check service health"
    echo "  logs [N]           Show last N lines of logs (default: 100)"
    echo "  validate           Validate configuration"
    echo "  rollback <v>       Rollback to version"
    echo ""
    echo "  images [list|clean]   Manage local images"
    echo "  deps [list|update]    Manage dependencies"
    echo ""
    echo "  help               Show this help"
    echo ""
    echo "Options:"
    echo "  --env ENV          Environment: dev, staging, prod (default: dev)"
    echo ""
    echo "Examples:"
    echo "  ./svc.sh install"
    echo "  ./svc.sh run --env staging"
    echo "  ./svc.sh image --local"
}

# =============================================================================
# Main
# =============================================================================

COMMAND="$1"
shift || true

case "$COMMAND" in
    install)   cmd_install ;;
    build)     cmd_build ;;
    test)      cmd_test ;;
    run)       cmd_run "$@" ;;
    lint)      cmd_lint ;;
    format)    cmd_format ;;
    publish)   cmd_publish ;;
    image)     cmd_image "$@" ;;
    version)   cmd_version "$@" ;;
    tag)       cmd_tag ;;
    status)    cmd_status ;;
    logs)      cmd_logs "$@" ;;
    validate)  cmd_validate ;;
    rollback)  cmd_rollback "$@" ;;
    images)    cmd_images "$@" ;;
    deps)      cmd_deps "$@" ;;
    help|--help|-h) cmd_help ;;
    "")        cmd_help ;;
    *)         log_error "Unknown command: $COMMAND"; cmd_help; exit 1 ;;
esac
