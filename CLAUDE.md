# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

The Jaffle Shop is a **dbt educational project** for testing GenAI coding capabilities with Claude Code and MCP dbt integration. This setup uses **PostgreSQL locally** for development.

## Docker Setup (Recommended)

### Prerequisites
- Docker and Docker Compose installed
- Python 3.9+ for dbt Core and MCP integration

### Quick Start with Docker
```bash
# Start both PostgreSQL and dbt containers
docker-compose up -d

# Run dbt commands in the dbt container
docker exec -it jaffle_shop_dbt dbt seed --full-refresh --vars '{"load_source_data": true}'
docker exec -it jaffle_shop_dbt dbt build
```

**Or use local dbt with Docker PostgreSQL:**
```bash
# Start only PostgreSQL
docker-compose up postgres -d

# Create Python virtual environment locally
python3 -m venv .venv
source .venv/bin/activate
pip install dbt-core dbt-postgres
pip install -r requirements.txt
dbt deps

# Use local target profile
dbt seed --target local --full-refresh --vars '{"load_source_data": true}'
dbt build --target local
```

The Docker setup provides:
- PostgreSQL 15 database named `jaffle_shop`
- dbt container with all dependencies pre-installed
- Pre-configured with schemas: `dbt_dev`, `prod`, `raw`
- Docker network for container communication
- Health checks and persistent data storage

### Alternative: Local PostgreSQL Setup

If you prefer to install PostgreSQL locally instead of using Docker:

```bash
# Create PostgreSQL database (run in psql or your preferred client)
CREATE DATABASE jaffle_shop;
CREATE SCHEMA dbt_dev;
CREATE SCHEMA prod;  
CREATE SCHEMA raw;
```

**Data Loading and Development**

**Using dbt container:**
```bash
# Load sample data (1 year of data)
docker exec -it jaffle_shop_dbt dbt seed --full-refresh --vars '{"load_source_data": true}'

# Generate larger dataset (optional, for testing performance)
docker exec -it jaffle_shop_dbt jafgen 3  # generates 3 years of data
docker exec -it jaffle_shop_dbt sh -c "rm -rf seeds/jaffle-data && mv jaffle-data seeds"
docker exec -it jaffle_shop_dbt dbt seed --full-refresh --vars '{"load_source_data": true}'

# Build entire project
docker exec -it jaffle_shop_dbt dbt build

# Run models only
docker exec -it jaffle_shop_dbt dbt run

# Run tests
docker exec -it jaffle_shop_dbt dbt test

# Clean artifacts
docker exec -it jaffle_shop_dbt dbt clean
```

**Using local dbt with Docker PostgreSQL:**
```bash
# Load sample data (1 year of data)
dbt seed --target local --full-refresh --vars '{"load_source_data": true}'

# Generate larger dataset (optional, for testing performance)
jafgen 3  # generates 3 years of data
rm -rf seeds/jaffle-data && mv jaffle-data seeds
dbt seed --target local --full-refresh --vars '{"load_source_data": true}'

# Build entire project
dbt build --target local

# Run models only
dbt run --target local

# Run tests
dbt test --target local

# Clean artifacts
dbt clean
```

**Using Task Runner (Recommended)**
```bash
# Install task: https://taskfile.dev/#/installation
# Then use automated workflows:
task venv           # Create virtual environment
task install DB=postgres  # Install dependencies
task gen YEARS=3    # Generate 3 years of data
task seed          # Seed the data
task clean         # Clean up temporary files
```

## Profile Configuration

### Docker Setup (Recommended)
The project includes a `profiles.yml` file with multiple targets:

- **dev/prod**: Uses `host: postgres` for running dbt inside Docker containers
- **local**: Uses `host: localhost` for running dbt locally against Docker PostgreSQL

### Manual Configuration
If you need to customize, the profiles.yml includes:

```yaml
jaffle_shop:
  outputs:
    dev:        # For dbt container
      host: postgres
    local:      # For local dbt with Docker PostgreSQL  
      host: localhost
    prod:       # For production deployment
      host: postgres
  target: dev
```

Switch targets with: `dbt run --target local` or `dbt run --target prod`

The `dbt_project.yml` is already configured to use the `jaffle_shop` profile.

## MCP dbt Integration

This project uses a **two-container setup** (PostgreSQL + dbt) with **local MCP integration** for enhanced GenAI coding capabilities with Claude Desktop.

### Architecture
- **PostgreSQL Container**: Database with your jaffle shop data
- **dbt Container**: All dbt dependencies and tools ready for use
- **Local MCP Server**: Runs on your machine for optimal Claude Desktop integration

### Setup Instructions

