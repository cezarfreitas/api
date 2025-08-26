#!/usr/bin/env bash
set -euo pipefail

# Deployment helper script
# Usage: fill environment variables or run interactively.
# Required: IMAGE_NAME (e.g. meu-usuario/minha-api) or set via first argument
# Optional: TAG (default: latest), REGISTRY (default: docker.io)
# Optional SSH deployment: set SSH_HOST and SSH_USER to deploy remotely (pull & run)

IMAGE_NAME="${1-"${IMAGE_NAME-}"}"
TAG="${TAG:-latest}"
REGISTRY="${REGISTRY:-docker.io}"
REGISTRY_USER="${REGISTRY_USER-}"
REGISTRY_PASSWORD="${REGISTRY_PASSWORD-}"

SSH_HOST="${SSH_HOST-}"
SSH_USER="${SSH_USER-}", SSH_PORT="${SSH_PORT:-22}"
REMOTE_CONTAINER_NAME="${REMOTE_CONTAINER_NAME:-api-container}"
REMOTE_PORT="${REMOTE_PORT:-8080}"

if [[ -z "$IMAGE_NAME" ]]; then
  echo "Erro: IMAGE_NAME não definido. Ex: meu-usuario/minha-api"
  echo "Uso: IMAGE_NAME=meu-usuario/minha-api $0"
  exit 1
fi

FULL_IMAGE="${REGISTRY}/${IMAGE_NAME}:${TAG}"

echo "Imagem alvo: $FULL_IMAGE"

# Build
echo "-> Rodando build local (pnpm build)"
pnpm install --frozen-lockfile || true
pnpm build

# Docker build
echo "-> Construindo imagem docker"
docker build -t "$FULL_IMAGE" .

# Login no registry (se credenciais fornecidas)
if [[ -n "$REGISTRY_USER" && -n "$REGISTRY_PASSWORD" ]]; then
  echo "-> Logando em $REGISTRY"
  echo "$REGISTRY_PASSWORD" | docker login --username "$REGISTRY_USER" --password-stdin "$REGISTRY"
fi

# Push
echo "-> Enviando imagem para o registry"
docker push "$FULL_IMAGE"

# Optional: deploy via SSH to a remote host
if [[ -n "$SSH_HOST" && -n "$SSH_USER" ]]; then
  echo "-> Implantando em $SSH_USER@$SSH_HOST"
  SSH_CMD="docker pull $FULL_IMAGE && docker stop $REMOTE_CONTAINER_NAME 2>/dev/null || true && docker rm $REMOTE_CONTAINER_NAME 2>/dev/null || true && docker run -d --name $REMOTE_CONTAINER_NAME -p $REMOTE_PORT:8080 --restart=unless-stopped $FULL_IMAGE"
  ssh -p "$SSH_PORT" "$SSH_USER@$SSH_HOST" "$SSH_CMD"
  echo "-> Deploy remoto concluído"
else
  echo "Nota: SSH_HOST/SSH_USER não definidos — apenas build + push realizados."
fi

echo "Pronto."
