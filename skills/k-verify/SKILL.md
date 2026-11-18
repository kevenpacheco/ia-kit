---
name: k-verify
description: Portões determinísticos de qualidade. Roda lint, tipos, testes, mutação (se houver) e validação visual via Playwright MCP, prova cada item do checklist.md com evidência e grava validation-report.md. Use antes de declarar qualquer trabalho concluído e antes de /k-commit.
argument-hint: "[slug]"
---

# k-verify — Autoverificação Determinística

Fluxo: k-spec → k-execute → k-review → **k-verify** → k-commit.

O agente não declara pronto: prova. Cada item do `checklist.md` precisa de evidência de execução real.

## Procedimento

### 1. Preparar
Localize a spec pelo slug ou pela pasta mais recente em `docs/specs/` e leia o `checklist.md`. Os comandos vêm da seção **Comandos do Projeto & Sensores** do arquivo de instruções; se faltar algum, pergunte uma vez e sugira registrá-lo lá.

### 2. Portões determinísticos
Rode nesta ordem e guarde a linha decisiva de cada saída:
1. Lint e formatação.
2. Tipos e build.
3. Testes unitários e de integração.
4. Testes de mutação, se o projeto tiver: mostram se a suíte pega bordas ou só cobre linhas.

### 3. Validação visual/E2E (quando a mudança toca tela)
1. Suba a aplicação com o comando da seção de sensores.
2. Com o Playwright MCP, navegue até a tela afetada, preencha formulários, clique nos botões e confira o console sem erros.
3. Capture snapshot ou screenshot como evidência dos itens `[Front-end]`.

Sem Playwright MCP disponível, registre esses itens como `não verificado`, nunca como aprovados.

### 4. Gravar `validation-report.md` e marcar o checklist
Na pasta da spec, sobrescrevendo a versão anterior:

```markdown
# Relatório de Validação — <AAAA-MM-DD HH:MM>

## Portões
- [x] Lint — `npm run lint` sem erros
- [x] Testes — `npm test`: 48 passed

## Checklist
- [x] [API] GET /api/v1/resource retorna 200 — teste `resource.int.test.ts › lista para autenticado`
- [ ] [Front-end] Cadastro exibe erro — FALHOU: <linha decisiva>

## Resultado: APROVADO | REPROVADO
```

Marque `[x]` no `checklist.md` apenas os itens com evidência. APROVADO exige todos os portões verdes e 100% do checklist.

### 5. Encaminhar
- **REPROVADO:** `Próximo passo: /k-execute` para corrigir, depois `/k-verify` de novo (e `/k-review`, se a correção for além de ajuste pontual).
- **APROVADO:** `Próximo passo: /k-commit`.

## Regras
- Nunca marque item como aprovado sem execução real nesta sessão.
- Não altere código de aplicação aqui; falha volta para o `k-execute`.
