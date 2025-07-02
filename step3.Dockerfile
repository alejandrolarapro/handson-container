# Version ultra-minimaliste avec image distroless
FROM node:18-alpine AS builder

WORKDIR /app
COPY frontend/package*.json ./
RUN npm ci --omit=dev && npm cache clean --force
COPY frontend/ .
RUN npm run build

# Stage intermédiaire pour obtenir un serveur HTTP statique minimal
FROM alpine:latest AS server-builder
RUN apk add --no-cache go git
RUN go install github.com/static-web-server/static-web-server@latest

# Image finale ultra-minimale avec distroless
FROM gcr.io/distroless/static-debian11

# Copier le serveur HTTP statique
COPY --from=server-builder /root/go/bin/static-web-server /server

# Copier les fichiers buildés
COPY --from=builder /app/dist /www

# Exposer le port
EXPOSE 8080

# Lancer le serveur
ENTRYPOINT ["/server"]
CMD ["--port", "8080", "--root", "/www", "--page404", "/www/index.html"]
