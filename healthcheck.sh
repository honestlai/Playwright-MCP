#!/bin/bash

# Simple health check script for Playwright MCP
# Checks if the MCP server is responding on port 8080

LOG_DIR="/app/logs"
HEALTH_LOG="$LOG_DIR/healthcheck.log"

# Function to log health check messages
log_health() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [HealthCheck] $1" | tee -a "$HEALTH_LOG"
}

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Check if MCP server is responding
log_health "Checking MCP server on port 8080..."

# Try to connect to the MCP endpoint
response=$(curl -s -w "%{http_code}" --max-time 5 "http://localhost:8080/mcp" 2>/dev/null)
http_code="${response: -3}"

if [ "$http_code" = "200" ] || [ "$http_code" = "400" ]; then
    log_health "✓ MCP server is healthy (HTTP $http_code)"
    exit 0
else
    log_health "✗ MCP server is unhealthy (HTTP $http_code)"
    exit 1
fi
