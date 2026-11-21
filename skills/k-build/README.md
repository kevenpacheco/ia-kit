# k-execute

Implementação contínua a partir de uma spec aprovada. Segunda etapa do fluxo: `/k-spec` → **`/k-execute`** → `/k-review` → `/k-verify` → `/k-commit`.

## O que faz

Cria a branch `<tipo>/<slug>` a partir de `origin/main` e implementa teste-primeiro, um item do checklist por vez: escreve o teste, vê falhar, implementa o mínimo para passar. Não pede aprovação a cada arquivo.

## Quando usar

- Depois do `/k-spec`.
- Para corrigir blockers do `/k-review` ou reprovações do `/k-verify`.

## Uso

```
/k-execute [slug] [fatia]
```

Sem slug, usa a única spec pendente ou lista as candidatas. Spec com fatias: uma fatia por sessão.

## Lê

`spec.md` e checklist inteiros, `review.md` e `validation-report.md` (se existirem) e os arquivos citados em Decisões Técnicas.

## Regras principais

- Recusa spec sem `aprovado_em`.
- Testa só os Pontos de teste da spec; mock apenas em fronteira do sistema.
- Valor esperado vem da spec, nunca recalculado como o código calcula.
- Nunca enfraquece asserção, apaga teste ou usa skip para ficar verde.
- Achado fora do escopo vai para `## Achados fora do escopo` da spec, sem corrigir.
- Decisões tomadas durante a execução são gravadas em `## Histórico de Decisões`.
- Máximo de duas rodadas de correção por spec.

**Próximo passo:** `/k-review`
