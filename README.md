# Playwright MCP Docker Container

A simple dockerized setup of Playwright MCP for browser automation.

## About This Project

While Playwright is a great tool set up by Microsoft, I couldn't find any simple information on how to stand this up as a Docker container. The little guidance I got from GPT had me stand up a container that was DOA (Dead On Arrival), so I decided to just make a quick and dirty dockerized setup of it that my dev containers / Cursor can access easily.

## What Playwright MCP Can Do

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

## Features

- Containerized Playwright MCP server
- Localhost-only access for security
- Health checks included
- Persistent volumes for screenshots, downloads, and output
- Non-root user for security
- **Two connection modes** for different deployment scenarios

## Connection Modes

### Command-Based Mode (Recommended for SSH/Remote)
- **Best for**: SSH tunnels, remote servers, Cloudflare connections
- **How it works**: Client executes MCP server directly via `docker exec`
- **Benefits**: No persistent HTTP connections, eliminates timeout issues
- **Use case**: When you're connecting over SSH or experiencing connection drops

### HTTP Mode (Suitable for Local)
- **Best for**: Local development, direct connections
- **How it works**: MCP server runs as HTTP service on port 8080
- **Benefits**: Standard MCP protocol, familiar HTTP endpoints
- **Use case**: When running locally without network issues

## Quick Start

Build and run:

```bash
docker-compose up -d
```

The Playwright MCP server will be available at http://localhost:8081

## Configuration

### For Command-Based Mode (SSH/Remote Recommended)
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

### For HTTP Mode (Local Development)
```json
{
  "mcpServers": {
    "Playwright_MCP": {
      "url": "http://localhost:8081/mcp"
    }
  }
}
```

The container is configured to only accept connections from localhost or containers on the local network for security. The port 8081 is exposed but bound to localhost only.

## Volumes

- `screenshots`: For storing browser screenshots
- `downloads`: For storing downloaded files
- `output`: For storing other output files

## Health Check

The container includes a health check that verifies the MCP server is responding on port 8080.

## Usage Examples

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

## Troubleshooting

### Container Health
```bash
# Check container status
docker ps | grep Playwright-MCP

# View logs
docker logs Playwright-MCP

# Health check
curl -v http://localhost:8081/mcp
```

### Connection Drops (SSH/Remote)
- **Solution**: Switch to command-based mode
- **Why**: Eliminates persistent HTTP connections that can timeout

### Container Won't Start
- **Check**: Port 8081 availability
- **Fix**: `docker compose down && docker compose up -d`
