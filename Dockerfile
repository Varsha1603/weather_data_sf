# Use the official Astro runtime image
FROM quay.io/astronomer/astro-runtime:latest

# Set the working directory
WORKDIR /usr/local/airflow

# Install any additional system dependencies if required
USER root
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    git \
    && rm -rf /var/lib/apt/lists/*

# Switch back to the airflow user
USER astro

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Expose ports for Airflow
EXPOSE 8090  # Changed from 8080

# Set environment variables (modify based on needs)
ENV AIRFLOW_HOME=/usr/local/airflow
ENV AIRFLOW__CORE__EXECUTOR=KubernetesExecutor
ENV AIRFLOW__KUBERNETES__NAMESPACE=airflow
ENV AIRFLOW__KUBERNETES__WORKER_CONTAINER_REPOSITORY=weatheracrname.azurecr.io/airflow
ENV AIRFLOW__KUBERNETES__WORKER_CONTAINER_TAG=latest

# Define the entry point for the container
ENTRYPOINT ["tini", "--"]

# Start Airflow webserver (modify if needed)
CMD ["airflow", "webserver"]
