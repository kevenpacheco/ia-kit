# k-plan — como usar

Etapa 2 de 4: `k-spec` → **k-plan** → `k-task` → `k-execute`.

## Invocacao

```
/k-plan
/k-plan corrigir-crop-banner
/k-plan docs/specs/20260807-143205-corrigir-crop-banner   # ou documentation/specs/..., conforme a raiz detectada
```

Sem argumento, pega a spec mais recente que ainda nao tem `plan.md`. Se houver ambiguidade, lista as candidatas e pergunta.

## O que ela faz

1. Le o `spec.md` e usa o `tipo` para decidir o que investigar.
2. Dispara subagentes de leitura **em paralelo** (fluxo atual, reuso, consumidores, historico, cobertura).
3. Em tipo `bug`, roda a grade de suspeitas e **prova a causa raiz** com `arquivo:linha`.
4. Classifica: **legado puro** ou **contexto em evolucao** (conforme convencao do projeto, se documentada, senao o criterio padrao da skill).
5. Monta 2-3 opcoes reais com trade-off e **espera voce escolher**.
6. Escreve `plan.md` ao lado do `spec.md`.
7. Cria a branch `<prefixo>/<slug>` a partir da `main` atualizada e commita `spec.md` + `plan.md`.

## Prefixo da branch, por tipo

| Tipo | Prefixo |
|---|---|
| `feature` | `feat/` |
| `bug` | `fix/` |
| `refactor` | `refactor/` |
| `chore` | `chore/` |
| `docs` | `docs/` |

O slug da branch e o mesmo do diretorio da spec, sem o timestamp. E por ele que `k-task` e `k-execute` reencontram a spec.

## O que ela nao faz

- Nao toca codigo de aplicacao.
- Nao quebra em tarefas — isso e `k-task`.
- Nao faz push. O push e unico, no fim do `k-execute`.

## Onde ele para e pergunta

- Se houver alteracao local nao commitada (nao faz `stash` sozinho).
- Se a causa raiz nao puder ser provada.
- Sempre, antes de gravar o plano: mostra causa raiz e opcoes e espera sua escolha.

## Saida

```
Plano criado: docs/specs/20260807-143205-corrigir-crop-banner/plan.md
Branch fix/corrigir-crop-banner criada. Commit: docs(spec): corrigir crop de banner
Proximo passo: /k-task
```
