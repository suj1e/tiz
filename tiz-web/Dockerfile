# Build stage
# v2 - Force cache refresh for TypeScript fixes
FROM node:20-alpine AS builder

WORKDIR /app

# Install pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# Copy package files first for better layer caching
COPY package.json pnpm-lock.yaml ./

# Install dependencies (prod only for smaller node_modules)
RUN pnpm install --frozen-lockfile --prod=false

# Copy source code and config files
COPY tsconfig.json tsconfig.app.json tsconfig.node.json vite.config.ts ./
COPY postcss.config.* tailwind.config.* ./
COPY src/ ./src/
COPY public/ ./public/
COPY index.html ./

# Build production bundle
RUN pnpm build && \
    # Verify build output
    ls -la dist/

# Production stage
FROM nginx:alpine

# Add labels for metadata
LABEL maintainer="tiz-team"
LABEL version="1.0.0"
LABEL description="Tiz frontend production image"

# Remove default nginx website and logs to reduce image size
RUN rm -rf /usr/share/nginx/html/* /var/log/nginx/*

# Copy nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built files from builder
COPY --from=builder /app/dist /usr/share/nginx/html

# Create non-root user for nginx (security best practice)
RUN addgroup -g 1001 -S nginx-app && \
    adduser -S -D -H -u 1001 -h /usr/share/nginx/html -s /sbin/nologin -G nginx-app -g nginx-app nginx-app && \
    chown -R nginx-app:nginx-app /usr/share/nginx/html && \
    chown -R nginx-app:nginx-app /var/cache/nginx && \
    chown -R nginx-app:nginx-app /var/log/nginx && \
    chown -R nginx-app:nginx-app /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R nginx-app:nginx-app /var/run/nginx.pid

# Switch to non-root user
USER nginx-app

EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
