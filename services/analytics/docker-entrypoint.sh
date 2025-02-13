#!/bin/bash
set -euo pipefail

echo ""
echo "🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧"
echo "Running the Superset docker-entrypoint script"
echo "🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧"
echo ""

# Validate mandatory variables
if [ -z "$SUPERSET_SECRET_KEY" ]; then
    echo "ERROR: SUPERSET_SECRET_KEY environment variable must be set" >&2
    echo "Please set this variable before starting the container:" >&2
    echo "export SUPERSET_SECRET_KEY=your-secure-key-here" >&2
    exit 1
fi

echo "Looking to see if we initialise Superset"

if [ ! -f "$SUPERSET_HOME/superset.db" ]; then
    echo ""
    echo "🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧"
    echo "We are initialising Superset"
    echo "🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧"
    echo ""

    superset db upgrade

    superset fab create-admin \
        --username "${ADMIN_USERNAME:-admin}" \
        --firstname "Admin" \
        --lastname "User" \
        --email "${ADMIN_EMAIL:-admin@example.com}" \
        --password "${ADMIN_PASSWORD:-admin}"

    # Load examples (optional, can be removed for faster startup)
    [ "$SUPERSET_LOAD_EXAMPLES" = "true" ] && superset load_examples

    # Initialize Superset
    superset init

    # Import dashboards (if any)
    DASHBOARD_FILE="${SUPERSET_DASHBOARD}/exported_dashboard.zip"

    echo ""
    echo "🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧"
    echo "Looking to see if we import Superset dashboard: ${DASHBOARD_FILE}"
    echo "🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧"
    echo ""

    if [ -f "$DASHBOARD_FILE" ]; then
        echo ""
        echo "🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧"
        echo "Yes we going to import Superset dashboard: ${DASHBOARD_FILE}"
        echo "🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧"
        echo ""
        if ! superset import-dashboards -p "$DASHBOARD_FILE" -u "${ADMIN_USERNAME:-admin}"; then
            echo "Warning: Dashboard import failed" >&2
        fi
    fi
fi

echo ""
echo "🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧"
echo "Finished with the Superset initialisation script"
echo "🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧🔧"
echo ""

# Start server with proper binding
exec superset run -p 8088 --with-threads --reload --debugger --host=0.0.0.0


# #!/bin/sh
# set -e

# # === 1. Environment Configuration ===
# export PYTHONPATH=/app
# export SUPERSET_HOME=${SUPERSET_HOME:-"$PYTHONPATH/superset_home"}
# export SUPERSET_CONFIGURATION=${SUPERSET_CONFIGURATION:-"$PYTHONPATH/config"}
# export FLASK_APP=${FLASK_APP:-"superset"}
# export TRANSFORMED_DATA_DATABASE=${TRANSFORMED_DATA_DATABASE:-"$PYTHONPATH/data/transformations/transformed_data.duckdb"}
# export WAIT_FOR_DUCKDB=${WAIT_FOR_DUCKDB:-"true"}

# echo "🔧 Configuring Superset environment"
# echo "   • SUPERSET_HOME: $SUPERSET_HOME"
# echo "   • Configuration: $SUPERSET_CONFIGURATION"
# echo "   • Database: $TRANSFORMED_DATA_DATABASE"

# # === 2. Set Default Admin Credentials ===
# ADMIN_USERNAME=${ADMIN_USERNAME:-admin}
# ADMIN_FIRSTNAME=${ADMIN_FIRSTNAME:-Superset}
# ADMIN_LASTNAME=${ADMIN_LASTNAME:-Admin}
# ADMIN_EMAIL=${ADMIN_EMAIL:-admin@example.com}
# ADMIN_PASSWORD=${ADMIN_PASSWORD:-admin}

# echo "👤 Admin configuration verified"

# # === 3. Verify Required Environment Variables ===
# if [ -z "$SUPERSET_SECRET_KEY" ]; then
#     echo "❌ ERROR: Missing SUPERSET_SECRET_KEY environment variable"
#     exit 1
# fi
# echo "✅ Environment variables verified"

# # === 4. Create Required Directories ===
# mkdir -p "$SUPERSET_HOME"
# echo "📁 Created Superset directory: $SUPERSET_HOME"

# # === 5. DuckDB Configuration ===
# if [ "$WAIT_FOR_DUCKDB" = "true" ]; then
#     echo "⏳ Checking database availability"
#     echo "   Location: $TRANSFORMED_DATA_DATABASE"
    
#     max_wait=300
#     waited=0
#     while [ ! -f "$TRANSFORMED_DATA_DATABASE" ]; do
#         if [ $waited -ge $max_wait ]; then
#             echo "⚠️  Database not found after ${max_wait}s"
#             echo "   Continuing startup process"
#             break
#         fi
#         echo "   Checking database... (${waited}s/${max_wait}s)"
#         sleep 5
#         waited=$((waited+5))
#     done
    
#     if [ -f "$TRANSFORMED_DATA_DATABASE" ]; then
#         echo "✅ Database connection successful"
#         export WAIT_FOR_DUCKDB="false"
#     fi
# fi

# # === 6. Initialize Superset ===
# if [ ! -f "$SUPERSET_HOME/superset.db" ]; then
#     echo "🔄 Performing first-time initialization"
#     echo "   Upgrading metadata database..."
#     superset db upgrade

#     echo "👤 Creating admin account"
#     superset fab create-admin \
#         --username "$ADMIN_USERNAME" \
#         --firstname "$ADMIN_FIRSTNAME" \
#         --lastname "$ADMIN_LASTNAME" \
#         --email "$ADMIN_EMAIL" \
#         --password "$ADMIN_PASSWORD"

#     echo "🚀 Initializing Superset"
#     superset init
#     echo "✅ Setup complete"
# fi

# # === 7. Import Dashboard Configuration ===
# DASHBOARD_MARKER="$SUPERSET_HOME/.dashboard_imported"
# DASHBOARD_FILE="$SUPERSET_CONFIGURATION/exported_dashboard.zip"

# if [ ! -f "$DASHBOARD_MARKER" ]; then
#     echo "   No import marker found, checking for dashboard file"
#     if [ -f "$DASHBOARD_FILE" ]; then
#         echo "   Dashboard file found, attempting import"
#         if superset import-dashboards -p "$DASHBOARD_FILE" -u "${ADMIN_USERNAME:-admin}"; then
#             touch "$DASHBOARD_MARKER"
#             echo "✅ Dashboard import successful"
#         else
#             echo "⚠️  Dashboard import failed"
#             echo "   Check application logs for details"
#         fi
#     else
#         echo "📊 No dashboard configuration found at:"
#         echo "   $DASHBOARD_FILE"
#         echo "   Creating marker file to skip future checks"
#         touch "$DASHBOARD_MARKER"
#     fi
# else
#     echo "📊 Dashboard marker exists, skipping import check"
# fi

# # === 8. Display Status Information ===
# PORT=${SUPERSET_PORT:-8088}
# echo "✨ Apache Superset is ready"
# echo "🌍 Access: http://localhost:${PORT}"
# echo "👤 User: ${ADMIN_USERNAME}"
# echo "📚 Documentation: https://superset.apache.org/docs/"

# # === 9. Execute Command ===
# exec "$@"