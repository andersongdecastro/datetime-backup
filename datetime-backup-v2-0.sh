#!/bin/bash

# ---------------------------------------------
# CARREGAR ORIGEM/DESTINO DO ARQUIVO .env
# ---------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/datetime-backup-v2-0.env"

if [ ! -f "$ENV_FILE" ]; then
    echo "Erro: arquivo de configuração não encontrado: $ENV_FILE" >&2
    echo "Copie datetime-backup-v2-0.env.example para $(basename "$ENV_FILE") e ajuste ORIGEM e DESTINO." >&2
    exit 1
fi

source "$ENV_FILE"


# ---------------------------------------------
# DATA e NOME DO ARQUIVO
# ---------------------------------------------
ANO=$(date +%Y)
MES=$(date +%m)
DIA=$(date +%d)
HORA=$(date +%H)
MIN=$(date +%M)

ARQUIVO="${PREFIXO}_${ANO}-${MES}-${DIA}_${HORA}-${MIN}.tar.zst"


# ---------------------------------------------
# EXECUTANDO O BACKUP (TAR + ZSTD)
# ---------------------------------------------

echo "➡ Criando backup em: $DESTINO/$ARQUIVO"

# --zstd ativa compressão Zstandard
# -cf cria arquivo tar
# -C muda para ORIGEM antes de compactar; "." inclui tudo (arquivos, pastas,
# ocultos e subdiretórios), sem exclusões
tar --zstd -cf "$DESTINO/$ARQUIVO" -C "$ORIGEM" .


# ---------------------------------------------
# MANTER APENAS OS ÚLTIMOS 2 BACKUPS
# ---------------------------------------------

cd "$DESTINO" || exit 1

ls -1tr "${PREFIXO}"_*.tar.zst | head -n -2 | xargs -r rm --

echo "✔ Backup finalizado!"