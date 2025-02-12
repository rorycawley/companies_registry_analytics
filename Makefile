# Makefile
# This Makefile provides a convenient interface for managing our dockerized services

# Load environment variables from .env file
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

# Colors
BLUE := \033[34m
GREEN := \033[32m
RED := \033[31m
YELLOW := \033[33m
BOLD := \033[1m
RESET := \033[0m

# Status Indicators with color and emojis
INFO := $(BLUE)ℹ 🔍$(RESET)
SUCCESS := $(GREEN)✓ ✨$(RESET)
WARNING := $(YELLOW)⚠ ⚡$(RESET)
ERROR := $(RED)✗ 🚫$(RESET)

# Section styling
HEADER = $(BLUE)$(BOLD)
STEP = $(YELLOW)

# Declare all phony targets
.PHONY: help start stop clean logs status build rebuild start-fresh test

# Default target when just running 'make'
.DEFAULT_GOAL := help

# Dry run configuration
DRYRUN ?= false

# Command wrapper for dry run mode
define execute_command
	if [ "$(DRYRUN)" = "true" ]; then \
		echo "[DRY RUN] Would execute: $(1)"; \
		true; \
	else \
		$(1); \
	fi
endef

# Timestamp function for logging
TIMESTAMP := $(shell date '+%H:%M:%S')

help:
	@echo "\n$(BLUE)$(BOLD)╔══════════════════════════════════════════════╗$(RESET)"
	@echo "$(BLUE)$(BOLD)║          🛠️  Available Commands  🛠️           ║$(RESET)"
	@echo "$(BLUE)$(BOLD)╚══════════════════════════════════════════════╝$(RESET)\n"
	@echo "$(BLUE)$(BOLD)Core Commands:$(RESET)"
	@echo "  $(BOLD)make start$(RESET)        $(GREEN)→$(RESET)  🚀 Start all services"
	@echo "  $(BOLD)make stop$(RESET)         $(GREEN)→$(RESET)  🛑 Stop all services"
	@echo "  $(BOLD)make clean$(RESET)        $(GREEN)→$(RESET)  🧹 Stop and remove all resources"
	@echo ""
	@echo "$(YELLOW)$(BOLD)Build Commands:$(RESET)"
	@echo "  $(BOLD)make build$(RESET)        $(GREEN)→$(RESET)  🏗️  Build all services"
	@echo "  $(BOLD)make rebuild$(RESET)      $(GREEN)→$(RESET)  🔄 Rebuild all services (no cache)"
	@echo "  $(BOLD)make start-fresh$(RESET)  $(GREEN)→$(RESET)  ⚡ Rebuild and start all services"
	@echo ""
	@echo "$(GREEN)$(BOLD)Monitoring Commands:$(RESET)"
	@echo "  $(BOLD)make status$(RESET)       $(GREEN)→$(RESET)  📊 Show container status"
	@echo "  $(BOLD)make logs$(RESET)         $(GREEN)→$(RESET)  📋 Follow container logs"
	@echo ""
	@echo "$(RED)$(BOLD)Testing Commands:$(RESET)"
	@echo "  $(BOLD)make test$(RESET)         $(GREEN)→$(RESET)  🧪 Run all tests\n"

build:
	@echo "$(INFO) $(STEP)Building service images... 🏗️  ($(TIMESTAMP))$(RESET)"
	@$(call execute_command,docker compose build)
	@echo "$(SUCCESS) Build completed successfully"

rebuild:
	@echo "$(INFO) $(STEP)Force rebuilding service images... 🔄 ($(TIMESTAMP))$(RESET)"
	@$(call execute_command,docker compose build --no-cache)
	@echo "$(SUCCESS) Rebuild completed successfully"

start: build
	@echo "$(INFO) $(STEP)Starting services... 🚀 ($(TIMESTAMP))$(RESET)"
	@$(call execute_command,docker compose up -d --remove-orphans)
	@echo "$(SUCCESS) Services started successfully"
	@$(MAKE) status

start-fresh: rebuild
	@echo "$(INFO) $(STEP)Starting services with fresh builds... ⚡ ($(TIMESTAMP))$(RESET)"
	@$(call execute_command,docker compose up -d --remove-orphans)
	@echo "$(SUCCESS) Services started successfully with fresh builds"
	@$(MAKE) status

stop:
	@echo "$(INFO) $(STEP)Stopping services... 🛑 ($(TIMESTAMP))$(RESET)"
	@$(call execute_command,docker compose down -t 0)
	@echo "$(SUCCESS) Services stopped successfully"

clean: stop
	@echo "$(INFO) $(STEP)Cleaning up resources... 🧹 ($(TIMESTAMP))$(RESET)"
	@$(call execute_command,docker compose down --volumes --remove-orphans)
	@rm -rf services/analytics/superset_home/*
	@echo "$(SUCCESS) Cleanup completed"

logs:
	@echo "$(INFO) $(STEP)Fetching logs... 📋 ($(TIMESTAMP))$(RESET)"
	@$(call execute_command,docker compose logs -f --tail=100)

status:
	@echo "$(HEADER)Current services status: 📊 ($(TIMESTAMP))$(RESET)"
	@$(call execute_command,docker compose ps)

test:
	@echo "$(INFO) $(STEP)Running tests... 🧪 ($(TIMESTAMP))$(RESET)"
	@$(call execute_command,docker compose run --rm test pytest)
	@echo "$(SUCCESS) All tests completed successfully"

# # Makefile
# # This Makefile provides a convenient interface for managing our dockerized services

# # Load environment variables from .env file
# ifneq (,$(wildcard ./.env))
#     include .env
#     export
# endif

# .PHONY: help start stop clean logs status

# # Default target when just running 'make'
# .DEFAULT_GOAL := help

# # Makefile should use tab characters for indentation, not spaces

# help:
# 	@echo "Available commands:"
# 	@echo "  make start           - Start all services"
# 	@echo "  make stop            - Stop all services"
# 	@echo "  make clean           - Stop and remove all resources (containers, networks)"
# 	@echo "  ---------------------------------------------------------------------------"
# 	@echo "  make status          - Show container status"
# 	@echo "  make logs            - Follow container logs"
# 	@echo "  make build           - Builds all services"	
# 	@echo "  make rebuild         - Rebuilds all services"	
# 	@echo "  make start-fresh     - Start all services after a rebuild"

# build: ## Build all services without starting them
# 	@echo "Building service images..."
# 	@docker compose build

# rebuild: ## Force rebuild all services without cache
# 	@echo "Force rebuilding service images..."
# 	@docker compose build --no-cache

# start: build ## Start all services
# 	@echo "Starting services..."
# 	@docker compose up -d --remove-orphans
# 	@echo "Services started successfully"	
# 	@make status

# start-fresh: rebuild ## Force rebuild and start all services
# 	@echo "Starting services with fresh builds..."
# 	@docker compose up -d --remove-orphans
# 	@echo "Services started successfully"
# 	@make status

# stop: ## Stop all services
# 	@echo "Stopping services..."
# 	@docker compose down --volumes --remove-orphans -t 0 
# 	@echo "Services stopped successfully"	

# clean: stop  ## Stop services and clean up resources
# 	@echo "Cleaning up resources..."
# 	@docker compose down --volumes --remove-orphans
# 	@docker compose rm -f
# 	@echo "Cleanup completed"

# logs: ## Display logs from all services
# 	@docker compose logs -f --tail=100

# status: ## Show status of all services
# 	@echo "Current services status:"
# 	@docker compose ps

# .PHONY: help setup env-check build start stop logs shell clean status

# # Default values for environment variables
# SUPERSET_SECRET_KEY ?= $(shell python3 -c "import secrets; print(secrets.token_hex(32))")
# SUPERSET_PORT ?= 8088
# TRANSFORMED_DATA_DATABASE ?= /app/data/transformations/transformed_data.duckdb

# # Environment file inclusion
# ifneq (,$(wildcard .env))
#     include .env
#     export $(shell sed 's/=.*//' .env)
# endif

# # Docker compose command definition with fallback
# DOCKER_COMPOSE_FILE := compose.yml
# ifeq (,$(wildcard $(DOCKER_COMPOSE_FILE)))
#     $(error ❌ $(DOCKER_COMPOSE_FILE) not found)
# endif
# DOCKER_COMPOSE := docker compose -f $(DOCKER_COMPOSE_FILE)

# # Valid service names
# VALID_SERVICES := analytics transformation ingestion registry-database

# # Default target
# help:
# 	@echo "\n✨ Available commands: ✨\n"
# 	@echo "  make setup                - ⚙️ Run the first-time setup script (creates .env)"
# 	@echo "  make env-check            - ✅ Check if all required environment variables are set"
# 	@echo "  make build                - 🏗️ Build the Docker images"
# 	@echo "  make start                - 🚀 Start the services"
# 	@echo "  make status               - 📊 Check the status of all services"
# 	@echo "  make stop                 - 🛑 Stop and remove the services"
# 	@echo "  make logs                 - 📖 View the logs of all services"
# 	@echo "  make shell SERVICE=<name> - 🐚 Open a shell (available: analytics, transformation, ingestion, registry-database)"
# 	@echo "  make clean                - 🧹 Clean out all services and resources\n"

# setup:
# 	@echo "⚙️ Setting up the system..."
# 	python3 ./scripts/setup.py || { echo "⚠️ Failed to run python3 setup.py"; exit 1; }
# 	@echo "✅ Setup complete!"

# env-check:
# 	@echo "Checking environment configuration..."
# ifndef SUPERSET_SECRET_KEY
# 	$(error ❌ SUPERSET_SECRET_KEY is not set. Please set this environment variable.)
# endif
# ifndef SUPERSET_PORT
# 	$(error ❌ SUPERSET_PORT is not set. Please set this environment variable.)
# endif
# 	@if ! echo "$(SUPERSET_PORT)" | grep -Eq '^[1-9][0-9]*$$' || [ "$(SUPERSET_PORT)" -lt 1024 ] || [ "$(SUPERSET_PORT)" -gt 65535 ]; then \
# 		echo "❌ SUPERSET_PORT must be a number between 1024 and 65535"; \
# 		exit 1; \
# 	fi
# ifndef TRANSFORMED_DATA_DATABASE
# 	$(error ❌ TRANSFORMED_DATA_DATABASE is not set. Please set this environment variable.)
# endif
# 	@echo "✅ Environment check passed!"

# build: env-check
# 	@echo "🏗️ Building the Docker images..."
# 	# $(DOCKER_COMPOSE) build || { echo "⚠️ Failed to build Docker images"; exit 1; }
# 	@echo "✅ Docker images built successfully!"

# start: env-check
# 	@echo "🚀 Starting the services..."
# 	# Start registry-database first
# 	# $(DOCKER_COMPOSE) up -d registry-database || { echo "⚠️ Failed to start registry-database service"; exit 1; }
# 	# sleep 5  # Allow database to initialize
# 	# Start remaining services
# 	# $(DOCKER_COMPOSE) up -d analytics transformation ingestion || { echo "⚠️ Failed to start dependent services"; exit 1; }
# 	@echo "🎉 Services started successfully!"
# 	@echo "📊 Analytics Dashboard: http://localhost:$${SUPERSET_PORT:-8088}"
# 	@echo "📖 View logs with: make logs"
# 	@echo "🐚 Access service shell with: make shell SERVICE=<name>"

# status:
# 	@echo "📊 Checking service status..."
# 	# $(DOCKER_COMPOSE) ps || echo "⚠️ Failed to retrieve service status: Docker daemon may not be running"
# 	@echo "\nContainer Healthcheck Status:"
# 	# $(DOCKER_COMPOSE) ps --format "table {{.Name}}\t{{.Status}}\t{{.Health}}" || echo "⚠️ Failed to retrieve detailed health status"

# stop:
# 	@echo "🛑 Stopping services..."
# 	# $(DOCKER_COMPOSE) down --volumes || echo "⚠️ Failed to stop services: Docker daemon may not be running"
# 	@echo "✅ Services stopped."

# logs:
# ifdef SERVICE
# 	@echo "📖 Tailing logs for $(SERVICE) (press Ctrl+C to exit)..."
# 	# $(DOCKER_COMPOSE) logs -f $(SERVICE) || echo "⚠️ Failed to retrieve logs for $(SERVICE) service"
# else
# 	@echo "📖 Tailing all container logs (press Ctrl+C to exit)..."
# 	# $(DOCKER_COMPOSE) logs -f || echo "⚠️ Failed to retrieve service logs"
# endif

# shell: env-check
# ifndef SERVICE
# 	$(error ❌ Please specify a service name: make shell SERVICE=<service_name>)
# endif
# ifeq ($(filter $(SERVICE),$(VALID_SERVICES)),)
# 	$(error ❌ Invalid service name: '$(SERVICE)'. Must be one of: $(VALID_SERVICES))
# endif
# 	@echo "🐚 Accessing the shell of $(SERVICE) service..."
# 	# $(DOCKER_COMPOSE) exec $(SERVICE) bash || echo "⚠️ Failed to access $(SERVICE) service shell"

# clean: stop
# 	@echo "🧹 Cleaning out the service resources..."
# 	# $(DOCKER_COMPOSE) down --volumes --rmi all || echo "⚠️ Failed to clean up Docker resources"
# 	rm -rf ./services/*/__pycache__
# 	rm -rf ./scripts/__pycache__
# 	@echo "✅ Service resources cleaned."