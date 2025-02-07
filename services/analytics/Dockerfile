# Multi-stage build to create a smaller final image
FROM python:3.10-slim AS builder

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libffi-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages
COPY requirements.txt /tmp/
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Final stage with minimal runtime dependencies
FROM python:3.10-slim

# Copy installed Python packages from builder
COPY --from=builder /usr/local/lib/python3.10/site-packages/ /usr/local/lib/python3.10/site-packages/

# Copy application code
COPY . /app/
WORKDIR /app

# Install runtime dependencies, create non-root user, and set permissions
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libffi8 \
    libssl3 \
    && rm -rf /var/lib/apt/lists/* && \
    adduser --disabled-password --gecos "" superset && \
    chown -R superset:superset /app && \
    chmod +x docker-entrypoint.sh

# Switch to non-root user for security
USER superset

# Expose port for Superset web interface
EXPOSE 8088

# Start Gunicorn with Superset application
CMD ["gunicorn", "--bind", "0.0.0.0:8088", "--workers", "4", "--timeout", "120", "superset.app:create_app()"]