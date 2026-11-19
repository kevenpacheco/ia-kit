# k-verify

Portões determinísticos de qualidade. Quarta etapa do fluxo: `/k-spec` → `/k-execute` → `/k-review` → **`/k-verify`** → `/k-commit`.

## O que faz

O agente não declara pronto: prova. Cada item do checklist precisa de evidência de execução real nesta sessão.

1. Roda lint, tipos/build, testes e mutação (se o projeto tiver).
2. Valida telas via Playwright MCP quando a mudança toca interface.
3. Passa por um verificador independente, que checa se cada teste realmente falharia se a regra fosse falsa e tenta valores que ninguém citou.
4. Grava `validation-report.md` amarrado ao código (`HEAD`, hash do diff e dos não rastreados).

## Quando usar

Antes de declarar qualquer trabalho concluído e antes do `/k-commit`.

## Uso

```
/k-verify [slug]
```

Os comandos vêm da seção **Comandos do Projeto & Sensores** do `CLAUDE.md`. Se faltar algum, a skill pergunta uma vez.

## Produz

- `validation-report.md` com portões, evidência por item (a linha real impressa pelo teste) e `Resultado: APROVADO | REPROVADO`.
- Itens `[x]` no checklist, só para os que têm evidência.

APROVADO exige todos os portões verdes, 100% do checklist e nenhum achado do verificador. Sem Playwright MCP, itens de tela ficam `não verificado`.

## Encaminhamento

- REPROVADO: `/k-execute` e depois `/k-verify` de novo (limite de duas rodadas por spec).
- APROVADO: `/k-commit`.

Não altera código de aplicação.
