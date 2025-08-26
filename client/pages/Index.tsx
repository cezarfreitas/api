import { DemoResponse } from "@shared/api";
import { useState } from "react";

export default function Index() {
  const [status, setStatus] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const checkStatus = async () => {
    setLoading(true);
    try {
      const apiBase = (import.meta as any).env?.VITE_API_URL ?? "";
      const res = await fetch(`${apiBase}/api/ping`, { cache: "no-store" });
      const json = await res.json();
      setStatus(json?.message ?? "OK");
    } catch (e) {
      setStatus("Servidor indisponível");
    } finally {
      setLoading(false);
    }
  };

  const dockerfile = `# Multi-stage Dockerfile otimizado
FROM node:20-alpine AS builder
RUN apk add --no-cache python3 build-base git
RUN corepack enable && corepack prepare pnpm@latest --activate
WORKDIR /app
COPY package.json pnpm-lock.yaml* ./
RUN pnpm install --frozen-lockfile
COPY . .
RUN pnpm build

FROM node:20-alpine AS production
RUN apk add --no-cache dumb-init
RUN addgroup -g 1001 -S nodejs && adduser -S nextjs -u 1001
RUN corepack enable && corepack prepare pnpm@latest --activate
WORKDIR /app
COPY package.json pnpm-lock.yaml* ./
RUN pnpm install --frozen-lockfile --prod
COPY --from=builder /app/dist ./dist
RUN chown -R nextjs:nodejs /app
USER nextjs
ENV NODE_ENV=production
ENV PORT=8080
EXPOSE 8080
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/server/node-build.mjs"]
`;

  return (
    <main className="min-h-screen bg-gradient-to-br from-slate-50 to-sky-50 font-sans text-slate-900">
      <section className="max-w-6xl mx-auto p-8">
        <header className="flex items-center justify-between gap-6">
          <div className="flex items-center gap-4">
            <div className="w-12 h-12 rounded-lg bg-gradient-to-br from-sky-600 to-indigo-600 shadow-lg flex items-center justify-center text-white font-bold">
              BE
            </div>
            <div>
              <h1 className="text-3xl font-extrabold">
                Backend API Docker-ready
              </h1>
              <p className="text-sm text-slate-600">
                API simples pronta para rodar em Docker e ser implantada em um
                VPS com EasyPanel
              </p>
            </div>
          </div>
        </header>

        <div className="mt-8 grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="md:col-span-2 bg-white border rounded-lg p-6 shadow-sm">
            <h2 className="text-lg font-semibold">Visão geral</h2>
            <p className="mt-2 text-slate-700">
              Este projeto contém uma API Express pequena com duas rotas de
              exemplo:
            </p>
            <ul className="mt-3 list-disc list-inside text-slate-700">
              <li>/api/ping — verifica se o serviço está respondendo</li>
              <li>/api/demo — retorna uma mensagem de demonstração</li>
            </ul>

            <h3 className="mt-6 font-semibold">Testar localmente</h3>
            <p className="mt-2 text-slate-700">
              Na sua máquina de desenvolvimento execute:
            </p>
            <pre className="mt-3 bg-slate-100 p-3 rounded text-sm overflow-x-auto">
              pnpm install pnpm dev
            </pre>

            <h3 className="mt-6 font-semibold">Exemplos de uso</h3>
            <div className="mt-2 grid grid-cols-1 gap-2">
              <pre className="bg-slate-100 p-3 rounded text-sm overflow-x-auto">
                curl -sS http://localhost:5173/api/ping curl -sS
                http://localhost:5173/api/demo
              </pre>
              <p className="text-xs text-slate-500">
                Nota: porta do dev server pode variar. Em produção o container
                expõe 8080.
              </p>
            </div>

            <h3 className="mt-6 font-semibold">
              Como implantar no VPS com EasyPanel
            </h3>
            <ol className="mt-2 list-decimal list-inside text-slate-700">
              <li>
                Crie uma imagem Docker localmente:{" "}
                <code className="bg-slate-100 px-1 rounded">
                  docker build -t meu-usuario/minha-api:latest .
                </code>
              </li>
              <li>
                Faça push para um registry (Docker Hub, GitHub Container
                Registry, etc):{" "}
                <code className="bg-slate-100 px-1 rounded">
                  docker push meu-usuario/minha-api:latest
                </code>
              </li>
              <li>
                No EasyPanel crie um novo serviço apontando para a imagem do
                registry, ou carregue o Dockerfile diretamente se a interface
                permitir.
              </li>
              <li>
                Configure variáveis de ambiente (ex: PORT) e defina a porta para
                8080.
              </li>
            </ol>

            <h3 className="mt-6 font-semibold">Observações</h3>
            <p className="text-slate-700">
              Se preferir, você pode configurar EasyPanel para construir a
              partir do Dockerfile presente neste repositório; caso contrário,
              construa e publique a imagem em um registry e aponte o EasyPanel
              para ela.
            </p>

            <div className="mt-6 flex items-center gap-3">
              <button
                onClick={checkStatus}
                className="inline-flex items-center gap-2 bg-sky-600 hover:bg-sky-700 text-white px-4 py-2 rounded"
              >
                {loading ? "Verificando..." : "Verificar /api/ping"}
              </button>
              <div className="text-sm text-slate-700">
                Status: <span className="font-medium">{status ?? "—"}</span>
              </div>
            </div>

            <div className="mt-4 p-3 bg-green-50 border border-green-200 rounded text-sm">
              ✅ <strong>Erro "vite: not found" CORRIGIDO!</strong> Dockerfile
              multi-stage agora instala devDependencies para build e otimiza
              imagem final.
            </div>

            <div className="mt-2 p-3 bg-blue-50 border border-blue-200 rounded text-sm">
              📋 <strong>Node.js 20.19.0+ obrigatório</strong> - Veja{" "}
              <code>DEPLOY.md</code> para comandos corretos de build/deploy.
            </div>
          </div>

          <aside className="bg-white border rounded-lg p-6 shadow-sm">
            <h3 className="font-semibold">Dockerfile</h3>
            <p className="mt-2 text-slate-600 text-sm">
              Copie e use o Dockerfile abaixo para empacotar a API em uma imagem
              pronta para EasyPanel.
            </p>
            <pre className="mt-3 bg-slate-100 p-3 rounded text-sm overflow-x-auto whitespace-pre-wrap">
              {dockerfile}
            </pre>

            <h4 className="mt-4 font-semibold">Comandos úteis</h4>
            <ul className="mt-2 list-disc list-inside text-slate-700 text-sm">
              <li>
                Construir:{" "}
                <code className="bg-slate-100 px-1 rounded">
                  docker build -t minha-api .
                </code>
              </li>
              <li>
                Executar local:{" "}
                <code className="bg-slate-100 px-1 rounded">
                  docker run -p 8080:8080 minha-api
                </code>
              </li>
            </ul>

            <div className="mt-6">
              <h4 className="font-semibold">Suporte</h4>
              <p className="text-slate-700 text-sm">
                Se quiser, posso gerar um Docker Compose, um serviço systemd, ou
                instruções passo-a-passo para EasyPanel.
              </p>
            </div>
          </aside>
        </div>

        <footer className="mt-12 text-center text-sm text-slate-500">
          Feito para VPS com EasyPanel • API minimalista pronta para Docker
        </footer>
      </section>
    </main>
  );
}