**1. Install MCP Prerequisites:**
```bash
# Install uv (Python package manager)
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.local/bin/env

# Install dbt locally for MCP
pip install dbt-core dbt-postgres

# Install dbt MCP server
uvx dbt-mcp --help  # This will install it automatically
```

**2. Claude Desktop Configuration:**
Add this to your Claude Desktop settings (`~/Library/Application Support/Claude/claude_desktop_config.json` on macOS):

```json
{
  "mcpServers": {
    "dbt-mcp": {
      "command": "uvx",
      "args": [
        "--env-file",
        "/absolute/path/to/your/jaffle-shop/.env.local",
        "dbt-mcp"
      ]
    }
  }
}
```

The `.env.local` file is already configured with:
```bash
DISABLE_DBT_CLI=false
DISABLE_SEMANTIC_LAYER=true
DISABLE_DISCOVERY=true
DISABLE_REMOTE=true
DBT_PROJECT_DIR=/absolute/path/to/your/code/jaffle-shop
DBT_PATH=dbt
DBT_CLI_TIMEOUT=30
```

**3. VSCode MCP Integration:**
VSCode also supports MCP! Configuration files are already created at:
- User-level: `~/Library/Application Support/Code/User/mcp.json`  
- Workspace-level: `.vscode/mcp.json`

Enable MCP in VSCode:
1. Open Settings (Cmd+,) → Features → Chat
2. Enable "Mcp" setting
3. Restart VSCode
4. Use Cmd+Shift+P → "MCP: List Servers" to verify dbt server is loaded

**4. Usage Patterns:**
- **Container dbt**: `docker exec jaffle_shop_dbt dbt run`
- **Claude Desktop MCP**: Works automatically via GUI
- **VSCode MCP**: Available via @dbt in chat  
- **Database**: Both local and container dbt connect to `localhost:5432`

**MCP Features Available:**
- Real-time model execution and testing  
- Interactive data exploration via SQL
- Code generation with immediate feedback
- Semantic understanding of data transformations
- Available in both Claude Desktop and VSCode
- Direct query execution against PostgreSQL

## Project Architecture

**Data Flow for Local Development**
1. **Raw CSV data** → PostgreSQL `raw` schema (via dbt seed)
2. **Staging models** → Clean/standardize (materialized as views)
3. **Mart models** → Business logic (materialized as tables)

**Key Directories**
- `models/staging/` - Data cleaning and standardization
- `models/marts/` - Business analytics models  
- `seeds/jaffle-data/` - Sample restaurant data
- `macros/` - SQL utilities (e.g., `cents_to_dollars.sql`)

## Code Quality Setup

```bash
# One-time setup for pre-commit hooks
pre-commit install

# Manual pre-commit run
pre-commit run --all-files
```

Pre-commit runs: ruff (Python), YAML validation, whitespace cleanup.

## Business Domain

Restaurant analytics with realistic e-commerce data:
- **Customers** - Lifetime value, segmentation, retention
- **Orders** - Revenue trends, seasonality, basket analysis
- **Products** - Performance metrics, profitability
- **Stores** - Multi-location operations, regional analysis

## Common Development Tasks

**Testing Changes**

**Using dbt container:**
```bash
docker exec -it jaffle_shop_dbt dbt run --select model_name  # Run specific model
docker exec -it jaffle_shop_dbt dbt test --select model_name # Test specific model
docker exec -it jaffle_shop_dbt dbt run --select +model_name # Run model and upstream dependencies
```

**Using local dbt:**
```bash
dbt run --target local --select model_name  # Run specific model
dbt test --target local --select model_name # Test specific model
dbt run --target local --select +model_name # Run model and upstream dependencies
```

**Data Exploration**
```bash
# Connect to Docker PostgreSQL to query results:
docker exec -it jaffle_shop_postgres psql -U jaffle_user -d jaffle_shop -c "SELECT * FROM dbt_dev.customers LIMIT 5;"

# Or connect directly if using local PostgreSQL:
psql -U jaffle_user -d jaffle_shop -c "SELECT * FROM dbt_dev.customers LIMIT 5;"
```

**Debugging**

**Using dbt container:**
```bash
docker exec -it jaffle_shop_dbt dbt run --debug          # Verbose output
docker exec -it jaffle_shop_dbt dbt compile             # Generate SQL without running
docker exec -it jaffle_shop_dbt dbt ls                  # List all models
docker exec -it jaffle_shop_dbt dbt docs generate       # Generate documentation
docker exec -it jaffle_shop_dbt dbt docs serve --host 0.0.0.0 --port 8080  # Serve docs (accessible at localhost:8080)
```

**Using local dbt:**
```bash
dbt run --target local --debug          # Verbose output
dbt compile --target local             # Generate SQL without running
dbt ls --target local                  # List all models
dbt docs generate --target local       # Generate documentation
dbt docs serve --target local          # Serve docs locally
```