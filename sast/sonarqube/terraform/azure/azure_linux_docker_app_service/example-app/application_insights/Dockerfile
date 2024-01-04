FROM node:18-slim

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY index.js ./

EXPOSE 4000
CMD ["node", "index.js"]
