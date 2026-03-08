#!/bin/bash
# Service Management Script for auth-service
# Usage: ./svc.sh <command> [options]

set -e

# =============================================================================
# Configuration
# =============================================================================

SERVICE_NAME="auth-service"
SERVICE_PORT="${PORT:-8101}"
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

check_gradle() {
    if ! command -v gradle &> /dev/null; then
        log_error "Gradle not found. Please install Gradle 9.3.1+"
        exit 1
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
        log_warn "Environment file not found: $env_file, using default"
        echo "${SCRIPT_DIR}/.env.dev"
    fi
}

get_version() {
    if [ -f "gradle.properties" ]; then
        grep -E "^version=" gradle.properties | cut -d'=' -f2 || echo "1.0.0-SNAPSHOT"
    else
        echo "1.0.0-SNAPSHOT"
    fi
}

# =============================================================================
# Commands
# =============================================================================

cmd_build() {
    log_info "Building ${SERVICE_NAME}..."
    check_gradle
    gradle :app:build --no-daemon
    log_success "Build complete"
}

cmd_test() {
    log_info "Running tests for ${SERVICE_NAME}..."
    check_gradle
    gradle :app:test --no-daemon
    log_success "Tests complete"
}

cmd_run() {
    local env="${1:-dev}"
    local env_file=$(get_env_file "$env")

    log_info "Running ${SERVICE_NAME} with environment: ${env}"
    check_gradle

    if [ -f "$env_file" ]; then
        export $(grep -v '^#' "$env_file" | xargs)
    fi

    gradle :app:bootRun --no-daemon
}

cmd_publish() {
    log_info "Publishing ${SERVICE_NAME} API to Maven..."
    check_gradle

    if [ -z "$ALIYUN_MAVEN_USERNAME" ] || [ -z "$ALIYUN_MAVEN_PASSWORD" ]; then
        log_error "ALIYUN_MAVEN_USERNAME and ALIYUN_MAVEN_PASSWORD must be set"
        log_info "Add to ~/.gradle/gradle.properties:"
        log_info "  aliyunMavenUsername=<username>"
        log_info "  aliyunMavenPassword=<password>"
        exit 1
    fi

    gradle :api:publish --no-daemon
    log_success "Published to Aliyun Maven"
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
        --build-arg ALIYUN_MAVEN_USERNAME="${ALIYUN_MAVEN_USERNAME:-}" \
        --build-arg ALIYUN_MAVEN_PASSWORD="${ALIYUN_MAVEN_PASSWORD:-}" \
        --build-arg PORT="${SERVICE_PORT}" \
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
        # Parse version
        local major minor patch
        IFS='.' read -r major minor patch <<< "${current%-SNAPSHOT}"
        patch=$((patch + 1))
        local new_version="${major}.${minor}.${patch}-SNAPSHOT"

        log_info "Bumping version: ${current} -> ${new_version}"
        if [ -f "gradle.properties" ]; then
            sed -i '' "s/^version=.*/version=${new_version}/" gradle.properties
            log_success "Version updated"
        else
            log_error "gradle.properties not found"
        fi
    else
        log_error "Unknown version action: ${action}"
        echo "Usage: $0 version [bump]"
    fi
}

cmd_tag() {
    local version=$(get_version)
    local tag_name="${SERVICE_NAME}/v${version%-SNAPSHOT}"

    log_info "Creating git tag: ${tag_name}"
    git tag -a "$tag_name" -m "Release ${tag_name}"
    log_success "Tag created: ${tag_name}"
    log_info "Push with: git push origin ${tag_name}"
}

cmd_status() {
    log_info "Checking ${SERVICE_NAME} status..."

    if curl -sf "http://localhost:${SERVICE_PORT}/actuator/health" > /dev/null 2>&1; then
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

    # Check Gradle
    if ! command -v gradle &> /dev/null; then
        log_error "Gradle not found"
        errors=$((errors + 1))
    else
        log_success "Gradle: $(gradle --version | head -1)"
    fi

    # Check Java
    if ! command -v java &> /dev/null; then
        log_error "Java not found"
        errors=$((errors + 1))
    else
        log_success "Java: $(java -version 2>&1 | head -1)"
    fi

    # Check Maven credentials
    if [ -z "$ALIYUN_MAVEN_USERNAME" ]; then
        log_warn "ALIYUN_MAVEN_USERNAME not set (required for publish)"
    else
        log_success "ALIYUN_MAVEN_USERNAME is set"
    fi

    if [ -z "$ALIYUN_MAVEN_PASSWORD" ]; then
        log_warn "ALIYUN_MAVEN_PASSWORD not set (required for publish)"
    else
        log_success "ALIYUN_MAVEN_PASSWORD is set"
    fi

    # Check Docker credentials
    if [ -z "$ALIYUN_REGISTRY_USERNAME" ]; then
        log_warn "ALIYUN_REGISTRY_USERNAME not set (required for image push)"
    else
        log_success "ALIYUN_REGISTRY_USERNAME is set"
    fi

    # Check env files
    for env in dev staging prod; do
        if [ -f "${SCRIPT_DIR}/.env.${env}" ]; then
            log_success ".env.${env} exists"
        else
            log_warn ".env.${env} not found"
        fi
    done

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
    check_gradle

    if [ -z "$action" ] || [ "$action" = "list" ]; then
        log_info "Dependencies for ${SERVICE_NAME}:"
        gradle :app:dependencies --no-daemon 2>/dev/null | head -100
    elif [ "$action" = "update" ]; then
        log_info "Checking for dependency updates..."
        gradle :app:dependencyUpdates --no-daemon 2>/dev/null || \
            log_warn "dependencyUpdates plugin not configured"
    else
        log_error "Unknown action: ${action}"
        echo "Usage: $0 deps [list|update]"
    fi
}

cmd_help() {
    echo "Service Management Script for ${SERVICE_NAME}"
    echo ""
    echo "Usage: ./svc.sh <command> [options]"
    echo ""
    echo "Commands:"
    echo "  build              Build the service"
    echo "  test               Run tests"
    echo "  run [--env ENV]    Run locally (default: dev)"
    echo ""
    echo "  publish            Publish API to Maven"
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
    echo "  ./svc.sh build"
    echo "  ./svc.sh run --env staging"
    echo "  ./svc.sh image --local"
    echo "  ./svc.sh publish"
}

# =============================================================================
# Main
# =============================================================================

COMMAND="$1"
shift || true

case "$COMMAND" in
    build)     cmd_build ;;
    test)      cmd_test ;;
    run)       cmd_run "$@" ;;
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
