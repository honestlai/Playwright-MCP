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
    curl \
    unzip \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user with home directory
RUN groupadd -r playwright && useradd -r -m -g playwright -G audio,video playwright

# Set working directory
WORKDIR /app

# Install Playwright MCP globally
RUN npm install -g @playwright/mcp@latest

# Install Playwright browsers
RUN npx playwright install chromium
RUN npx playwright install chrome
RUN npx playwright install-deps chromium
RUN npx playwright install-deps chrome

# Change ownership of the app directory and home directory
RUN chown -R playwright:playwright /app
RUN chown -R playwright:playwright /home/playwright

# Fix Chrome sandbox permissions
RUN if [ -f /opt/google/chrome/chrome-sandbox ]; then \
        chmod 4755 /opt/google/chrome/chrome-sandbox; \
    fi

# Set environment variables for better browser session management
ENV PLAYWRIGHT_BROWSERS_PATH=/home/playwright/.cache/ms-playwright
ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=0
ENV PLAYWRIGHT_ISOLATED_BROWSER=1

# Chrome-specific environment variables to fix permission issues
ENV CHROME_DEVEL_SANDBOX=/usr/lib/chromium/chrome-sandbox
ENV CHROME_NO_SANDBOX=1
ENV CHROME_DISABLE_GPU=1
ENV CHROME_DISABLE_DEV_SHM=1

# Copy health check script
COPY --chown=playwright:playwright healthcheck.sh /app/healthcheck.sh
RUN chmod +x /app/healthcheck.sh

# Switch to non-root user
USER playwright

# Expose the port
EXPOSE 8080

# Health check - check if the MCP endpoint is responding
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD /app/healthcheck.sh

# Start the Playwright MCP server
CMD ["mcp-server-playwright", "--port", "8080", "--host", "0.0.0.0", "--headless", "--isolated"]
