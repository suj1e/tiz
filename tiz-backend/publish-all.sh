#!/bin/bash
# Batch publish script for all services
# Usage: ./publish-all.sh [--changed] [--dry-run]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# Services to publish (in dependency order)
SERVICES=(
    "common"
    "llm-api"
    "auth-service"
    "chat-service"
    "content-service"
    "practice-service"
    "quiz-service"
    "user-service"
)

# Parse arguments
CHANGED_ONLY=false
DRY_RUN=false

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
        *)
            log_error "Unknown option: $1"
            echo "Usage: $0 [--changed] [--dry-run]"
            exit 1
            ;;
    esac
done

# Check if we're in the right directory
if [ ! -f "common/svc.sh" ]; then
    log_error "Please run this script from the tiz-backend directory"
    exit 1
fi

# Function to check if a directory has changes
has_changes() {
    local dir="$1"
    if [ "$CHANGED_ONLY" = false ]; then
        return 0  # Always publish if not filtering by changes
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

# Function to publish a service
publish_service() {
    local service="$1"
    local svc_dir="${SCRIPT_DIR}/${service}"

    if [ ! -f "${svc_dir}/svc.sh" ]; then
        log_warn "No svc.sh found for ${service}, skipping"
        return 1
    fi

    log_info "Publishing ${service}..."

    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would run: cd ${service} && ./svc.sh publish"
        return 0
    fi

    cd "$svc_dir"
    ./svc.sh publish
    local result=$?
    cd "$SCRIPT_DIR"

    if [ $result -eq 0 ]; then
        log_success "${service} published successfully"
    else
        log_error "Failed to publish ${service}"
        return 1
    fi
}

# Main
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

SUCCESS_COUNT=0
FAIL_COUNT=0
SKIPPED_COUNT=0

for service in "${SERVICES[@]}"; do
    if has_changes "$service"; then
        if publish_service "$service"; then
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
