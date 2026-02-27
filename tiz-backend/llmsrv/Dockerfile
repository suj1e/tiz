# Tiz AI Service Dockerfile
# Multi-stage build for optimized production image

# ============================================
# Stage 1: Builder
# ============================================
FROM python:3.11-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install pixi
RUN curl -fsSL https://pixi.sh/install.sh | bash
ENV PATH="/root/.pixi/bin:$PATH"

WORKDIR /app

# Copy dependency files
COPY pixi.toml pyproject.toml ./

# Install dependencies
RUN pixi install

# ============================================
# Stage 2: Production
# ============================================
FROM python:3.11-slim AS production

# Create non-root user for security
RUN groupadd -r appgroup && useradd -r -g appgroup appuser

WORKDIR /app

# Copy virtual environment from builder
COPY --from=builder /app/.pixi/envs/default /app/.pixi/envs/default

# Copy application code
COPY app/ ./app/
COPY pyproject.toml ./

# Set environment variables
ENV PATH="/app/.pixi/envs/default/bin:$PATH"
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Switch to non-root user
RUN chown -R appuser:appgroup /app
USER appuser

# Expose port
EXPOSE 8106

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8106/health')" || exit 1

# Run the application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8106"]

# ============================================
# Stage 3: Development
# ============================================
FROM production AS development

# Switch back to root for development
USER root

# Install development tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Switch back to app user
USER appuser

# Run with reload for development
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8106", "--reload"]
