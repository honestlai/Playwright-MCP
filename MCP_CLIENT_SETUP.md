# MCP Client Setup Guide

Complete guide for setting up MCP clients to use the **Playwright MCP Container** with **command-based execution** to eliminate SSH tunnel connection issues.

## 🎯 **Overview**

This guide covers how to configure various MCP clients to connect to our **Playwright MCP container** using the **command-based approach** that eliminates SSH tunnel connection drops.

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

## 📋 **Recommended Configuration (Command-Based)**

**This is the recommended approach** - eliminates SSH tunnel connection issues:

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

### **Why Command-Based Works Better**
- ✅ **No HTTP layer** to timeout
- ✅ **No persistent connections** that can drop
- ✅ **Fresh execution** for each MCP interaction
- ✅ **Direct communication** with container
- ✅ **Eliminates connection state issues**

## 🔧 **Client-Specific Configurations**

### **VS Code / Cursor**

#### **Command-Based Configuration (Recommended)**
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

#### **Alternative: Enhanced HTTP Configuration**
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

### **Cursor-Specific Configuration**
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

### **Other MCP Clients**

#### **Simple Command-Based Configuration**
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
        "@playwright/mcp@latest"
      ]
    }
  }
}
```

## 🔍 **Testing Your Configuration**

### **1. Test Command-Based Execution**
```bash
# Test the command manually
docker exec -i Playwright-MCP npx @playwright/mcp@latest --help

# Test with specific arguments
docker exec -i Playwright-MCP npx @playwright/mcp@latest --port 8080 --host 0.0.0.0 --headless --isolated
```

Expected output:
```
Usage: npx @playwright/mcp@latest [options]

Options:
  --port <port>           Port to listen on (default: 8080)
  --host <host>           Host to bind to (default: 0.0.0.0)
  --headless              Run in headless mode
  --isolated              Run in isolated mode
  --help                  Show this help message
```

### **2. Test HTTP Endpoint (if using HTTP config)**
```bash
# Test HTTP endpoint
curl -v http://localhost:8081/mcp
```

**Note**: HTTP 400 responses are expected for GET requests to MCP endpoints.

### **3. Check Container Health**
```bash
# Check if container is running
docker ps

# Check container health status
docker inspect --format='{{.State.Health.Status}}' Playwright-MCP

# View container logs
docker logs Playwright-MCP
```

## 🔄 **How Command-Based Execution Works**

### **Execution Flow**
1. **VS Code Request**: VS Code needs to execute an MCP tool
2. **Command Execution**: VS Code runs `docker exec -i Playwright-MCP npx @playwright/mcp@latest ...`
3. **Fresh Process**: A new MCP server process starts in the container
4. **Tool Execution**: The MCP tool executes and returns results
5. **Process Cleanup**: The MCP server process terminates

### **Benefits Over HTTP**
- **No Persistent Connections**: Each interaction is fresh
- **No Timeout Issues**: No HTTP layer to timeout
- **No Connection State**: No connection state to maintain
- **SSH Friendly**: Works reliably over SSH tunnels

### **Expected Behavior**
- **VS Code Bubble**: Stays green consistently
- **Tool Execution**: Each tool call starts fresh
- **No Disconnections**: No persistent connections to drop
- **Reliable Performance**: Consistent behavior over SSH

## 🛠️ **Troubleshooting**

### **Common Issues**

#### **1. Command Execution Fails**
```bash
# Test command manually
docker exec -i Playwright-MCP npx @playwright/mcp@latest --help

# Check container permissions
docker exec -it Playwright-MCP whoami

# Check if npx is available
docker exec -it Playwright-MCP which npx
```

#### **2. Container Not Running**
```bash
# Check if container is running
docker ps

# Start container if needed
docker compose up -d

# Check logs for errors
docker logs Playwright-MCP
```

#### **3. VS Code/Cursor Can't Connect**
- Verify container is running: `docker ps`
- Check MCP configuration syntax
- Restart VS Code/Cursor after configuration changes
- Ensure Docker is accessible from your SSH session

#### **4. Permission Issues**
```bash
# Check container user
docker exec -it Playwright-MCP whoami

# Check file permissions
docker exec -it Playwright-MCP ls -la /home/playwright/.cache/ms-playwright

# Fix permissions if needed
docker exec -it Playwright-MCP chown -R playwright:playwright /home/playwright/.cache
```

### **Debugging Commands**

#### **Check Container Status**
```bash
# Check if container is running
docker ps

# Check container health
docker inspect --format='{{.State.Health.Status}}' Playwright-MCP

# View container logs
docker logs Playwright-MCP
```

#### **Test MCP Server**
```bash
# Test MCP server directly
docker exec -i Playwright-MCP npx @playwright/mcp@latest --port 8080 --host 0.0.0.0

# Check MCP process
docker exec Playwright-MCP ps aux | grep playwright
```

#### **Check Resource Usage**
```bash
# Check resource usage
docker stats Playwright-MCP

# Check memory usage
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

## 📊 **Performance Monitoring**

### **Health Metrics**
- **Container Health**: Should show "HEALTHY"
- **Command Execution**: < 2 seconds for MCP server startup
- **Memory Usage**: ~200MB for container
- **CPU Usage**: < 5% under normal load

### **Monitoring Commands**
```bash
# Real-time monitoring
watch -n 5 'docker ps && echo "---" && docker stats --no-stream Playwright-MCP'

# Log monitoring
docker logs -f Playwright-MCP

# Health monitoring
watch -n 10 'docker inspect --format="{{.State.Health.Status}}" Playwright-MCP'
```

## 🔧 **Advanced Configuration**

### **Custom Environment Variables**
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
        "PLAYWRIGHT_BROWSERS_PATH": "/home/playwright/.cache/ms-playwright",
        "NODE_ENV": "production",
        "PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD": "0"
      }
    }
  }
}
```

### **Alternative Container Names**
If your container has a different name:
```json
{
  "mcpServers": {
    "Playwright_MCP": {
      "command": "docker",
      "args": [
        "exec",
        "-i",
        "your-container-name",
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

## 🎯 **Best Practices**

### **1. Use Command-Based Configuration**
- Eliminates SSH tunnel connection issues
- Provides consistent behavior
- No persistent connection problems

### **2. Monitor Container Health**
- Check status regularly: `docker ps`
- Monitor logs for errors: `docker logs Playwright-MCP`
- Watch resource usage: `docker stats Playwright-MCP`

### **3. Test Configuration**
- Test command manually before using
- Verify container permissions
- Check environment variables

### **4. Keep Container Updated**
- Regularly rebuild container for security updates
- Monitor for new Playwright MCP versions
- Test after updates

## 📚 **Additional Resources**

- **[Cursor Setup Guide](CURSOR_SETUP.md)** - VS Code/Cursor specific setup
- **[Main README](README.md)** - Complete project overview

## 🎉 **Success Indicators**

Your setup is working correctly when:
- ✅ Container shows "HEALTHY" status
- ✅ VS Code bubble stays green consistently
- ✅ MCP tools execute without connection errors
- ✅ Command execution completes successfully
- ✅ No timeout or disconnection issues

**Your MCP client is now configured for maximum SSH stability!** 🚀
