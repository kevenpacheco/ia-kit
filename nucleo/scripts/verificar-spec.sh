#!/bin/sh
# Confere a forma do spec.md antes do k-plan.
#
# Script confere FORMA, agente confere SENTIDO. Exit 0 aqui significa que a spec
# tem frontmatter legivel, tipo e fluxo validos, e criterios enderecaveis - nao
# que os criterios descrevam o comportamento certo. Isso e julgamento humano,
# feito na entrevista do k-spec.
#
#   sh verificar-spec.sh <pasta-da-spec>
#
# Exit: 0 forma valida, 1 achado, 2 erro de uso ou ambiente.

set -eu

DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$DIR/comum.sh"

PASTA="${1:-}"
[ -n "$PASTA" ] || aborta "uso: sh verificar-spec.sh <pasta-da-spec>"
[ -d "$PASTA" ] || aborta "pasta nao encontrada: $PASTA"

SPEC="$PASTA/spec.md"
[ -f "$SPEC" ] || aborta "spec.md nao encontrado em $PASTA"

TMP=$(mktemp -d 2>/dev/null || mktemp -d -t iakit)
trap 'rm -rf "$TMP"' EXIT INT TERM
SPEC=$(sem_cr "$SPEC" "$TMP")

TIPOS="feature bug refactor chore docs"
FLUXOS="pendente ativo concluido descartado"

# --- frontmatter -------------------------------------------------------------
if ! frontmatter "$SPEC" >/dev/null 2>&1; then
  aborta "$SPEC nao comeca com frontmatter delimitado por ---"
fi

TITULO=$(campo_frontmatter "$SPEC" titulo)
TIPO=$(campo_frontmatter "$SPEC" tipo)
FLUXO=$(campo_frontmatter "$SPEC" fluxo)

[ -n "$TITULO" ] || falha "frontmatter sem titulo"

# --- fluxo -------------------------------------------------------------------
if [ -z "$FLUXO" ]; then
  falha "frontmatter sem fluxo (esperado: $FLUXOS)"
else
  ENCONTRADO=nao
  for F in $FLUXOS; do [ "$F" = "$FLUXO" ] && ENCONTRADO=sim; done
  [ "$ENCONTRADO" = sim ] || falha "fluxo invalido: '$FLUXO' (esperado: $FLUXOS)"
fi

# --- stub para aqui ----------------------------------------------------------
# fluxo: pendente e stub do modo desvio: tipo vazio de proposito, corpo com
# ## Achado em vez de criterios. Cobrar criterio aqui mandaria o k-spec
# elaborar o stub - que e exatamente o proximo passo, nao um defeito.
if [ "$FLUXO" = "pendente" ]; then
  [ -z "$TIPO" ] || falha "stub (fluxo: pendente) com tipo preenchido: '$TIPO'. Tipo nasce na elaboracao."
  fechar "stub valido - elabore com /k-spec antes do /k-plan"
fi

if [ "$FLUXO" = "descartado" ]; then
  grep -q '^## Por que foi descartado' "$SPEC" \
    || falha "fluxo: descartado sem secao '## Por que foi descartado'"
  fechar "spec descartada, com motivo registrado"
fi

# --- tipo --------------------------------------------------------------------
if [ -z "$TIPO" ]; then
  falha "frontmatter sem tipo (esperado: $TIPOS)"
else
  ENCONTRADO=nao
  for T in $TIPOS; do [ "$T" = "$TIPO" ] && ENCONTRADO=sim; done
  [ "$ENCONTRADO" = sim ] || falha "tipo invalido: '$TIPO' (esperado: $TIPOS)"
fi

# --- criterios de aceite -----------------------------------------------------
grep -q '^## Crit' "$SPEC" || falha "sem secao de criterios de aceite"

# Item de criterio: "- [ ] CA-<n> <texto>" ou "- [x] ...".
CRITERIOS=$(grep -c '^- \[[ xX]\] CA-[0-9][0-9]*[[:space:]]' "$SPEC" || true)
SEM_ID=$(grep '^- \[[ xX]\] ' "$SPEC" | grep -cv '^- \[[ xX]\] CA-[0-9][0-9]*[[:space:]]' || true)

if [ "$CRITERIOS" -eq 0 ]; then
  falha "nenhum criterio no formato '- [ ] CA-<n> <texto>'"
fi
if [ "$SEM_ID" -gt 0 ]; then
  falha "$SEM_ID criterio(s) sem identificador CA-<n>. Sem ID nao ha razao de cobertura."
fi

# --- ID duplicado ------------------------------------------------------------
DUPES=$(grep -o '^- \[[ xX]\] CA-[0-9][0-9]*' "$SPEC" \
  | sed 's/^.*\(CA-[0-9][0-9]*\)$/\1/' \
  | sort | uniq -d || true)
if [ -n "$DUPES" ]; then
  for D in $DUPES; do falha "identificador repetido: $D"; done
fi

fechar "spec com $CRITERIOS criterio(s) enderecavel(is)"
