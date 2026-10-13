# CLAUDE.md

> Modelo do ia-kit. Copie para a raiz do projeto como `CLAUDE.md` (ou `AGENTS.md`) e preencha os campos `<...>`.
> Este arquivo é carregado em toda sessão: mantenha aqui só o que vale sempre. Procedimentos de cada fase ficam nas skills (`.claude/skills/`), carregadas sob demanda.

## 1. Visão Geral e Princípios
Este repositório adota o modelo **Spec-Lean (Spec-Driven + Progressive Disclosure)** com revisão por **subagentes** e sensores **determinísticos**.

* **Contexto Enxuto:** Mantenha a janela de contexto abaixo de 60%. Detalhe operacional vive nas skills; não copie regra de skill para cá.
* **Autoverificação:** O código só é considerado pronto após passar nos sensores da seção 2 e em 100% do `checklist.md` da spec.
* **Isolamento:** Planejamento (`/k-spec`) e implementação (`/k-execute`) rodam em sessões separadas; a implementação começa com contexto zerado e lê apenas os artefatos da spec.

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

`/k-spec` → *(sessão nova)* `/k-execute` → `/k-review` → `/k-verify` → `/k-commit`

Blocker no review ou reprovação no verify volta para `/k-execute`.

| Skill | Quando | Lê | Produz |
|---|---|---|---|
| `/k-spec` | início de qualquer trabalho que vire commit | pedido, código, este arquivo | `spec.md`, `checklist.md` |
| `/k-execute` | spec pronta, em sessão nova | `spec.md`, `checklist.md` | código + testes |
| `/k-review` | implementação com testes verdes | diff vs `main`, `spec.md` | `review.md` |
| `/k-verify` | review sem blockers | `checklist.md`, seção 2 | `validation-report.md`, checklist marcado |
| `/k-commit` | verify aprovado | `review.md`, `validation-report.md` | commits (Conventional Commits) |
| `/k-prune` | periodicamente, fora do fluxo | este arquivo, `.claude/skills/` | proposta de poda |

---

## 4. Diretrizes de Código & Convenções
* **Arquitetura Limpa:** Mantenha separação clara entre lógica de domínio, casos de uso e camada de infraestrutura.
* **Tratamento de Erros:** Trate exceções explicitamente e registre logs contextuais sem expor dados sensíveis.
* **Testes Obrigatórios:** Toda nova funcionalidade ou alteração deve vir acompanhada de testes unitários ou de integração.

---

## 5. Regra de Ouro
Nunca declare uma tarefa como "concluída" sem antes executar `/k-verify` e ter 100% dos itens do `checklist.md` aprovados com evidência de testes reais e determinísticos.
