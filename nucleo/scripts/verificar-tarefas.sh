#!/bin/sh
# Confere a forma das tarefas contra os criterios da spec, antes do k-execute.
#
# Script confere FORMA, agente confere SENTIDO. Exit 0 aqui significa que todo
# criterio tem pelo menos uma tarefa que diz cobri-lo - nao que a tarefa
# realmente o implemente. Quem julga isso e o verificador do encerramento.
#
#   sh verificar-tarefas.sh <pasta-da-spec>
#
# Exit: 0 forma valida, 1 achado, 2 erro de uso ou ambiente.

set -eu

DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$DIR/comum.sh"

PASTA="${1:-}"
[ -n "$PASTA" ] || aborta "uso: sh verificar-tarefas.sh <pasta-da-spec>"
[ -d "$PASTA" ] || aborta "pasta nao encontrada: $PASTA"

SPEC="$PASTA/spec.md"
[ -f "$SPEC" ] || aborta "spec.md nao encontrado em $PASTA"
[ -d "$PASTA/tasks" ] || aborta "pasta tasks/ nao encontrada em $PASTA. Rode /k-plan antes."

TMP=$(mktemp -d 2>/dev/null || mktemp -d -t iakit)
trap 'rm -rf "$TMP"' EXIT INT TERM
mkdir -p "$TMP/t"
SPEC=$(sem_cr "$SPEC" "$TMP")

# --- criterios declarados na spec -------------------------------------------
grep -o '^- \[[ xX]\] CA-[0-9][0-9]*' "$SPEC" \
  | sed 's/^.*\(CA-[0-9][0-9]*\)$/\1/' \
  | sort -u > "$TMP/criterios" || true

if [ ! -s "$TMP/criterios" ]; then
  aborta "nenhum criterio CA-<n> em $SPEC. Rode verificar-spec.sh primeiro."
fi

# --- tarefas -----------------------------------------------------------------
TAREFAS=0
: > "$TMP/cobertos"

for T in "$PASTA"/tasks/*.md; do
  [ -f "$T" ] || continue
  TAREFAS=$((TAREFAS + 1))
  NOME=$(basename "$T")
  T=$(sem_cr "$T" "$TMP/t")

  if ! frontmatter "$T" >/dev/null 2>&1; then
    falha "$NOME: sem frontmatter delimitado por ---"
    continue
  fi

  # arquivos: precisa existir e ter pelo menos um item de lista.
  ITENS=$(frontmatter "$T" | awk '
    /^arquivos:/ { dentro = 1; next }
    dentro && /^[a-z_][a-z_]*:/ { dentro = 0 }
    dentro && /^[[:space:]]*- / { n++ }
    END { print n + 0 }
  ')
  [ "$ITENS" -gt 0 ] || falha "$NOME: campo arquivos vazio. E essa lista que limita o executor."

  STATUS=$(campo_frontmatter "$T" status)
  case "$STATUS" in
    pendente|em-andamento|concluida|bloqueada) ;;
    "") falha "$NOME: sem status" ;;
    *)  falha "$NOME: status invalido '$STATUS'" ;;
  esac

  # criterios: lista inline [CA-1, CA-2]. Ausente e diferente de vazia.
  LINHA=$(frontmatter "$T" | grep '^criterios:' || true)
  if [ -z "$LINHA" ]; then
    falha "$NOME: sem campo criterios. Use [] explicito em tarefa sem comportamento novo."
    continue
  fi

  CITADOS=$(printf '%s\n' "$LINHA" \
    | sed 's/^criterios:[[:space:]]*//; s/^\[//; s/\]$//; s/,/ /g')

  for C in $CITADOS; do
    case "$C" in
      CA-[0-9]*) ;;
      *) falha "$NOME: criterio malformado '$C' (esperado CA-<n>)"; continue ;;
    esac
    if grep -qxF "$C" "$TMP/criterios"; then
      printf '%s\n' "$C" >> "$TMP/cobertos"
    else
      falha "$NOME: cita $C, que nao existe na spec"
    fi
  done
done

[ "$TAREFAS" -gt 0 ] || aborta "nenhuma tarefa em $PASTA/tasks/"

# --- criterio descoberto -----------------------------------------------------
sort -u "$TMP/cobertos" > "$TMP/cobertos-u" 2>/dev/null || : > "$TMP/cobertos-u"
DESCOBERTOS=$(comm -23 "$TMP/criterios" "$TMP/cobertos-u")
if [ -n "$DESCOBERTOS" ]; then
  for D in $DESCOBERTOS; do
    falha "criterio sem tarefa que o cubra: $D"
  done
fi

TOTAL=$(wc -l < "$TMP/criterios" | tr -d ' ')
COBERTOS=$(wc -l < "$TMP/cobertos-u" | tr -d ' ')
fechar "$TAREFAS tarefa(s), $COBERTOS de $TOTAL criterio(s) cobertos"
