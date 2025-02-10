# docker build --no-cache -t companies-registry-analytics-image .
#
# docker run -d -p 8088:8088 \
#     -e SUPERSET_SECRET_KEY="U5ijkoEeu7iJ5BS0O6J1TaNNULDUuLRH0Vz3Lue4dkvUfjTcPaOfrZqW" \
#     -v $(pwd)/superset_home:/app/superset_home \
#     -v $(pwd)/config:/app/config \
#     -v $(pwd)/../../data/transformations:/app/data/transformations \
#     --name companies-registry-analytics \
#     companies-registry-analytics-image
#
# docker run -d -p 8088:8088 \
# -e SUPERSET_SECRET_KEY="U5ijkoEeu7iJ5BS0O6J1TaNNULDUuLRH0Vz3Lue4dkvUfjTcPaOfrZqW" \
# -e PREVENT_UNSAFE_DB_CONNECTIONS=false \
# -e ENABLE_TEMPLATE_PROCESSING=false \
# -v $(pwd)/superset_home:/app/superset_home \
# -v $(pwd)/config:/app/config \
# -v $(pwd)/../../data/transformations:/app/data/transformations \
# --name companies-registry-analytics \
# companies-registry-analytics-image
# 
# duckdb:///data/transformations/transformed_data.duckdb
# 
# docker rm -f companies-registry-analytics
# rm -rf superset_home 
# docker rmi companies-registry-analytics-image  
#
# docker logs companies-registry-analytics
#
# docker exec -it companies-registry-analytics superset export-dashboards -f /app/superset_home/exported_dashboards.zip  
# Use python:3.10.12-slim-bullseye for Superset. Debian-based images enable faster installation 
# of pre-built Python wheels, significantly improving build times compared to Alpine, which 
# requires compiling from source.
FROM python:3.10.12-slim-bullseye

ENV PYTHONPATH=/app \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONLOGGING=INFO \
    DEBIAN_FRONTEND=noninteractive \
    VIRTUAL_ENV=/app/venv \
    PATH="/app/venv/bin:$PATH" \
    FLASK_APP=superset \
    FLASK_ENV=development \
    SUPERSET_ENV=dev \
    VERSIONED_EXPORT=true \
    SUPERSET_PORT=8088 \
    SUPERSET_TIMEOUT=300 \
    SUPERSET_LOAD_EXAMPLES=false \
    SUPERSET_HOME=/app/superset_home \
    SUPERSET_DASHBOARD=/app/config

# Create the Superset user and group early with specific UID/GID
RUN groupadd --system --gid 1001 superset && \
    useradd --system --uid 1001 --gid superset --shell /bin/bash --create-home superset

# Install system dependencies required for Superset
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3-dev \
    python3-pip \
    libsasl2-dev \
    libldap2-dev \
    default-libmysqlclient-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create and set working directory
WORKDIR /app

# Copy the requirements.txt into the container
COPY --chown=superset:superset requirements.txt .

# Set up Python virtual environment and install dependencies
RUN python -m venv /app/venv && \
    . /app/venv/bin/activate && \
    pip install --upgrade pip && \
    pip install uv==0.5.29 && \
    uv pip install --system --no-cache -r requirements.txt && \
    chown -R superset:superset /app/venv

# Create a health check script
COPY --chown=superset:superset <<-EOF /usr/local/bin/health-check.sh
    #!/bin/bash
    if curl -f "http://localhost:8088/health" >/dev/null 2>&1; then
        exit 0
    else
        exit 1
    fi
EOF

# Copy entrypoint script and set permissions
COPY --chown=superset:superset docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/health-check.sh && \
    chmod +x /usr/local/bin/docker-entrypoint.sh

# Create and set up Superset home directory
RUN mkdir -p ${SUPERSET_HOME} && \
    chown -R superset:superset ${SUPERSET_HOME}

# Add security hardening
RUN chmod -R 755 /usr/local/bin/ && \
    chmod -R 644 ${SUPERSET_HOME}

# Switch to non-root user
USER superset

EXPOSE ${SUPERSET_PORT}

# Add health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 CMD [ "/usr/local/bin/health-check.sh" ]

# How to override SUPERSET_SECRET_KEY:
#   docker run -e SUPERSET_SECRET_KEY="your-secret-key" ...
ENTRYPOINT ["docker-entrypoint.sh"]