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
    jq \
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
RUN npx playwright install-deps

# Create necessary directories
RUN mkdir -p /app/screenshots /app/downloads /app/output /app/logs
RUN chown -R playwright:playwright /app

# Copy healthcheck script
COPY healthcheck.sh /app/healthcheck.sh
RUN chmod +x /app/healthcheck.sh

# Switch to playwright user
USER playwright

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD /app/healthcheck.sh

# Start Playwright MCP server
CMD ["npx", "@playwright/mcp@latest", "--port", "8080", "--host", "0.0.0.0", "--headless", "--isolated"]
