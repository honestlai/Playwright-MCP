# Playwright MCP Container

A robust, production-ready Docker container for running Playwright MCP (Model Context Protocol) with **command-based execution** to eliminate SSH tunnel connection issues.

## 🎯 **Problem Solved**

**Original Issue**: Cursor/VS Code MCP connections dropping over SSH tunnels, causing red/green bubble cycling.

**Root Cause**: URL-based MCP connections (`"url": "http://localhost:8081/mcp"`) over SSH tunnels create multiple failure points:
- Laptop → SSH tunnel → Cloudflare → server → Docker container → MCP server
- SSE timeouts after 5 minutes of idle time
- Persistent connections that can drop unexpectedly

**Solution**: **Command-based MCP configuration** that executes the MCP server directly inside the container, eliminating HTTP timeouts and connection state issues.

## 🚀 **Quick Start**

### **1. Start the Container**
```bash
docker compose up -d
```

### **2. Verify Container Health**
```bash
docker ps
```

### **3. Configure Your MCP Client**
Use the command-based configuration below.

## 📋 **MCP Client Configuration**

### **Command-Based Configuration (Recommended)**

**This eliminates SSH tunnel connection issues** by executing MCP directly in the container:

```json
{
  "mcpServers": {
    "Playwright_MCP": {
      "command": "docker",
      "args": [
        "exec",
        "-i",
        "Playwright-MCP",
        "npx",
        "@playwright/mcp@latest",
        "--port",
        "8080",
        "--host",
        "0.0.0.0",
        "--headless",
        "--isolated"
      ],
      "env": {
        "PLAYWRIGHT_BROWSERS_PATH": "/home/playwright/.cache/ms-playwright"
      }
    }
  }
}
```

### **Alternative: Enhanced HTTP Configuration**

If you prefer HTTP-based connections (less reliable over SSH):

```json
{
  "mcpServers": {
    "Playwright_MCP": {
      "url": "http://localhost:8081/mcp",
      "retryDelay": 1000,
      "maxRetries": 20,
      "timeout": 60000,
      "backoffMultiplier": 2.0,
      "maxRetryDelay": 15000,
      "connectionTimeout": 15000,
      "keepAlive": true,
      "retryOnTimeout": true,
      "retryOnConnectionError": true
    }
  }
}
```

## 🔧 **Management Commands**

### **Container Management**
```bash
# Start container
docker compose up -d

# Stop container
docker compose down

# Restart container
docker compose restart

# View logs
docker compose logs -f

# Check status
docker ps
```

### **Health Check**
```bash
# Test MCP endpoint
curl -v http://localhost:8081/mcp

# Check container health
docker inspect --format='{{.State.Health.Status}}' Playwright-MCP
```

## 🏗️ **Architecture**

### **Command-Based Approach (Recommended)**
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   VS Code       │    │   SSH Tunnel    │    │   Docker        │
│   / Cursor      │───▶│   (Cloudflare)  │───▶│   Container     │
│                 │    │                 │    │                 │
│ Command-based   │    │ No persistent   │    │ Direct MCP      │
│ MCP execution   │    │ connections     │    │ execution       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### **Why Command-Based Works Better**
- ✅ **No HTTP layer** to timeout
- ✅ **No persistent connections** that can drop
- ✅ **Fresh execution** for each MCP interaction
- ✅ **Direct communication** with container
- ✅ **Eliminates connection state issues**

## 🔍 **Monitoring & Troubleshooting**

### **Check Container Health**
```bash
# Check if container is running
docker ps

# Check container health status
docker inspect --format='{{.State.Health.Status}}' Playwright-MCP

# View container logs
docker logs Playwright-MCP
```

### **Test MCP Connection**
```bash
# Test HTTP endpoint (if using HTTP config)
curl -v http://localhost:8081/mcp

# Test command-based execution
docker exec -i Playwright-MCP npx @playwright/mcp@latest --help
```

### **Resource Usage**
```bash
# Check resource usage
docker stats Playwright-MCP

# Check memory usage
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

## 🛠️ **Troubleshooting**

### **Common Issues**

#### **1. Container Not Starting**
```bash
# Check logs for errors
docker compose logs

# Rebuild container
docker compose down
docker compose build --no-cache
docker compose up -d
```

#### **2. MCP Command Execution Fails**
```bash
# Test command manually
docker exec -i Playwright-MCP npx @playwright/mcp@latest --help

# Check container permissions
docker exec -it Playwright-MCP whoami
```

#### **3. VS Code/Cursor Can't Connect**
- Verify container is running: `docker ps`
- Check MCP configuration syntax
- Restart VS Code/Cursor after configuration changes
- Ensure Docker is accessible from your SSH session

### **Debugging Commands**
```bash
# Enter container for debugging
docker exec -it Playwright-MCP /bin/bash

# Check MCP process
docker exec Playwright-MCP ps aux | grep playwright

# Test MCP server directly
docker exec -i Playwright-MCP npx @playwright/mcp@latest --port 8080 --host 0.0.0.0
```

## 📊 **Performance & Reliability**

| Feature | Command-Based | HTTP-Based |
|---------|---------------|------------|
| **SSH Stability** | ✅ Excellent | ⚠️ Problematic |
| **Connection Drops** | ✅ None | ❌ Frequent |
| **Timeout Issues** | ✅ None | ❌ Common |
| **Setup Complexity** | ⚠️ Moderate | ✅ Simple |
| **Debugging** | ✅ Easy | ⚠️ Complex |

## 🎯 **Getting Started**

1. **Start the container**:
   ```bash
   docker compose up -d
   ```

2. **Configure your MCP client** using the command-based configuration above

3. **Test the connection**:
   ```bash
   docker exec -i Playwright-MCP npx @playwright/mcp@latest --help
   ```

4. **Monitor health**:
   ```bash
   docker ps
   docker logs Playwright-MCP
   ```

## 📝 **Configuration Files**

- `docker-compose.yml` - Container orchestration
- `Dockerfile` - Container image definition
- `healthcheck.sh` - Health monitoring script
- `cursor-mcp-config.json` - Example Cursor configuration

## 📚 **Documentation**

- **[MCP Client Setup Guide](MCP_CLIENT_SETUP.md)** - Detailed configuration guide
- **[Cursor Setup Guide](CURSOR_SETUP.md)** - VS Code/Cursor specific setup

## 🤝 **Contributing**

Feel free to submit issues and enhancement requests!

## 📄 **License**

This project is open source and available under the [MIT License](LICENSE).
