#!/usr/bin/env bash
# Verifica as invariantes do repositorio do kit antes de um release.
#
#   sh ci/verificar.sh            # todas as checagens, menos a de tag
#   sh ci/verificar.sh --tag v2.0.0
#
# Em CI, GITHUB_REF_TYPE=tag e GITHUB_REF_NAME sao lidos automaticamente.

set -uo pipefail
cd "$(dirname "$0")/.."

TETO_FLUXO=150
TETO_REFERENCIA=200

TAG=""
if [ "${1:-}" = "--tag" ] && [ -n "${2:-}" ]; then
  TAG="$2"
elif [ "${GITHUB_REF_TYPE:-}" = "tag" ]; then
  TAG="${GITHUB_REF_NAME:-}"
fi

FALHAS=0
falha() { printf 'FALHA  %s\n' "$1"; FALHAS=$((FALHAS + 1)); }
ok()    { printf 'ok     %s\n' "$1"; }

# --- 1. versao ------------------------------------------------------------
if [ ! -f nucleo/VERSAO ]; then
  falha "nucleo/VERSAO nao existe"
  exit 1
fi
VERSAO=$(tr -d ' \t\r\n' < nucleo/VERSAO)

# Sem sufixo de prerelease: a versao e sempre X.Y.Z. Sufixo obriga toda ferramenta
# que le a versao a tratar dois formatos, e '/releases/latest' do GitHub ignora
# prerelease, o que quebraria o comando padrao do instalador.
if printf '%s' "$VERSAO" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  ok "versao $VERSAO"
else
  falha "nucleo/VERSAO='$VERSAO' nao e X.Y.Z limpo (sem sufixo)"
fi

if [ "$(wc -l < nucleo/VERSAO)" -gt 1 ]; then
  falha "nucleo/VERSAO tem mais de uma linha"
fi

if grep -Eq '^versao:' nucleo/esquema.yml; then
  falha "nucleo/esquema.yml declara 'versao:' - a versao e unica e vive em nucleo/VERSAO"
else
  ok "fonte unica de versao"
fi

# --- 2. tag bate com a versao ---------------------------------------------
if [ -n "$TAG" ]; then
  if [ "$TAG" = "v$VERSAO" ]; then
    ok "tag $TAG bate com nucleo/VERSAO"
  else
    falha "tag '$TAG' != 'v$VERSAO' (nucleo/VERSAO)"
  fi
fi

# --- 3. teto de linha (D3) ------------------------------------------------
for ARQ in nucleo/fluxo/*.md; do
  N=$(wc -l < "$ARQ")
  [ "$N" -gt "$TETO_FLUXO" ] && falha "$ARQ tem $N linhas (teto $TETO_FLUXO)"
done
for ARQ in nucleo/referencias/*.md; do
  N=$(wc -l < "$ARQ")
  [ "$N" -gt "$TETO_REFERENCIA" ] && falha "$ARQ tem $N linhas (teto $TETO_REFERENCIA)"
done
ok "teto de linha (fluxo $TETO_FLUXO, referencia $TETO_REFERENCIA)"

# --- 4. todo campo do esquema e usado por um fluxo que existe --------------
while IFS= read -r LINHA; do
  CAMPO=${LINHA%%:*}
  CAMPO=$(printf '%s' "$CAMPO" | tr -d ' ')
  USADORES=$(printf '%s' "$LINHA" | sed -n 's/.*usado_por: \[\([^]]*\)\].*/\1/p' | tr -d ' ')
  if [ -z "$USADORES" ]; then
    falha "esquema: campo '$CAMPO' sem usado_por"
    continue
  fi
  for USADOR in $(printf '%s' "$USADORES" | tr ',' ' '); do
    case "$USADOR" in
      k-*) [ -f "nucleo/fluxo/$USADOR.md" ] || falha "esquema: campo '$CAMPO' cita fluxo inexistente '$USADOR'" ;;
    esac
  done
done < <(grep -E '^  [a-z_][a-z_.]*: *\{' nucleo/esquema.yml)
ok "campos do esquema apontam para fluxo existente"

