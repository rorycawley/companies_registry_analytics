# Analytics Platform Setup Guide

This system provides a modular and cross-platform data analytics platform designed to operate efficiently across different scales, from local development to enterprise-level deployments.

## Prerequisites

The following software must be installed on your system before proceeding:
- Docker and Docker Compose
- Python 3.x
- Make

## Initial Setup

To initialize your environment, run:
```bash
make setup
```

This command creates a `.env` file with the required configuration settings. After setup, verify your environment variables with:

```bash
make env-check
```

## Service Architecture

The platform consists of four main services:
- analytics: Data visualization and exploration interface
- transformations: Data processing and transformation service
- ingestion: Data ingestion and integration service
- registry-database: Core data storage service

## Operation Commands

Start the platform:
```bash
make start
```
This launches all services and provides access to the analytics dashboard at http://localhost:[SUPERSET_PORT].

Monitor service status:
```bash
make status
```

View service logs:
```bash
make logs                    # View all service logs
make logs SERVICE=analytics  # View specific service logs
```

Access service shells:
```bash
make shell SERVICE=analytics
```

Stop all services:
```bash
make stop
```

Remove all resources:
```bash
make clean
```

For a complete list of available commands and their descriptions, run:
```bash
make help
```

## Development Workflow

The typical development workflow follows these steps:

1. Initialize the environment using `make setup`
2. Verify configuration with `make env-check`
3. Build services using `make build`
4. Start the platform with `make start`
5. Monitor operations through `make status` and `make logs`
6. Access specific services via `make shell SERVICE=<service-name>`
7. Stop services using `make stop`
8. Clean up resources with `make clean` when needed

Each command includes safeguards to ensure proper configuration and execution.

# Notable Docker commands

```sh
docker stop companies-registry-analytics-container
docker rm companies-registry-analytics-container
docker rmi companies-registry-analytics-image

docker run -d -p 8088:8088 \
-v /Users/rorycawley/Development/pydev/companies_registry_analytics/services/analytics/superset_home:/app/superset_home \
-v /Users/rorycawley/Development/pydev/companies_registry_analytics/data/transformations/transformed_data.duckdb:/app/data/transformations/transformed_data.duckdb \
-v /Users/rorycawley/Development/pydev/companies_registry_analytics/services/analytics/assets/:/app/assets \
-e SUPERSET_SECRET_KEY="U5ijkoEeu7iJ5BS0O6J1TaNNULDUuLRH0Vz3Lue4dkvUfjTcPaOfrZqW" \
--name companies-registry-analytics-container \
companies-registry-analytics-image

docker logs companies-registry-analytics-container

docker build -t companies-registry-analytics-image .

docker build --no-cache -t companies-registry-analytics-image .

docker exec companies-registry-analytics-container ls -la /app/superset_home/.dashboard_imported

docker exec companies-registry-analytics-container rm /app/superset_home/.dashboard_imported
```