# Contrato do projeto — `.ia-kit/contrato.yml`

Declara o que o kit precisa saber sobre este projeto. Substitui prosa por campo: skill não
adivinha comando, não infere convenção, não reinterpreta instrução a cada invocação.

**Regra central:** campo vazio faz a skill **parar e perguntar**. Nunca chutar.

---

## Esquema

```yaml
kit_versao: 2.0.0-alpha.1          # versão do núcleo que gerou este contrato
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
  seguranca: <cmd>                 # obrigatório para o gate D10

git:
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
  teto_tokens_tarefa: 300000       # estourou: para e devolve ao humano
  tentativas_gate: 2
  limiar_promocao:                 # acima disso, k-commit sugere abrir um fluxo
    arquivos: 5
    linhas: 150

commit:
  idioma: pt-BR
  atribuicao_ia: false             # true libera rodapé de IA na mensagem

shipping:
  automatico: false                # true: push + PR ao encerrar o fluxo, sem perguntar
  alvo_pr: main                    # base do PR; vazio faz perguntar a cada vez
  pr_draft_quando: [achado_aberto, modo_legado]
  merge: manual                    # nunca automático

modelos:
  forte: <id ou alias>             # k-plan, k-execute
  barato: <id ou alias>            # k-scan, sumarização, refutação, busca
```

---

## Campos

| Campo | Obrigatório | Quem usa | Se faltar |
|---|---|---|---|
| `kit_versao` | sim | `k-init` | migração não roda |
| `ferramentas` | sim | `k-init` | shim não é regenerado |
| `projeto.nome` | sim | corpo de PR, commit | pergunta |
| `projeto.stack` | sim | `k-plan`, `k-task` | pergunta |
| `specs.raiz` | sim | todo o fluxo | pergunta |
| `comandos.lint` | sim | gate 1 | gate para |
| `comandos.teste_unit` | sim | gate 2 | gate para |
| `comandos.teste_integracao` | não | gate 2 | camada ignorada |
| `comandos.suite` | sim | encerramento | encerramento para |
| `comandos.seguranca` | sim | gate 3 | **gate para — ver abaixo** |
| `git.branch_principal` | sim | `k-spec`, `k-plan` | pergunta |
| `git.branches_protegidas` | sim | `k-execute` | assume `[main]` e avisa |
| `git.prefixos` | sim | `k-plan` | usa o padrão da tabela |
| `execucao.modo_padrao` | sim | `k-plan` | assume `evolucao` |
| `execucao.teto_tokens_tarefa` | sim | `k-execute` | sem teto, avisa |
| `execucao.limiar_promocao` | sim | `k-commit` | não sugere promoção |
| `commit.idioma` | sim | `k-commit` | assume `pt-BR` |
| `commit.atribuicao_ia` | sim | `k-commit` | assume `false` |
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

O `k-execute` então **avisa em toda invocação** até o campo ser preenchido. Ele não bloqueia
o trabalho — bloquear o fluxo inteiro por falta de ferramenta empurraria o time a remover o
gate. Avisar de forma persistente mantém a dívida visível.

Candidatos por stack, em ordem de preferência do detector:

| Stack | Candidatos |
|---|---|
| JavaScript / TypeScript | `semgrep --config auto`, `npm audit --audit-level=high` |
| Python | `semgrep --config auto`, `bandit -r <src>` |
| Go | `gosec ./...`, `govulncheck ./...` |
| PHP | `semgrep --config auto` |
| Qualquer um | `gitleaks detect`, `trivy fs .` |

---

## Validação

O `k-init` **executa** cada comando antes de gravar. Comando que não roda não entra no
contrato — contrato com comando quebrado é pior que campo vazio, porque a skill confia nele
e falha no meio do fluxo.

- Comando falhou por não existir: campo fica vazio, com o motivo registrado.
- Comando falhou por teste vermelho ou lint sujo: **é considerado válido** (ele roda; o
  projeto é que está sujo). O `k-init` reporta o estado sem tentar corrigir.

---

## Precedência

1. Contrato (`.ia-kit/contrato.yml`)
2. Convenção documentada do projeto
3. Padrão do núcleo

Nada abaixo sobrescreve o que está acima.

---

## Migração entre versões

`kit_versao` diferente do núcleo instalado: o `k-init` roda em modo atualização — mostra
campo por campo o que muda, pede confirmação, preserva o que o projeto já respondeu. Nunca
sobrescreve contrato existente sem diff na tela.
