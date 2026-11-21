# k-review

Code review multi-agente em paralelo. Quarta etapa do fluxo: `/k-discover` → `/k-plan` → `/k-build` → **`/k-review`** → `/k-verify` → `/k-commit`.

## O que faz

Quem implementou tem viés de confirmação. Quatro subagentes somente de leitura (`sonnet`) auditam o diff contra o merge-base com `origin/main` e o resultado é consolidado em `review.md`.

| Revisor | Foco |
|---|---|
| Segurança | OWASP Top 10, segredos, sanitização, autenticação e autorização |
| Arquitetura (eixo padrões) | convenções do projeto, `CODING_STANDARDS.md`, camadas, smells |
| Aderência à spec (eixo spec) | o que falta, o que ninguém pediu, arquivo fora do mapa do `plan.md`, o que está errado |
| Performance & testes | N+1, perda de desempenho, caminho novo sem teste |

Trabalho pequeno: roda só o revisor de aderência à spec.

## Quando usar

Depois do `/k-build` e antes do `/k-verify`, ou para revisar mudanças locais antes de commitar.

## Uso

```
/k-review [slug]
```

## Produz

`review.md` na pasta da spec (sobrescreve a rodada anterior), com:

- 🔴 **Blockers**: impedem o commit
- 🟡 **Should fix**: decisão sua
- 🔵 **Nice to have**

Cada achado traz `arquivo:linha`, o revisor e o eixo.

## Encaminhamento

- Com blockers: `/k-build` para corrigir e `/k-review` de novo (limite de duas rodadas por spec).
- Sem blockers: `/k-verify`.
