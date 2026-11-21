# k-plan

Plano de execução e testes de aceite. Segunda etapa do fluxo: `/k-discover` → **`/k-plan`** → `/k-build` → `/k-review` → `/k-verify` → `/k-commit`.

## O que faz

Transforma a spec aprovada (o **quê**) num plano que um modelo menor executa sem decidir nada (o **como**): mapa de arquivos, padrão do repositório a copiar, interfaces, comandos exatos e passos ligados aos IDs do checklist. Cria a branch e escreve os testes de aceite falhando, com o ID do checklist no nome, e grava o hash deles: dali em diante o executor não pode alterá-los.

No fim, um subagente frio, no modelo do executor, lê só o plano e diz o que teria que adivinhar. Lacuna técnica corrige o plano; lacuna de produto vai para `duvidas.md` e volta ao `/k-discover`.

Rode numa sessão nova com o modelo mais forte (Opus): o planejador só conhece o que a spec diz, e isso testa se ela está completa.

## Quando usar

- Depois do `/k-discover` (trabalho médio ou grande).
- Quando a spec mudou e o `/k-build` recusou por `spec_hash` divergente.
- Quando o `/k-build` parou com dúvida técnica em `duvidas.md`.

## Uso

```
/k-plan [slug] [fatia]
```

## Lê

`spec.md`, `checklist.md`, `contexto.md`, `duvidas.md` e o código citado no contexto.

## Produz

- `plan.md` na pasta da spec, com `spec_hash` e o hash de cada teste de aceite no frontmatter.
- Branch `<tipo>/<slug>`.
- Testes de aceite vermelhos pelo motivo certo (e, se a linguagem exigir, esqueletos de interface sem lógica).
- `duvidas.md`, se houver decisão de produto em aberto.

## Não faz

Não implementa lógica de produção, não altera a spec e não faz commit.

**Próximo passo:** `/k-build <slug>` em sessão nova
