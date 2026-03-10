#!/bin/bash
# Service Management Script for tiz-web (React + TypeScript + Vite)
# Usage: ./svc.sh <command> [options]

set -e

# =============================================================================
# Configuration
# =============================================================================

SERVICE_NAME="tiz-web"
SERVICE_PORT="${PORT:-80}"
DEV_PORT="${DEV_PORT:-5173}"
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

check_pnpm() {
    if ! command -v pnpm &> /dev/null; then
        log_error "pnpm not found. Please install: npm install -g pnpm"
        exit 1
    fi
}

ensure_dependencies() {
    if [ ! -d "node_modules" ]; then
        log_warn "node_modules not found, installing dependencies..."
        pnpm install
    fi
}

check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker not found. Please install Docker"
        exit 1
    fi
}

get_version() {
    if [ -f "package.json" ]; then
        grep -E '"version":' package.json | head -1 | cut -d'"' -f4 || echo "0.0.0"
    else
        echo "0.0.0"
    fi
}

# =============================================================================
# Commands
# =============================================================================

cmd_install() {
    log_info "Installing dependencies for ${SERVICE_NAME}..."
    check_pnpm
    pnpm install
    log_success "Dependencies installed"
}

cmd_build() {
    log_info "Building ${SERVICE_NAME} for production..."
    check_pnpm
    ensure_dependencies
    pnpm build
    log_success "Build complete: dist/"
}

cmd_dev() {
    local mock="${1:-false}"

    log_info "Starting ${SERVICE_NAME} development server..."
    check_pnpm
    ensure_dependencies

    if [ "$mock" = "--mock" ] || [ "$mock" = "-m" ]; then
        log_info "Running with mock mode (no backend needed)"
        VITE_MOCK=true pnpm dev
    else
        log_info "Running with backend connection"
        pnpm dev
    fi
}

cmd_preview() {
    log_info "Previewing production build..."
    check_pnpm
    ensure_dependencies

    if [ ! -d "dist" ]; then
        log_error "No build found. Run './svc.sh build' first"
        exit 1
    fi

    pnpm preview
}

cmd_test() {
    local coverage="${1:-false}"

    log_info "Running tests for ${SERVICE_NAME}..."
    check_pnpm
    ensure_dependencies

    if [ "$coverage" = "--coverage" ] || [ "$coverage" = "-c" ]; then
        pnpm test:coverage
    else
        pnpm test:run
    fi
    log_success "Tests complete"
}

cmd_lint() {
    log_info "Running linters for ${SERVICE_NAME}..."
    check_pnpm
    ensure_dependencies
    pnpm lint
    log_success "Lint complete"
}

cmd_format() {
    log_info "Formatting code for ${SERVICE_NAME}..."
    check_pnpm
    npx prettier --write "src/**/*.{ts,tsx,css,json}"
    log_success "Format complete"
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
        if [ -f "package.json" ]; then
            # Use sed to update version in package.json (Linux compatible)
            sed -i "s/\"version\": \"${current}\"/\"version\": \"${new_version}\"/" package.json
            log_success "Version updated"
        else
            log_error "package.json not found"
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

    # Check development server
    if curl -sf "http://localhost:${DEV_PORT}" > /dev/null 2>&1; then
        log_success "Dev server running on port ${DEV_PORT}"
    else
        log_info "Dev server not running on port ${DEV_PORT}"
    fi

    # Check production container
    if docker ps --format '{{.Names}}' | grep -q "^${SERVICE_NAME}$"; then
        log_success "Docker container ${SERVICE_NAME} is running"
        if curl -sf "http://localhost:${SERVICE_PORT}" > /dev/null 2>&1; then
            log_success "Production server healthy (port ${SERVICE_PORT})"
        else
            log_warn "Production server not responding on port ${SERVICE_PORT}"
        fi
    else
        log_info "Docker container ${SERVICE_NAME} not running"
    fi
}

cmd_logs() {
    local lines="${1:-100}"
    log_info "Showing last ${lines} lines of logs..."

    if docker ps --format '{{.Names}}' | grep -q "^${SERVICE_NAME}$"; then
        docker logs --tail "$lines" "${SERVICE_NAME}"
    else
        log_warn "Container ${SERVICE_NAME} not running"
    fi
}

