# Dockerfile para executar a API em produção (Node 20 + pnpm)
FROM node:20-alpine AS base

# Dependências do sistema para compilar pacotes nativos
RUN apk add --no-cache python3 build-base git

# Habilita corepack e pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

# Copiar package.json primeiro para usar cache de camada
COPY package.json pnpm-lock.yaml* ./

# Instalar dependências (apenas produção)
RUN pnpm install --frozen-lockfile --prod

# Copiar todo o código
COPY . .

# Build (se houver passos de build para client/server)
RUN pnpm build

ENV NODE_ENV=production
EXPOSE 8080
CMD ["node", "dist/server/node-build.mjs"]
