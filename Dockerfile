FROM node:8.16.0-stretch-slim

# monaco-languageclient
WORKDIR /app
COPY example/package.json package.json
COPY example/tsconfig.json tsconfig.json
COPY example/webpack.config.js webpack.config.js
COPY example/src src
RUN npm install && npm run build

#RUN npm run start:ext

