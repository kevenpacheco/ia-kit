# Verificadores de forma

Os quatro scripts de `.ia-kit/scripts/`, o que cada um confere, e — mais importante — o que
nenhum deles confere.

---

## A regra que governa os quatro

**O script confere forma. O agente confere sentido.**

Exit 0 não significa "o trabalho está certo". Significa "a forma permite verificar".

Um script consegue provar que todo critério de aceite tem identificador e que alguma tarefa
diz cobri-lo. Não consegue provar que a tarefa implementa o critério, nem que o critério
descreve o comportamento certo. Isso é julgamento, e julgamento é do agente e do humano.

Cada script repete essa frase na última linha do caso verde, de propósito. É o único
instante em que ela muda alguma coisa: quando quem chamou está prestes a ler exit 0 como
aprovação do trabalho.

## Tabela de saída

| Código | Significa | O chamador faz |
|---|---|---|
| `0` | a forma permite verificar | segue |
| `1` | forma violada, achados listados | para, corrige a forma, roda de novo |
| `2` | uso incorreto ou ambiente faltando | para — é erro de quem chamou, não do artefato |
| `3` | arquivo fora do subconjunto YAML do kit | para, reescreve o que o script apontou |
| `4` | forma completa, veredito reprovado | para — só `verificar-verificacao.sh` emite |

O `3` existe separado do `1` de propósito. **"Não consegui ler" e "está errado" são coisas
diferentes**, e tratar a primeira como aprovação é o único desfecho inaceitável: produz
exatamente a falsa confiança que estes scripts existem para eliminar.

O `4` existe separado do `1` pelo mesmo motivo, invertido. Um `verificacao.md` com um
critério reprovado **está com a forma certa** — o script que saísse `1` ali estaria julgando
sentido. Saindo `4`, ele só transporta um veredito que o verificador escreveu.

## Os quatro

| Script | Argumento | Confere | Chamado por |
|---|---|---|---|
| `verificar-contrato.sh` | contrato e esquema, ou vazio | campo obrigatório ausente, órfão, ou listado em `removidos` | `k-init` passo 0 |
| `verificar-spec.sh` | pasta da spec | frontmatter, `tipo` e `fluxo` na lista fechada, critérios com `CA-n` único | `k-spec`, antes de encerrar |
| `verificar-tarefas.sh` | pasta da spec | `arquivos` preenchido, `status` válido, todo `CA-n` coberto por alguma tarefa | `k-plan`, antes de commitar |
| `verificar-verificacao.sh` | pasta da spec | veredito e evidência `arquivo:linha` por critério, range e perfil declarados | `k-execute`, no encerramento |

Todos são POSIX sh e ASCII puro, sem dependência além de `sh`, `awk`, `grep` e `sed`.

## Subconjunto de YAML que eles leem

Os scripts **não são parser de YAML. São reconhecedores.** O que eles aceitam:

- chave no início da linha, ou com 2 espaços de indentação
- valor escalar, lista inline `[a, b]`, ou lista de bloco com `- `
- comentário com `#` no início da linha ou depois do valor

O que está fora, e é detectado ruidosamente com exit 3:

- bloco literal (`|` ou `>`)
- âncora ou alias (`&x`, `*x`)
- mais de um documento no mesmo arquivo
- tabulação como indentação

Fora do subconjunto o script **sai 3 e não aprova nada**. Aprovar o que não conseguiu ler
seria pior que não ter script.

A mensagem de exit 3 nomeia o arquivo e o que atrapalhou. Quem chamou acabou de escrever o
arquivo e tem contexto inteiro para corrigir a linha e rodar de novo.

## Por que não ancoram em cabeçalho

Script do núcleo é ASCII puro, e cabeçalho do kit é acentuado (`## Critérios de aceite`).
Casar `é` em `LC_ALL=C` depende de locale — o `.` casa **byte**, e `é` em UTF-8 são dois.

Por isso a âncora é sempre um **prefixo ASCII de linha**: `- [ ] CA-1`, `- CA-1 aprovado`,
`numero:`. Consequência boa: a prosa das seções pode mudar à vontade sem quebrar gate.

**Regra para quem escrever script novo:** ancore em prefixo ASCII de linha, nunca em
cabeçalho.

## O que eles não conferem

Vale para os quatro, e precisa estar escrito, senão exit 0 vira carimbo:

- **Se o critério descreve o comportamento certo.** Spec errada com forma certa passa.
- **Se a tarefa implementa o que diz cobrir.** A cobertura é declarada, não provada. Quem
  prova é o verificador do encerramento, contra o diff.
- **Se o comando do contrato funciona.** Quem valida executando é o `k-init`.
- **Qualquer coisa sobre o código de aplicação.** Nenhum deles lê código.

## Quando `sh` não existe

Projeto Windows sem Git Bash no PATH não roda nenhum dos quatro. A queda segue o precedente
de `comandos.seguranca` vazio: **avisa em toda invocação e não bloqueia**.

`execucao.verificadores` governa:

| Valor | Efeito |
|---|---|
| `obrigatorio` | etapa não fecha sem o script sair 0. Recomendado onde `sh` existe |
| `quando_disponivel` (padrão) | `sh` ausente: avisa que o gate de forma não rodou e segue |
| `desligado` | não roda e não avisa. Registra a dívida no contrato |

Bloquear onde `sh` não existe empurraria o time a arrancar o gate — mesmo raciocínio pelo
qual `comandos.seguranca` vazio avisa em vez de travar.
