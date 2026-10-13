#!/bin/sh
# Confere .ia-kit/contrato.yml contra .ia-kit/esquema.yml.
#
# Chamado pelo k-init (passo 0), em reconfiguracao e em atualizacao. Reporta,
# nesta ordem: campo obrigatorio ausente, campo orfao, campo removido.
#
# Script confere FORMA, agente confere SENTIDO. Exit 0 aqui significa que o
# contrato tem os campos que o esquema exige - nao que os valores deles estejam
# certos. Comando que existe no contrato e nao roda e problema do k-init, que
# valida executando.
#
#   sh verificar-contrato.sh [caminho-do-contrato] [caminho-do-esquema]
#
# Exit: 0 forma valida, 1 achado, 2 erro de uso ou ambiente.

set -eu

DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$DIR/comum.sh"

CONTRATO="${1:-}"
ESQUEMA="${2:-}"

# Sem argumento: procura no layout instalado (.ia-kit/) e no repo do kit (nucleo/).
if [ -z "$CONTRATO" ]; then
  for C in .ia-kit/contrato.yml "$DIR/../contrato.yml"; do
    [ -f "$C" ] && { CONTRATO="$C"; break; }
  done
fi
if [ -z "$ESQUEMA" ]; then
  for E in .ia-kit/esquema.yml "$DIR/../esquema.yml" nucleo/esquema.yml; do
    [ -f "$E" ] && { ESQUEMA="$E"; break; }
  done
fi

[ -n "$CONTRATO" ] && [ -f "$CONTRATO" ] || aborta "contrato nao encontrado. Passe o caminho como primeiro argumento."
[ -n "$ESQUEMA" ] && [ -f "$ESQUEMA" ] || aborta "esquema nao encontrado. Passe o caminho como segundo argumento."

TMP=$(mktemp -d 2>/dev/null || mktemp -d -t iakit)
trap 'rm -rf "$TMP"' EXIT INT TERM
mkdir -p "$TMP/c" "$TMP/e"
CONTRATO=$(sem_cr "$CONTRATO" "$TMP/c")
ESQUEMA=$(sem_cr "$ESQUEMA" "$TMP/e")

recusar_yaml_fora_do_subconjunto "$CONTRATO"
recusar_yaml_fora_do_subconjunto "$ESQUEMA"


# --- campos declarados no esquema, com obrigatoriedade -----------------------
# Linha de campo: dois espacos, nome pontuado, dois pontos, abre chave.
# A secao `removidos:` fica fora: suas chaves nao tem `{`.
awk '
  /^removidos:/ { fim = 1 }
  fim { next }
  /^  [a-z_][a-z_.]*: *\{/ {
    pos = index($0, ":")
    nome = substr($0, 3, pos - 3)
    gsub(/[ \t]/, "", nome)
    obrig = ($0 ~ /obrigatorio: *true/) ? "sim" : "nao"
    print nome " " obrig
  }
' "$ESQUEMA" > "$TMP/esquema"

[ -s "$TMP/esquema" ] || aborta "nenhum campo lido de $ESQUEMA - formato inesperado"

# --- campos removidos, com a versao de saida e o substituto ------------------
awk '
  /^removidos:/ { dentro = 1; next }
  !dentro { next }
  /^  [a-z_][a-z_.]*: *$/ {
    pos = index($0, ":")
    nome = substr($0, 3, pos - 3)
    gsub(/[ \t]/, "", nome)
    atual = nome
    saiu[atual] = ""
    subst[atual] = ""
    ordem[++n] = atual
    next
  }
  /^    saiu_em:/  { v = $0; sub(/^ *saiu_em: */, "", v);     saiu[atual] = v }
  /^    substituto:/ { v = $0; sub(/^ *substituto: */, "", v); subst[atual] = v }
  END {
    for (i = 1; i <= n; i++) {
      k = ordem[i]
      print k "\t" (saiu[k] == "" ? "?" : saiu[k]) "\t" (subst[k] == "" ? "-" : subst[k])
    }
  }
' "$ESQUEMA" > "$TMP/removidos"

# --- campos presentes no contrato, achatados em caminho pontuado -------------
# Profundidade 2. Chave com 4+ espacos e conteudo de mapa (ex.: limites_tarefa),
# nao campo proprio - o esquema declara o mapa inteiro como um campo so.
awk '
  { sub(/\r$/, "") }
  /^[[:space:]]*#/ { next }
  /^[[:space:]]*$/ { next }
  /^[[:space:]]*- / { next }
  /^[a-z_][a-z_]*:/ {
    pos = index($0, ":")
    pai = substr($0, 1, pos - 1)
    resto = substr($0, pos + 1)
    sub(/[ \t]*#.*$/, "", resto)
    gsub(/^[ \t]+|[ \t]+$/, "", resto)
    if (resto != "") print pai
    next
  }
  /^  [a-z_][a-z_]*:/ {
    if (pai == "") next
    pos = index($0, ":")
    filho = substr($0, 3, pos - 3)
    gsub(/[ \t]/, "", filho)
    print pai "." filho
    next
  }
' "$CONTRATO" | sort -u > "$TMP/contrato"

[ -s "$TMP/contrato" ] || aborta "nenhum campo lido de $CONTRATO - formato inesperado"

# --- 1. campo obrigatorio ausente -------------------------------------------
while read -r NOME OBRIG; do
  [ "$OBRIG" = "sim" ] || continue
  grep -qxF "$NOME" "$TMP/contrato" || falha "campo obrigatorio ausente: $NOME"
done < "$TMP/esquema"

# --- 2. campo orfao ----------------------------------------------------------
cut -d' ' -f1 "$TMP/esquema" | sort -u > "$TMP/conhecidos"
cut -f1 "$TMP/removidos" | sort -u > "$TMP/fora"
while read -r NOME; do
  grep -qxF "$NOME" "$TMP/conhecidos" && continue
  grep -qxF "$NOME" "$TMP/fora" && continue
  falha "campo orfao (o esquema nao conhece): $NOME"
done < "$TMP/contrato"

# --- 3. campo removido ainda presente ---------------------------------------
while IFS="$(printf '\t')" read -r NOME SAIU SUBST; do
  grep -qxF "$NOME" "$TMP/contrato" || continue
  falha "campo removido na $SAIU ainda presente: $NOME (substituto: $SUBST)"
done < "$TMP/removidos"

fechar "contrato bate com o esquema"
