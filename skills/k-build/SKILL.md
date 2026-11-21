---
name: k-execute
description: Implementação contínua a partir de uma spec Spec-Lean aprovada. Lê spec.md e checklist.md, cria a branch e implementa teste-primeiro, guiado pelo feedback dos testes, sem pedir aprovação a cada arquivo. Use depois de /k-spec, ou para corrigir blockers do /k-review e reprovações do /k-verify.
argument-hint: "[slug] [fatia]"
---

# k-execute — Implementação Contínua

Fluxo: k-spec → **k-execute** → k-review → k-verify → k-commit.

## Procedimento

### 1. Localizar a spec
Slug por argumento → `docs/specs/*-<slug>/`. Sem argumento: se houver uma única spec sem `validation-report.md` aprovado, use-a; senão liste as candidatas e pergunte. Não chute.

- Sem `aprovado_em` no frontmatter do `spec.md`: recuse e mande rodar `/k-spec`.
- Spec com `## Fatias`: implemente uma fatia por sessão (`<slug> <fatia>`), respeitando `bloqueado por`; sem fatia no argumento, pergunte qual.
- Se a sessão já carrega a discussão do planejamento e o contexto está pesado, recomende uma sessão nova.

### 2. Carregar só o necessário
- `spec.md` e o checklist inteiros (`checklist.md`, ou a seção `## Checklist` do `spec.md`).
- `review.md` e `validation-report.md`, se existirem: são os blockers e falhas a corrigir nesta rodada.
- Os arquivos de código citados em `## Decisões Técnicas`.

Nada além disso até precisar.

### 3. Garantir a branch
Antes de alterar código, crie ou confirme `<tipo>/<slug>` (`tipo` do `spec.md`: `feat/`, `fix/`, `refactor/`, `chore/`, `docs/`), partindo de `origin/main` atualizado. Árvore suja na `main`: não faça `git pull`; crie a branch com as alterações e siga.

### 4. Implementar
- Siga as decisões do `spec.md`; não reabra decisão já tomada.
- Um item do checklist por vez: escreva o teste, **veja o teste falhar**, implemente o mínimo para passar. Uma fatia vertical por vez (um teste → uma implementação). Refatoração fica para depois do review, fora deste ciclo.
- Teste só nos **Pontos de teste** do `spec.md`. Mock só em fronteira do sistema, nunca em colaborador interno.
- O valor esperado vem da spec ou de um literal conhecido, nunca recalculado como o código calcula. Ruim: `expect(total(items)).toBe(items.reduce(...))`. Bom: `expect(total([{price:10},{price:5}])).toBe(15)`.
- Rode os testes da seção **Comandos do Projeto & Sensores** do arquivo de instruções a cada item, para validar suposições cedo.
- **Integridade dos testes:** nunca enfraqueça asserção, apague teste nem use skip/disable/pending para ficar verde. Se o teste estiver errado segundo a spec, pare e pergunte ao usuário antes de mudar.
- Altere só o que a spec pede. Achado fora do escopo: registre em `## Achados fora do escopo` no fim do `spec.md` e siga, sem corrigir.

### 5. Quando parar
- **Bloqueio técnico não previsto** (decisão de produto ausente, contradição na spec, dependência indisponível): pare, explique e proponha opções. Fora isso, não peça aprovação a cada arquivo.
- **Decisão do usuário durante a execução:** grave no mesmo turno em `## Histórico de Decisões` do `spec.md`, com as palavras dele (uma compactação apaga o chat).
- **Sessão inchada** por muitos ciclos de tentativa e erro: registre o que já foi feito em `## Progresso` no `spec.md` e recomende continuar em sessão nova. Ao retomar, o estado do git vale mais que as anotações de `## Progresso`.
- **Terceira rodada de correção:** o limite é duas por spec (veja `k-review` e `k-verify`); pare e leve ao usuário o que ainda falha.

### 6. Encerrar
Só com os testes verdes:
```
Implementação concluída: <resumo em uma linha>
Testes: <comando> — verde
Próximo passo: /k-review
```
