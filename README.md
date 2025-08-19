# Playwright MCP Docker Container

A simple dockerized setup of Playwright MCP for browser automation.

## About This Project

While Playwright is a great tool set up by Microsoft, I couldn't find any simple information on how to stand this up as a Docker container. The little guidance I got from GPT had me stand up a container that was DOA (Dead On Arrival), so I decided to just make a quick and dirty dockerized setup of it that my dev containers / Cursor can access easily.

## Features

- Containerized Playwright MCP server
- Localhost-only access for security
- Health checks included
- Persistent volumes for screenshots, downloads, and output
- Non-root user for security

## Quick Start

1. Build and run:
   ```bash
   docker-compose up -d
   ```

2. The Playwright MCP server will be available at `http://localhost:8080`

## Configuration

The container is configured to only accept connections from localhost or containers on the local network for security. The port 8080 is exposed but bound to localhost only.

## Volumes

- `screenshots`: For storing browser screenshots
- `downloads`: For storing downloaded files
- `output`: For storing other output files

## Health Check

The container includes a health check that verifies the MCP server is responding on port 8080.
