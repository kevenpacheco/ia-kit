# k-commit

Validação final e commit. Última etapa do fluxo: `/k-spec` → `/k-execute` → `/k-review` → `/k-verify` → **`/k-commit`**.

## O que faz

1. Confere os portões: `review.md` sem blockers, `validation-report.md` APROVADO, checklist completo e código idêntico ao verificado (compara `HEAD` e hashes).
2. Confere o repositório: sem temporários, rascunhos ou segredos.
3. Garante a branch certa e atualizada com `origin/main` (conflito nunca é resolvido sozinho).
4. Cria commits pequenos em Conventional Commits, em português.
5. Pergunta antes de push + PR; merge só com aprovação explícita para aquele PR.

## Quando usar

Depois do `/k-verify`, ou sempre que for commitar, abrir PR ou mesclar. Commit avulso, sem spec, pula a conferência dos portões e avisa você.

## Uso

```
/k-commit [slug]
```

## Formato da mensagem

```
<tipo>(<escopo>): <descrição no infinitivo, minúscula, sem ponto, até 72 caracteres>
```

Tipos: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `perf`, `style`.

## Regras

- Nunca commita direto na `main`.
- Nunca usa `git add .` / `-A`, `--no-verify` ou `--no-gpg-sign`.
- Nunca menciona IA na mensagem.
- Marca o item do `roadmap.md` como `[x]` no mesmo commit, se existir.
