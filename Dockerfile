FROM node:20-slim

# Install system dependencies for Playwright browsers
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    ca-certificates \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libdrm2 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libgbm1 \
    libxss1 \
    libgtkd-3-0 \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user with home directory
RUN groupadd -r playwright && useradd -r -m -g playwright -G audio,video playwright

# Set working directory
WORKDIR /app

# Install Playwright MCP globally
RUN npm install -g @playwright/mcp@latest

# Install Playwright browsers
RUN npx playwright install chromium
RUN npx playwright install-deps chromium

# Change ownership of the app directory and home directory
RUN chown -R playwright:playwright /app
RUN chown -R playwright:playwright /home/playwright

# Switch to non-root user
USER playwright

# Expose the port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

# Start the Playwright MCP server
CMD ["mcp-server-playwright", "--port", "8080", "--host", "0.0.0.0", "--headless"]
