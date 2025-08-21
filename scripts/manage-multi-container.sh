#!/bin/bash

# Multi-Container MCP Management Script
# This script manages the 5 separate MCP containers

COMPOSE_FILE="docker-compose-multi.yml"
LOG_FILE="/tmp/mcp-multi-container.log"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [MultiContainer] $1" | tee -a "$LOG_FILE"
}

# Function to check if containers are running
check_containers() {
    log_message "=== Checking Container Status ==="
    
    for i in {1..5}; do
        container_name="Playwright-MCP-$i"
        port=$((8080 + i))
        
        if docker ps --format "table {{.Names}}" | grep -q "^${container_name}$"; then
            # Check if the container is healthy
            health_status=$(docker inspect --format='{{.State.Health.Status}}' "$container_name" 2>/dev/null)
            
            if [ "$health_status" = "healthy" ]; then
                log_message "✓ Container $container_name (port $port): HEALTHY"
            elif [ "$health_status" = "unhealthy" ]; then
                log_message "✗ Container $container_name (port $port): UNHEALTHY"
            else
                log_message "⚠️  Container $container_name (port $port): $health_status"
            fi
        else
            log_message "✗ Container $container_name (port $port): NOT RUNNING"
        fi
    done
}

# Function to start all containers
start_containers() {
    log_message "Starting all MCP containers..."
    docker compose -f "$COMPOSE_FILE" up -d
    sleep 10
    check_containers
}

# Function to stop all containers
stop_containers() {
    log_message "Stopping all MCP containers..."
    docker compose -f "$COMPOSE_FILE" down
}

# Function to restart all containers
restart_containers() {
    log_message "Restarting all MCP containers..."
    docker compose -f "$COMPOSE_FILE" restart
    sleep 10
    check_containers
}

# Function to show logs
show_logs() {
    local container=${1:-"all"}
    
    if [ "$container" = "all" ]; then
        log_message "Showing logs for all containers..."
        docker compose -f "$COMPOSE_FILE" logs --tail=50
    else
        log_message "Showing logs for container $container..."
        docker logs --tail=50 "Playwright-MCP-$container"
    fi
}

# Function to test all endpoints
test_endpoints() {
    log_message "=== Testing All MCP Endpoints ==="
    
    for i in {1..5}; do
        port=$((8080 + i))
        url="http://localhost:$port/mcp"
        
        log_message "Testing endpoint $url..."
        
        response=$(curl -s -w "%{http_code}" --max-time 5 "$url" 2>/dev/null)
        http_code="${response: -3}"
        
        if [ "$http_code" = "200" ] || [ "$http_code" = "400" ]; then
            log_message "✓ Endpoint $url: HEALTHY (HTTP $http_code)"
        else
            log_message "✗ Endpoint $url: UNHEALTHY (HTTP $http_code)"
        fi
    done
}

# Main script logic
case "${1:-status}" in
    "start")
        start_containers
        ;;
    "stop")
        stop_containers
        ;;
    "restart")
        restart_containers
        ;;
    "status")
        check_containers
        ;;
    "logs")
        show_logs "$2"
        ;;
    "test")
        test_endpoints
        ;;
    "help"|"-h"|"--help")
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  start     - Start all MCP containers"
        echo "  stop      - Stop all MCP containers"
        echo "  restart   - Restart all MCP containers"
        echo "  status    - Check status of all containers (default)"
        echo "  logs [n]  - Show logs (all or container n)"
        echo "  test      - Test all MCP endpoints"
        echo "  help      - Show this help message"
        ;;
    *)
        log_message "Unknown command: $1"
        log_message "Use '$0 help' for usage information"
        exit 1
        ;;
esac
