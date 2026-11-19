# k-retro

Retro de uma feature e geração de guardrails. Fora do fluxo principal: roda depois do `/k-commit`.

## O que faz

Lê `review.md` e `validation-report.md` (inclusive rodadas anteriores via `git log -p`) e transforma os erros reais em proteção para a próxima feature. Só entra aprendizado baseado em achado concreto da spec, nunca preferência genérica.

| Tipo de achado | Vira |
|---|---|
| Mecânico (sintaxe, API proibida, import, local de arquivo) | check automático: regra de lint, hook de pre-commit ou job de CI |
| Julgamento (o linter não pega) | padrão em `CODING_STANDARDS.md`, lido pelo `/k-review` |
| Repositório sem hook nem CI de lint, tipos e testes | já é um achado |

Descarta o que o repositório já força e o que é pontual demais para se repetir.

## Quando usar

Depois do `/k-commit` de uma feature. Para podar regras antigas, use `/k-prune`.

## Uso

```
/k-retro [slug]
```

Sem slug, usa a pasta mais recente de `docs/specs/`.

## Resultado

Uma tabela de propostas ordenada por severidade. Você escolhe quais aplicar (números / todos / nenhum) e só os aprovados são aplicados, com o menor texto possível. O commit é feito pelo `/k-commit`.
