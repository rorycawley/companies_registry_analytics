#!/bin/sh

set -e

# === 1. Check Required Environment Variables ===
REQUIRED_ENV_VARS="SUPERSET_SECRET_KEY FLASK_APP ADMIN_USERNAME ADMIN_PASSWORD"
for var in $REQUIRED_ENV_VARS; do
  if [ -z "$(printenv $var)" ]; then
    echo "Error: Environment variable $var is not set." >&2
    exit 1
  fi
done
echo "All required environment variables are set."

# === 2. Wait for DuckDB file to be available ===
DUCKDB_FILE="/app/data/transformation/trans.duckdb"
echo "Waiting for DuckDB file at ${DUCKDB_FILE} to be available..."
max_wait=300
waited=0
while [ ! -f "$DUCKDB_FILE" ]; do
  sleep 5
  waited=$((waited+5))
  if [ $waited -ge $max_wait ]; then
    echo "Error: Timeout waiting for DuckDB file at ${DUCKDB_FILE}" >&2
    exit 1
  fi
done
echo "DuckDB file found."

# === 3. Set Superset Home (to override ~/.superset) ===
if [ -z "$SUPERSET_HOME" ]; then
  export SUPERSET_HOME="/app/superset_home"
  mkdir -p "$SUPERSET_HOME"
fi

if [ ! -f "$SUPERSET_HOME/superset.db" ]; then
# === 4. Upgrade Superset Metadata DB ===
echo "Upgrading Superset DB..."
  superset db upgrade
# === 5. Create Admin User if Not Already Present ===
  superset fab create-admin \
    --username admin \
    --firstname Superset \
    --lastname Admin \
    --email admin@example.com \
    --password admin

# === 6. Initialize Superset ===
  echo "Initializing Superset database..."
  superset init
fi


# === 7. Import Exported Dashboard (only once) ===
if [ ! -f "/app/superset_home/.dashboard_imported" ]; then
  if [ -f "/app/exported_dashboards/exported_dashboard.zip" ]; then
    echo "Importing exported dashboard..."
    superset import_datasources -p /app/exported_dashboards/exported_dashboard.zip -u admin
    touch /app/superset_home/.dashboard_imported
  else
    echo "No exported dashboard zip found, skipping import."
  fi
else
  echo "Exported dashboard already imported, skipping."
fi

# === 9. Print Friendly Message with Configurable Port ===
PORT=${SUPERSET_PORT:-8088}
echo "--------------------------------------------------"
echo "Superset is up and running!"
echo "Access Superset at http://localhost:${PORT}"
echo "--------------------------------------------------"

# === 10. Execute the provided command (gunicorn) ===
exec "$@"
