# -------------------------------
#       Build Frontend
# -------------------------------
FROM ghcr.io/cirruslabs/flutter:3.32.5 as frontend-build
WORKDIR /app
COPY .git .git
COPY ./frontend ./
RUN flutter build web --release --no-tree-shake-icons --build-name=$(git describe --tags --always)

# -------------------------------
#       Build Backend
# -------------------------------
FROM node:lts-alpine3.19 as backend-build
# Install git
RUN apk add git
WORKDIR /app
# Copy and install packages so they can cache
COPY ./backend/package.json ./package.json
RUN npm i
# Copy all content
COPY .git .git
COPY ./backend .
RUN npm run build

# -------------------------------
#      Build Final Result
# -------------------------------
FROM nginx:alpine as prod
# Using port 80 like normal
EXPOSE 80

# Set some default env variables
ENV sprout_server_port=8001
ENV sprout_server_apiBasePath=/api
ENV sprout_database_sqlite_database=/sprout/sprout.sqlite

# Grab the files we need
COPY ./nginx.conf /etc/nginx/nginx.conf
# Frontend
COPY --from=frontend-build /app/build/web /usr/share/nginx/html
# Backend
COPY --from=backend-build --chmod=0755 /app/sprout /sprout-backend
# Grab required bcrypt file
COPY --from=backend-build /app/node_modules/bcrypt/lib/binding/napi-v3/bcrypt_lib.node .

# Install some required packages
RUN apk update && apk add libstdc++

# Start nginx along side backend. Frontend is hosted via nginx, backend runs it's own internal API
ENTRYPOINT ["/bin/sh", "-c" , "nginx & ./sprout-backend"]