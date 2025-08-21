# Playwright MCP Docker Container

A simple dockerized setup of Playwright MCP for browser automation.

## About This Project

While Playwright is a great tool set up by Microsoft, I couldn't find any simple information on how to stand this up as a Docker container. The little guidance I got from GPT had me stand up a container that was DOA (Dead On Arrival), so I decided to just make a quick and dirty dockerized setup of it that my dev containers / Cursor can access easily.

## 🚀 What Playwright MCP Can Do

The Playwright MCP is a **game-changer for web development** in Cursor/VS Code. It provides:

- **Full browser automation** directly from your editor
- **Web scraping and testing** without leaving your IDE
- **Screenshot capture** and visual testing
- **Form filling and navigation** automation
- **PDF generation** from web pages
- **Mobile device emulation** for responsive testing
- **Network interception** and debugging
- **Performance monitoring** and metrics

This MCP transforms your development workflow by bringing browser automation capabilities right into your coding environment, making web app development, testing, and debugging incredibly efficient.

## 🏗️ Architecture

This container provides two connection modes optimized for different deployment scenarios:

### **Command-Based Mode (Recommended for SSH/Remote)**
- **Best for**: SSH tunnels, remote servers, Cloudflare connections
- **How it works**: Client executes MCP server directly via `docker exec`
- **Benefits**: No persistent HTTP connections, eliminates timeout issues
- **Use case**: When you're connecting over SSH or experiencing connection drops

### **HTTP Mode (Suitable for Local)**
- **Best for**: Local development, direct connections
- **How it works**: MCP server runs as HTTP service on port 8080
- **Benefits**: Standard MCP protocol, familiar HTTP endpoints
- **Use case**: When running locally without network issues

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose installed
- Cursor or VS Code with MCP support

### 1. Clone and Start
```bash
git clone <repository-url>
cd Playwright-MCP
docker compose up -d
```

### 2. Configure Your MCP Client

#### For Command-Based Mode (SSH/Remote Recommended)
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

#### For HTTP Mode (Local Development)
```json
{
  "mcpServers": {
    "Playwright_MCP": {
      "url": "http://localhost:8081/mcp"
    }
  }
}
```

### 3. Verify Installation
```bash
# Check container status
docker ps | grep Playwright-MCP

# Test command-based execution
docker exec -i Playwright-MCP npx @playwright/mcp@latest --headless --isolated --help
```

## 📊 Connection Mode Comparison

| Feature | Command-Based | HTTP Mode |
|---------|---------------|-----------|
| **SSH Stability** | ✅ Excellent | ⚠️ May timeout |
| **Connection Drops** | ✅ None | ⚠️ Can occur |
| **Setup Complexity** | ⚠️ More config | ✅ Simple |
| **Performance** | ✅ Optimal | ✅ Good |
| **Local Development** | ✅ Works | ✅ Works |
| **Remote Development** | ✅ Recommended | ❌ Not recommended |

## 🔧 Configuration

### Environment Variables
```yaml
# docker-compose.yml
environment:
  - PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
  - NODE_ENV=production
```

### Port Mapping
```yaml
ports:
  - "127.0.0.1:8081:8080"  # HTTP mode endpoint
```

### Resource Limits
```yaml
mem_limit: 4g
mem_reservation: 2g
```

## 🛠️ Usage Examples

### Basic Browser Automation
```javascript
// Navigate to a website
await browser.navigate({ url: "https://example.com" });

// Take a screenshot
await browser.take_screenshot({ 
  filename: "screenshot.png",
  fullPage: true 
});

// Fill a form
await browser.type({ 
  element: "input[name='username']", 
  text: "myuser" 
});
```

### Advanced Features
```javascript
// Mobile emulation
await browser.navigate({ 
  url: "https://example.com",
  device: "iPhone 15" 
});

// PDF generation
await browser.evaluate({ 
  function: "() => window.print()" 
});

// Network monitoring
await browser.network_requests();
```

## 🔍 Troubleshooting

### Container Health
```bash
# Check container status
docker ps | grep Playwright-MCP

# View logs
docker logs Playwright-MCP

# Health check
curl -v http://localhost:8081/mcp
```

### Common Issues

#### Connection Drops (SSH/Remote)
- **Solution**: Switch to command-based mode
- **Why**: Eliminates persistent HTTP connections that can timeout

#### Container Won't Start
- **Check**: Port 8081 availability
- **Fix**: `docker compose down && docker compose up -d`

#### MCP Tools Not Available
- **Check**: Client configuration
- **Verify**: Container is healthy and running

## 📈 Performance

### Resource Usage
- **Memory**: ~200MB typical usage
- **CPU**: Low usage during idle
- **Network**: Minimal overhead

### Optimization Tips
- Use `--headless` mode for automation
- Enable `--isolated` for clean sessions
- Monitor resource usage with `docker stats`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- [Playwright](https://playwright.dev/) for the amazing browser automation framework
- [Model Context Protocol](https://modelcontextprotocol.io/) for the MCP specification
- The Cursor/VS Code community for MCP integration

---

**Ready to transform your web development workflow?** 🚀

This Playwright MCP container brings powerful browser automation directly into your development environment, making web app development, testing, and debugging incredibly efficient. Whether you're building web applications, scraping data, or testing user interfaces, this MCP provides the tools you need right in your editor.
