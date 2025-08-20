#!/bin/bash

# Playwright MCP Monitoring Script
# This script helps monitor and maintain the Playwright MCP connection

CONTAINER_NAME="Playwright-MCP"
MCP_URL="http://localhost:8081/mcp"
LOG_FILE="/tmp/playwright-mcp-monitor.log"

echo "=== Playwright MCP Monitor ==="
echo "Started at: $(date)"
echo "Log file: $LOG_FILE"
echo ""

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to check container status
check_container() {
    if docker ps --format "table {{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
        log_message "✓ Container $CONTAINER_NAME is running"
        return 0
    else
        log_message "✗ Container $CONTAINER_NAME is not running"
        return 1
    fi
}

# Function to check container health
check_health() {
    local health_status=$(docker inspect --format='{{.State.Health.Status}}' "$CONTAINER_NAME" 2>/dev/null)
    if [ "$health_status" = "healthy" ]; then
        log_message "✓ Container health status: $health_status"
        return 0
    else
        log_message "✗ Container health status: $health_status"
        return 1
    fi
}

# Function to check MCP endpoint
check_mcp_endpoint() {
    local response=$(curl -s -w "%{http_code}" --max-time 5 "$MCP_URL" 2>/dev/null)
    local http_code="${response: -3}"
    
    if [ "$http_code" = "200" ] || [ "$http_code" = "400" ]; then
        log_message "✓ MCP endpoint responding (HTTP $http_code)"
        return 0
    else
        log_message "✗ MCP endpoint not responding (HTTP $http_code)"
        return 1
    fi
}

# Function to check process inside container
check_process() {
    if docker exec "$CONTAINER_NAME" pgrep -f "mcp-server-playwright" >/dev/null 2>&1; then
        log_message "✓ MCP server process is running inside container"
        return 0
    else
        log_message "✗ MCP server process is not running inside container"
        return 1
    fi
}

# Function to restart container if needed
restart_container() {
    log_message "🔄 Restarting container..."
    docker-compose down
    sleep 5
    docker-compose up -d
    sleep 10
    
    # Wait for container to be ready
    local attempts=0
    while [ $attempts -lt 30 ]; do
        if check_container && check_health && check_mcp_endpoint; then
            log_message "✓ Container restarted successfully"
            return 0
        fi
        sleep 2
        attempts=$((attempts + 1))
    done
    
    log_message "✗ Container restart failed after 60 seconds"
    return 1
}

# Function to show container logs
show_logs() {
    log_message "📋 Recent container logs:"
    docker logs --tail 20 "$CONTAINER_NAME" 2>&1 | while IFS= read -r line; do
        log_message "  $line"
    done
}

# Function to show system resources
show_resources() {
    log_message "📊 Container resource usage:"
    docker stats --no-stream "$CONTAINER_NAME" 2>&1 | while IFS= read -r line; do
        log_message "  $line"
    done
}

# Main monitoring loop
main() {
    log_message "Starting monitoring loop..."
    
    while true; do
        echo ""
        log_message "--- Health Check ---"
        
        local issues=0
        
        # Check container status
        if ! check_container; then
            issues=$((issues + 1))
        fi
        
        # Check health status
        if ! check_health; then
            issues=$((issues + 1))
        fi
        
        # Check MCP endpoint
        if ! check_mcp_endpoint; then
            issues=$((issues + 1))
        fi
        
        # Check process
        if ! check_process; then
            issues=$((issues + 1))
        fi
        
        # If there are issues, try to restart
        if [ $issues -gt 0 ]; then
            log_message "⚠️  Found $issues issue(s), attempting restart..."
            show_logs
            show_resources
            
            if restart_container; then
                log_message "✅ Issues resolved after restart"
            else
                log_message "❌ Failed to resolve issues"
            fi
        else
            log_message "✅ All checks passed"
        fi
        
        # Wait before next check
        log_message "Sleeping for 60 seconds..."
        sleep 60
    done
}

# Handle script arguments
case "${1:-monitor}" in
    "monitor")
        main
        ;;
    "status")
        echo "=== Quick Status Check ==="
        check_container
        check_health
        check_mcp_endpoint
        check_process
        ;;
    "restart")
        restart_container
        ;;
    "logs")
        show_logs
        ;;
    "resources")
        show_resources
        ;;
    *)
        echo "Usage: $0 [monitor|status|restart|logs|resources]"
        echo "  monitor   - Start continuous monitoring (default)"
        echo "  status    - Quick status check"
        echo "  restart   - Restart the container"
        echo "  logs      - Show recent logs"
        echo "  resources - Show resource usage"
        exit 1
        ;;
esac
