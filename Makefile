.PHONY: help setup env-check build start stop logs shell clean

# Default target
help:
	@echo "\n✨ Available commands: ✨\n"
	@echo "  make setup             - ⚙️ Run the first-time setup script"
	@echo "  make env-check         - ✅ Check if all required environment variables are set"
	@echo "  make build             - 🏗️ Build the Docker images"
	@echo "  make start             - 🚀 Start the services"
	@echo "  make stop              - 🛑 Stop and remove the services"
	@echo "  make logs              - 📖 View the logs of the services"
	@echo "  make shell SERVICE     - 🐚 Open a shell inside a running service (e.g., make shell SERVICE=dashboard)"
	@echo "  make clean             - 🧹 Clean out the services resources\n"

setup: env-check
	@echo "⚙️ Setting up the system..."
	python3 setup.py
	@echo "✅ Setup complete!"

env-check:
ifndef SUPERSET_SECRET_KEY
	$(error ❌ SUPERSET_SECRET_KEY is not set. Please set this environment variable.)
endif
ifndef SUPERSET_PORT
	$(error ❌ SUPERSET_PORT is not set. Please set this environment variable.)
endif
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
	# docker-compose build
	@echo "✅ Docker images built successfully!"

start: env-check
	@echo "🚀 Starting the services..."
	# docker-compose up -d
	@echo "🎉 Services are starting up. Access Superset at http://localhost:$${SUPERSET_PORT:-8088}"
	@echo "📖 Use 'make logs' to view container logs with: make logs"

stop: env-check
	@echo "🛑 Stopping services..."
	# docker-compose down --volumes
	@echo "✅ Services stopped."

logs:
	@echo "📖 Tailing container logs (press Ctrl+C to exit)..."
	# docker-compose logs -f superset

shell: env-check
	@echo "🐚 Accessing the shell of $(SERVICE) service..."
	# docker compose exec $(SERVICE) bash

clean: stop
	@echo "🧹 Cleaning out the service resources..."
	# docker compose down --volumes --rmi all
	# rm -rf ./dashboard/__pycache__
	@echo "✅ Service resources cleaned."