# --- 5. todo caminho .ia-kit/ citado existe no nucleo ---------------------
PERMITIDOS="contrato.yml taticas metricas"
while IFS= read -r REF; do
  RESTO=${REF#.ia-kit/}
  RESTO=${RESTO%/}
  RESTO=${RESTO%.}
  [ -z "$RESTO" ] && continue
  case "$RESTO" in *'*'* | *'<'*) continue ;; esac
  PULAR=0
  for P in $PERMITIDOS; do
    case "$RESTO" in "$P" | "$P"/*) PULAR=1 ;; esac
  done
  [ "$PULAR" -eq 1 ] && continue
  if [ ! -e "nucleo/$RESTO" ]; then
    falha "caminho citado nao existe: .ia-kit/$RESTO"
  fi
done < <(grep -rhoE '\.ia-kit/[A-Za-z0-9_./*<>-]+' nucleo adaptadores | sort -u)
ok "caminhos .ia-kit/ resolvem no nucleo"

# --- 6. fluxo e shim andam juntos ----------------------------------------
for ARQ in nucleo/fluxo/k-*.md; do
  NOME=$(basename "$ARQ" .md)
  [ -f "adaptadores/claude-code/skills/$NOME/SKILL.md" ] \
    || falha "fluxo '$NOME' sem shim em adaptadores/claude-code/skills/"
  grep -q "fluxo/$NOME.md" adaptadores/agents-md/trecho.md \
    || falha "fluxo '$NOME' ausente do bloco de adaptadores/agents-md/trecho.md"
done
for DIR in adaptadores/claude-code/skills/*/; do
  NOME=$(basename "$DIR")
  [ -f "nucleo/fluxo/$NOME.md" ] || falha "shim orfao: '$NOME' nao tem nucleo/fluxo/$NOME.md"
done
ok "fluxo e shim em sincronia"

# --- 7. toda ferramenta aceita tem adaptador ------------------------------
FERRAMENTAS=$(sed -n 's/.*valores: \[\(claude-code[^]]*\)\].*/\1/p' nucleo/esquema.yml | head -1 | tr -d ' ')
for FERRAMENTA in $(printf '%s' "$FERRAMENTAS" | tr ',' ' '); do
  [ -d "adaptadores/$FERRAMENTA" ] \
    || falha "esquema aceita ferramenta '$FERRAMENTA' mas adaptadores/$FERRAMENTA nao existe"
done
ok "ferramentas aceitas tem adaptador"

# --- 8. changelog e migracao ----------------------------------------------
[ -f CHANGELOG.md ] || falha "CHANGELOG.md nao existe"
if [ -f CHANGELOG.md ] && ! grep -q "^## $VERSAO\$" CHANGELOG.md; then
  falha "CHANGELOG.md nao tem secao '## $VERSAO'"
fi
[ -f docs/migracao.md ] || falha "docs/migracao.md nao existe"
ok "CHANGELOG.md e docs/migracao.md presentes"

# --- 9. instalador ---------------------------------------------------------
for ARQ in instalador/instalar.sh instalador/instalar.ps1; do
  [ -f "$ARQ" ] || falha "$ARQ nao existe"
done
if command -v sh >/dev/null 2>&1 && [ -f instalador/instalar.sh ]; then
  sh -n instalador/instalar.sh || falha "instalador/instalar.sh tem erro de sintaxe"
fi
ok "instalador presente"

# --- 10. script so com ASCII ----------------------------------------------
# O PowerShell 5.1 le .ps1 sem BOM como CP1252. Um em dash em UTF-8 (E2 80 94)
# vira 'a-acento, euro, aspa-curva' - e a aspa curva fecha string, engolindo o
# resto do script sem erro de sintaxe. Prosa acentuada fica nos .md.
for ARQ in instalador/instalar.sh instalador/instalar.ps1 ci/verificar.sh; do
  [ -f "$ARQ" ] || continue
  if LC_ALL=C grep -qP '[^\x00-\x7F]' "$ARQ" 2>/dev/null; then
    falha "$ARQ tem caractere fora de ASCII"
  fi
done
ok "scripts so com ASCII"

# --- resultado -------------------------------------------------------------
printf '\n'
if [ "$FALHAS" -eq 0 ]; then
  printf 'tudo verde - kit %s\n' "$VERSAO"
  exit 0
fi
printf '%s falha(s)\n' "$FALHAS"
exit 1
