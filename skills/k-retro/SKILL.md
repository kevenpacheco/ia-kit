---
name: k-retro
description: Retro de uma feature. Lê review.md e validation-report.md da spec e transforma os erros reais em proteção para a próxima, com check automático (lint, hook, CI) para erro mecânico e padrão em CODING_STANDARDS.md para questão de julgamento. Use depois do /k-commit de uma feature, fora do fluxo; para podar regras antigas use /k-prune.
argument-hint: "[slug]"
---

# k-retro — Retro & Guardrails

Fora do fluxo: roda depois do `/k-commit`. Só entra aprendizado com base em achado real da spec, nunca preferência genérica.

## Procedimento

### 1. Coletar
Localize a spec pelo slug ou pela pasta mais recente em `docs/specs/`. Leia `review.md` e `validation-report.md` (inclusive o que reprovou em rodadas anteriores, via `git log -p` da pasta se preciso).

### 2. Classificar cada achado recorrente ou grave
- **Mecânico** (padrão sintático, API proibida, forma de import, local de arquivo): vira check automático — regra de lint, hook de pre-commit ou job de CI.
- **Julgamento** (o linter não pega): vira padrão de código em `CODING_STANDARDS.md`, lido pelo `k-review`.
- **Sem guardrail:** repositório sem hook nem CI rodando lint, tipos e testes já é um achado.

Descarte o que o repositório já força e o achado pontual sem chance de repetir.

### 3. Propor e aplicar
```
| # | Severidade | Achado | Tipo | Proposta |
```
Ordene por severidade. Pergunte quais aplicar (números / todos / nenhum) e aplique só os aprovados, com o menor texto possível. Commite pelo `/k-commit`.
