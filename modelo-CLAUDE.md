# CLAUDE.md

> Modelo do ia-kit. Copie para a raiz do projeto como `CLAUDE.md` (ou `AGENTS.md`) e preencha os campos `<...>`.
> Este arquivo é carregado em toda sessão: mantenha aqui só o que vale sempre e ponteiros. Procedimentos de cada fase ficam nas skills (`.claude/skills/`), carregadas sob demanda.

## 1. Visão Geral e Princípios
Este repositório adota o modelo **Spec-Lean (Spec-Driven + Progressive Disclosure)** com revisão por **subagentes** e sensores **determinísticos**.

* **Contexto Enxuto:** Detalhe operacional vive nas skills; não copie regra de skill para cá.
* **Autoverificação:** O código só é considerado pronto após passar nos sensores da seção 2 e em 100% do checklist da spec.
* **Isolamento:** A implementação lê apenas os artefatos da spec. Abra sessão nova entre `/k-spec` e `/k-execute` quando o contexto já estiver pesado; continuar na mesma preserva o porquê das decisões.

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

`/k-spec` → `/k-execute` → `/k-review` → `/k-verify` → `/k-commit`

Blocker no review ou reprovação no verify volta para `/k-execute`, no máximo duas rodadas por spec; na segunda reprovação, pare e leve ao usuário.

Tamanho do trabalho: **pequeno** (até ~3 arquivos) usa spec de uma linha e review só de aderência à spec; **médio** segue o fluxo completo; **grande** (mais de ~8 itens no checklist) é dividido em fatias, uma por sessão.

| Skill | Quando | Lê | Produz |
|---|---|---|---|
| `/k-spec` | início de qualquer trabalho que vire commit | pedido, código, este arquivo, `GLOSSARY.md`, `docs/adr/` | `spec.md` aprovado, `checklist.md` |
| `/k-execute` | spec aprovada | `spec.md`, `checklist.md` | branch, código + testes |
| `/k-review` | implementação com testes verdes | diff vs merge-base com `main`, `spec.md`, `CODING_STANDARDS.md` | `review.md` |
| `/k-verify` | review sem blockers | `checklist.md`, seção 2 | `validation-report.md`, checklist marcado |
| `/k-commit` | verify aprovado | `review.md`, `validation-report.md` | commits (Conventional Commits) |
| `/k-retro` | depois do commit, fora do fluxo | `review.md`, `validation-report.md` | guardrails e padrões novos |
| `/k-prune` | periodicamente, fora do fluxo | este arquivo, `.claude/skills/` | proposta de poda |

---

## 4. Convenções de Código
Padrões de código ficam em `CODING_STANDARDS.md` (lido pelo `/k-review`). Toda funcionalidade ou alteração vem com teste.

---

## 5. Regra de Ouro
Nunca declare uma tarefa como "concluída" sem antes executar `/k-verify` e ter 100% dos itens do checklist aprovados com evidência de testes reais e determinísticos.
