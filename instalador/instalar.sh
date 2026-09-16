#!/bin/sh
# Instala ou atualiza o nucleo do ia-kit em .ia-kit/.
#
# Este script so troca arquivo. Ele nao entrevista, nao gera shim e nao commita.
# Depois de rodar, rode o k-init: e ele quem reconcilia o contrato e os shims.
#
#   sh instalar.sh                        # ultima versao publicada
#   sh instalar.sh --versao 2.0.0         # versao fixa
#   sh instalar.sh --versao main          # branch ou sha, para desenvolvimento
#   sh instalar.sh --origem https://github.com/minha-org/ia-kit
#   sh instalar.sh --destino caminho/.ia-kit

set -eu

ORIGEM="https://github.com/kevenpacheco/ia-kit"
VERSAO="latest"
DESTINO=".ia-kit"
FORCAR=0

# Caminhos dentro de .ia-kit/ que pertencem ao projeto, nao ao kit.
PRESERVAR="contrato.yml taticas metricas"

erro() { printf 'erro: %s\n' "$1" >&2; exit 1; }
aviso() { printf '%s\n' "$1" >&2; }

ajuda() {
  cat <<'FIM'
Instala ou atualiza o nucleo do ia-kit em .ia-kit/.
Depois de rodar, rode o k-init: e ele quem reconcilia o contrato e os shims.

  --versao <tag|branch|sha>  padrao: ultima versao publicada
  --origem <url>             padrao: https://github.com/kevenpacheco/ia-kit
  --destino <dir>            padrao: .ia-kit
  --forcar                   substitui diretorio que nao parece um nucleo do kit
FIM
  exit 0
}

while [ $# -gt 0 ]; do
  case "$1" in
    --versao)  [ $# -ge 2 ] || erro "--versao exige um valor"; VERSAO="$2"; shift 2 ;;
    --origem)  [ $# -ge 2 ] || erro "--origem exige um valor"; ORIGEM="$2"; shift 2 ;;
    --destino) [ $# -ge 2 ] || erro "--destino exige um valor"; DESTINO="$2"; shift 2 ;;
    --forcar)  FORCAR=1; shift ;;
    --ajuda|-h) ajuda ;;
    *) erro "argumento desconhecido: $1 (use --ajuda)" ;;
  esac
done

ORIGEM=$(printf '%s' "$ORIGEM" | sed 's#/*$##')

case "$DESTINO" in
  ""|"/"|"."|"..") erro "--destino invalido: '$DESTINO'" ;;
esac

# Recusar antes de baixar: destino que existe e nao parece um nucleo do kit.
if [ -e "$DESTINO" ]; then
  [ -d "$DESTINO" ] || erro "$DESTINO existe e nao e diretorio"
  if [ ! -f "$DESTINO/VERSAO" ] && [ ! -f "$DESTINO/contrato.yml" ] && [ "$FORCAR" -eq 0 ]; then
    erro "$DESTINO existe mas nao parece um nucleo do ia-kit. Use --forcar se for mesmo para substituir."
  fi
fi

command -v tar >/dev/null 2>&1 || erro "tar nao encontrado"
if command -v curl >/dev/null 2>&1; then
  baixar() { curl -fsSL "$1" -o "$2"; }
  ler_url() { curl -fsSL "$1"; }
elif command -v wget >/dev/null 2>&1; then
  baixar() { wget -qO "$2" "$1"; }
  ler_url() { wget -qO - "$1"; }
else
  erro "curl ou wget nao encontrado"
fi

# --- resolver a referencia a baixar ---------------------------------------
if [ "$VERSAO" = "latest" ]; then
  CAMINHO=$(printf '%s' "$ORIGEM" | sed 's#^https\{0,1\}://[^/]*/##')
  VERSAO=$(ler_url "https://api.github.com/repos/$CAMINHO/releases/latest" 2>/dev/null \
    | sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
    | head -1 | sed 's/^v//') || true
  [ -n "${VERSAO:-}" ] || erro "nenhum release publicado em $ORIGEM. Passe --versao <tag|branch|sha>."
fi

case "$VERSAO" in
  [0-9]*.[0-9]*.[0-9]*) REF="v$VERSAO" ;;
  *) REF="$VERSAO" ;;
esac

# --- baixar e extrair ------------------------------------------------------
TMP=$(mktemp -d 2>/dev/null || mktemp -d -t iakit)
trap 'rm -rf "$TMP"' EXIT INT TERM

URL="$ORIGEM/archive/$REF.tar.gz"
printf 'baixando %s\n' "$URL"
baixar "$URL" "$TMP/kit.tar.gz" || erro "download falhou. Versao '$VERSAO' existe em $ORIGEM?"

tar -xzf "$TMP/kit.tar.gz" -C "$TMP" || erro "pacote invalido"
PACOTE=$(find "$TMP" -mindepth 1 -maxdepth 1 -type d | head -1)
[ -n "$PACOTE" ] || erro "pacote vazio"
[ -f "$PACOTE/nucleo/VERSAO" ] || erro "pacote nao contem nucleo/VERSAO - origem errada?"

NOVA=$(tr -d ' \t\r\n' < "$PACOTE/nucleo/VERSAO")
ANTERIOR="ausente"
[ -f "$DESTINO/VERSAO" ] && ANTERIOR=$(tr -d ' \t\r\n' < "$DESTINO/VERSAO")

# --- guardar o que e do projeto -------------------------------------------
if [ -e "$DESTINO" ]; then
  mkdir -p "$TMP/preservado"
  for ITEM in $PRESERVAR; do
    if [ -e "$DESTINO/$ITEM" ]; then
      cp -R "$DESTINO/$ITEM" "$TMP/preservado/" || erro "falhou ao preservar $ITEM"
      printf 'preservando %s\n' "$DESTINO/$ITEM"
    fi
  done
  rm -rf "$DESTINO"
fi

# --- instalar --------------------------------------------------------------
mkdir -p "$(dirname "$DESTINO")"
cp -R "$PACOTE/nucleo" "$DESTINO"

if [ -d "$TMP/preservado" ]; then
  for ITEM in $PRESERVAR; do
    [ -e "$TMP/preservado/$ITEM" ] && cp -R "$TMP/preservado/$ITEM" "$DESTINO/"
  done
fi

printf '\nnucleo: %s -> %s  em %s/\n' "$ANTERIOR" "$NOVA" "$DESTINO"
if [ -f "$DESTINO/contrato.yml" ]; then
  printf 'contrato.yml preservado.\n'
else
  printf 'sem contrato.yml - instalacao nova.\n'
fi
printf 'proximo passo: rode k-init. O instalador nao gera shim nem reconcilia contrato.\n'
