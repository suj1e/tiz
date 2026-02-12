#!/bin/bash

# Flutter Web Preview Script for ECS
# Usage: ecsPreviewWeb.sh {start|stop|restart|status}

set -e

# Configuration
FLUTTER_HOME="/root/flutter"
FLUTTER_BIN="$FLUTTER_HOME/bin/flutter"
PROJECT_DIR="/opt/dev/apps/tiz-mobile"
BUILD_DIR="$PROJECT_DIR/build/web"
PORT=42001
PID_FILE="$PROJECT_DIR/.ecs_preview_web.pid"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

echo_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo_usage() {
    echo "Usage: $0 {start|stop|restart|status}"
    echo ""
    echo "Commands:"
    echo "  start    - Build and start the web server"
    echo "  stop     - Stop the web server"
    echo "  restart  - Restart the web server"
    echo "  status   - Show server status"
    exit 1
}

# Function to get PID of process on port
get_port_pid() {
    lsof -ti:$PORT 2>/dev/null || true
}

# Function to check if server is running
is_running() {
    local pid=$(get_port_pid)
    if [ -n "$pid" ]; then
        return 0
    fi
    return 1
}

# Function to stop web server
stop_server() {
    echo_info "=========================================="
    echo_info "Stopping Flutter Web Server"
    echo_info "=========================================="
    echo ""

    local pid=$(get_port_pid)
    if [ -n "$pid" ]; then
        echo_info "Stopping web server on port $PORT (PID: $pid)..."
        kill -15 $pid 2>/dev/null || true
        sleep 2

        # Force kill if still running
        if is_running; then
            echo_warn "Graceful shutdown failed, forcing..."
            kill -9 $pid 2>/dev/null || true
            sleep 1
        fi

        if ! is_running; then
            echo_info "Web server stopped successfully"
            rm -f "$PID_FILE"
            return 0
        else
            echo_error "Failed to stop web server"
            return 1
        fi
    else
        echo_info "No web server running on port $PORT"
        rm -f "$PID_FILE"
        return 0
    fi
}

# Function to show server status
show_status() {
    echo_info "=========================================="
    echo_info "Flutter Web Server Status"
    echo_info "=========================================="
    echo ""

    local pid=$(get_port_pid)
    if [ -n "$pid" ]; then
        echo_info "Status: ${GREEN}Running${NC}"
        echo_info "Port: $PORT"
        echo_info "PID: $pid"
        echo_info "URL: http://localhost:$PORT"
        echo ""

        # Show process info
        echo_info "Process Details:"
        ps -p $pid -o pid,ppid,cmd 2>/dev/null || true
    else
        echo_warn "Status: ${YELLOW}Stopped${NC}"
        echo_info "No web server running on port $PORT"
    fi
    echo ""
}

# Function to compile Flutter web
build_flutter_web() {
    echo_info "Building Flutter web project..."
    cd "$PROJECT_DIR"

    # Clean previous build
    echo_info "Cleaning previous build..."
    "$FLUTTER_BIN" clean

    # Get dependencies
    echo_info "Getting dependencies..."
    "$FLUTTER_BIN" pub get

    # Build web release
    echo_info "Building web release..."
    "$FLUTTER_BIN" build web --release

    if [ -d "$BUILD_DIR" ]; then
        echo_info "Build successful! Output: $BUILD_DIR"
        return 0
    else
        echo_error "Build failed! $BUILD_DIR not found"
        return 1
    fi
}

# Function to start web server
start_server() {
    echo_info "=========================================="
    echo_info "Starting Flutter Web Server"
    echo_info "=========================================="
    echo ""

    # Check if Flutter exists
    if [ ! -f "$FLUTTER_BIN" ]; then
        echo_error "Flutter not found at $FLUTTER_BIN"
        exit 1
    fi

    # Check if already running
    if is_running; then
        local pid=$(get_port_pid)
        echo_warn "Web server is already running on port $PORT (PID: $pid)"
        echo_info "Use '$0 restart' to restart the server"
        exit 1
    fi

    # Build Flutter web
    if ! build_flutter_web; then
        echo_error "Build failed, exiting"
        exit 1
    fi

    # Start web server
    echo_info "Starting web server on port $PORT..."
    cd "$BUILD_DIR"

    # Start simple HTTP server in background
    nohup python3 -m http.server $PORT > /dev/null 2>&1 &
    SERVER_PID=$!

    # Save PID
    echo $SERVER_PID > "$PID_FILE"

    sleep 2

    # Verify server is running
    if is_running; then
        echo_info "=========================================="
        echo_info "Web server started successfully!"
        echo_info "=========================================="
        echo_info "URL:      http://localhost:$PORT"
        echo_info "Port:     $PORT"
        echo_info "PID:      $SERVER_PID"
        echo_info "Log file: /tmp/tiz-web.log"
        echo ""
        echo_info "Use '$0 stop' to stop the server"
        echo_info "Use '$0 status' to check status"
        echo ""
    else
        echo_error "Failed to start web server"
        rm -f "$PID_FILE"
        exit 1
    fi
}

# Main execution
main() {
    case "${1:-start}" in
        start)
            start_server
            ;;
        stop)
            stop_server
            ;;
        restart)
            stop_server
            sleep 1
            start_server
            ;;
        status)
            show_status
            ;;
        *)
            echo_usage
            ;;
    esac
}

# Run main function
main "$@"
