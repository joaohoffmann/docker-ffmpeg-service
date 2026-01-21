FROM ubuntu:22.04

LABEL description="Docker image for media conversion using FFmpeg and Node.js"

#####################################################################
#
# A Docker image to convert audio and video for web using web API
#
#   with
#     - FFmpeg (installed from Ubuntu repositories)
#     - NodeJS 16.x
#     - fluent-ffmpeg
#
#####################################################################

# Evitar prompts interativos durante a instalação
ENV DEBIAN_FRONTEND=noninteractive

# Instalar FFmpeg e dependências do sistema
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    # FFmpeg e codecs de áudio/vídeo
    ffmpeg \
    # Dependências para compilação e ferramentas úteis
    curl \
    ca-certificates \
    gnupg \
    git \
    # Ferramentas de build para pacotes npm nativos
    build-essential \
    python3 \
    # Limpeza será feita no final
    && rm -rf /var/lib/apt/lists/*

# Instalar Node.js 16.x via NodeSource (mais compatível com dependências antigas)
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Criar diretório de trabalho da aplicação
WORKDIR /usr/src/app

# Criar diretório para uploads temporários
RUN mkdir -p /usr/src/app/uploads

# Copiar package.json e instalar dependências
# (Fazemos isso antes de copiar o código para aproveitar cache do Docker)
COPY package.json /usr/src/app/
RUN npm install --production --legacy-peer-deps && \
    npm cache clean --force

# Instalar fluent-ffmpeg globalmente
RUN npm install -g fluent-ffmpeg

# Copiar o restante dos arquivos da aplicação
COPY . /usr/src/app

# Criar usuário não-root para segurança
RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /usr/src/app && \
    chown -R appuser:appuser /usr/src/app/uploads

# Mudar para usuário não-root
USER appuser

# Expor a porta da aplicação
EXPOSE 3000

# Healthcheck usando node (mais confiável que curl)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})" || exit 1

# Comando para iniciar a aplicação
CMD ["node", "app.js"]
