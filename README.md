# 🥪 The Jaffle Shop 🤖 MCP + Claude Code Example

This project demonstrates **AI-enhanced dbt development** using **MCP (Model Context Protocol)** and **Claude Code**. Built around the classic Jaffle Shop dataset (a fictional restaurant), it showcases how to integrate Claude AI directly into your dbt workflow for interactive data modeling, analysis, and development.

## 🚀 What This Demonstrates

- **MCP Integration**: Direct Claude access to dbt commands, SQL execution, and data exploration
- **Claude Code Workflows**: AI-assisted model development, testing, and debugging
- **Local Development**: PostgreSQL + Docker setup optimized for AI coding
- **Real-time Interaction**: Query data, generate models, and analyze results with AI assistance

## 🏗️ Quick Start

### Prerequisites
- Docker and Docker Compose
- Python 3.9+
- **macOS or Windows** (Claude Desktop not available on Linux)

### 1. Download and Install Claude Desktop

**Download Claude Desktop:**
- **macOS**: Download from [claude.ai/download](https://claude.ai/download)
- **Windows**: Download from [claude.ai/download](https://claude.ai/download)

> **⚠️ Important**: Claude Desktop is **not available on Linux**. Linux users should use Claude Code via the web interface or consider using VSCode with MCP integration instead.

**Install and sign in:**
1. Install the downloaded application
2. Sign in with your Claude account
3. Verify Claude Desktop is running

### 2. Download and Install Claude Code

**Download Claude Code:**
```bash
# macOS (via Homebrew)
brew install claude

# Or download directly from: https://claude.ai/code
# Follow installation instructions for your platform
```

**Verify installation:**
```bash
claude --version
```

### 3. Set Up the dbt Project

```bash
# Clone and enter the project
git clone <your-repo>
cd jaffle-shop

# Start PostgreSQL and dbt containers
docker-compose up -d

# Load sample data (1 year of restaurant data)
docker exec -it jaffle_shop_dbt dbt seed --full-refresh --vars '{"load_source_data": true}'

# Build all models
docker exec -it jaffle_shop_dbt dbt build
```

### 4. Install and Configure MCP Server

**Install MCP prerequisites:**
```bash
# Install uv (Python package manager)
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.local/bin/env

# Install dbt for MCP integration
pip install dbt-core dbt-postgres

# Install the dbt MCP server
uvx install dbt-mcp
```

**Test MCP server:**
```bash
# Verify the MCP server works
uvx dbt-mcp --help
```

### 5. Configure Claude Desktop MCP Integration

> **Note**: This step requires Claude Desktop (macOS/Windows only)

**Create MCP configuration:**

Add to your Claude Desktop config file:
- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`

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

**Important**: Replace `/absolute/path/to/your/jaffle-shop/` with your actual project path.

**Verify the .env.local file exists:**
The project includes a `.env.local` file with:
```bash
DISABLE_DBT_CLI=false
DISABLE_SEMANTIC_LAYER=true
DISABLE_DISCOVERY=true
DISABLE_REMOTE=true
DBT_PROJECT_DIR=/Users/username/code/jaffle-shop  # Update this path!
DBT_PATH=dbt
DBT_CLI_TIMEOUT=30
```

Update the `DBT_PROJECT_DIR` to match your project location.

### 6. Start Using MCP with Claude

**With Claude Desktop (macOS/Windows):**
1. **Restart Claude Desktop** to load the MCP configuration
2. Open Claude Desktop
3. Test MCP integration by asking:
   - "List all dbt models in this project"
   - "Show me the first 10 rows from the customers table"
   - "Run dbt test and show me the results"

**With Claude Code (all platforms):**
```bash
# Start Claude Code in your project directory
cd /path/to/jaffle-shop
claude code
```

Then interact with your dbt project through Claude Code.

### 7. Alternative: VSCode MCP Integration (Linux-friendly)

For Linux users or those preferring VSCode:

**Enable MCP in VSCode:**
1. Install the Claude extension for VSCode
2. Open Settings (Cmd+,) → Features → Chat → Enable "Mcp"
3. Configuration files are at:
   - User-level: `~/Library/Application Support/Code/User/mcp.json`
   - Workspace-level: `.vscode/mcp.json` (included in project)

4. Restart VSCode
5. Use `@dbt` in chat to access dbt functionality

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│ Claude Desktop/ │◄──►│   MCP Server     │◄──►│  dbt + Postgres │
│ Claude Code     │    │   (dbt-mcp)      │    │   (Docker)      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

- **PostgreSQL Container**: Stores your Jaffle Shop data
- **dbt Container**: Handles model building and transformations  
- **MCP Server**: Bridges Claude AI with your dbt project
- **Claude Interface**: Provides AI interaction (Desktop, Code, or VSCode)

## 📊 Sample Data

The project includes realistic restaurant data:
- **Customers**: Customer profiles and segmentation
- **Orders**: Transaction history with seasonality
- **Products**: Menu items with pricing and categories
- **Stores**: Multi-location restaurant operations

Perfect for exploring:
- Revenue analysis and forecasting
- Customer lifetime value modeling
- Product performance analytics
- Seasonal trend analysis

## 🎯 AI-Enhanced Workflows

### Data Exploration
```
You: "What are our top-selling products this quarter?"
Claude: [Queries data and shows results with insights]
```

### Model Development
```
You: "Create a customer segmentation model based on purchase behavior"
Claude: [Generates SQL model with business logic and tests]
```

### Debugging & Testing
```
You: "This test is failing - can you help debug it?"
Claude: [Analyzes test, identifies issue, suggests fixes]
```

## 🔧 Development Commands

**Using Claude with MCP:**
```
# In Claude Desktop/Code:
"Run dbt build and show me any errors"
"Test the customers model"
"Show me the compiled SQL for the orders model"
"Generate documentation and serve it"
```

**Direct Docker commands:**
```bash
# Run specific models
docker exec -it jaffle_shop_dbt dbt run --select model_name

# Test models  
docker exec -it jaffle_shop_dbt dbt test --select model_name

# Generate documentation
docker exec -it jaffle_shop_dbt dbt docs generate
docker exec -it jaffle_shop_dbt dbt docs serve --host 0.0.0.0 --port 8080
```

## 🚀 Advanced Usage

### Generate Larger Datasets
```bash
# Generate 3 years of data for more interesting analysis
docker exec -it jaffle_shop_dbt jafgen 3
docker exec -it jaffle_shop_dbt sh -c "rm -rf seeds/jaffle-data && mv jaffle-data seeds"
docker exec -it jaffle_shop_dbt dbt seed --full-refresh --vars '{"load_source_data": true}'
```

### Multiple Development Targets
The project supports different environments:
- `dev`: Default development (container-to-container)
- `local`: Local dbt with Docker PostgreSQL
- `prod`: Production deployment

## 📁 Project Structure

```
models/
├── staging/          # Data cleaning and standardization
└── marts/           # Business logic and analytics

seeds/jaffle-data/   # Sample CSV data
macros/             # SQL utilities
.env.local          # MCP configuration
mcp-config.json     # VSCode MCP settings
```

## 🛠️ Troubleshooting

**Claude Desktop not available (Linux users):**
- Use VSCode with MCP integration instead
- Or use Claude Code via the web interface
- Consider running on macOS/Windows via VM if needed

**Claude Desktop MCP not working?**
- Verify `.env.local` has correct `DBT_PROJECT_DIR` path
- Test: `uvx dbt-mcp --help` should work without errors
- Check Claude Desktop config file JSON syntax
- Restart Claude Desktop after config changes

**MCP server errors?**
- Ensure dbt is installed: `dbt --version`
- Check project path in `.env.local` is absolute
- Verify Docker containers are running: `docker ps`

**Container issues?**
- Run `docker-compose logs` to see error details
- Ensure ports 5432 and 8080 aren't in use
- Try `docker-compose down && docker-compose up -d`

**dbt errors?**
- Check database connection: `docker exec -it jaffle_shop_dbt dbt debug`
- Verify data loaded: `docker exec -it jaffle_shop_dbt dbt ls`

## 🎓 Next Steps

1. **Install Claude Desktop** (macOS/Windows) or set up VSCode MCP (Linux)
2. **Configure MCP integration** with your project path
3. **Test the connection** - Ask Claude to list your models
4. **Explore the data** - Query tables and analyze patterns
5. **Build new models** - Create custom analytics with AI assistance
6. **Experiment with workflows** - Try different AI-enhanced development patterns

---

**Ready to revolutionize your analytics workflow?** Install Claude Desktop, configure MCP, and begin your AI-enhanced dbt journey! 🚀