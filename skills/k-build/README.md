# k-build

Implementação a partir do plano. Terceira etapa do fluxo: `/k-discover` → `/k-plan` → **`/k-build`** → `/k-review` → `/k-verify` → `/k-commit`.

## O que faz

Segue os passos do `plan.md` até os testes de aceite, escritos pelo `/k-plan`, ficarem verdes. Copia os padrões indicados, usa as interfaces como escritas e não decide nada que o plano não decidiu: o que falta vira `duvidas.md` e a execução para. Roda em `sonnet` (frontmatter `model:`), porque a tarefa é mecânica.

## Quando usar

- Depois do `/k-plan` (ou do `/k-discover`, em trabalho pequeno).
- Para corrigir blockers do `/k-review` ou reprovações do `/k-verify`.

## Uso

```
/k-build [slug] [fatia]
```

Sem slug, usa a única spec pendente ou lista as candidatas. Spec com fatias: uma fatia por sessão.

## Lê

`plan.md`, `spec.md`, checklist, testes de aceite, arquivos do mapa e, se existirem, `review.md` e `validation-report.md`.

## Regras principais

- Recusa spec sem aprovação, falta de `plan.md`, `spec_hash` divergente (a spec mudou depois do plano) e `duvidas.md` pendente.
- Nunca altera teste de aceite (o `/k-verify` confere o hash) nem toca arquivo fora do mapa do plano.
- Testes unitários novos com valor esperado literal; mock apenas em fronteira do sistema.
- Progresso, decisões do usuário e achados fora do escopo vão para `## Execução` do `plan.md`; o `spec.md` não muda.
- Máximo de duas rodadas de correção por spec.

**Próximo passo:** `/k-review`