cmd_validate() {
    log_info "Validating ${SERVICE_NAME} configuration..."

    local errors=0

    if ! command -v pnpm &> /dev/null; then
        log_error "pnpm not found"
        errors=$((errors + 1))
    else
        log_success "pnpm: $(pnpm --version)"
    fi

    if ! command -v node &> /dev/null; then
        log_error "Node.js not found"
        errors=$((errors + 1))
    else
        log_success "Node: $(node --version)"
    fi

    if [ -f "package.json" ]; then
        log_success "package.json exists"
    else
        log_error "package.json not found"
        errors=$((errors + 1))
    fi

    if [ -f "vite.config.ts" ]; then
        log_success "vite.config.ts exists"
    else
        log_error "vite.config.ts not found"
        errors=$((errors + 1))
    fi

    if [ -f "Dockerfile" ]; then
        log_success "Dockerfile exists"
    else
        log_warn "Dockerfile not found"
    fi

    if [ $errors -gt 0 ]; then
        log_error "Validation failed with ${errors} error(s)"
        exit 1
    else
        log_success "Validation passed"
    fi
}

cmd_deps() {
    local action="$1"
    check_pnpm

    if [ -z "$action" ] || [ "$action" = "list" ]; then
        log_info "Dependencies for ${SERVICE_NAME}:"
        pnpm list --depth=0
    elif [ "$action" = "outdated" ]; then
        log_info "Checking for outdated dependencies..."
        pnpm outdated
    elif [ "$action" = "update" ]; then
        log_info "Updating dependencies..."
        pnpm update
        log_success "Dependencies updated"
    else
        log_error "Unknown action: ${action}"
        echo "Usage: $0 deps [list|outdated|update]"
    fi
}

cmd_clean() {
    log_info "Cleaning build artifacts..."
    rm -rf dist/
    rm -rf node_modules/.vite/
    rm -rf coverage/
    log_success "Cleaned dist/, cache, and coverage/"
}

cmd_help() {
    echo "Service Management Script for ${SERVICE_NAME} (React + TypeScript + Vite)"
    echo ""
    echo "Usage: ./svc.sh <command> [options]"
    echo ""
    echo "Commands:"
    echo "  install            Install dependencies"
    echo "  build              Build for production"
    echo "  dev [--mock|-m]    Start dev server (use --mock for mock mode)"
    echo "  preview            Preview production build"
    echo "  test [--coverage]  Run tests"
    echo "  lint               Run linters"
    echo "  format             Format code with Prettier"
    echo "  clean              Clean build artifacts"
    echo ""
    echo "  image [--local]    Build Docker image (and push unless --local)"
    echo ""
    echo "  version            Show current version"
    echo "  version bump       Increment patch version"
    echo "  tag                Create git tag"
    echo ""
    echo "  status             Check service health"
    echo "  logs [N]           Show last N lines of container logs (default: 100)"
    echo "  validate           Validate configuration"
    echo "  deps [list|outdated|update]   Manage dependencies"
    echo ""
    echo "  help               Show this help"
    echo ""
    echo "Examples:"
    echo "  ./svc.sh dev              # Start dev server with backend"
    echo "  ./svc.sh dev --mock       # Start dev server with mock data"
    echo "  ./svc.sh build            # Build for production"
    echo "  ./svc.sh test --coverage  # Run tests with coverage"
    echo "  ./svc.sh image --local    # Build Docker image without pushing"
}

# =============================================================================
# Main
# =============================================================================

COMMAND="$1"
shift || true

case "$COMMAND" in
    install)   cmd_install ;;
    build)     cmd_build ;;
    dev)       cmd_dev "$@" ;;
    preview)   cmd_preview ;;
    test)      cmd_test "$@" ;;
    lint)      cmd_lint ;;
    format)    cmd_format ;;
    clean)     cmd_clean ;;
    image)     cmd_image "$@" ;;
    version)   cmd_version "$@" ;;
    tag)       cmd_tag ;;
    status)    cmd_status ;;
    logs)      cmd_logs "$@" ;;
    validate)  cmd_validate ;;
    deps)      cmd_deps "$@" ;;
    help|--help|-h) cmd_help ;;
    "")        cmd_help ;;
    *)         log_error "Unknown command: $COMMAND"; cmd_help; exit 1 ;;
esac
