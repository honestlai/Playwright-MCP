# MCP Client Setup Guide

Complete guide for setting up MCP clients to use the **Playwright MCP Multi-Container Setup** with automatic failover and redundancy.

## 🎯 **Overview**

This guide covers how to configure various MCP clients to connect to our **5-container Playwright MCP setup**:

- **Primary**: `http://localhost:8081/mcp`
- **Secondary**: `http://localhost:8082/mcp`
- **Tertiary**: `http://localhost:8083/mcp`
- **Quaternary**: `http://localhost:8084/mcp`
- **Quinary**: `http://localhost:8085/mcp`

## 🚀 **Quick Start**

### **1. Start the Multi-Container Setup**
```bash
./scripts/manage-multi-container.sh start
```

### **2. Test All Endpoints**
```bash
./scripts/manage-multi-container.sh test
```

### **3. Configure Your MCP Client**
Use one of the configurations below based on your client.

## 📋 **Recommended Configuration (Single MCP with Fallbacks)**

**This is the recommended approach** - one MCP entry with automatic failover:

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

### **Why This Approach?**
- ✅ **Automatic failover** - VS Code handles switching between endpoints
- ✅ **Simpler configuration** - one entry to manage
- ✅ **Better user experience** - shows as one reliable MCP server
- ✅ **No manual intervention** - failover happens transparently

## 🔧 **Client-Specific Configurations**

### **VS Code / Cursor**

#### **Option 1: Single MCP with Fallbacks (Recommended)**
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

#### **Option 2: Multiple Separate MCPs**
```json
{
  "mcpServers": {
    "Playwright_MCP_1": {
      "url": "http://localhost:8081/mcp"
    },
    "Playwright_MCP_2": {
      "url": "http://localhost:8082/mcp"
    },
    "Playwright_MCP_3": {
      "url": "http://localhost:8083/mcp"
    },
    "Playwright_MCP_4": {
      "url": "http://localhost:8084/mcp"
    },
    "Playwright_MCP_5": {
      "url": "http://localhost:8085/mcp"
    }
  }
}
```

