FROM nginx:1.25.4-alpine3.18

COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 26257
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]