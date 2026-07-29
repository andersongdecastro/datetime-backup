#!/usr/bin/env bash
set -euo pipefail

DIR_BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORIGEM="${DIR_BASE}/teste1"
DESTINO="${DIR_BASE}/$(date +%Y%m%d)"

if [ ! -d "$ORIGEM" ]; then
    echo "Erro: pasta de origem '$ORIGEM' não existe." >&2
    exit 1
fi

mkdir -p "$DESTINO"

rsync -aHAX "$ORIGEM"/ "$DESTINO"/

echo "Sincronização concluída: '$ORIGEM' -> '$DESTINO'"

# Mantém apenas as duas pastas mais recentes no padrão yyyyMMdd (8 dígitos),
# ordenando pelo nome (decrescente) e removendo as demais.
mapfile -t PASTAS < <(find "$DIR_BASE" -maxdepth 1 -mindepth 1 -type d -name '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' -printf '%f\n' | sort -r)

TOTAL=${#PASTAS[@]}
if [ "$TOTAL" -gt 2 ]; then
    for ((i = 2; i < TOTAL; i++)); do
        PASTA_ANTIGA="${DIR_BASE}/${PASTAS[$i]}"
        echo "Removendo pasta antiga: '$PASTA_ANTIGA'"
        rm -rf "$PASTA_ANTIGA"
    done
fi

echo "Concluído."
