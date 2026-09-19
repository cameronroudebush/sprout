# -------------------------------
#       Build Frontend
# -------------------------------
FROM ghcr.io/adrianjagielak/flutter:3.47.4 AS frontend-build
WORKDIR /app
COPY .git .git
COPY ./frontend ./
RUN flutter build web --release --no-tree-shake-icons --build-name=$(git describe --tags --always)

# -------------------------------
#       Build Backend
# -------------------------------
FROM node:24-alpine3.23 AS backend-build
# Install build tools for compiling native C++ modules
RUN apk add --no-cache git python3 make g++
WORKDIR /app

COPY ./backend/package.json ./
RUN npm i

COPY .git .git
COPY ./backend .
RUN npm run build

# -------------------------------
#       Build Final Result
# -------------------------------
FROM alpine:3.24.1 AS prod
EXPOSE 80

# Install runtime Node engine and Nginx (no npm or build tools)
RUN apk add --no-cache nginx libstdc++ ca-certificates nodejs=~24 \
    && rm -rf /var/cache/apk/*

ENV sprout_server_port=8001
ENV sprout_database_sqlite_database=/sprout/sprout.sqlite
ENV sprout_database_backup_directory=/sprout/backups/database

WORKDIR /app

# Grab static assets
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY --from=frontend-build /app/build/web /usr/share/nginx/html

# Copy bundled application code
COPY --from=backend-build /app/dist ./dist

# Copy strictly required external packages and their native build artifacts
COPY --from=backend-build /app/node_modules/better-sqlite3 ./node_modules/better-sqlite3
COPY --from=backend-build /app/node_modules/bindings ./node_modules/bindings
COPY --from=backend-build /app/node_modules/file-uri-to-path ./node_modules/file-uri-to-path
COPY --from=backend-build /app/node_modules/bcrypt ./node_modules/bcrypt
COPY --from=backend-build /app/node_modules/node-gyp-build ./node_modules/node-gyp-build

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://127.0.0.1:80/ && \
      wget --no-verbose --tries=1 --spider http://127.0.0.1:8001/api/core/heartbeat || exit 1

ENTRYPOINT ["/bin/sh", "-c" , "nginx & node --enable-source-maps /app/dist/main.js"]