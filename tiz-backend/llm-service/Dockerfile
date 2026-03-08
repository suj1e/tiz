# Tiz AI Service Dockerfile
# Production-ready multi-stage build using pixi for dependency management

# ============================================
# Stage 1: Builder
# ============================================
FROM python:3.11-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install pixi to /usr/local/bin for consistent path
RUN curl -fsSL https://pixi.sh/install.sh | bash && \
    ln -sf /root/.pixi/bin/pixi /usr/local/bin/pixi

WORKDIR /app

# Copy dependency files
COPY pixi.toml pyproject.toml ./

# Install dependencies and create relocatable venv
RUN pixi install && \
    pixi run python -m venv /opt/venv && \
    pixi run pip freeze > /tmp/requirements.txt && \
    /opt/venv/bin/pip install --no-cache-dir -r /tmp/requirements.txt && \
    rm /tmp/requirements.txt

# ============================================
# Stage 2: Production
# ============================================
FROM python:3.11-slim AS production

# Install runtime dependencies only
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user for security
RUN groupadd -r appgroup && useradd -r -g appgroup -d /app appuser

WORKDIR /app

# Copy virtual environment from builder
COPY --from=builder --chown=appuser:appgroup /opt/venv /opt/venv

# Copy application code
COPY --chown=appuser:appgroup app/ ./app/
COPY --chown=appuser:appgroup pyproject.toml ./

# Set environment variables
ENV PATH="/opt/venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8106

# Health check with extended start period for uvicorn warmup
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8106/health || exit 1

# Run the application with production settings
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8106", "--workers", "2"]
