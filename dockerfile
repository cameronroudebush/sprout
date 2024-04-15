FROM node:lts-alpine3.19 as base
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

# FROM nginx:alpine
# EXPOSE 8000
# COPY nginx.conf /etc/nginx/nginx.conf
# COPY --from=builder /build/build /app