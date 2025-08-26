# Dockerfile corrigido para evitar conflitos npm/pnpm
FROM node:20-alpine AS base

# Dependências do sistema
RUN apk add --no-cache python3 build-base git

# Limpar npm cache e habilitar pnpm
RUN npm cache clean --force && \
    corepack enable && \
    corepack prepare pnpm@latest --activate

WORKDIR /app

# Copiar package.json primeiro para cache de camadas
COPY package.json pnpm-lock.yaml* ./

# Limpar qualquer cache/lock existente e instalar dependências
RUN rm -rf node_modules package-lock.json && \
    pnpm install --frozen-lockfile

# Copiar código fonte
COPY . .

# Build da aplicação
RUN pnpm build

# Configurar ambiente de produção
ENV NODE_ENV=production
ENV PORT=8080
EXPOSE 8080

# Comando de execução
CMD ["node", "dist/server/node-build.mjs"]