### **Cursor-Specific Configuration**
```json
{
  "mcpServers": {
    "Playwright_MCP": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-playwright"],
      "env": { "PLAYWRIGHT_BROWSERS_PATH": "0" },
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

### **Other MCP Clients**

#### **Simple Configuration**
```json
{
  "mcpServers": {
    "Playwright_MCP": {
      "url": "http://localhost:8081/mcp",
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

## 🔍 **Testing Your Configuration**

### **1. Test All Endpoints**
```bash
./scripts/manage-multi-container.sh test
```

Expected output:
```
[MultiContainer] === Testing All MCP Endpoints ===
[MultiContainer] Testing endpoint http://localhost:8081/mcp...
[MultiContainer] ✓ Endpoint http://localhost:8081/mcp: HEALTHY (HTTP 400)
[MultiContainer] Testing endpoint http://localhost:8082/mcp...
[MultiContainer] ✓ Endpoint http://localhost:8082/mcp: HEALTHY (HTTP 400)
...
```

### **2. Test Individual Endpoints**
```bash
# Test primary endpoint
curl -v http://localhost:8081/mcp

# Test secondary endpoint
curl -v http://localhost:8082/mcp
```

**Note**: HTTP 400 responses are expected for GET requests to MCP endpoints.

### **3. Check Container Health**
```bash
./scripts/manage-multi-container.sh status
```

Expected output:
```
[MultiContainer] === Checking Container Status ===
[MultiContainer] ✓ Container Playwright-MCP-1 (port 8081): HEALTHY
[MultiContainer] ✓ Container Playwright-MCP-2 (port 8082): HEALTHY
[MultiContainer] ✓ Container Playwright-MCP-3 (port 8083): HEALTHY
[MultiContainer] ✓ Container Playwright-MCP-4 (port 8084): HEALTHY
[MultiContainer] ✓ Container Playwright-MCP-5 (port 8085): HEALTHY
```

## 🔄 **Failover Behavior**

### **How Failover Works**
1. **Primary Connection**: VS Code connects to `http://localhost:8081/mcp`
2. **Failure Detection**: If primary fails, VS Code detects the failure
3. **Automatic Switch**: VS Code automatically tries `http://localhost:8082/mcp`
4. **Continue Process**: If secondary fails, tries tertiary, and so on
5. **Recovery**: When primary recovers, VS Code may switch back

### **Failover Timing**
- **Detection Time**: ~500ms (retryDelay)
- **Switch Time**: ~1-2 seconds
- **Total Recovery**: ~2-3 seconds

### **Expected Behavior**
- **VS Code Bubble**: Stays green as long as at least one endpoint is healthy
- **Connection**: Seamlessly switches between healthy endpoints
- **User Experience**: No interruption in MCP functionality

## 🛠️ **Troubleshooting**

### **Common Issues**

#### **1. All Endpoints Unhealthy**
```bash
# Check if containers are running
docker ps

# Restart all containers
./scripts/manage-multi-container.sh restart

# Check logs for errors
./scripts/manage-multi-container.sh logs
```

#### **2. VS Code Can't Connect**
- Verify containers are running: `./scripts/manage-multi-container.sh status`
- Check firewall settings
- Ensure VS Code MCP extension is installed
- Restart VS Code after configuration changes

#### **3. Slow Failover**
- Increase `retryDelay` to 1000ms
- Increase `maxRetries` to 20
- Check network connectivity

#### **4. Memory Issues**
```bash
# Check resource usage
docker stats

# Restart containers if needed
./scripts/manage-multi-container.sh restart
```

### **Debugging Commands**

#### **Check Container Logs**
```bash
# All containers
./scripts/manage-multi-container.sh logs

# Specific container
./scripts/manage-multi-container.sh logs 1
```

#### **Check Resource Usage**
```bash
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

#### **Check Network Connectivity**
```bash
# Test each endpoint
for port in 8081 8082 8083 8084 8085; do
  echo "Testing port $port..."
  curl -s -w "HTTP %{http_code}\n" http://localhost:$port/mcp
done
```

## 📊 **Performance Monitoring**

### **Health Metrics**
- **Container Health**: All 5 containers should show "HEALTHY"
- **Response Time**: < 100ms for healthy endpoints
- **Memory Usage**: ~200MB per container
- **CPU Usage**: < 5% per container under normal load

### **Monitoring Commands**
```bash
# Real-time monitoring
watch -n 5 './scripts/manage-multi-container.sh status'

# Resource monitoring
docker stats

# Log monitoring
./scripts/manage-multi-container.sh logs | tail -f
```

## 🔧 **Advanced Configuration**

### **Custom Retry Settings**
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

### **Load Balancing Configuration**
```json
{
  "mcpServers": {
    "Playwright_MCP": {
      "url": "http://localhost:8081/mcp",
      "loadBalancing": true,
      "healthCheckInterval": 30000,
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

## 🎯 **Best Practices**

### **1. Use Single MCP with Fallbacks**
- Simpler configuration
- Automatic failover
- Better user experience

### **2. Monitor Health Regularly**
- Check status daily: `./scripts/manage-multi-container.sh status`
- Monitor logs for errors: `./scripts/manage-multi-container.sh logs`
- Watch resource usage: `docker stats`

### **3. Test Failover**
- Periodically test by stopping one container
- Verify VS Code switches to another endpoint
- Ensure no interruption in functionality

### **4. Keep Containers Updated**
- Regularly rebuild containers for security updates
- Monitor for new Playwright MCP versions
- Test after updates

## 📚 **Additional Resources**

- **[Multi-Container Setup Guide](README-MULTI-CONTAINER.md)** - Detailed setup instructions
- **[Final Setup Summary](FINAL_SETUP_SUMMARY.md)** - Complete overview
- **[Cursor Setup Guide](CURSOR_SETUP.md)** - VS Code/Cursor specific setup

## 🎉 **Success Indicators**

Your setup is working correctly when:
- ✅ All 5 containers show "HEALTHY" status
- ✅ VS Code bubble stays green
- ✅ MCP tools are available and responsive
- ✅ No connection errors in VS Code
- ✅ Automatic failover works when containers restart

**Your MCP client is now configured for maximum reliability!** 🚀
