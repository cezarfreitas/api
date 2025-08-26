# Guia de Deploy - Troubleshooting

## ❌ Erro: "vite: not found" (exit code 1)

### Problema: devDependencies não instaladas no build Docker

**Causa:** Dockerfile anterior usava `--prod` mas o Vite é devDependency necessária para build.

**✅ Solução:** Novo Dockerfile multi-stage:
- Stage 1: instala todas as deps + faz build
- Stage 2: apenas deps de produção + artifacts

```bash
# Build corrigido
docker build --no-cache --target production -t minha-api .
```

## ❌ Erro: "Command failed with exit code 7"

### Problema: Script não encontrado ou sem permissão

**Soluções:**

### 1️⃣ Usar path correto no Docker:

```bash
# ❌ Errado:
docker exec -i container bash -c 'chmod +x deploy.sh && exec /deploy.sh'

# ✅ Correto:
docker exec -i container bash -c 'chmod +x /app/deploy.sh && exec /app/deploy.sh'
# ou
docker exec -i container bash -c 'chmod +x /app/scripts/deploy.sh && exec /app/scripts/deploy.sh'
```

### 2️⃣ Executar fora do container:

```bash
# No host (fora do container)
chmod +x deploy.sh scripts/deploy.sh
IMAGE_NAME=meu-usuario/minha-api ./deploy.sh
```

### 3️⃣ Build e deploy manual:

```bash
# Build local
pnpm install && pnpm build

# Build Docker (multi-stage, corrigido para vite)
docker build --no-cache --target production -t meu-usuario/minha-api:latest .

# Push para registry
docker login
docker push meu-usuario/minha-api:latest

# Deploy no VPS
ssh usuario@vps.com "docker pull meu-usuario/minha-api:latest && docker stop api-container || true && docker rm api-container || true && docker run -d --name api-container -p 8080:8080 --restart=unless-stopped meu-usuario/minha-api:latest"
```

### 4️⃣ Deploy direto via Docker Compose:

```yaml
# docker-compose.yml
version: "3.8"
services:
  api:
    image: meu-usuario/minha-api:latest
    restart: unless-stopped
    ports:
      - "8080:8080"
    environment:
      - NODE_ENV=production
      - PORT=8080
```

```bash
docker compose up -d
```

## 🔧 Variables de ambiente necessárias

```bash
# Para deploy.sh
export IMAGE_NAME="meu-usuario/minha-api"
export TAG="latest"
export REGISTRY="docker.io"
export REGISTRY_USER="meu-usuario"
export REGISTRY_PASSWORD="minha-senha"

# Para deploy remoto (opcional)
export SSH_HOST="meu.vps.com"
export SSH_USER="root"
export SSH_PORT="22"
```

## 🚀 Comandos rápidos

### Deploy local:

```bash
# Build e teste local
docker build -t minha-api .
docker run -p 8080:8080 minha-api

# Teste
curl http://localhost:8080/api/ping
```

### Deploy para registry:

```bash
docker tag minha-api meu-usuario/minha-api:latest
docker push meu-usuario/minha-api:latest
```

### Deploy no VPS via SSH:

```bash
ssh usuario@vps.com << 'EOF'
docker pull meu-usuario/minha-api:latest
docker stop api-container 2>/dev/null || true
docker rm api-container 2>/dev/null || true
docker run -d \
  --name api-container \
  -p 8080:8080 \
  --restart=unless-stopped \
  meu-usuario/minha-api:latest
EOF
```
