# Contrato do projeto — `.ia-kit/contrato.yml`

Declara o que o kit precisa saber sobre este projeto. Substitui prosa por campo: skill não
adivinha comando, não infere convenção, não reinterpreta instrução a cada invocação.

**Regra central:** campo vazio faz a skill **parar e perguntar**. Nunca chutar.

---

## Esquema

```yaml
kit_versao: 2.0.0          # versão do núcleo que gerou este contrato
kit_origem: https://github.com/kevenpacheco/ia-kit   # de onde atualizar
ferramentas: [claude-code]         # shims gerados: claude-code | agents-md | cursor

projeto:
  nome: <string>
  stack: <string curto>            # ex.: "TypeScript, Next.js, Postgres"

specs:
  raiz: docs/specs                 # onde vivem as pastas de spec

comandos:                          # vazio = skill pergunta na hora de usar
  lint: <cmd>
  formato: <cmd>                   # opcional
  teste_unit: <cmd>
  teste_integracao: <cmd>          # opcional
  suite: <cmd>                     # roda tudo; usado no encerramento do fluxo
  seguranca: <cmd>                 # varredura completa
  seguranca_diff: <cmd>            # varredura incremental; {base} e {arquivos} são
                                   # substituídos na hora. Vazio = gate cai para completa

git:
  forja: github                    # github | gitlab | bitbucket | azure | nenhuma
  branch_principal: main
  branches_protegidas: [main]
  prefixos:
    feature: feat
    bug: fix
    refactor: refactor
    chore: chore
    docs: docs

execucao:
  modo_padrao: evolucao            # greenfield | evolucao | legado
  encadeamento: automatico         # automatico | manual — ver "Encadeamento"
  tentativas_gate: 2
  limites_tarefa:                  # sinais observáveis; estourou, para e devolve
    arquivos_lidos: 40
    rodadas_ferramenta: 60
    minutos: 20
  limiar_promocao:                 # acima disso, k-commit sugere abrir um fluxo
    arquivos: 5
    linhas: 150

commit:
  idioma: pt-BR
  atribuicao_ia: false             # true libera rodapé de IA na mensagem
  revisao_subagente: por_limiar    # sempre | por_limiar | nunca
  revisao_limiar:
    arquivos: 3
    linhas: 80

shipping:
  automatico: false                # true: push + PR ao encerrar o fluxo, sem perguntar
  alvo_pr: main                    # base do PR; vazio faz perguntar a cada vez
  pr_draft_quando: [achado_aberto, modo_legado]
  merge: manual                    # nunca automático

modelos:                           # aplicado onde a ferramenta permite; ver "Modelos"
  forte: <id ou alias>             # k-plan, k-execute
  barato: <id ou alias>            # k-scan, sumarização, refutação, busca
```

---

## Campos

| Campo | Obrigatório | Quem usa | Se faltar |
|---|---|---|---|
| `kit_versao` | sim | `k-init` | migração não roda |
| `kit_origem` | sim | `k-init` | ninguém sabe de onde atualizar |
| `ferramentas` | sim | `k-init` | shim não é regenerado |
| `projeto.nome` | sim | corpo de PR, commit | pergunta |
| `projeto.stack` | sim | `k-plan`, `k-task` | pergunta |
| `specs.raiz` | sim | todo o fluxo | pergunta |
| `comandos.lint` | sim | gate 1 | gate para |
| `comandos.teste_unit` | sim | gate 2 | gate para |
| `comandos.teste_integracao` | não | gate 2 | camada ignorada |
| `comandos.suite` | sim | encerramento | encerramento para |
| `comandos.seguranca` | sim | gate 3 | **avisa a cada commit — ver abaixo** |
| `comandos.seguranca_diff` | não | gate 3 | cai para varredura completa e avisa o custo |
| `git.forja` | sim | `k-revisao`, shipping | assume `nenhuma`: PR e comentários viram passo manual |
| `git.branch_principal` | sim | `k-spec`, `k-plan` | pergunta |
| `git.branches_protegidas` | sim | `k-execute` | assume `[main]` e avisa |
| `git.prefixos` | sim | `k-plan` | usa o padrão da tabela |
| `execucao.modo_padrao` | sim | `k-plan` | assume `evolucao` |
| `execucao.encadeamento` | sim | `k-spec`, `k-plan` | assume `automatico` |
| `execucao.limites_tarefa` | sim | `k-execute` | sem limite, avisa uma vez |
| `execucao.limiar_promocao` | sim | `k-commit` | não sugere promoção |
| `commit.idioma` | sim | `k-commit` | assume `pt-BR` |
| `commit.atribuicao_ia` | sim | `k-commit` | assume `false` |
| `commit.revisao_subagente` | sim | `k-commit` | assume `por_limiar` |
| `shipping.automatico` | sim | `k-execute` | assume `false` — pergunta antes de subir |
| `shipping.alvo_pr` | não | `k-execute` | pergunta o alvo a cada PR |
| `shipping.pr_draft_quando` | sim | `k-commit` | PR nunca sai como draft |
| `shipping.merge` | sim | `k-commit` | assume `manual` |
| `modelos.forte` / `modelos.barato` | não | roteamento | usa o modelo da sessão |

