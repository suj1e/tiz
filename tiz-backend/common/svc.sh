#!/bin/bash
# Service Management Script for common (Shared Library)
# Usage: ./svc.sh <command> [options]
#
# Note: This is a library module, not a runnable service.
#       Commands like run, image, status are not available.

#
# Credentials can be set via:
#   1. Environment variables (preferred): ALIYUN_MAVEN_USERNAME, ALIYUN_MAVEN_PASSWORD
#   2. Global gradle.properties: aliyunMavenUsername, aliyunMavenPassword

set -e

# =============================================================================
# Configuration
# =============================================================================

SERVICE_NAME="common"
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

get_version() {
    if [ -f "gradle.properties" ]; then
        grep -E "^version=" gradle.properties | cut -d'=' -f2 || echo "1.0.0-SNAPSHOT"
    else
        echo "1.0.0-SNAPSHOT"
    fi
}

check_maven_credentials() {
    # Check if credentials are available (env vars or gradle.properties)
    local has_creds=false

    if [ -n "$ALIYUN_MAVEN_USERNAME" ] && [ -n "$ALIYUN_MAVEN_PASSWORD" ]; then
        has_creds=true
        log_info "Using credentials from environment variables"
    elif [ -f ~/.gradle/gradle.properties ]; then
        if grep -q "aliyunMavenUsername=" ~/.gradle/gradle.properties > /dev/null 2>&1; then
            has_creds=true
            log_info "Using credentials from ~/.gradle/gradle.properties"
        fi
    fi

    if [ "$has_creds" = false ]; then
        log_error "Maven credentials not configured"
        log_info ""
        log_info "Set credentials via environment variables (preferred):"
        log_info "  export ALIYUN_MAVEN_USERNAME=<username>"
        log_info "  export ALIYUN_MAVEN_PASSWORD=<password>"
        log_info ""
        log_info "Or add to ~/.gradle/gradle.properties:"
        log_info "  aliyunMavenUsername=<username>"
        log_info "  aliyunMavenPassword=<password>"
        exit 1
    fi
}

# =============================================================================
# Commands
# =============================================================================

cmd_build() {
    log_info "Building ${SERVICE_NAME}..."
    check_gradle
    gradle build --no-daemon
    log_success "Build complete"
}


cmd_test() {
    log_info "Running tests for ${SERVICE_NAME}..."
    check_gradle
    gradle test --no-daemon
    log_success "Tests complete"
}


cmd_publish() {
    log_info "Publishing ${SERVICE_NAME} to Aliyun Maven..."
    check_gradle
    check_maven_credentials

    gradle publish --no-daemon
    log_success "Published to Aliyun Maven"
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


cmd_validate() {
    log_info "Validating ${SERVICE_NAME} configuration..."

    local errors=0

    if ! command -v gradle &> /dev/null; then
        log_error "Gradle not found"
        errors=$((errors + 1))
    else
        log_success "Gradle: $(gradle --version | head -1)"
    fi

    if ! command -v java &> /dev/null; then
        log_error "Java not found"
        errors=$((errors + 1))
    else
        log_success "Java: $(java -version 2>&1 | head -1)"
    fi

    # Check credentials (env vars or gradle.properties)
    if [ -n "$ALIYUN_MAVEN_USERNAME" ] && [ -n "$ALIYUN_MAVEN_PASSWORD" ]; then
        log_success "ALIYUN_MAVEN_USERNAME is set (from env)"
        log_success "ALIYUN_MAVEN_PASSWORD is set (from env)"
    elif [ -f ~/.gradle/gradle.properties ] && grep -q "aliyunMavenUsername=" ~/.gradle/gradle.properties > /dev/null 2>&1; then
        log_success "Maven credentials configured in ~/.gradle/gradle.properties"
    else
        log_warn "Maven credentials not configured (required for publish)"
        log_info "  Set via: export ALIYUN_MAVEN_USERNAME=<username>"
        log_info "  Or add to ~/.gradle/gradle.properties"
    fi

    if [ -f "gradle.properties" ]; then
        log_success "gradle.properties exists"
    else
        log_error "gradle.properties not found"
        errors=$((errors + 1))
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
    check_gradle

    if [ -z "$action" ] || [ "$action" = "list" ]; then
        log_info "Dependencies for ${SERVICE_NAME}:"
        gradle dependencies --no-daemon 2>/dev/null | head -100
    elif [ "$action" = "update" ]; then
        log_info "Checking for dependency updates..."
        gradle dependencyUpdates --no-daemon 2>/dev/null || \
            log_warn "dependencyUpdates plugin not configured"
    else
        log_error "Unknown action: ${action}"
        echo "Usage: $0 deps [list|update]"
    fi
}

cmd_help() {
    echo "Service Management Script for ${SERVICE_NAME} (Shared Library)"
    echo ""
    echo "Usage: ./svc.sh <command> [options]"
    echo ""
    echo "Commands:"
    echo "  build              Build the library"
    echo "  test               Run tests"
    echo "  publish            Publish to Aliyun Maven"
    echo ""
    echo "  version            Show current version"
    echo "  version bump       Increment patch version"
    echo "  tag                Create git tag"
    echo ""
    echo "  validate           Validate configuration"
    echo "  deps [list|update] Manage dependencies"
    echo ""
    echo "  help               Show this help"
    echo ""
    echo "Credentials for publish:"
    echo "  Environment variables (preferred):"
    echo "    ALIYUN_MAVEN_USERNAME, ALIYUN_MAVEN_PASSWORD"
    echo "  Or ~/.gradle/gradle.properties:"
    echo "    aliyunMavenUsername, aliyunMavenPassword"
    echo ""
    echo "Note: This is a library module, not a runnable service."
    echo "      Commands run, image, status, logs, rollback, images are not available."
}

# =============================================================================
# Main
# =============================================================================

COMMAND="$1"
shift || true

case "$COMMAND" in
    build)     cmd_build ;;
    test)      cmd_test ;;
    publish)   cmd_publish ;;
    version)   cmd_version "$@" ;;
    tag)       cmd_tag ;;
    validate)  cmd_validate ;;
    deps)      cmd_deps "$@" ;;
    help|--help|-h) cmd_help ;;
    "")        cmd_help ;;
    run|image|status|logs|rollback|images)
        log_error "Command '$COMMAND' not available for library modules"
        log_info "This is a library, not a runnable service"
        exit 1
        ;;
    *)         log_error "Unknown command: $COMMAND"; cmd_help; exit 1 ;;
esac
