---
name: k-commit
description: Validação final e commit. Confirma que review.md não tem blockers e que validation-report.md está APROVADO, garante a branch certa e cria commits em Conventional Commits (pt-BR); push, PR e merge só com confirmação do usuário. Use depois de /k-verify, ou sempre que for commitar, abrir PR ou mesclar no projeto.
argument-hint: "[slug]"
---

# k-commit — Validação Final & Commit

Fluxo: k-discover → k-plan → k-build → k-review → k-verify → **k-commit**.

## Procedimento

### 1. Conferir os portões
Na pasta da spec (`docs/specs/*-<slug>/`):
- `review.md` sem itens em `🔴 Blockers`.
- `validation-report.md` com `Resultado: APROVADO` e todos os itens do checklist marcados (`checklist.md`, ou a seção `## Checklist` do `spec.md`).
- Código igual ao verificado: recalcule `HEAD`, hash do diff e hash dos não rastreados exatamente como o `k-verify` (seção **Código verificado** do relatório) e compare. Divergiu: rode `/k-verify` de novo.

Faltou algo: pare e diga qual skill rodar. Commit avulso, sem spec (fora do fluxo): pule este passo e avise o usuário.

### 2. Conferir o repositório
`git status`, `git diff` e `git log --oneline -5`. Nenhum arquivo temporário, rascunho ou segredo pode entrar no commit.

### 3. Garantir a branch
O `k-plan` já cria a branch `<prefixo>/<slug>`. Aqui só confira:
- **Em branch de trabalho:** confirme que ela combina com a mudança e que contém `origin/main` (`git fetch origin main && git merge-base --is-ancestor origin/main HEAD`). Se estiver desatualizada, faça merge de `origin/main`. Conflito: nunca resolva sozinho; mostre e pergunte arquivo por arquivo.
- **Na `main`** (fora do fluxo): crie `<prefixo>/<slug>` pelo `tipo` (`feat/`, `fix/`, `refactor/`, `chore/`, `docs/`) levando as alterações; não rode `git pull` com a árvore suja.

### 4. Commitar
Commits pequenos e focados, um por unidade lógica (spec com fatias: um commit por fatia). Adicione arquivos pelo nome. A pasta da spec entra junto com o código ou num commit `docs(spec)` próprio.

```text
<tipo>(<escopo>): <descrição no infinitivo, minúscula, sem ponto, até 72 caracteres>

<corpo opcional: o que mudou e por quê; spec em docs/specs/<ts>-<slug>/>

- Checklist de aceitação verificado via k-verify
- Revisão de código concluída sem blockers via k-review
```

Tipos: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `perf`, `style`. Passe a mensagem via HEREDOC no `git commit -m`.

### 5. Fechar
1. Se existir `roadmap.md`, marque o item trabalhado como `[x]` no mesmo commit.
2. Pergunte se é hora de push + PR. Só siga com o "sim"; imprima a URL do PR.
3. Merge apenas com aprovação explícita para aquele PR: `gh pr merge <n> --merge --delete-branch`, depois `git checkout main && git pull`.

## Regras
- Mensagens em português brasileiro.
- Nunca commitar direto na `main`.
- Nunca `git add .` / `git add -A`, `--no-verify` ou `--no-gpg-sign`.
- Nunca mencionar IA ou assistente na mensagem, nem `Co-Authored-By` de IA.
