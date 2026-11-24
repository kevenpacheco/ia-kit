# ia-kit

Skills do Claude Code para um fluxo de desenvolvimento **Spec-Lean**: gastar onde importa — entender e decidir o que fazer, com o modelo mais forte — e transformar isso num contrato (plano + testes de aceite travados) que modelos menores executam e validam com pouco erro.

```
/k-discover → /k-plan → /k-build → /k-review → /k-verify → /k-commit
```

| Skill | O que faz | Modelo |
|---|---|---|
| `k-discover` | Investiga o código, entrevista você em rodadas até não restar decisão aberta e grava o **quê**: `contexto.md`, `spec.md` e `checklist.md` com IDs, com a sua aprovação | sessão em Opus |
| `k-plan` | Grava o **como** em `plan.md` (mapa de arquivos, padrões a copiar, comandos, passos), cria a branch, escreve os testes de aceite falhando e trava o hash deles; uma simulação fria aponta o que ainda exigiria adivinhar | sessão em Opus |
| `k-build` | Segue o plano até os testes de aceite ficarem verdes, sem alterá-los e sem sair do mapa; o que o plano não cobre vira `duvidas.md` | `sonnet` |
| `k-review` | Code review por quatro subagentes em paralelo (padrões e aderência à spec e ao plano), consolidado em `review.md` | `sonnet` |
| `k-verify` | Confere o contrato (hashes, escopo, um teste por ID), roda lint, tipos, testes e E2E, passa por um verificador independente e grava `validation-report.md` | `haiku` + verificador `sonnet` |
| `k-commit` | Confere os portões, garante a branch e commita em Conventional Commits (pt-BR) | sessão |
| `k-retro` | Fora do fluxo: transforma os achados de uma feature em guardrails e padrões de código | sessão |
| `k-prune` | Fora do fluxo: audita `CLAUDE.md` e skills e propõe poda | sessão |

Blocker no review ou reprovação no verify volta para `/k-build`, no máximo duas rodadas por spec. Dúvida que o plano não responde volta para `/k-plan` (técnica) ou `/k-discover` (produto). O processo se ajusta ao tamanho: pequeno (até ~3 arquivos) leva checklist e plano dentro do `spec.md` e pula o `/k-plan`; grande (mais de ~8 itens no checklist) é dividido em fatias, uma por sessão.

### Modelos e sessões

`k-build`, `k-review` e `k-verify` fixam o modelo no frontmatter (`model:`). O Claude Code aplica esse override só no turno que invoca a skill, o que basta para etapas autônomas. `k-discover` e `k-plan` são conversas de vários turnos, então não fixam modelo: abra a sessão já no modelo mais forte (`/model`).

Abra **uma sessão nova por etapa**. Cada etapa lê só os artefatos da anterior, e trocar de modelo no meio de uma sessão longa descarta o cache do contexto acumulado.

## Instalar

Na raiz do projeto que vai usar as skills (requer Node.js):

```sh
npx skills add kevenpacheco/ia-kit -a claude-code -s '*' -y
```

As skills são copiadas para `.claude/skills/` e a versão instalada fica registrada em `skills-lock.json`. Commite os dois.

| Quero... | Comando |
|---|---|
| ver as skills disponíveis | `npx skills add kevenpacheco/ia-kit --list` |
| instalar só algumas | `npx skills add kevenpacheco/ia-kit -a claude-code -s k-discover k-plan` |
| instalar para todos os meus projetos | acrescente `-g` (vai para `~/.claude/skills/`) |
| fixar uma versão | `npx skills add kevenpacheco/ia-kit@v4.0.0 -a claude-code -s '*' -y` |

Sem `-a`, o CLI pergunta para quais ferramentas instalar.

## Atualizar

```sh
npx skills check    # mostra atualizações disponíveis e skills editadas localmente
npx skills update   # atualiza as skills instaladas
```

## CLAUDE.md do projeto

O instalador **não** cria nem altera o `CLAUDE.md`. As skills leem dele a seção **Comandos do Projeto & Sensores** (testes, lint, build, E2E). Para tê-la, copie [`modelo-CLAUDE.md`](modelo-CLAUDE.md) para a raiz do projeto como `CLAUDE.md` (ou `AGENTS.md`) e preencha os campos `<...>`. Sem essa seção, o `/k-verify` pergunta cada comando uma vez.

Opcionais, lidos quando existem: [`modelo-CODING_STANDARDS.md`](modelo-CODING_STANDARDS.md) (copie como `CODING_STANDARDS.md`; o `/k-review` o usa e o `/k-retro` o alimenta), `GLOSSARY.md` e `docs/adr/` (mantidos pelo `/k-discover`).

## Migrar da v3

| v3 | v4 |
|---|---|
| `/k-spec` | `/k-discover` (agora grava também `contexto.md` e numera o checklist) |
| — | `/k-plan` (novo: `plan.md`, branch e testes de aceite travados por hash) |
| `/k-execute` | `/k-build` (segue o plano; não altera testes de aceite nem sai do mapa) |

Depois de `npx skills update`, apague `.claude/skills/k-spec` e `.claude/skills/k-execute` se continuarem lá, e atualize a seção de fluxo do seu `CLAUDE.md` a partir do [`modelo-CLAUDE.md`](modelo-CLAUDE.md). Spec da v3 em andamento: rode `/k-discover <slug>` para numerar o checklist e completar os exemplos, depois `/k-plan <slug>` antes do `/k-build`.

## Versões anteriores

O fluxo v3 (`k-spec`, `k-execute`, `k-review`, `k-verify`, `k-commit`, `k-retro`, `k-prune`) está na tag `v3.0.0`:

```sh
npx skills add kevenpacheco/ia-kit@v3.0.0 -a claude-code -s '*' -y
```

O fluxo v1 (`k-spec`, `k-plan`, `k-task`, `k-execute`, `k-scan`, `k-commit`) está na branch `v1` e na tag `v1.0.0`:

```sh
npx skills add kevenpacheco/ia-kit@v1.0.0 -a claude-code -s '*' -y
```

## Desenvolver no kit

As skills ficam em `skills/<nome>/SKILL.md`, com `name` e `description` no frontmatter. **Sempre coloque o `description:` entre aspas duplas** — como é texto em pt-BR, costuma ter `: ` (dois-pontos + espaço), que num valor YAML sem aspas quebra o parse e faz o `npx skills add` pular a skill em silêncio (sem erro visível). Para testar uma mudança antes de publicar, instale a partir do clone local num projeto de teste:

```sh
npx skills add <caminho-do-clone> -a claude-code -s '*' -y
```

Publicar uma versão: depois do merge no `main`, crie a tag `vX.Y.Z` e faça `git push --tags`.
