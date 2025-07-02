FROM node:18-alpine AS build
 
# on se place dans un dossier de travail et on y copie tout le code de l'application
WORKDIR /app
COPY frontend/ .
 
# on package l'application
RUN npm install && \
    npm run build
 
FROM nginx:alpine
 
# port à exposer pour accéder à l'application
EXPOSE 80
 
# on récupère le résultat de notre conteneur de build
COPY --from=build /app/dist/ /usr/share/nginx/html
 
CMD ["nginx", "-g", "daemon off;"]
