# Use an official Python runtime as a parent image
FROM python:3.11-slim

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file and install dependencies
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy the rest of the project code into the container
COPY . .

# Copy the entrypoint script to /usr/local/bin and make it executable
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Create a non-root user for security
RUN useradd -m -r rl_csv_pipeline_user && \
    chown -R rl_csv_pipeline_user:rl_csv_pipeline_user /app
USER rl_csv_pipeline_user

# Create the output directory and set permissions
RUN mkdir -p /app/data/ingestion/risky_locations && \
    chown -R rl_csv_pipeline_user:rl_csv_pipeline_user /app/data/ingestion/risky_locations

ENTRYPOINT ["docker-entrypoint.sh"]