# -------------------------------
#       Build Frontend
# -------------------------------
FROM ghcr.io/cirruslabs/flutter:3.41.4 AS frontend-build
WORKDIR /app
COPY .git .git
COPY ./frontend ./
RUN flutter build web --release --no-tree-shake-icons --build-name=$(git describe --tags --always)

# -------------------------------
#       Build Backend
# -------------------------------
FROM node:lts-alpine AS backend-build
# Install git
RUN apk add git
WORKDIR /app
# Copy and install packages so they can cache
COPY ./backend/package.json ./package.json
RUN npm i --include=optional
# Copy all content
COPY .git .git
COPY ./backend .
RUN npm run build

# -------------------------------
#      Build Final Result
# -------------------------------
FROM alpine:3.23 AS prod
# Using port 80 like normal
EXPOSE 80

# Install some required packages
RUN apk add --no-cache nginx libstdc++ ca-certificates \
    && rm -rf /var/cache/apk/*

# Set some default env variables
ENV sprout_server_port=8001
ENV sprout_database_sqlite_database=/sprout/sprout.sqlite
ENV sprout_database_backup_directory=/sprout/backups/database

# Grab the files we need
COPY ./nginx.conf /etc/nginx/nginx.conf
# Frontend
COPY --from=frontend-build /app/build/web /usr/share/nginx/html
# Backend
COPY --from=backend-build --chmod=0755 /app/sprout /sprout-backend

# Confirm that we maintain a healthy status
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://127.0.0.1:80/ && \
      wget --no-verbose --tries=1 --spider http://127.0.0.1:8001/api/core/heartbeat || exit 1

# Start nginx along side backend. Frontend is hosted via nginx, backend runs it's own internal API
ENTRYPOINT ["/bin/sh", "-c" , "nginx & ./sprout-backend"]