FROM python:3.11-slim

# Create a non-root system user for security hardening
RUN useradd -m -u 1000 appuser

WORKDIR /app

# Copy application script
COPY app.py .

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch runtime context to non-root user
USER appuser

# Expose required container port
EXPOSE 8081

# Disable Python stdout buffering so container logs show instantly
ENV PYTHONUNBUFFERED=1

CMD ["python", "app.py"]
