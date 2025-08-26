#!/usr/bin/env bash
set -euo pipefail

# Script de deploy corrigido com melhor tratamento de erros
IMAGE_NAME="${1-"${IMAGE_NAME-}"}"
TAG="${TAG:-latest}"
REGISTRY="${REGISTRY:-docker.io}"

if [[ -z "$IMAGE_NAME" ]]; then
  echo "Erro: IMAGE_NAME não definido. Ex: meu-usuario/minha-api"
  echo "Uso: IMAGE_NAME=meu-usuario/minha-api $0"
  exit 1
fi

FULL_IMAGE="${REGISTRY}/${IMAGE_NAME}:${TAG}"
echo "🔧 Imagem alvo: $FULL_IMAGE"

# Limpar cache e builds anteriores
echo "🧹 Limpando cache..."
rm -rf node_modules package-lock.json dist/ || true
npm cache clean --force || true

# Instalar dependências com pnpm
echo "📦 Instalando dependências..."
if ! command -v pnpm &> /dev/null; then
  npm install -g pnpm
fi
pnpm install --frozen-lockfile

# Build local
echo "����️ Build da aplicação..."
pnpm build

# Build Docker com cache busting
echo "🐳 Construindo imagem Docker..."
docker build --no-cache -t "$FULL_IMAGE" .

# Login e push (se credenciais fornecidas)
if [[ -n "${REGISTRY_USER-}" && -n "${REGISTRY_PASSWORD-}" ]]; then
  echo "🔑 Login no registry..."
  echo "$REGISTRY_PASSWORD" | docker login --username "$REGISTRY_USER" --password-stdin "$REGISTRY"
  
  echo "📤 Enviando para registry..."
  docker push "$FULL_IMAGE"
fi

# Deploy remoto via SSH (opcional)
if [[ -n "${SSH_HOST-}" && -n "${SSH_USER-}" ]]; then
  SSH_PORT="${SSH_PORT:-22}"
  CONTAINER_NAME="${CONTAINER_NAME:-api-container}"
  REMOTE_PORT="${REMOTE_PORT:-8080}"
  
  echo "🚀 Deploy remoto para $SSH_USER@$SSH_HOST..."
  SSH_CMD="docker pull $FULL_IMAGE && docker stop $CONTAINER_NAME 2>/dev/null || true && docker rm $CONTAINER_NAME 2>/dev/null || true && docker run -d --name $CONTAINER_NAME -p $REMOTE_PORT:8080 --restart=unless-stopped $FULL_IMAGE"
  ssh -p "$SSH_PORT" "$SSH_USER@$SSH_HOST" "$SSH_CMD"
  echo "✅ Deploy concluído!"
else
  echo "ℹ️  Para deploy remoto, configure SSH_HOST e SSH_USER"
fi

echo "✅ Processo finalizado com sucesso!"
