FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install uv (Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    echo 'export PATH="/root/.local/bin:$PATH"' >> /root/.bashrc
ENV PATH="/root/.local/bin:$PATH"

# Set working directory
WORKDIR /app

# Copy requirements files
COPY requirements.txt requirements.in ./

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir dbt-core dbt-postgres && \
    pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# Create dbt profiles directory and copy profiles
RUN mkdir -p /root/.dbt
COPY profiles.yml /root/.dbt/profiles.yml

# Copy MCP configuration
COPY .env.mcp /app/.env

# Install dbt packages
RUN dbt deps

# Install dbt MCP server
RUN /root/.local/bin/uv tool install dbt-mcp

# Create startup script for MCP server
RUN echo '#!/bin/bash' > /usr/local/bin/start-mcp.sh && \
    echo 'export PATH="/root/.local/bin:$PATH"' >> /usr/local/bin/start-mcp.sh && \
    echo 'cd /app' >> /usr/local/bin/start-mcp.sh && \
    echo 'exec /root/.local/bin/uvx --env-file /app/.env dbt-mcp' >> /usr/local/bin/start-mcp.sh && \
    chmod +x /usr/local/bin/start-mcp.sh

# Set default command
CMD ["tail", "-f", "/dev/null"]