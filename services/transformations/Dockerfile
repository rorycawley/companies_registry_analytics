FROM python:3.10.12-slim

ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt .

RUN python -m venv /app/venv && \
    pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY . .

COPY docker-entrypoint.sh /app/
RUN chmod +x /app/docker-entrypoint.sh

ENTRYPOINT ["/app/docker-entrypoint.sh"]
