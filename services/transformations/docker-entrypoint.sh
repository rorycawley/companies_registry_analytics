#!/bin/bash
set -e  # Exit on error

# List of required environment variables
required_vars=(
    "DBT_DATAWAREHOUSE_DB"
    "DBT_SOURCE_COMPANIES_REGISTRY_PARQUET_EXPORT"
    "DBT_SOURCE_PEPS_PARQUET_EXPORT"
    "DBT_SOURCE_RISKY_LOCATIONS_PARQUET_EXPORT"
)

# Check each required variable
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: Required environment variable '$var' is not set"
        exit 1
    fi
done

# Run DBT commands
dbt seed
dbt compile


# If all checks pass, execute the command passed to the script
exec "$@"