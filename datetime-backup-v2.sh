#!/bin/bash

# ---------------------------------------------
# CONFIGURAÇÕES
# ---------------------------------------------

# Diretório de origem
ORIGEM="/home/andersoncastro/pulse-backup"

# Diretório de destino
DESTINO="/home/andersoncastro/MEGA/backups/pulse-backup/Linux"

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

ARQUIVO="home_son_${ANO}-${MES}-${DIA}_${HORA}-${MIN}.tar.zst"


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

ls -1tr home_son_*.tar.zst | head -n -3 | xargs -r rm --

echo "✔ Backup finalizado!"