### `comandos.seguranca`

Campo vazio não é neutro. Sem gate de segurança, código gerado por IA entra no repositório
com cerca de 44% de chance de carregar uma vulnerabilidade — é a lacuna que a decisão D10
existe para fechar. Quando o `k-init` não encontra ferramenta instalada, ele registra:

```yaml
comandos:
  seguranca: ""
  seguranca_pendente: "nenhuma ferramenta detectada em <data>"
```

O `k-commit` então **avisa em toda invocação** até o campo ser preenchido. Ele não bloqueia o
trabalho — bloquear o fluxo inteiro por falta de ferramenta empurraria o time a remover o
gate. Avisar de forma persistente mantém a dívida visível.

Candidatos por stack e modelos de invocação incremental: `gate.md`.

### `comandos.seguranca_diff`

Campo próprio porque varredura completa leva minutos e faz o gate ser desligado, enquanto a
incremental leva segundos e sobrevive ao uso diário. O `k-init` testa se a ferramenta
detectada sabe operar assim antes de gravar.

Placeholders substituídos na hora: `{base}` e `{arquivos}`. Vazio: o gate cai para varredura
completa e avisa o custo.

### `execucao.limites_tarefa`

Sinais **observáveis** de tarefa fora de controle: arquivos lidos, rodadas de ferramenta,
minutos. Não é contagem de token — o agente não lê o próprio consumo de forma confiável
durante a execução, e regra que ninguém consegue cumprir ensina a ignorar regras.

Estourou qualquer um: para, registra qual sinal estourou e devolve. Tarefa que estoura quase
sempre está mal quebrada, e o sinal é mais útil como diagnóstico da quebra do que como
controle de custo.

O custo em dinheiro entra depois, no relatório de fechamento, a partir do que a ferramenta
reportar. Retrospectivo e confiável vale mais que preditivo e inventado.

### `execucao.encadeamento`

| Valor | Efeito |
|---|---|
| `automatico` | `k-spec` → `k-plan` → `k-task` seguem sem perguntar. As paradas que sobram são as decisões reais: entrevista da spec e escolha da opção técnica |
| `manual` | cada etapa para no fim e informa a próxima |

Campo único, lido pelas duas etapas. O modo de execução (`greenfield`/`legado`) governa
granularidade e autonomia; **não** governa encadeamento. Misturar os dois fazia o `k-spec`
decidir com base num modo que só o `k-plan` define.

### `commit.revisao_subagente`

| Valor | Quando dispara |
|---|---|
| `sempre` | todo diff de código |
| `por_limiar` | diff de código acima de `commit.revisao_limiar` |
| `nunca` | desligada |

Padrão `por_limiar`. Revisão por subagente é o segundo maior consumo do kit, depois do
`k-scan`, e num diff de três linhas ela quase sempre repete o que lint e testes já disseram.
O limiar existe para gastar o subagente onde ele tem chance de achar algo que o gate não
acha.

### `modelos`

Aplicado onde a ferramenta permite: subagente costuma aceitar modelo próprio, a etapa
principal nem sempre. Onde não dá para impor, vale como recomendação registrada — e a
economia só é afirmada depois de aparecer no baseline.

---

## Validação, precedência e migração

O `k-init` **executa** cada comando antes de gravar. Comando que não roda não entra: contrato
com comando quebrado é pior que campo vazio, porque a skill confia nele e falha no meio do
fluxo. Comando que roda e sai diferente de zero é válido — o projeto é que está sujo, e o
`k-init` reporta sem corrigir.

Precedência: contrato → convenção documentada do projeto → padrão do núcleo. Nada abaixo
sobrescreve o que está acima.

`kit_versao` diferente de `.ia-kit/VERSAO`: modo atualização, com diff campo a campo,
confirmação, e as respostas anteriores preservadas. O esquema legível por máquina está em
`.ia-kit/esquema.yml`, e é contra ele que o `k-init` confere campo órfão, campo ausente e
campo removido. O que cada bump de versão promete, e o que o instalador preserva:
`instalacao.md`.
