# Playwright MCP Docker Container

A simple dockerized setup of Playwright MCP for browser automation.

## About This Project

While Playwright is a great tool set up by Microsoft, I couldn't find any simple information on how to stand this up as a Docker container. The little guidance I got from GPT had me stand up a container that was DOA (Dead On Arrival), so I decided to just make a quick and dirty dockerized setup of it that my dev containers / Cursor can access easily.

## Features

### 🚀 **Core Capabilities**
- Containerized Playwright MCP server with full automation capabilities
- Localhost-only access for security
- Health checks and monitoring included
- Persistent volumes for screenshots, downloads, and output
- Non-root user for enhanced security

### 🌐 **Browser Support**
- **Chrome** (370MB) - Full Chrome browser for Chrome-specific sites
- **Chromium** (590MB) - Default Playwright browser, most stable
- **Firefox** (256MB) - Firefox browser for cross-browser testing
- **WebKit** (272MB) - Safari compatibility and testing

### 📱 **Mobile & Responsive Testing**
- **iPhone emulation** - iPhone 12, 13, 14, 15 viewports
- **iPad emulation** - iPad Pro, iPad Air, iPad Mini
- **Android emulation** - Galaxy S8, Pixel, Samsung devices
- **Custom viewport sizes** - Any mobile/tablet resolution

### 🧪 **Advanced Testing Features**
- **End-to-end testing** - Complete user journey automation
- **Form testing** - Fill, submit, validate complex forms
- **Authentication flows** - Login, session management, OAuth
- **Performance monitoring** - Page load times, resource tracking
- **Screenshot generation** - Full page, element, mobile screenshots
- **Data extraction** - Scraping, content analysis, API testing

### 🐛 **Debugging & Analysis**
- **Console monitoring** - Real-time JavaScript error tracking
- **Network analysis** - Failed request detection, API monitoring
- **DOM inspection** - Element finding, attribute validation
- **CSS debugging** - Style inspection, layout analysis
- **Accessibility audits** - WCAG compliance checking

### 🔧 **Development Workflow**
- **Cross-browser testing** - Test across all major browsers
- **Mobile responsiveness** - Validate mobile-first designs
- **File upload handling** - Test file upload functionality
- **Keyboard/mouse interactions** - Complex user interactions
- **Page navigation** - History, redirects, URL management

### 📊 **Code Generation Support**
- **Test case creation** - Generate Playwright test scripts
- **Selector generation** - CSS selector creation and validation
- **Page object models** - Structured test automation
- **API testing** - REST API automation and validation

## Quick Start

1. Build and run:
   ```bash
   docker-compose up -d
   ```

2. The Playwright MCP server will be available at `http://localhost:8081`

## 📦 **Container Details**

- **Total Size**: ~2.25GB (includes all browsers for full compatibility)
- **Base Image**: Node.js 20 Alpine Linux
- **Security**: Non-root user, localhost-only binding
- **Port**: 8081 (bound to 127.0.0.1 for security)
- **Health Check**: Automatic monitoring of MCP server status

## Configuration

The container is configured to only accept connections from localhost or containers on the local network for security. The port 8081 is exposed but bound to localhost only.

## Volumes

- `screenshots`: For storing browser screenshots
- `downloads`: For storing downloaded files
- `output`: For storing other output files

## Health Check

The container includes a health check that verifies the MCP server is responding on port 8080 (internal).
