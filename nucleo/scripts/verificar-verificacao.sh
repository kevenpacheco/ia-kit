#!/bin/sh
# Confere a forma do verificacao.md. Gate de conclusao do fluxo.
#
# Script confere FORMA, agente confere SENTIDO. Exit 0 aqui significa que existe
# um veredito com evidencia para cada criterio - nao que o veredito esteja
# certo. Quem julga o codigo e o verificador; este script so recusa relatorio
# que nao da para conferir.
#
#   sh verificar-verificacao.sh <pasta-da-spec> [--perfil-esperado <p>]
#
# Exit: 0 aprovado, 1 forma violada, 2 erro de uso, 3 fora do subconjunto,
#       4 forma completa e veredito reprovado.

set -eu

DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$DIR/comum.sh"

PASTA="${1:-}"
[ -n "$PASTA" ] || aborta "uso: sh verificar-verificacao.sh <pasta-da-spec> [--perfil-esperado <p>]"
[ -d "$PASTA" ] || aborta "pasta nao encontrada: $PASTA"
shift

PERFIL_ESPERADO=""
while [ $# -gt 0 ]; do
  case "$1" in
    --perfil-esperado) [ $# -ge 2 ] || aborta "--perfil-esperado exige um valor"
                       PERFIL_ESPERADO="$2"; shift 2 ;;
    *) aborta "argumento desconhecido: $1" ;;
  esac
done

SPEC="$PASTA/spec.md"
VERIF="$PASTA/verificacao.md"
[ -f "$SPEC" ] || aborta "spec.md nao encontrado em $PASTA"

if [ ! -f "$VERIF" ]; then
  falha "verificacao.md ausente. O fluxo nao foi verificado - veja encerramento.md."
  fechar
fi

PERFIS="rapido padrao rigoroso"
VEREDITOS="aprovado reprovado sem-evidencia nao-aplicavel"
GLOBAIS="aprovado aprovado-com-ressalva reprovado"

TMP=$(mktemp -d 2>/dev/null || mktemp -d -t iakit)
trap 'rm -rf "$TMP"' EXIT INT TERM
mkdir -p "$TMP/v"
SPEC=$(sem_cr "$SPEC" "$TMP/v")
VERIF=$(sem_cr "$VERIF" "$TMP")

frontmatter "$VERIF" >/dev/null 2>&1 || ilegivel "$VERIF nao comeca com frontmatter"

RODADA=$(campo_frontmatter "$VERIF" rodada)
GLOBAL=$(campo_frontmatter "$VERIF" veredito)
PERFIL=$(campo_frontmatter "$VERIF" perfil)
BASE=$(campo_frontmatter "$VERIF" base)
HEAD_=$(campo_frontmatter "$VERIF" head)

# --- frontmatter -------------------------------------------------------------
case "$RODADA" in
  '') falha "frontmatter sem rodada" ;;
  *[!0-9]*) falha "rodada nao e inteiro: '$RODADA'" ;;
esac

[ -n "$BASE" ] || falha "frontmatter sem base. Sem o SHA base, o range nao e conferivel."
[ -n "$HEAD_" ] || falha "frontmatter sem head. Sem o SHA topo, o range nao e conferivel."

if [ -z "$PERFIL" ]; then
  falha "frontmatter sem perfil"
else
  ENCONTRADO=nao
  for P in $PERFIS; do [ "$P" = "$PERFIL" ] && ENCONTRADO=sim; done
  [ "$ENCONTRADO" = sim ] || falha "perfil invalido: '$PERFIL' (esperado: $PERFIS)"
fi

if [ -n "$PERFIL_ESPERADO" ] && [ "$PERFIL" != "$PERFIL_ESPERADO" ]; then
  falha "perfil divergente: relatorio diz '$PERFIL', o fluxo pediu '$PERFIL_ESPERADO'"
fi

if [ -z "$GLOBAL" ]; then
  falha "frontmatter sem veredito global"
