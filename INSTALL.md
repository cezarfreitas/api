# Guia de Instalação Manual

## 🐳 Via Docker (Recomendado)

### Build e execução local:

```bash
# Limpar ambiente
rm -rf node_modules package-lock.json dist/

# Build da imagem
docker build -t minha-api:latest .

# Executar
docker run -d --name api-container -p 8080:8080 --restart=unless-stopped minha-api:latest

# Testar
curl http://localhost:8080/api/ping
```

### Variável de ambiente (opcional): VITE_API_URL

Defina a URL base da API para o frontend quando a API estiver em outro host/domínio.

```bash
# Exemplo em produção
export VITE_API_URL="https://api.seu-dominio.com"
# Em Docker, passe via --env ou arquivo .env
```

Frontend usará `${VITE_API_URL}/api/...` (se definido) ou caminho relativo `/api/...`.

### Deploy para registry + VPS:

```bash
# Build e push
docker build -t seu-usuario/minha-api:latest .
docker push seu-usuario/minha-api:latest

# No VPS
docker pull seu-usuario/minha-api:latest
docker run -d --name api-container -p 8080:8080 --restart=unless-stopped seu-usuario/minha-api:latest
```

## 🛠️ Instalação Nativa (Node.js)

### Pré-requisitos:

- **Node.js 20.19.0+** (obrigatório - Vite 7+ não funciona com Node 18)
- pnpm (recomendado) ou npm 10+

### Passos:

```bash
# 1. Limpar cache/dependências antigas
rm -rf node_modules package-lock.json dist/
npm cache clean --force

# 2. Instalar pnpm (se necessário)
npm install -g pnpm
# ou via corepack:
corepack enable && corepack prepare pnpm@latest --activate

# 3. Instalar dependências
pnpm install --frozen-lockfile

# 4. Build
pnpm build

# 5. Executar
NODE_ENV=production PORT=8080 node dist/server/node-build.mjs
```

## 🔧 Troubleshooting

### Erro "Unsupported engine" (Node 18.x):

```bash
# Atualizar para Node 20+ (recomendado: usar nvm)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install 20
nvm use 20
nvm alias default 20

# Verificar versão
node --version  # deve ser 20.19.0+
```

### Erro "Cannot find module '/code/dist/server/node-build.mjs'":

```bash
# Certificar que o build foi executado
pnpm build
ls -la dist/server/  # deve mostrar node-build.mjs
```

### Erro "pnpm: command not found":

```bash
npm install -g pnpm --force
# ou
corepack enable && corepack prepare pnpm@latest --activate
```

### Erro "Tracker idealTree already exists":

```bash
rm -rf node_modules package-lock.json /root/.npm/_locks
npm cache clean --force
```

### Conflitos binários (pnpx já existe):

```bash
rm -f /root/.nvm/versions/node/*/bin/pnpx
rm -f /root/.nvm/versions/node/*/bin/pnpm
npm install -g pnpm --force
```

## 🚀 Deploy com Script Automático

```bash
# Configurar variáveis
export IMAGE_NAME="seu-usuario/minha-api"
export REGISTRY_USER="seu-usuario"
export REGISTRY_PASSWORD="sua-senha"

# Deploy completo
./scripts/deploy.sh

# Deploy remoto (opcional)
export SSH_HOST="seu.vps.com"
export SSH_USER="root"
./scripts/deploy.sh
```

## 📋 Systemd Service (Linux)

Criar `/etc/systemd/system/minha-api.service`:

```ini
[Unit]
Description=Minha API Backend
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/caminho/para/projeto
Environment=NODE_ENV=production
Environment=PORT=8080
ExecStart=/usr/bin/node /caminho/para/projeto/dist/server/node-build.mjs
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now minha-api
sudo systemctl status minha-api
```
