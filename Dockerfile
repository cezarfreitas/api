# Multi-stage Dockerfile otimizado - Node 20 LTS
FROM node:20-alpine AS builder

# Dependências do sistema para build
RUN apk add --no-cache python3 build-base git

# Habilitar pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

# Copiar package.json e lock files
COPY package.json pnpm-lock.yaml* ./

# Instalar TODAS as dependências (incluindo devDependencies para build)
ENV npm_config_ignore_scripts=false
RUN pnpm install --frozen-lockfile --ignore-scripts=false

# Copiar código fonte
COPY . .

# Build da aplicação
RUN pnpm build

# Verificar se build foi gerado
RUN ls -la dist/server/node-build.mjs || (echo "❌ Build falhou" && exit 1)

# Estágio de produção (imagem final menor)
FROM node:20-alpine AS production

# Dependências mínimas para runtime
RUN apk add --no-cache dumb-init

# Criar usuário não-root
RUN addgroup -g 1001 -S nodejs && adduser -S nextjs -u 1001

# Habilitar pnpm (só para instalar deps de produção)
RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

# Copiar apenas package.json para instalar deps de produção
COPY package.json pnpm-lock.yaml* ./

# Instalar apenas dependências de produção
RUN pnpm install --frozen-lockfile --prod

# Copiar build artifacts do estágio anterior
COPY --from=builder /app/dist ./dist

# Mudar ownership para usuário não-root
RUN chown -R nextjs:nodejs /app
USER nextjs

# Configurar ambiente
ENV NODE_ENV=production
ENV PORT=8080
EXPOSE 8080

# Usar dumb-init para handling de sinais
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/server/node-build.mjs"]
