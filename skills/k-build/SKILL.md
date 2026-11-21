---
name: k-build
description: Implementação mecânica a partir do plan.md. Segue os passos do plano até os testes de aceite (já escritos e travados por hash) ficarem verdes, sem alterá-los e sem tocar arquivo fora do mapa; o que o plano não cobre vira duvidas.md, nunca decisão própria. Use depois de /k-plan (ou de /k-discover em trabalho pequeno), ou para corrigir blockers do /k-review e reprovações do /k-verify.
argument-hint: "[slug] [fatia]"
model: sonnet
---

# k-build — Implementação a partir do Plano

Fluxo: k-discover → k-plan → **k-build** → k-review → k-verify → k-commit.

As decisões já foram tomadas: o quê no `spec.md`, o como no `plan.md`, a prova nos testes de aceite. Seu trabalho é deixar esses testes verdes seguindo o plano. Quando o plano não responde, você para e pergunta por escrito — não escolhe.

## Procedimento

### 1. Localizar e validar
Slug por argumento → `docs/specs/*-<slug>/`. Sem argumento: se houver uma única spec sem `validation-report.md` aprovado, use-a; senão liste as candidatas e pergunte. Não chute.

Recuse, indicando a skill certa, quando:
- falta `aprovado_em` no `spec.md` → `/k-discover`;
- trabalho médio ou grande sem `plan.md` (ou sem a seção da fatia pedida) → `/k-plan`;
- `spec_hash` do `plan.md` difere de `git hash-object <spec.md>` → a spec mudou: `/k-plan <slug>`;
- há `duvidas.md` pendente → `/k-discover` (produto) ou `/k-plan` (técnica).

Trabalho pequeno: o plano é a seção `## Plano` do `spec.md`; não há hash nem testes de aceite prévios — escreva o teste de cada item do checklist primeiro, com o ID no nome, e veja-o falhar antes de implementar.

### 2. Carregar só o necessário
`plan.md`, `spec.md`, o checklist, os testes de aceite e os arquivos do mapa. `review.md` e `validation-report.md`, se existirem: são os blockers e falhas desta rodada. Não leia `contexto.md` nem explore o repositório além disso; se precisou, o plano tem lacuna (passo 5).

### 3. Branch
O `/k-plan` já criou `<tipo>/<slug>`: faça checkout. Se não existir (trabalho pequeno), crie a partir de `origin/main` atualizado; árvore suja na `main`: não faça `git pull`, crie a branch com as alterações e siga.

### 4. Implementar
- Siga os **Passos** do plano em ordem. Copie os **Padrões** indicados; use as **Interfaces** exatamente como escritas; rode os **Comandos** do plano.
- A cada passo, rode os testes de aceite do passo e veja os IDs dele passarem antes de seguir.
- Pode criar testes unitários para lógica interna ao lado dos arquivos do mapa. O valor esperado vem da spec ou de um literal, nunca recalculado como o código calcula. Ruim: `expect(total(items)).toBe(items.reduce(...))`. Bom: `expect(total([{price:10},{price:5}])).toBe(15)`. Mock só em fronteira do sistema.
- **Testes de aceite são intocáveis:** não edite, não apague, não use skip. O `/k-verify` confere o hash e reprova qualquer alteração. Se um deles parece errado, passo 5.
- **Só arquivos do mapa** (mais testes unitários novos). Precisa tocar outro arquivo: passo 5.
- Nunca enfraqueça asserção nem desative teste para ficar verde.
- Achado fora do escopo: registre em `## Execução` do `plan.md` e siga, sem corrigir.

### 5. Quando o plano não responde
Grave em `duvidas.md` na pasta da spec: pergunta, onde surgiu (passo do plano ou ID), o que você tentou, opções. Pare e indique:
- dúvida técnica (arquivo fora do mapa, padrão que não serve, teste de aceite que não carrega) → `/k-plan <slug>`;
- dúvida de produto (regra ambígua, caso não previsto) → `/k-discover <slug>`.

Não implemente a opção que parece óbvia. Fora esses casos, não peça aprovação a cada arquivo.

### 6. Durante a sessão
- **Decisão do usuário durante a execução:** grave no mesmo turno em `## Execução` do `plan.md`, com as palavras dele (uma compactação apaga o chat). O `spec.md` não muda.
- **Sessão inchada** por tentativa e erro: registre o feito em `## Execução` do `plan.md` e recomende sessão nova. Ao retomar, o estado do git vale mais que as anotações.
- **Terceira rodada de correção:** o limite é duas por spec (veja `k-review` e `k-verify`); pare e leve ao usuário o que ainda falha.

### 7. Encerrar
Só com todos os testes de aceite e a suíte verdes:
```
Implementação concluída: <resumo em uma linha>
Testes de aceite: <comando> — <n>/<n> verdes
Suíte: <comando> — verde
Próximo passo: /k-review
```
