# CLAUDE.md

> Modelo do ia-kit. Copie para a raiz do projeto como `CLAUDE.md` (ou `AGENTS.md`) e preencha os campos `<...>`.
> Este arquivo é carregado em toda sessão: mantenha aqui só o que vale sempre e ponteiros. Procedimentos de cada fase ficam nas skills (`.claude/skills/`), carregadas sob demanda.

## 1. Visão Geral e Princípios
Este repositório adota o modelo **Spec-Lean (Spec-Driven + Progressive Disclosure)** com revisão por **subagentes** e sensores **determinísticos**.

* **Contexto Enxuto:** Detalhe operacional vive nas skills; não copie regra de skill para cá.
* **Autoverificação:** O código só é considerado pronto após passar nos sensores da seção 2 e em 100% do checklist da spec.
* **Isolamento:** Cada etapa lê apenas os artefatos da anterior. Abra uma sessão nova por etapa; `/k-discover` e `/k-plan` no modelo mais forte, as demais fixam o próprio modelo.

---

## 2. Comandos do Projeto & Sensores
Fonte única dos comandos que as skills executam. Preencha por projeto e remova o que não se aplica. Se faltar um comando, a skill pergunta uma vez — registre a resposta aqui.

| Sensor | Comando |
|---|---|
| Testes unitários e integração | `<ex.: npm test / pytest>` |
| Lint & formatação | `<ex.: npm run lint / flake8>` |
| Tipos & build | `<ex.: tsc --noEmit / npm run build>` |
| Testes de mutação (opcional) | `<ex.: npx stryker run / mutmut run>` |
| Subir a aplicação para E2E | `<ex.: npm run dev>` |
| Automação visual (E2E) | Playwright via MCP |

---

## 3. Fluxo de Skills
Artefatos de cada trabalho ficam em `docs/specs/<AAAAMMDD-HHMMSS>-<slug>/`.

`/k-discover` → `/k-plan` → `/k-build` → `/k-review` → `/k-verify` → `/k-commit`

Blocker no review ou reprovação no verify volta para `/k-build`, no máximo duas rodadas por spec; na segunda reprovação, pare e leve ao usuário. O que o plano não responde vira `duvidas.md` e volta para `/k-plan` (técnico) ou `/k-discover` (produto).

Tamanho do trabalho: **pequeno** (até ~3 arquivos) leva checklist e plano dentro do `spec.md`, pula o `/k-plan` e tem review só de aderência à spec; **médio** segue o fluxo completo; **grande** (mais de ~8 itens no checklist) é dividido em fatias, uma por sessão.

| Skill | Quando | Lê | Produz |
|---|---|---|---|
| `/k-discover` | início de qualquer trabalho que vire commit | pedido, código, este arquivo, `GLOSSARY.md`, `docs/adr/` | `contexto.md`, `spec.md` aprovado, `checklist.md` com IDs |
| `/k-plan` | spec aprovada | `spec.md`, `checklist.md`, `contexto.md` | `plan.md`, branch, testes de aceite vermelhos (hash travado) |
| `/k-build` | plano pronto | `plan.md`, `spec.md`, testes de aceite | código + testes unitários, testes de aceite verdes |
| `/k-review` | implementação com testes verdes | diff vs merge-base com `main`, `spec.md`, `plan.md`, `CODING_STANDARDS.md` | `review.md` |
| `/k-verify` | review sem blockers | `checklist.md`, `plan.md`, seção 2 | `validation-report.md`, checklist marcado |
| `/k-commit` | verify aprovado | `review.md`, `validation-report.md` | commits (Conventional Commits) |
| `/k-retro` | depois do commit, fora do fluxo | `review.md`, `validation-report.md` | guardrails e padrões novos |
| `/k-prune` | periodicamente, fora do fluxo | este arquivo, `.claude/skills/` | proposta de poda |

---

## 4. Convenções de Código
Padrões de código ficam em `CODING_STANDARDS.md` (lido pelo `/k-review`). Toda funcionalidade ou alteração vem com teste.

---

## 5. Regra de Ouro
Nunca declare uma tarefa como "concluída" sem antes executar `/k-verify` e ter 100% dos itens do checklist aprovados com evidência de testes reais e determinísticos.
