---
name: k-verify
description: Portões determinísticos de qualidade. Roda lint, tipos, testes, mutação (se houver) e validação visual via Playwright MCP, prova cada item do checklist com a linha real do teste, passa por um verificador independente e grava validation-report.md amarrado ao código. Use antes de declarar qualquer trabalho concluído e antes de /k-commit.
argument-hint: "[slug]"
---

# k-verify — Autoverificação Determinística

Fluxo: k-spec → k-execute → k-review → **k-verify** → k-commit.

O agente não declara pronto: prova. Cada item do checklist precisa de evidência de execução real.

## Procedimento

### 1. Preparar
Localize a spec pelo slug ou pela pasta mais recente em `docs/specs/` e leia o checklist (`checklist.md`, ou a seção `## Checklist` do `spec.md`). Os comandos vêm da seção **Comandos do Projeto & Sensores** do arquivo de instruções; se faltar algum, pergunte uma vez e sugira registrá-lo lá.

### 2. Portões determinísticos
Rode nesta ordem e guarde a linha decisiva de cada saída:
1. Lint e formatação.
2. Tipos e build.
3. Testes unitários e de integração.
4. Testes de mutação, se o projeto tiver: mostram se a suíte pega bordas ou só cobre linhas.

### 3. Validação visual/E2E (quando a mudança toca tela)
1. Suba a aplicação com o comando da seção de sensores.
2. Com o Playwright MCP, navegue até a tela afetada, preencha formulários, clique nos botões e confira o console sem erros.
3. Capture snapshot ou screenshot como evidência dos itens `[Front-end]`. Havendo mockup na pasta da spec, capture no mesmo tamanho de janela dele (não redimensione depois) e compare região por região: controles, arranjo, textos, desenho, renderização.

Sem Playwright MCP disponível, registre esses itens como `não verificado`, nunca como aprovados.

### 4. Verificador independente
Subagente somente de leitura, sem o raciocínio do autor: recebe `spec.md`, o checklist, o diff e as saídas dos testes. Ele:
1. para cada item, abre o teste citado e julga: "esse teste falharia se a regra fosse falsa?" (asserção no valor que a regra fixa, nos casos que ela nomeia);
2. aponta asserções mais frouxas que a regra: `toBeDefined()`, só "não lançou erro", contar chamadas em vez de checar o estado resultante, só o caminho feliz quando a spec lista bordas;
3. para duas regras da spec, testa um valor que ninguém citou (outro lado da borda, vazio, muito grande) como teste descartável, sem commitar.

Cada "não" é um achado que reprova o item. Sem subagente disponível: refaça este passo em sessão nova e registre `auto-verificado` no relatório.

### 5. Gravar `validation-report.md` e marcar o checklist
Na pasta da spec, sobrescrevendo a versão anterior. A evidência de cada item é a linha que o teste imprime ao passar, copiada da saída real desta execução, com o marcador de sucesso (`✓`, `PASSED`, `ok`). Se o reporter padrão só mostra resumo, rode em modo verbose. Um filtro que não seleciona nenhum teste não é evidência.

Prova amarrada ao código, sempre excluindo a pasta da spec (o relatório e o checklist mudam depois): grave o `HEAD` (`git rev-parse HEAD`), o hash de `git diff HEAD -- . ':!docs/specs'` (via `git hash-object --stdin`) e o hash da lista de não rastreados (`git ls-files --others --exclude-standard -- . ':!docs/specs'`, com o conteúdo desses arquivos incluído no hash: `git ls-files ... | xargs git hash-object | git hash-object --stdin`). Ajuste `docs/specs` se a pasta for `documentation/specs`.

```markdown
# Relatório de Validação — <AAAA-MM-DD HH:MM> — rodada <n>

## Código verificado
- HEAD: <sha>
- Hash do diff: <hash>
- Hash dos não rastreados: <hash>

## Portões
- [x] Lint — `npm run lint` sem erros
- [x] Testes — `npm test`: 48 passed

## Checklist
- [x] [API] GET /api/v1/resource retorna 200 — `✓ resource.int.test.ts › lista para autenticado`
- [ ] [Front-end] Cadastro exibe erro — FALHOU: <linha decisiva>

## Verificador independente
<achados, ou "sem achados"; `auto-verificado` se não houve subagente>

## Resultado: APROVADO | REPROVADO
```

Marque `[x]` no checklist apenas os itens com evidência. APROVADO exige todos os portões verdes, 100% do checklist e nenhum achado do verificador.

### 6. Encaminhar
- **REPROVADO:** `Próximo passo: /k-execute` para corrigir, depois `/k-verify` de novo (e `/k-review`, se a correção for além de ajuste pontual). Limite de duas rodadas de correção por spec: reprovado na rodada 2, pare e leve ao usuário o que ainda falha.
- **APROVADO:** `Próximo passo: /k-commit`.

## Regras
- Nunca marque item como aprovado sem execução real nesta sessão.
- Não altere código de aplicação aqui; falha volta para o `k-execute`.
