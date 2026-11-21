---
name: k-verify
description: Portões determinísticos de qualidade. Confere que os testes de aceite não foram alterados (hash do plan.md), que o diff ficou dentro do mapa do plano e que cada ID do checklist tem teste passando; roda lint, tipos, testes, mutação (se houver) e validação visual via Playwright MCP; passa por um verificador independente e grava validation-report.md amarrado ao código. Use antes de declarar qualquer trabalho concluído e antes de /k-commit.
argument-hint: "[slug]"
model: haiku
---

# k-verify — Autoverificação Determinística

Fluxo: k-discover → k-plan → k-build → k-review → **k-verify** → k-commit.

O agente não declara pronto: prova. Cada item do checklist precisa de evidência de execução real. Quase tudo aqui é mecânico — rodar comando, comparar hash, copiar linha — e o julgamento fica com o verificador independente.

## Procedimento

### 1. Preparar
Localize a spec pelo slug ou pela pasta mais recente em `docs/specs/` e leia o checklist (`checklist.md`, ou a seção `## Checklist` do `spec.md`) e o frontmatter do `plan.md`. Os comandos vêm da seção `## Comandos` do `plan.md` e, na falta, da seção **Comandos do Projeto & Sensores** do arquivo de instruções; se faltar algum, pergunte uma vez e sugira registrá-lo lá.

### 2. Portões de contrato
Trabalho médio ou grande (com `plan.md`). Qualquer falha reprova, sem exceção:
1. **Spec intacta:** `git hash-object <spec.md>` igual ao `spec_hash` do `plan.md`.
2. **Testes de aceite intactos:** para cada item de `testes_aceite`, `git hash-object <caminho>` igual ao `hash` gravado. Arquivo ausente também reprova.
3. **Escopo:** lista de arquivos alterados e novos (`git diff --name-only $(git merge-base origin/main HEAD)` mais `git ls-files --others --exclude-standard`), fora a pasta da spec. Cada um precisa estar no mapa de arquivos do `plan.md`, ser teste de aceite ou ser arquivo de teste unitário novo. Liste os que sobram.
4. **Rastreio:** cada ID do checklist (`C1`, `C2`…) aparece no nome de pelo menos um teste. ID sem teste reprova o item.

Trabalho pequeno: só o rastreio (4).

### 3. Portões determinísticos
Rode nesta ordem e guarde a linha decisiva de cada saída:
1. Lint e formatação.
2. Tipos e build.
3. Testes unitários e de integração, em modo verbose para que cada teste apareça com seu nome.
4. Testes de mutação, se o projeto tiver: mostram se a suíte pega bordas ou só cobre linhas.

### 4. Validação visual/E2E (quando a mudança toca tela)
1. Suba a aplicação com o comando da seção de sensores.
2. Com o Playwright MCP, navegue até a tela afetada, preencha formulários, clique nos botões e confira o console sem erros.
3. Capture snapshot ou screenshot como evidência dos itens `[Front-end]`. Havendo mockup na pasta da spec, capture no mesmo tamanho de janela dele (não redimensione depois) e compare região por região: controles, arranjo, textos, desenho, renderização.

Sem Playwright MCP disponível, registre esses itens como `não verificado`, nunca como aprovados.

### 5. Verificador independente
Subagente somente de leitura com `model: sonnet`, sem o raciocínio do autor: recebe `spec.md`, o checklist, o diff e as saídas dos testes. Os testes de aceite foram escritos pelo planejador e estão travados; o foco é o que o executor escreveu. Ele:
1. para cada teste unitário novo, julga: "esse teste falharia se a lógica estivesse errada?" e aponta asserções frouxas (`toBeDefined()`, só "não lançou erro", contar chamadas em vez de checar o estado, valor esperado recalculado como o código calcula);
2. para duas regras da spec, testa um valor que ninguém citou (outro lado da borda, vazio, muito grande) como teste descartável, sem commitar;
3. aponta lógica no diff que nenhum teste exercita.

Cada achado reprova o item correspondente. Sem subagente disponível: refaça este passo em sessão nova e registre `auto-verificado` no relatório.

### 6. Gravar `validation-report.md` e marcar o checklist
Na pasta da spec, sobrescrevendo a versão anterior. A evidência de cada item é a linha que o teste com aquele ID imprime ao passar, copiada da saída real desta execução, com o marcador de sucesso (`✓`, `PASSED`, `ok`). Um filtro que não seleciona nenhum teste não é evidência.

Prova amarrada ao código, sempre excluindo a pasta da spec (o relatório e o checklist mudam depois): grave o `HEAD` (`git rev-parse HEAD`), o hash de `git diff HEAD -- . ':!docs/specs'` (via `git hash-object --stdin`) e o hash da lista de não rastreados (`git ls-files --others --exclude-standard -- . ':!docs/specs'`, com o conteúdo desses arquivos incluído no hash: `git ls-files ... | xargs git hash-object | git hash-object --stdin`). Ajuste `docs/specs` se a pasta for `documentation/specs`.

```markdown
# Relatório de Validação — <AAAA-MM-DD HH:MM> — rodada <n>

## Código verificado
- HEAD: <sha>
- Hash do diff: <hash>
- Hash dos não rastreados: <hash>

## Contrato
- [x] Spec intacta — spec_hash confere
- [x] Testes de aceite intactos — 3/3 hashes conferem
- [x] Escopo — nenhum arquivo fora do mapa
- [x] Rastreio — 5/5 IDs com teste

## Portões
- [x] Lint — `npm run lint` sem erros
- [x] Testes — `npm test`: 48 passed

## Checklist
- [x] C1 [API] GET /api/v1/resource retorna 200 — `✓ resource.int.test.ts › C1: lista para autenticado`
- [ ] C3 [Front-end] Cadastro exibe erro — FALHOU: <linha decisiva>

## Verificador independente
<achados, ou "sem achados"; `auto-verificado` se não houve subagente>

## Resultado: APROVADO | REPROVADO
```

Marque `[x]` no checklist apenas os itens com evidência. APROVADO exige todos os portões de contrato e determinísticos verdes, 100% do checklist e nenhum achado do verificador.

### 7. Encaminhar
- **REPROVADO por contrato** (spec, teste de aceite ou escopo): diga qual arquivo divergiu. Se a mudança foi intencional e combinada, ela passa por `/k-plan` (novo hash e mapa); senão, `/k-build` desfaz.
- **REPROVADO por portão ou checklist:** `Próximo passo: /k-build` para corrigir, depois `/k-verify` de novo (e `/k-review`, se a correção for além de ajuste pontual). Limite de duas rodadas de correção por spec: reprovado na rodada 2, pare e leve ao usuário o que ainda falha.
- **APROVADO:** `Próximo passo: /k-commit`.

## Regras
- Nunca marque item como aprovado sem execução real nesta sessão.
- Não altere código de aplicação nem testes aqui; falha volta para o `k-build`.
