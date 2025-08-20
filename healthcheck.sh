#!/bin/bash

# Health check script for Playwright MCP
# The MCP endpoint returns 400 for invalid requests, which is expected
# We consider the service healthy if we get any HTTP response

response=$(curl -s -w "%{http_code}" --max-time 5 http://localhost:8080/mcp 2>/dev/null)
http_code="${response: -3}"

# Consider healthy if we get any HTTP response (200, 400, etc.)
if [[ "$http_code" =~ ^[0-9]+$ ]] && [ "$http_code" -ge 200 ] && [ "$http_code" -lt 600 ]; then
    exit 0
else
    exit 1
fi
