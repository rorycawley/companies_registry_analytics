# Use an official Python runtime as a parent image
FROM python:3.10.12-slim

# ENV POSTGRES_USER=${POSTGRES_USER}

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file and install dependencies
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy the rest of the project code into the container
COPY . .

# Create a non-root user for security
RUN useradd -m -r pipeline_user && \
    chown -R pipeline_user:pipeline_user /app
USER pipeline_user

# Set the default command to run your pipeline script
CMD ["python", "pipeline.py"]