else
  ENCONTRADO=nao
  for G in $GLOBAIS; do [ "$G" = "$GLOBAL" ] && ENCONTRADO=sim; done
  [ "$ENCONTRADO" = sim ] || falha "veredito global invalido: '$GLOBAL' (esperado: $GLOBAIS)"
fi

# --- criterios da spec -------------------------------------------------------
grep -o '^- \[[ xX]\] CA-[0-9][0-9]*' "$SPEC" \
  | sed 's/^.*\(CA-[0-9][0-9]*\)$/\1/' | sort -u > "$TMP/criterios" || true
[ -s "$TMP/criterios" ] || aborta "nenhum criterio CA-<n> em $SPEC"

# --- vereditos por criterio --------------------------------------------------
# Forma da linha, fixa para ser conferivel:
#   - CA-<n> <veredito> <arquivo:linha ou -> <texto livre>
awk '$1 == "-" && $2 ~ /^CA-[0-9]+$/ { print $2, $3, $4 }' "$VERIF" > "$TMP/vereditos"

REPROVADOS=0
while read -r CA; do
  N=$(awk -v ca="$CA" '$1 == ca' "$TMP/vereditos" | wc -l | tr -d ' ')
  if [ "$N" -eq 0 ]; then
    falha "$CA sem veredito no relatorio"
    REPROVADOS=$((REPROVADOS + 1))
    continue
  fi
  if [ "$N" -gt 1 ]; then
    falha "$CA com $N vereditos. Um criterio, um veredito."
    continue
  fi

  V=$(awk -v ca="$CA" '$1 == ca { print $2 }' "$TMP/vereditos")
  E=$(awk -v ca="$CA" '$1 == ca { print $3 }' "$TMP/vereditos")

  ENCONTRADO=nao
  for X in $VEREDITOS; do [ "$X" = "$V" ] && ENCONTRADO=sim; done
  if [ "$ENCONTRADO" != sim ]; then
    falha "$CA com veredito invalido '$V' (esperado: $VEREDITOS)"
    continue
  fi

  # Evidencia arquivo:linha e obrigatoria em aprovado e reprovado.
  case "$V" in
    aprovado|reprovado)
      case "$E" in
        *:[0-9]*) ;;
        *) falha "$CA ($V) sem evidencia arquivo:linha. Veredito sem evidencia nao e veredito." ;;
      esac
      ;;
  esac

  # sem-evidencia conta como reprovado: ausencia de evidencia nao e evidencia
  # de conformidade. Sem esta linha o relatorio inteiro vira teatro.
  case "$V" in
    reprovado|sem-evidencia) REPROVADOS=$((REPROVADOS + 1)) ;;
  esac
done < "$TMP/criterios"

# --- veredito citando criterio que nao existe --------------------------------
cut -d' ' -f1 "$TMP/vereditos" | sort -u > "$TMP/citados"
while read -r C; do
  grep -qxF "$C" "$TMP/criterios" || falha "relatorio cita $C, que nao existe na spec"
done < "$TMP/citados"

# --- coerencia do veredito global -------------------------------------------
if [ "$REPROVADOS" -gt 0 ] && [ "$GLOBAL" != "reprovado" ]; then
  falha "veredito global '$GLOBAL' com $REPROVADOS criterio(s) reprovado(s) ou sem evidencia"
fi
if [ "$REPROVADOS" -eq 0 ] && [ "$GLOBAL" = "reprovado" ]; then
  falha "veredito global 'reprovado' sem nenhum criterio reprovado"
fi

[ "$ACHADOS" -eq 0 ] || fechar

TOTAL=$(wc -l < "$TMP/criterios" | tr -d ' ')
if [ "$REPROVADOS" -gt 0 ]; then
  printf '\nok     forma completa: %s criterio(s), rodada %s, perfil %s\n' "$TOTAL" "$RODADA" "$PERFIL"
  printf 'REPROVADO  %s de %s criterio(s). O fluxo nao fecha.\n' "$REPROVADOS" "$TOTAL" >&2
  exit 4
fi

fechar "$TOTAL criterio(s) com veredito e evidencia, rodada $RODADA, perfil $PERFIL"
