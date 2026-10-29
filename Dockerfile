# Use an official lightweight Python image based on Debian Slim to minimize attack surface
FROM python:3.11-slim

# Create a non-root system user with a explicit UID (1000) for least-privilege security
RUN useradd -m -u 1000 appuser

# Set the working directory inside the container for all subsequent commands
WORKDIR /app

# Copy application source code into the container working directory
COPY app.py .

# Change ownership of the application directory to the non-root user
RUN chown -R appuser:appuser /app

# Switch execution context from root to the unprivileged user
USER appuser

# Document that the container listens on port 8081 at runtime
EXPOSE 8081

# Ensure Python outputs stdout/stderr directly without buffering for real-time docker logs
ENV PYTHONUNBUFFERED=1

# Native Docker Healthcheck querying port 8081 every 30 seconds to monitor container health
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8081/')" || exit 1

# Define the default command to start the Python web application
CMD ["python", "app.py"]
