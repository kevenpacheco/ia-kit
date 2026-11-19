# ia-kit

Skills do Claude Code para um fluxo de desenvolvimento **Spec-Lean**: planejar antes de codar, implementar em sessão limpa, revisar com subagentes e só commitar com evidência de que o checklist de aceite passou.

```
/k-spec → /k-execute → /k-review → /k-verify → /k-commit
```

| Skill | O que faz |
|---|---|
| `k-spec` | Investiga o código, entrevista você em rodadas e grava `spec.md` + `checklist.md`, com a sua aprovação |
| `k-execute` | Cria a branch e implementa teste-primeiro a partir da spec |
| `k-review` | Code review por quatro subagentes em paralelo (padrões e aderência à spec), consolidado em `review.md` |
| `k-verify` | Roda lint, tipos, testes e E2E, prova cada item do checklist com a linha real do teste e um verificador independente, e grava `validation-report.md` |
| `k-commit` | Confere os portões, garante a branch e commita em Conventional Commits (pt-BR) |
| `k-retro` | Fora do fluxo: transforma os achados de uma feature em guardrails e padrões de código |
| `k-prune` | Fora do fluxo: audita `CLAUDE.md` e skills e propõe poda |

Blocker no review ou reprovação no verify volta para `/k-execute`, no máximo duas rodadas por spec. O processo se ajusta ao tamanho: pequeno (até ~3 arquivos) usa spec de uma linha; grande (mais de ~8 itens no checklist) é dividido em fatias, uma por sessão.

## Instalar

Na raiz do projeto que vai usar as skills (requer Node.js):

```sh
npx skills add kevenpacheco/ia-kit -a claude-code -s '*' -y
```

As skills são copiadas para `.claude/skills/` e a versão instalada fica registrada em `skills-lock.json`. Commite os dois.

| Quero... | Comando |
|---|---|
| ver as skills disponíveis | `npx skills add kevenpacheco/ia-kit --list` |
| instalar só algumas | `npx skills add kevenpacheco/ia-kit -a claude-code -s k-spec k-execute` |
| instalar para todos os meus projetos | acrescente `-g` (vai para `~/.claude/skills/`) |
| fixar uma versão | `npx skills add kevenpacheco/ia-kit@v3.0.0 -a claude-code -s '*' -y` |

Sem `-a`, o CLI pergunta para quais ferramentas instalar.

## Como usar, passo a passo

Exemplo: adicionar um filtro por data numa listagem.

**0. Preparar (uma vez por projeto).** Instale as skills e copie o [`modelo-CLAUDE.md`](#claudemd-do-projeto) preenchendo os comandos de teste, lint e build.

**1. Planejar: `/k-spec adicionar filtro por data na listagem de pedidos`**
Responda às perguntas (o `/k-spec` só pergunta o que o código não responde). No fim, leia o `spec.md` e o `checklist.md` e diga "sim" para aprovar. Nada é implementado ainda.

**2. Implementar: `/k-execute`**
Abra uma **sessão nova** (`/clear`) se a conversa do planejamento estiver longa. Ele cria a branch e implementa teste-primeiro, sem pedir aprovação a cada arquivo. Termina com os testes verdes.

**3. Revisar: `/k-review`**
Quatro revisores em paralelo geram o `review.md`.
- Com 🔴 blockers: rode `/k-execute` para corrigir e `/k-review` de novo.
- Sem blockers: leia os 🟡 should-fix e decida quais aplicar.

**4. Provar: `/k-verify`**
Roda lint, tipos e testes, prova cada item do checklist e grava o `validation-report.md`.
- REPROVADO: volte para `/k-execute`, depois `/k-verify` de novo.
- APROVADO: siga em frente.

**5. Commitar: `/k-commit`**
Confere tudo, commita em Conventional Commits e pergunta se quer push e PR. O merge só acontece se você aprovar.

**6. Depois (opcional).** `/k-retro` transforma os erros achados em regras de lint ou padrões de código. `/k-prune` poda instruções e skills que ficaram obsoletas.

```
/k-spec ─▶ /k-execute ─▶ /k-review ─▶ /k-verify ─▶ /k-commit
              ▲             │ blocker      │ reprovado
              └─────────────┴──────────────┘
```

Dicas:
- Cada skill diz o próximo passo ao terminar; basta seguir.
- Com mais de uma spec aberta, passe o slug: `/k-execute filtro-por-data`.
- Spec grande vira fatias: rode `/k-execute <slug> <fatia>`, uma por sessão.
- Máximo de duas rodadas de correção por spec; na terceira, o fluxo para e leva a decisão a você.
- Cada skill tem um README em `skills/<skill>/` com os detalhes.

## Atualizar

```sh
npx skills check    # mostra atualizações disponíveis e skills editadas localmente
npx skills update   # atualiza as skills instaladas
```

## CLAUDE.md do projeto

O instalador **não** cria nem altera o `CLAUDE.md`. As skills leem dele a seção **Comandos do Projeto & Sensores** (testes, lint, build, E2E). Para tê-la, copie [`modelo-CLAUDE.md`](modelo-CLAUDE.md) para a raiz do projeto como `CLAUDE.md` (ou `AGENTS.md`) e preencha os campos `<...>`. Sem essa seção, o `/k-verify` pergunta cada comando uma vez.

Opcionais, lidos quando existem: [`modelo-CODING_STANDARDS.md`](modelo-CODING_STANDARDS.md) (copie como `CODING_STANDARDS.md`; o `/k-review` o usa e o `/k-retro` o alimenta), `GLOSSARY.md` e `docs/adr/` (mantidos pelo `/k-spec`).

## Versões anteriores

O fluxo v1 (`k-spec`, `k-plan`, `k-task`, `k-execute`, `k-scan`, `k-commit`) está na branch `v1` e na tag `v1.0.0`:

```sh
npx skills add kevenpacheco/ia-kit@v1.0.0 -a claude-code -s '*' -y
```

## Desenvolver no kit

As skills ficam em `skills/<nome>/SKILL.md`, com `name` e `description` no frontmatter. Para testar uma mudança antes de publicar, instale a partir do clone local num projeto de teste:

```sh
npx skills add <caminho-do-clone> -a claude-code -s '*' -y
```

Publicar uma versão: depois do merge no `main`, crie a tag `vX.Y.Z` e faça `git push --tags`.
