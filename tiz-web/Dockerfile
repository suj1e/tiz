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

# Production stage - Desktop
FROM nginx:alpine AS desktop

LABEL maintainer="tiz-team"
LABEL version="2.0.0"
LABEL description="Tiz frontend - Desktop version"

RUN rm -rf /usr/share/nginx/html/* /var/log/nginx/*

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/dist/desktop /usr/share/nginx/html

RUN addgroup -g 1001 -S nginx-app && \
    adduser -S -D -H -u 1001 -h /usr/share/nginx/html -s /sbin/nologin -G nginx-app -g nginx-app nginx-app && \
    chown -R nginx-app:nginx-app /usr/share/nginx/html /var/cache/nginx /var/log/nginx /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R nginx-app:nginx-app /var/run/nginx.pid

USER nginx-app
EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]

# Production stage - Mobile
FROM nginx:alpine AS mobile

LABEL maintainer="tiz-team"
LABEL version="2.0.0"
LABEL description="Tiz frontend - Mobile version"

RUN rm -rf /usr/share/nginx/html/* /var/log/nginx/*

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/dist/mobile /usr/share/nginx/html

RUN addgroup -g 1001 -S nginx-app && \
    adduser -S -D -H -u 1001 -h /usr/share/nginx/html -s /sbin/nologin -G nginx-app -g nginx-app nginx-app && \
    chown -R nginx-app:nginx-app /usr/share/nginx/html /var/cache/nginx /var/log/nginx /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R nginx-app:nginx-app /var/run/nginx.pid

USER nginx-app
EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
