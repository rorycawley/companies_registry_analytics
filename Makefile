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
.PHONY: help start stop clean logs status build rebuild start-fresh test nuclear run

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
	@echo "$(YELLOW)$(BOLD)          🛠️  Available Commands  🛠️           $(RESET)"
	@echo "$(BLUE)$(BOLD)Core Commands:$(RESET)"
	@echo "  $(BOLD)make start$(RESET)        $(GREEN)→$(RESET)  🚀 Start all services"
	@echo "  $(BOLD)make stop$(RESET)         $(GREEN)→$(RESET)  🛑 Stop all services"
	@echo "  $(BOLD)make clean$(RESET)        $(GREEN)→$(RESET)  🧹 Stop and remove all resources"
	@echo "  $(BOLD)make run$(RESET)          $(GREEN)→$(RESET)  🔧 Run command in service (e.g., make run transformations dbt test)"
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
	@echo "$(BLUE)$(BOLD)Testing Commands:$(RESET)"
	@echo "  $(BOLD)make test$(RESET)         $(GREEN)→$(RESET)  🧪 Run all tests"
	@echo ""
	@echo "$(RED)$(BOLD)Danger Zone:$(RESET)"
	@echo "  $(BOLD)make nuclear$(RESET)      $(GREEN)→$(RESET)  💥 Remove all Docker resources\n"

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
	# @rm -rf data/ingestion/companies_registry/*.duckdb
	# @rm -rf data/ingestion/companies_registry/parquet_tables/*	
	@rm -rf data/transformations/*	
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

run:
	@echo "$(INFO) $(STEP)Running command in $(word 2,$(MAKECMDGOALS))... 🚀 ($(TIMESTAMP))$(RESET)"
	@$(call execute_command,docker compose run --rm $(word 2,$(MAKECMDGOALS)) $(wordlist 3,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS)))

nuke:
	@echo "$(ERROR) $(STEP)WARNING: This will remove ALL Docker resources! ($(TIMESTAMP))$(RESET)"
	@echo "$(ERROR) This includes:"
	@echo "  - All containers (running or stopped)"
	@echo "  - All volumes"
	@echo "  - All networks"
	@echo "  - All images"
	@$(call execute_command,docker system prune -a --volumes -f)
