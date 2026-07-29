#!/bin/bash

# ---------------------------------------------
# CONFIGURAÇÕES
# ---------------------------------------------

# Diretório de origem
ORIGEM="/home/andersoncastro/pulse-backup"

# Diretório de destino
DESTINO="/home/andersoncastro/MEGA/backups/pulse-backup/Linux"


# ---------------------------------------------
# DATA e NOME DO ARQUIVO
# ---------------------------------------------
ANO=$(date +%Y)
MES=$(date +%m)
DIA=$(date +%d)
HORA=$(date +%H)
MIN=$(date +%M)

ARQUIVO="pulse-backup_${ANO}-${MES}-${DIA}_${HORA}-${MIN}.tar.zst"


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

ls -1tr pulse-backup_*.tar.zst | head -n -2 | xargs -r rm --

echo "✔ Backup finalizado!"