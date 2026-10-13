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
  verificadores: quando_disponivel  # obrigatorio | quando_disponivel | desligado
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

verificacao:
  perfil: padrao                   # rapido | padrao | rigoroso
  rodadas_max: 2                   # teto de rodadas de reprovacao
  injecao_falha: obrigatoria_bug   # obrigatoria_bug | sempre | nunca
  preparar_arvore: <cmd>           # roda na arvore descartavel antes da injecao

shipping:
  automatico: false                # true: push + PR ao encerrar o fluxo, sem perguntar
  alvo_pr: main                    # base do PR; vazio faz perguntar a cada vez
  pr_draft_quando: [achado_aberto, modo_legado, verificacao_ressalva]
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
| `projeto.stack` | sim | `k-plan` | pergunta |
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
| `execucao.verificadores` | nao | `k-init` | assume `quando_disponivel` |
| `verificacao.perfil` | nao | `k-execute` | assume `padrao` |
| `verificacao.rodadas_max` | nao | `k-execute` | assume 2 |
| `verificacao.injecao_falha` | nao | `k-execute` | assume `obrigatoria_bug` |
| `verificacao.preparar_arvore` | nao | `k-execute` | a corrida de controle decide |
| `shipping.automatico` | sim | `k-execute` | assume `false` — pergunta antes de subir |
| `shipping.alvo_pr` | não | `k-execute` | pergunta o alvo a cada PR |
| `shipping.pr_draft_quando` | sim | `k-commit` | PR nunca sai como draft |
| `shipping.merge` | sim | `k-commit` | assume `manual` |
| `modelos.forte` / `modelos.barato` | nao | roteamento | usa o modelo da sessao. Limite de aplicacao: D7 |

### `comandos.seguranca` e `comandos.seguranca_diff`

Campo vazio não é neutro: sem gate de segurança o código entra com a taxa de vulnerabilidade
que a D10 existe para atacar. Vazio, o `k-init` grava `seguranca_pendente` com a data e o
`k-commit` avisa em toda invocação, sem bloquear. `seguranca_diff` é campo próprio porque a
varredura completa leva minutos e é desligada; a incremental leva segundos. Placeholders
`{base}` e `{arquivos}`. Candidatos, invocação incremental e triagem dos achados: `gate.md`.

### `execucao.limites_tarefa`

Sinais **observáveis** de tarefa fora de controle: arquivos lidos, rodadas de ferramenta,
minutos. Não é contagem de token — o agente não lê o próprio consumo de forma confiável.
Estourou qualquer um: para e devolve. Por que estes três sinais, e não outros: D8.

### `execucao.encadeamento`

| Valor | Efeito |
|---|---|
| `automatico` | `k-spec` → `k-plan` seguem sem perguntar. As paradas que sobram são as decisões reais: entrevista da spec e escolha da opção técnica |
| `manual` | cada etapa para no fim e informa a próxima |

Campo único, lido pelas duas etapas. O modo de execução governa granularidade e autonomia;
**não** governa encadeamento — misturar os dois fazia o `k-spec` decidir com base num modo
que só o `k-plan` define.

### `commit.revisao_subagente`

| Valor | Quando dispara |
|---|---|
| `sempre` | todo diff de código |
| `por_limiar` | diff de código acima de `commit.revisao_limiar` |
| `nunca` | desligada |

Padrão `por_limiar`. É o segundo maior consumo do kit, depois do `k-scan`, e num diff de três
linhas repete o que lint e testes já disseram. Não confunda com `verificacao`, abaixo.

---
### `verificacao`

Verificação **não é** `commit.revisao_subagente`. Confundir os dois é o erro de configuração
mais provável desta versão:

| | `commit.revisao_subagente` | `verificacao` |
|---|---|---|
| Quando | a cada commit | uma vez, no fim do fluxo |
| Contra o quê | convenções, simplificação, reuso | os critérios de aceite da spec |
| Quem julga | subagente no contexto do autor | subagente **sem** a sessão do autor |
| Efeito | informativo | **bloqueia** push e PR |

O veredito sai sempre de subagente fresco: skill roda na mesma conversa de quem escreveu o
código, e sem o despacho "verificação independente" é auto-avaliação com outro nome.

`verificacao` ausente — kit anterior à 2.1.0 — faz a verificação **rodar e avisar, sem
bloquear**, até o `k-init` gravar os campos. Mesmo precedente de `comandos.seguranca` vazio.

Perfis e formato do relatório: `verificacao-formato.md`. Injeção de falha:
`injecao-falha.md`. Encerramento e protocolo do verificador: `encerramento.md`. `sh`
ausente: `verificadores.md`.
---

## Validação, precedência e migração

O `k-init` **executa** cada comando antes de gravar. Comando que não roda não entra: contrato
com comando quebrado é pior que campo vazio, porque a skill confia nele e falha no meio do
fluxo. Comando que roda e sai diferente de zero é válido — o projeto é que está sujo, e o
`k-init` reporta sem corrigir.

Precedência: contrato → convenção documentada do projeto → padrão do núcleo. Nada abaixo
sobrescreve o que está acima.

`kit_versao` diferente de `.ia-kit/VERSAO`: modo atualização, com diff campo a campo e as
respostas anteriores preservadas. Quem confere o contrato contra `.ia-kit/esquema.yml` é o
`verificar-contrato.sh`. O que cada bump promete: `instalacao.md`.
