FROM node:18-alpine AS builder
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN apk update
RUN apk add --no-cache python3
COPY . /app
WORKDIR /app
RUN npm config set registry https://registry.npmmirror.com
RUN npm install -g pnpm
RUN pnpm install
RUN pnpm run build-web
RUN pnpm run build-api
RUN pnpm run build-doc

FROM node:18-alpine
COPY --from=builder /app/roadbook-api /app
COPY --from=builder /app/packages/roadbook-vue/dist /app/views
COPY --from=builder /app/packages/docs/dist /app/views/docs
WORKDIR /app
ENV NODE_ENV=production
RUN mkdir -p /app/storage/public/uploads
RUN mkdir -p /app/storage/logs/
RUN chmod +x /app/script/start.sh
RUN chmod +x /app/script/gen.sh
RUN sh script/gen.sh
EXPOSE 3000
ENTRYPOINT [ "sh", "/app/script/start.sh" ]
