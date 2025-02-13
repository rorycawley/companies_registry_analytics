#!/bin/bash
set -euo pipefail

# Run DBT commands
dbt seed
dbt compile
dbt run
dbt test