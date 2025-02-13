FROM python:3.10.12-slim

# Declare build arguments with default values
ARG SUPERSET_HOME
ARG SUPERSET_PORT
ARG SUPERSET_DASHBOARD

# Set environment variables using the build arguments
ENV SUPERSET_HOME=${SUPERSET_HOME} \
    SUPERSET_PORT=${SUPERSET_PORT} \
    SUPERSET_DASHBOARD=${SUPERSET_DASHBOARD}

# build-time configuration that shouldn't change
ENV PYTHONPATH=/app \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONLOGGING=INFO \
    DEBIAN_FRONTEND=noninteractive \
    VIRTUAL_ENV=/app/venv \
    PATH="/app/venv/bin:$PATH"

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

# Copy entrypoint script and set permissions
COPY --chown=superset:superset docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Ensure proper permissions
# Create Superset home directory and set permissions
RUN mkdir -p ${SUPERSET_HOME} && \
    chown -R superset:superset ${SUPERSET_HOME}

# Add security hardening
RUN chmod -R 755 /usr/local/bin/ && \
    chmod -R 755 ${SUPERSET_HOME}

# Switch to non-root user
USER superset

EXPOSE ${SUPERSET_PORT}

# How to override SUPERSET_SECRET_KEY:
#   docker run -e SUPERSET_SECRET_KEY="your-secret-key" ...
ENTRYPOINT ["docker-entrypoint.sh"]