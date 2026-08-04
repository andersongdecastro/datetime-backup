#!/bin/bash

# ---------------------------------------------
# CARREGAR ORIGEM/DESTINO DO ARQUIVO .env
# ---------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/datetime-backup-v1-0.env"

if [ ! -f "$ENV_FILE" ]; then
    echo "Erro: arquivo de configuração não encontrado: $ENV_FILE" >&2
    echo "Copie datetime-backup-v1-0.env.example para $(basename "$ENV_FILE") e ajuste ORIGEM e DESTINO." >&2
    exit 1
fi

source "$ENV_FILE"


# ---------------------------------------------
# CONFIGURAÇÕES
# ---------------------------------------------

# Arquivos/pastas NÃO ocultos que NÃO devem ser incluídos
EXCLUSOES=("go" "snap")

# Arquivos/pastas ocultos que DEVEM ser incluídos
INCLUIR_OCULTOS=(".ssh")


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
# CONSTRUÇÃO DA LISTA DE ITENS PARA BACKUP
# ---------------------------------------------

cd "$ORIGEM" || exit 1

# Pega todos os itens NÃO ocultos
ITENS=()
for item in *; do
    [ -e "$item" ] || continue

    # Se estiver na lista de exclusões, pula
    if printf '%s\n' "${EXCLUSOES[@]}" | grep -qx "$item"; then
        continue
    fi

    ITENS+=("$item")
done

# Adiciona itens ocultos especificados
for oculto in "${INCLUIR_OCULTOS[@]}"; do
    if [ -e "$oculto" ]; then
        ITENS+=("$oculto")
    fi
done


# ---------------------------------------------
# EXECUTANDO O BACKUP (TAR + ZSTD)
# ---------------------------------------------

echo "➡ Criando backup em: $DESTINO/$ARQUIVO"

# --zstd ativa compressão Zstandard
# -cf cria arquivo tar
tar --zstd -cf "$DESTINO/$ARQUIVO" "${ITENS[@]}"


# ---------------------------------------------
# MANTER APENAS OS ÚLTIMOS 3 BACKUPS
# ---------------------------------------------

cd "$DESTINO" || exit 1

ls -1tr "${PREFIXO}"_*.tar.zst | head -n -3 | xargs -r rm --

echo "✔ Backup finalizado!"