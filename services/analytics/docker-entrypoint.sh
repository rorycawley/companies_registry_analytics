#!/bin/sh
set -e

# === 1. Environment Configuration ===
export PYTHONPATH=/app
export SUPERSET_HOME=${SUPERSET_HOME:-"$PYTHONPATH/superset_home"}
export SUPERSET_CONFIGURATION=${SUPERSET_CONFIGURATION:-"$PYTHONPATH/config"}
export FLASK_APP=${FLASK_APP:-"superset"}
export TRANSFORMED_DATA_DATABASE=${TRANSFORMED_DATA_DATABASE:-"$PYTHONPATH/data/transformations/transformed_data.duckdb"}
export WAIT_FOR_DUCKDB=${WAIT_FOR_DUCKDB:-"true"}

# === 2. Set Default Admin Credentials (if not provided via environment) ===
# These default values match your non-Docker setup.
ADMIN_USERNAME=${ADMIN_USERNAME:-admin}
ADMIN_FIRSTNAME=${ADMIN_FIRSTNAME:-Superset}
ADMIN_LASTNAME=${ADMIN_LASTNAME:-Admin}
ADMIN_EMAIL=${ADMIN_EMAIL:-admin@example.com}
ADMIN_PASSWORD=${ADMIN_PASSWORD:-admin}

# === 2. Verify Required Environment Variables ===
if [ -z "$SUPERSET_SECRET_KEY" ]; then
    echo "Error: SUPERSET_SECRET_KEY environment variable is required."
    exit 1
fi
echo "All required environment variables are set."

# === 3. Create Required Directories ===
mkdir -p "$SUPERSET_HOME"

# === 4. DuckDB Configuration ===
if [ "$WAIT_FOR_DUCKDB" = "true" ]; then
    echo "Waiting for DuckDB file at ${TRANSFORMED_DATA_DATABASE}..."
    
    max_wait=300
    waited=0
    while [ ! -f "$TRANSFORMED_DATA_DATABASE" ]; do
        if [ $waited -ge $max_wait ]; then
            echo "Warning: Transformed data database file not found after ${max_wait} seconds. Continuing startup..."
            break
        fi
        echo "Waiting for Transformed data database file... ($waited/${max_wait}s)"
        sleep 5
        waited=$((waited+5))
    done
    
    if [ -f "$TRANSFORMED_DATA_DATABASE" ]; then
        echo "Transformed data database file found successfully."
        export WAIT_FOR_DUCKDB="false"
    fi
fi



# === 5. Initialize Superset if Not Already Initialized ===
if [ ! -f "$SUPERSET_HOME/superset.db" ]; then
  echo "Upgrading Superset Metadata DB..."
  superset db upgrade

  echo "Creating Admin User..."
  superset fab create-admin \
    --username "$ADMIN_USERNAME" \
    --firstname "$ADMIN_FIRSTNAME" \
    --lastname "$ADMIN_LASTNAME" \
    --email "$ADMIN_EMAIL" \
    --password "$ADMIN_PASSWORD"

  echo "Initializing Superset..."
  superset init
fi

# === 7. Import Exported Dashboard (only once) ===
DASHBOARD_MARKER="$SUPERSET_HOME/.dashboard_imported"
DASHBOARD_FILE="$SUPERSET_CONFIGURATION/exported_dashboard.zip"

if [ ! -f "$DASHBOARD_MARKER" ]; then
    if [ -f "$DASHBOARD_FILE" ]; then
        echo "Importing dashboard from $DASHBOARD_FILE..."
        if superset import-dashboards -p "$DASHBOARD_FILE" -u "${ADMIN_USERNAME:-admin}"; then
            touch "$DASHBOARD_MARKER"
            echo "Dashboard import completed successfully."
        else
            echo "Warning: Dashboard import failed. Please check the logs."
        fi
    else
        echo "No dashboard file found at $DASHBOARD_FILE. Marking check as complete."
        touch "$DASHBOARD_MARKER"
    fi
fi


# === 7. Health Check and Port Configuration ===
PORT=${SUPERSET_PORT:-8088}
echo "============================================"
echo "Apache Superset Initialization Complete"
echo "----------------------------------------"
echo "Access URL: http://localhost:${PORT}"
echo "Admin User: ${ADMIN_USERNAME:-admin}"
echo "============================================"

# === 10. Execute the provided command (gunicorn) ===
exec "$@"
