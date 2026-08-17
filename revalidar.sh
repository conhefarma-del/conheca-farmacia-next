#!/usr/bin/env bash
# =============================================================================
# revalidar.sh — Invalida a cache ISR do Next.js depois de alterações diretas
# na base de dados (ex.: migrações aplicadas no SQL editor do Supabase).
#
# Uso:
#   ./revalidar.sh                 # revalida o tag "interacoes"
#   ./revalidar.sh quiz            # revalida outro tag da whitelist (articles, events,
#                                  #   flashcards, guides, interviews, protocolos, quiz, scientific)
#   ./revalidar.sh --path /pt/medicamentos   # revalida um path específico
#
# Requer:
#   - REVALIDATE_SECRET no .env.local (ou exportado no ambiente)
#   - curl
# =============================================================================
set -euo pipefail

cd "$(dirname "$0")"

# Carrega .env.local se existir (sem sobrescrever variáveis já definidas)
if [[ -f .env.local ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env.local
  set +a
fi

SECRET="${REVALIDATE_SECRET:-}"
if [[ -z "$SECRET" ]]; then
  echo "ERRO: REVALIDATE_SECRET não encontrado no .env.local nem no ambiente." >&2
  exit 1
fi

TAG="interacoes"
PATH_ARG=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --path)
      PATH_ARG="${2:-}"
      if [[ -z "$PATH_ARG" ]]; then
        echo "ERRO: --path requer um valor (ex.: /pt/medicamentos)." >&2
        exit 1
      fi
      shift 2
      ;;
    -h|--help)
      sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      TAG="$1"
      shift
      ;;
  esac
done

URL="https://www.conhecafarmacia.com/api/revalidate?secret=${SECRET}&tag=${TAG}"
if [[ -n "$PATH_ARG" ]]; then
  URL="${URL}&path=${PATH_ARG}"
fi

echo "→ Revalidando tag '${TAG}'${PATH_ARG:+ + path '${PATH_ARG}'} em ${URL%%\?*} ..."

RESP="$(curl -sS -m 25 -w '\n%{http_code}' "$URL")"
BODY="$(echo "$RESP" | head -n -1)"
HTTP="$(echo "$RESP" | tail -n 1)"

echo "HTTP ${HTTP}"
echo "${BODY}"

if [[ "$HTTP" == "200" ]]; then
  echo "✅ Cache revalidada com sucesso."
else
  echo "⚠️  Falha na revalidação (HTTP ${HTTP})." >&2
  exit 1
fi
