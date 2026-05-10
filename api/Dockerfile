FROM node:20-slim

RUN npm install -g pnpm

WORKDIR /app

COPY package.json pnpm-lock.yaml ./

RUN pnpm install --frozen-lockfile

COPY . .

RUN pnpm build

EXPOSE 7860

CMD ["sh", "-c", "pnpm migrate:global && pnpm migrate:tenant && pnpm start"]
