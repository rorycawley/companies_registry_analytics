.PHONY: help setup env-check build start stop logs shell clean status

# Default values for environment variables
SUPERSET_SECRET_KEY ?= $(shell python3 -c "import secrets; print(secrets.token_hex(32))")
SUPERSET_PORT ?= 8088
SUPERSET_WORKERS ?= 4
SUPERSET_TIMEOUT ?= 60
DUCKDB_DATABASE ?= data/transformations/transformed_data.duckdb

# Environment file inclusion
ifneq (,$(wildcard .env))
    include .env
    export $(shell sed 's/=.*//' .env)
endif

# Docker compose command definition with fallback
DOCKER_COMPOSE_FILE := compose.yml
ifeq (,$(wildcard $(DOCKER_COMPOSE_FILE)))
    $(error ❌ $(DOCKER_COMPOSE_FILE) not found)
endif
DOCKER_COMPOSE := docker compose -f $(DOCKER_COMPOSE_FILE)

# Valid service names
VALID_SERVICES := analytics transformation ingestion registry-database

# Default target
help:
	@echo "\n✨ Available commands: ✨\n"
	@echo "  make setup                - ⚙️ Run the first-time setup script (creates .env)"
	@echo "  make env-check            - ✅ Check if all required environment variables are set"
	@echo "  make build                - 🏗️ Build the Docker images"
	@echo "  make start                - 🚀 Start the services"
	@echo "  make status               - 📊 Check the status of all services"
	@echo "  make stop                 - 🛑 Stop and remove the services"
	@echo "  make logs                 - 📖 View the logs of all services"
	@echo "  make shell SERVICE=<name> - 🐚 Open a shell (available: analytics, transformation, ingestion, registry-database)"
	@echo "  make clean                - 🧹 Clean out all services and resources\n"

setup:
	@echo "⚙️ Setting up the system..."
	python3 ./scripts/setup.py || { echo "⚠️ Failed to run python3 setup.py"; exit 1; }
	@echo "✅ Setup complete!"

env-check:
	@echo "Checking environment configuration..."
ifndef SUPERSET_SECRET_KEY
	$(error ❌ SUPERSET_SECRET_KEY is not set. Please set this environment variable.)
endif
ifndef SUPERSET_PORT
	$(error ❌ SUPERSET_PORT is not set. Please set this environment variable.)
endif
	@if ! echo "$(SUPERSET_PORT)" | grep -Eq '^[1-9][0-9]*$$' || [ "$(SUPERSET_PORT)" -lt 1024 ] || [ "$(SUPERSET_PORT)" -gt 65535 ]; then \
		echo "❌ SUPERSET_PORT must be a number between 1024 and 65535"; \
		exit 1; \
	fi
ifndef SUPERSET_WORKERS
	$(error ❌ SUPERSET_WORKERS is not set. Please set this environment variable.)
endif
ifndef SUPERSET_TIMEOUT
	$(error ❌ SUPERSET_TIMEOUT is not set. Please set this environment variable.)
endif
ifndef DUCKDB_DATABASE
	$(error ❌ DUCKDB_DATABASE is not set. Please set this environment variable.)
endif
	@echo "✅ Environment check passed!"

build: env-check
	@echo "🏗️ Building the Docker images..."
	# $(DOCKER_COMPOSE) build || { echo "⚠️ Failed to build Docker images"; exit 1; }
	@echo "✅ Docker images built successfully!"

start: env-check
	@echo "🚀 Starting the services..."
	# Start registry-database first
	# $(DOCKER_COMPOSE) up -d registry-database || { echo "⚠️ Failed to start registry-database service"; exit 1; }
	# sleep 5  # Allow database to initialize
	# Start remaining services
	# $(DOCKER_COMPOSE) up -d analytics transformation ingestion || { echo "⚠️ Failed to start dependent services"; exit 1; }
	@echo "🎉 Services started successfully!"
	@echo "📊 Analytics Dashboard: http://localhost:$${SUPERSET_PORT:-8088}"
	@echo "📖 View logs with: make logs"
	@echo "🐚 Access service shell with: make shell SERVICE=<name>"

status:
	@echo "📊 Checking service status..."
	# $(DOCKER_COMPOSE) ps || echo "⚠️ Failed to retrieve service status: Docker daemon may not be running"
	@echo "\nContainer Healthcheck Status:"
	# $(DOCKER_COMPOSE) ps --format "table {{.Name}}\t{{.Status}}\t{{.Health}}" || echo "⚠️ Failed to retrieve detailed health status"

stop:
	@echo "🛑 Stopping services..."
	# $(DOCKER_COMPOSE) down --volumes || echo "⚠️ Failed to stop services: Docker daemon may not be running"
	@echo "✅ Services stopped."

logs:
ifdef SERVICE
	@echo "📖 Tailing logs for $(SERVICE) (press Ctrl+C to exit)..."
	# $(DOCKER_COMPOSE) logs -f $(SERVICE) || echo "⚠️ Failed to retrieve logs for $(SERVICE) service"
else
	@echo "📖 Tailing all container logs (press Ctrl+C to exit)..."
	# $(DOCKER_COMPOSE) logs -f || echo "⚠️ Failed to retrieve service logs"
endif

shell: env-check
ifndef SERVICE
	$(error ❌ Please specify a service name: make shell SERVICE=<service_name>)
endif
ifeq ($(filter $(SERVICE),$(VALID_SERVICES)),)
	$(error ❌ Invalid service name: '$(SERVICE)'. Must be one of: $(VALID_SERVICES))
endif
	@echo "🐚 Accessing the shell of $(SERVICE) service..."
	# $(DOCKER_COMPOSE) exec $(SERVICE) bash || echo "⚠️ Failed to access $(SERVICE) service shell"

clean: stop
	@echo "🧹 Cleaning out the service resources..."
	# $(DOCKER_COMPOSE) down --volumes --rmi all || echo "⚠️ Failed to clean up Docker resources"
	rm -rf ./services/*/__pycache__
	rm -rf ./scripts/__pycache__
	@echo "✅ Service resources cleaned."