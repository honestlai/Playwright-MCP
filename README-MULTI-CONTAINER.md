# Playwright MCP Multi-Container Setup

A reliable, scalable setup with **5 separate containers**, each running a single Playwright MCP instance for maximum stability and redundancy.

## 🎯 **Why Multi-Container is Better**

- **Complete Isolation**: Each MCP instance runs in its own container
- **Better Resource Management**: Individual memory and CPU allocation
- **Fault Tolerance**: If one container fails, others continue working
- **Easy Scaling**: Add or remove containers as needed
- **Simple Debugging**: Isolated logs and processes

## 🚀 **Quick Start**

### 1. Start All Containers
```bash
./scripts/manage-multi-container.sh start
```

### 2. Check Status
```bash
./scripts/manage-multi-container.sh status
```

### 3. Test All Endpoints
```bash
./scripts/manage-multi-container.sh test
```

## 📋 **Container Configuration**

| Container | Port | URL | Status |
|-----------|------|-----|--------|
| Playwright-MCP-1 | 8081 | `http://localhost:8081/mcp` | Primary |
| Playwright-MCP-2 | 8082 | `http://localhost:8082/mcp` | Secondary |
| Playwright-MCP-3 | 8083 | `http://localhost:8083/mcp` | Tertiary |
| Playwright-MCP-4 | 8084 | `http://localhost:8084/mcp` | Quaternary |
| Playwright-MCP-5 | 8085 | `http://localhost:8085/mcp` | Quinary |

## 🔧 **Management Commands**

```bash
# Start all containers
./scripts/manage-multi-container.sh start

# Stop all containers
./scripts/manage-multi-container.sh stop

# Restart all containers
./scripts/manage-multi-container.sh restart

# Check status of all containers
./scripts/manage-multi-container.sh status

# Show logs (all containers)
./scripts/manage-multi-container.sh logs

# Show logs for specific container
./scripts/manage-multi-container.sh logs 1

# Test all endpoints
./scripts/manage-multi-container.sh test

# Show help
./scripts/manage-multi-container.sh help
```

## 📝 **MCP Client Configuration**

Use this configuration in your MCP client for automatic failover:

```json
{
  "mcpServers": {
    "Playwright_MCP": {
      "url": "http://localhost:8081/mcp",
      "retryDelay": 500,
      "maxRetries": 15,
      "timeout": 45000,
      "backoffMultiplier": 1.5,
      "maxRetryDelay": 10000,
      "connectionTimeout": 10000,
      "keepAlive": true,
      "retryOnTimeout": true,
      "retryOnConnectionError": true,
      "fallbackUrls": [
        "http://localhost:8082/mcp",
        "http://localhost:8083/mcp",
        "http://localhost:8084/mcp",
        "http://localhost:8085/mcp"
      ]
    }
  }
}
```

## 🔍 **Monitoring & Troubleshooting**

### Check Container Health
```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### View Individual Container Logs
```bash
docker logs Playwright-MCP-1
docker logs Playwright-MCP-2
# ... etc
```

### Check Resource Usage
```bash
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

## 🛠 **Architecture Benefits**

1. **Isolation**: Each container is completely independent
2. **Reliability**: Container restart policies ensure availability
3. **Scalability**: Easy to add more containers
4. **Monitoring**: Individual health checks for each container
5. **Debugging**: Isolated logs and processes

## 🔄 **Automatic Recovery**

- **Restart Policy**: `unless-stopped` ensures containers restart automatically
- **Health Checks**: Each container has its own health monitoring
- **Load Balancing**: Your MCP client can automatically failover between instances

## 📊 **Performance**

- **Memory**: ~200MB per container
- **CPU**: Minimal overhead per container
- **Network**: Shared volumes for screenshots/downloads
- **Storage**: Shared browser cache for efficiency

This setup provides maximum reliability with minimal complexity!
