# Tiz AI Service Dockerfile
# Extract dependencies from pixi.toml and use pip (pixi not needed during build)

# ============================================
# Stage 1: Builder
# ============================================
FROM python:3.11-slim AS builder

# Use Aliyun mirror for faster downloads in China
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list.d/debian.sources 2>/dev/null || \
    sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list 2>/dev/null || true

WORKDIR /app

# Copy pixi.toml and extract script
COPY pixi.toml extract_deps.py ./

# Install toml package, extract dependencies, and install them
RUN pip install toml -i https://pypi.tuna.tsinghua.edu.cn/simple && \
    python3 extract_deps.py && \
    cat requirements.txt && \
    pip install --no-cache-dir -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

# ============================================
# Stage 2: Production
# ============================================
FROM python:3.11-slim AS production

# Use Aliyun mirror for faster downloads in China
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list.d/debian.sources 2>/dev/null || \
    sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list 2>/dev/null || true

# Install runtime dependencies only
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user for security
RUN groupadd -r appgroup && useradd -r -g appgroup -d /app appuser

WORKDIR /app

# Copy site-packages from builder
COPY --from=builder --chown=appuser:appgroup /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder --chown=appuser:appgroup /usr/local/bin /usr/local/bin

# Copy application code
COPY --chown=appuser:appgroup app/ ./app/
COPY --chown=appuser:appgroup pyproject.toml pixi.toml ./

# Set environment variables
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
