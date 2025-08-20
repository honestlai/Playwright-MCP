# Cursor Playwright MCP Setup Guide

This guide helps you maintain a consistent Playwright MCP connection in Cursor.

## Quick Setup

1. **Rebuild the container with improved configuration:**
   ```bash
   docker-compose down
   docker-compose build --no-cache
   docker-compose up -d
   ```

2. **Verify the connection:**
   ```bash
   ./monitor-playwright.sh status
   ```

3. **Start monitoring (optional):**
   ```bash
   ./monitor-playwright.sh monitor
   ```

## Cursor Configuration

Add this to your Cursor settings (`.cursorrules` or Cursor settings):

```json
{
  "mcpServers": {
    "playwright": {
      "url": "http://localhost:8081/mcp",
      "timeout": 30000,
      "retries": 3
    }
  }
}
```

## Common Issues and Solutions

### Issue: MCP Status Shows Red in Cursor

**Symptoms:**
- Playwright tools show as unavailable
- MCP status indicator is red
- Connection timeouts

**Solutions:**

1. **Check container status:**
   ```bash
   ./monitor-playwright.sh status
   ```

2. **Restart the container:**
   ```bash
   ./monitor-playwright.sh restart
   ```

3. **Check for port conflicts:**
   ```bash
   netstat -tlnp | grep 8081
   ```

4. **Verify firewall settings:**
   ```bash
   sudo ufw status
   # If enabled, allow port 8081
   sudo ufw allow 8081
   ```

### Issue: Intermittent Connection Drops

**Causes:**
- Memory pressure
- Browser process crashes
- Network timeouts
- Resource exhaustion

**Solutions:**

1. **Monitor resource usage:**
   ```bash
   ./monitor-playwright.sh resources
   ```

2. **Check container logs:**
   ```bash
   ./monitor-playwright.sh logs
   ```

3. **Increase system resources:**
   - Ensure Docker has at least 4GB RAM allocated
   - Increase Docker memory limit if needed

### Issue: Browser Launch Failures

**Symptoms:**
- "Browser not installed" errors
- Permission denied errors
- Sandbox issues

**Solutions:**

1. **Reinstall browsers:**
   ```bash
   docker exec Playwright-MCP npx playwright install chromium
   docker exec Playwright-MCP npx playwright install chrome
   ```

2. **Fix permissions:**
   ```bash
   docker exec Playwright-MCP chmod -R 755 /home/playwright/.cache/ms-playwright
   ```

## Proactive Maintenance

### 1. Automatic Monitoring

Run the monitoring script in the background:
```bash
nohup ./monitor-playwright.sh monitor > /dev/null 2>&1 &
```

### 2. Scheduled Restarts

Add to crontab for daily restarts:
```bash
# Add to crontab (crontab -e)
0 2 * * * cd /path/to/Playwright-MCP && ./monitor-playwright.sh restart
```

### 3. Resource Monitoring

Monitor system resources:
```bash
# Check Docker resource usage
docker stats Playwright-MCP

# Check system memory
free -h

# Check disk space
df -h
```

## Troubleshooting Commands

### Quick Diagnostics
```bash
# Check all components
./monitor-playwright.sh status

# View recent logs
docker logs --tail 50 Playwright-MCP

# Test MCP endpoint directly
curl -v http://localhost:8081/mcp

# Check container health
docker inspect Playwright-MCP --format='{{.State.Health}}'
```

### Advanced Debugging
```bash
# Enter container for debugging
docker exec -it Playwright-MCP bash

# Check browser installations
docker exec Playwright-MCP npx playwright --version

# Test browser launch
docker exec Playwright-MCP npx playwright test --browser=chromium --headed
```

## Performance Optimization

### 1. Browser Caching
The container now uses a persistent volume for browser cache:
```yaml
volumes:
  - browser_cache:/home/playwright/.cache/ms-playwright
```

### 2. Memory Management
- Container limited to 4GB RAM
- Automatic restart on memory issues
- Browser isolation for stability

### 3. Connection Pooling
- MCP server configured for multiple concurrent connections
- Timeout handling for long-running operations
- Automatic cleanup of browser instances

## Integration with Cursor

### 1. Reliable Connection
- Health checks every 30 seconds
- Automatic restart on failures
- Persistent browser cache

### 2. Error Recovery
- Graceful handling of browser crashes
- Automatic reconnection attempts
- Fallback to different browsers

### 3. Performance Monitoring
- Real-time resource monitoring
- Log aggregation and analysis
- Proactive issue detection

## Best Practices

1. **Regular Maintenance:**
   - Run status checks daily
   - Monitor resource usage
   - Keep logs for debugging

2. **Resource Management:**
   - Ensure adequate system resources
   - Monitor Docker memory usage
   - Clean up old browser instances

3. **Monitoring:**
   - Use the monitoring script
   - Set up alerts for failures
   - Track connection stability

4. **Backup and Recovery:**
   - Backup browser cache volume
   - Document configuration changes
   - Test recovery procedures

## Support

If you continue to experience issues:

1. Check the monitoring logs: `/tmp/playwright-mcp-monitor.log`
2. Review container logs: `docker logs Playwright-MCP`
3. Verify system resources and Docker configuration
4. Consider updating to the latest Playwright MCP version

The improved configuration should provide much more stable connectivity for your Cursor agent!
