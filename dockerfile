FROM node:lts-alpine3.19 as base

# Install git
RUN apk add git

WORKDIR /app
# Copy and install packages so they can cache
COPY ./package.json ./package.json
COPY ./frontend/package.json ./frontend/package.json
COPY ./backend/package.json ./backend/package.json
COPY ./common/package.json ./common/package.json
RUN npm run install:all

# Copy all content
COPY . .

FROM base as frontend-base
RUN npm run build --prefix ./frontend

FROM base as backend-base
RUN npm run build --prefix ./backend

FROM nginx:alpine as prod
# Using port 80 like normal
EXPOSE 80

# Set some default env variables
ENV sprout_server_port=8001
ENV sprout_server_apiBasePath=/api

# Grab the files we need
COPY ./frontend/nginx.conf /etc/nginx/nginx.conf
# Frontend
COPY --from=frontend-base /app/frontend/www /usr/share/nginx/html
# Backend
COPY --from=backend-base --chmod=0755 /app/backend/sprout /sprout
# Grab required bcrypt file
COPY --from=backend-base /app/backend/node_modules/bcrypt/lib/binding/napi-v3/bcrypt_lib.node .

# Install some required packages
RUN apk update && apk add libstdc++

# Start nginx along side backend. Frontend is hosted via nginx, backend runs it's own internal API
ENTRYPOINT ["/bin/sh", "-c" , "nginx & ./sprout"]