#!/bin/sh
# Funcoes compartilhadas pelos verificadores do ia-kit.
#
# Este arquivo nao roda sozinho: os demais scripts fazem `. comum.sh`.
#
# REGRA QUE GOVERNA TODOS ELES:
#   o script confere FORMA, o agente confere SENTIDO.
#   Exit 0 nao significa "o trabalho esta certo". Significa "a forma permite
#   verificar". Nenhum destes scripts le codigo de aplicacao nem julga solucao.
#
# ASCII puro, POSIX sh. Sem bashism, sem `grep -P`, sem `local`.

ACHADOS=0

falha() {
  printf 'FALHA  %s\n' "$1" >&2
  ACHADOS=$((ACHADOS + 1))
}

aviso() {
  printf 'aviso  %s\n' "$1" >&2
}

ok() {
  printf 'ok     %s\n' "$1"
}

# Tabela de saida, compartilhada pelos quatro scripts:
#
#   0  a forma permite verificar          segue
#   1  forma violada, achados listados    para, corrige a forma, roda de novo
#   2  uso incorreto ou ambiente          para, e erro de quem chamou
#   3  arquivo fora do subconjunto YAML   para, reescreve a linha apontada
#
# O 3 existe separado do 1 de proposito. "Nao consegui ler" e "esta errado" sao
# coisas diferentes, e tratar a primeira como aprovacao e o unico desfecho
# inaceitavel: produz exatamente a falsa confianca que estes scripts existem
# para eliminar.

# Uso incorreto, ou ambiente sem o que o script precisa.
aborta() {
  printf 'erro: %s\n' "$1" >&2
  exit 2
}

# Arquivo que o script nao sabe ler. Nomeia o que atrapalhou: quem chamou
# acabou de escrever o arquivo e consegue corrigir a linha exata.
ilegivel() {
  printf 'ILEGIVEL  %s\n' "$1" >&2
  printf 'Fora do subconjunto YAML do kit. Veja referencias/verificadores.md.\n' >&2
  exit 3
}

# Fecha o script com o codigo certo.
#
# A ultima linha do caso verde repete a regra no unico instante em que ela
# muda alguma coisa: quando quem chamou esta prestes a ler exit 0 como
# aprovacao do trabalho.
fechar() {
  if [ "$ACHADOS" -gt 0 ]; then
    printf '\n%s achado(s). Forma invalida - nao siga.\n' "$ACHADOS" >&2
    exit 1
  fi
  printf '\nok     %s\n' "${1:-forma valida}"
  printf 'ok     forma verificavel. O sentido e do agente.\n'
  exit 0
}

# Subconjunto de YAML que estes scripts sabem ler:
#   - chave no inicio da linha, ou com 2 espacos de indentacao
#   - valor escalar, ou lista inline [a, b], ou lista de bloco com "- "
#   - comentario com # no inicio ou depois do valor
#   - sem ancora (&x, *x), sem bloco literal (| ou >), sem documento multiplo
#
# Fora disso, o script sai 3 pelo `ilegivel`.
recusar_yaml_fora_do_subconjunto() {
  ARQ="$1"
  if grep -q '^[[:space:]]*[a-z_.]*:[[:space:]]*[|>][[:space:]]*$' "$ARQ"; then
    ilegivel "$ARQ usa bloco literal (| ou >)"
  fi
  if grep -q '[[:space:]][&*][a-zA-Z_]' "$ARQ"; then
    ilegivel "$ARQ usa ancora ou alias YAML"
  fi
  if [ "$(grep -c '^---[[:space:]]*$' "$ARQ")" -gt 1 ]; then
    ilegivel "$ARQ tem mais de um documento YAML"
  fi
  if grep -q "$(printf '^[ ]*\t')" "$ARQ"; then
    ilegivel "$ARQ usa tabulacao na indentacao"
  fi
}

# Frontmatter de um .md: imprime as linhas entre o primeiro e o segundo ---.
# Sem frontmatter, imprime nada e devolve 1.
frontmatter() {
  awk '
    { sub(/$/, "") }
    NR == 1 && $0 != "---" { exit 1 }
    NR == 1 { dentro = 1; next }
    dentro && $0 == "---" { exit 0 }
    dentro { print }
    END { if (dentro != 1) exit 1 }
  ' "$1"
}

# Valor de uma chave escalar do frontmatter. Vazio quando ausente.
campo_frontmatter() {
  frontmatter "$1" | awk -v chave="$2" '
    {
      pos = index($0, ":")
      if (pos == 0) next
      k = substr($0, 1, pos - 1)
      gsub(/^[ \t]+|[ \t]+$/, "", k)
      if (k != chave) next
      v = substr($0, pos + 1)
      sub(/[ \t]*#.*$/, "", v)
      gsub(/^[ \t]+|[ \t]+$/, "", v)
      print v
      exit
    }
  '
}

# Copia do arquivo sem CR, num diretorio temporario que o chamador ja criou.
# Imprime o caminho da copia.
#
# Por que isto existe: checkout Windows com autocrlf grava CRLF, e o awk do
# Git Bash remove o \r sozinho enquanto o mawk do Linux nao. Sem normalizar, o
# gate passaria na maquina de quem escreveu e falharia no CI - verde pelo
# motivo errado, que e o desfecho que estes scripts existem para impedir.
sem_cr() {
  DESTINO="$2/$(basename "$1")"
  tr -d '\r' < "$1" > "$DESTINO"
  printf '%s\n' "$DESTINO"
}
