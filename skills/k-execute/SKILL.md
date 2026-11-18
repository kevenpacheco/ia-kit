---
name: k-execute
description: Implementação contínua a partir de uma spec Spec-Lean. Lê spec.md e checklist.md em contexto zerado e implementa código e testes de uma vez, guiado pelo feedback dos testes, sem pedir aprovação a cada arquivo. Use depois de /k-spec, em sessão nova, ou para corrigir blockers do /k-review e reprovações do /k-verify.
argument-hint: "[slug]"
---

# k-execute — Implementação Contínua

Fluxo: k-spec → **k-execute** → k-review → k-verify → k-commit.

## Procedimento

### 1. Localizar a spec
Slug por argumento → `docs/specs/*-<slug>/`. Sem argumento: se houver uma única spec sem `validation-report.md` aprovado, use-a; senão liste as candidatas e pergunte. Não chute.

Se a sessão já carrega a discussão do planejamento, recomende abrir uma sessão nova antes de seguir.

### 2. Carregar só o necessário
- `spec.md` e `checklist.md` inteiros.
- `review.md` e `validation-report.md`, se existirem: são os blockers e falhas a corrigir nesta rodada.
- Os arquivos de código citados em `## Decisões Técnicas`.

Nada além disso até precisar.

### 3. Implementar
- Siga as decisões do `spec.md`; não reabra decisão já tomada.
- Escreva os testes de cada item do `checklist.md` junto com o código, nas convenções do repositório.
- Rode os testes da seção **Comandos do Projeto & Sensores** do arquivo de instruções a cada módulo, para validar suposições cedo.
- Altere só o que a spec pede. Achado fora do escopo: registre em `## Achados fora do escopo` no fim do `spec.md` e siga, sem corrigir.

### 4. Quando parar
- **Bloqueio técnico não previsto** (decisão de produto ausente, contradição na spec, dependência indisponível): pare, explique e proponha opções. Fora isso, não peça aprovação a cada arquivo.
- **Sessão inchada** por muitos ciclos de tentativa e erro: registre o que já foi feito em `## Progresso` no `spec.md` e recomende continuar em sessão nova.

### 5. Encerrar
Só com os testes verdes:
```
Implementação concluída: <resumo em uma linha>
Testes: <comando> — verde
Próximo passo: /k-review
```
