# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Install pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# Copy package files first for better layer caching
COPY package.json pnpm-lock.yaml ./

# Install dependencies
RUN pnpm install --frozen-lockfile --prod=false

# Copy source code and config files
COPY tsconfig.json tsconfig.app.json tsconfig.node.json vitest.config.ts ./
COPY postcss.config.* ./
COPY src/ ./src/
COPY public/ ./public/
COPY index.desktop.html index.mobile.html ./
COPY vite.config.desktop.ts vite.config.mobile.ts ./

# Build both versions
RUN pnpm build:all && \
    ls -la dist/desktop/ dist/mobile/

# Production stage - Unified desktop + mobile
FROM nginx:alpine

LABEL maintainer="tiz-team"
LABEL version="3.0.0"
LABEL description="Tiz frontend - Unified desktop/mobile with UA routing"

RUN rm -rf /usr/share/nginx/html/* /var/log/nginx/*

# Copy nginx config with UA routing
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy both builds and rename index files
COPY --from=builder /app/dist/desktop /usr/share/nginx/html/desktop
COPY --from=builder /app/dist/mobile /usr/share/nginx/html/mobile

# Rename index files to standard index.html
RUN mv /usr/share/nginx/html/desktop/index.desktop.html /usr/share/nginx/html/desktop/index.html && \
    mv /usr/share/nginx/html/mobile/index.mobile.html /usr/share/nginx/html/mobile/index.html

# Create non-root user
RUN addgroup -g 1001 -S nginx-app && \
    adduser -S -D -H -u 1001 -h /usr/share/nginx/html -s /sbin/nologin -G nginx-app -g nginx-app nginx-app && \
    chown -R nginx-app:nginx-app /usr/share/nginx/html /var/cache/nginx /var/log/nginx /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R nginx-app:nginx-app /var/run/nginx.pid

USER nginx-app
EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

CMD ["nginx", "-g", "daemon off;"]
