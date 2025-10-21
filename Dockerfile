ARG NODE_VERSION=20.13.1

FROM node:${NODE_VERSION}-slim

RUN apt-get update && apt-get install -y openssl iputils-ping net-tools python3 make g++ sqlite3 postgresql-client

WORKDIR /app

# DATABASE_URL environment variable takes precedence over .env file configuration
ENV DATABASE_URL=file:/app/sqlite/chatollama.sqlite

COPY pnpm-lock.yaml package.json ./
RUN npm install -g pnpm
RUN pnpm i

COPY . .

# 关键修改：添加此行以修复 Windows/CRLF 换行符问题
# 此命令在所有 .sh 脚本中查找并删除回车符 (\r)，解决 "Illegal option -" 错误。
RUN sed -i 's/\r//g' /app/scripts/*.sh

# Make scripts executable
RUN chmod +x /app/scripts/*.sh

RUN pnpm run prisma-generate

RUN pnpm run build

EXPOSE 3000

CMD ["sh", "/app/scripts/startup.sh"]
