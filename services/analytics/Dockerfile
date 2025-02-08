# --- Stage 1: Build stage ---
FROM python:3.10-slim AS builder

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libffi-dev \
    libssl-dev \
    default-libmysqlclient-dev \
    libpq-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Set OpenSSL compilation flags
ENV LDFLAGS="-L/usr/lib/openssl"
ENV CFLAGS="-I/usr/include/openssl"

# Create necessary directories
WORKDIR /app

# Install Python packages
COPY requirements.txt /app/
RUN pip install --upgrade pip setuptools && \
    pip install --no-cache-dir -r /app/requirements.txt && \
    pip install --no-cache-dir gunicorn

# --- Stage 2: Final runtime image ---
FROM python:3.10-slim

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libffi8 \
    libssl3 \
    libpq5 \
    default-mysql-client \
    mariadb-client-core \
    libmariadb3 \
    && rm -rf /var/lib/apt/lists/*

# Copy Python environment from builder
COPY --from=builder /usr/local/lib/python3.10 /usr/local/lib/python3.10
COPY --from=builder /usr/local/bin/superset /usr/local/bin/
COPY --from=builder /usr/local/bin/gunicorn /usr/local/bin/

# Set up application environment
WORKDIR /app
COPY . /app/

# Create required directories and set permissions
RUN mkdir -p /app/superset_home /app/data/transformations && \
    adduser --disabled-password --gecos "" superset && \
    chown -R superset:superset /app && \
    chmod +x /app/docker-entrypoint.sh

# Set environment variables
ENV FLASK_APP=superset \
    SUPERSET_HOME=/app/superset_home \
    PYTHONPATH=/app \
    PATH="/usr/local/bin:$PATH"

# Switch to non-root user
USER superset

# Expose port
EXPOSE 8088

# Set entrypoint and default command
ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["gunicorn", "--bind", "0.0.0.0:8088", "--workers", "2", "--timeout", "120", "superset.app:create_app()"]