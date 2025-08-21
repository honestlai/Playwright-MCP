# Playwright MCP Container

A production-ready Docker container for running Playwright MCP (Model Context Protocol) with support for both HTTP and command-based execution modes.

## 🎯 **Overview**

This container provides a robust Playwright MCP server that can be used with VS Code, Cursor, and other MCP-compatible clients. It supports two connection modes:

- **Command-based execution** (recommended for SSH/remote connections)
- **HTTP-based connections** (suitable for local development)

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
Choose the configuration that best fits your setup (see below).

## 📋 **MCP Client Configuration**

### **Command-Based Configuration (Recommended for SSH/Remote)**

Command-based execution is ideal when connecting over SSH tunnels or remote connections. It eliminates HTTP timeouts and connection state issues by executing the MCP server directly in the container for each interaction.

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
        "--headless",
        "--isolated"
      ]
    }
  }
}
```

**Benefits of Command-Based Mode:**
- ✅ **No HTTP timeouts** - Each interaction is a fresh execution
- ✅ **No persistent connections** - Eliminates connection drops
- ✅ **SSH tunnel friendly** - Works reliably over remote connections
- ✅ **No connection state issues** - Each request is independent

### **HTTP-Based Configuration (Suitable for Local Development)**

HTTP-based connections are simpler to set up and work well for local development environments.

```json
{
  "mcpServers": {
    "Playwright_MCP": {
      "url": "http://localhost:8081/mcp",
      "retryDelay": 1000,
      "maxRetries": 10,
      "timeout": 30000,
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
# Test MCP endpoint (for HTTP mode)
curl -v http://localhost:8081/mcp

# Check container health
docker inspect --format='{{.State.Health.Status}}' Playwright-MCP

# Test command-based execution
docker exec -i Playwright-MCP npx @playwright/mcp@latest --help
```

## 🏗️ **Architecture**

### **Command-Based Mode**
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   VS Code       │    │   SSH Tunnel    │    │   Docker        │
│   / Cursor      │───▶│   (Optional)    │───▶│   Container     │
│                 │    │                 │    │                 │
│ Command-based   │    │ No persistent   │    │ Direct MCP      │
│ MCP execution   │    │ connections     │    │ execution       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### **HTTP Mode**
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   VS Code       │    │   HTTP/SSE      │    │   Docker        │
│   / Cursor      │───▶│   Connection    │───▶│   Container     │
│                 │    │                 │    │                 │
│ HTTP-based      │    │ Persistent      │    │ MCP HTTP        │
│ MCP connection  │    │ connection      │    │ server          │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

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
- Ensure Docker is accessible from your environment

### **Debugging Commands**
```bash
# Enter container for debugging
docker exec -it Playwright-MCP /bin/bash

# Check MCP process
docker exec Playwright-MCP ps aux | grep playwright

# Test MCP server directly
docker exec -i Playwright-MCP npx @playwright/mcp@latest --headless --isolated
```

## 📊 **Connection Mode Comparison**

| Feature | Command-Based | HTTP-Based |
|---------|---------------|------------|
| **SSH/Remote Stability** | ✅ Excellent | ⚠️ May have issues |
| **Connection Drops** | ✅ None | ⚠️ Possible |
| **Timeout Issues** | ✅ None | ⚠️ May occur |
| **Setup Complexity** | ⚠️ Moderate | ✅ Simple |
| **Local Development** | ✅ Works | ✅ Works |
| **Debugging** | ✅ Easy | ⚠️ Moderate |

## 🎯 **Getting Started**

1. **Start the container**:
   ```bash
   docker compose up -d
   ```

2. **Choose your configuration**:
   - Use **command-based** for SSH/remote connections
   - Use **HTTP-based** for local development

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
