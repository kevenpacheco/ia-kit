---
name: k-spec
description: Planejamento Spec-Lean. Investiga o código, entrevista o usuário uma pergunta por vez e grava spec.md (plano único com escopo, regras de domínio e decisões técnicas) e checklist.md (critérios de aceite verificáveis). Use ao iniciar qualquer feature, correção, refactor ou chore que vá virar commit. Primeira etapa do fluxo; a seguinte é /k-execute em sessão nova.
argument-hint: "[descrição do trabalho | slug de spec existente]"
---

# k-spec — Planejamento Spec-Lean

Fluxo: **k-spec** → k-execute → k-review → k-verify → k-commit.

Substitui a decomposição em micro-tarefas (spec → design → tasks) por um plano único e um checklist de aceite. O executor implementa a partir do plano; o checklist é o contrato que o `k-verify` prova.

## Procedimento

### 1. Resolver o alvo
- Argumento que casa com uma pasta em `docs/specs/` → atualizar aquela spec.
- Texto livre → trabalho novo.
- Sem argumento → pergunte o que será feito.

### 2. Descobrir antes de perguntar
Leia o arquivo de instruções do projeto (`CLAUDE.md`/`AGENTS.md`) e, se existir, o `roadmap.md`. Para o código, dispare subagentes somente de leitura em paralelo, um por eixo: fluxo atual afetado, reuso disponível, testes existentes, documentação. Cada um devolve conclusões com `arquivo:linha`, nunca despejo de código.

Mostre uma síntese curta dos achados antes da primeira pergunta. Nunca pergunte o que o repositório responde.

### 3. Entrevistar até não restar ambiguidade
- **Uma pergunta por vez**; espere a resposta antes da próxima.
- Use `AskUserQuestion` (ou texto, se não existir) com 2 a 4 alternativas reais, a recomendada primeiro com `(Recomendado)`, cada uma dizendo o que se ganha e o que se perde.
- Só pergunte o que muda o resultado. O resto vira premissa registrada.

### 4. Gravar `spec.md`
Pasta: `docs/specs/<AAAAMMDD-HHMMSS>-<slug>/` (use `documentation/specs/` se o projeto já usa `documentation/`). Slug curto, kebab-case, sem acento.

```markdown
---
titulo: <título curto>
tipo: feat | fix | refactor | chore | docs
criado_em: <AAAA-MM-DD HH:MM>
---

## Contexto & Escopo
Problema que o trabalho resolve e o que entra.

### Fora do escopo

## Regras de Domínio
Cenários no formato: dado <contexto>, quando <ação>, então <resultado observável>.
Inclua casos de borda e de erro.

## Decisões Técnicas
Onde a mudança mora (`arquivo:linha`), modelagem de dados, rotas/contratos,
estratégia de erros e reuso identificado.

## Histórico de Decisões
Escolha feita na entrevista, alternativa descartada e motivo.

## Premissas
O que foi assumido sem confirmação. Omita a seção se vazia.
```

Mantenha só o essencial: o executor lê o `spec.md` inteiro em contexto zerado.

### 5. Gravar `checklist.md`
Converta cada regra e decisão do `spec.md` em um item verificável por teste ou observação direta, com a camada entre colchetes:

```markdown
- [ ] [API] GET /api/v1/resource retorna 200 com array de dados para usuário autenticado.
- [ ] [API] POST /api/v1/resource sem autenticação retorna 401 Unauthorized.
- [ ] [Front-end] Tela de cadastro exibe mensagem de erro ao submeter formulário inválido.
- [ ] [Testes] Teste unitário cobre a lógica de cálculo de estoque no Service.
```

Item que não dá para provar ("código limpo", "boa performance") não entra: reescreva com critério mensurável ou remova.

### 6. Encerrar
```
Spec: docs/specs/<ts>-<slug>/spec.md
Checklist: docs/specs/<ts>-<slug>/checklist.md (<n> itens)
Próximo passo: abra uma sessão nova e rode /k-execute <slug>
```

## Restrições
- Não altere código de aplicação nem faça commit nesta etapa.
- Sem micro-tarefas: não quebre a implementação em passos de instrução de código.
- Não tome decisão que o usuário não tomou; pergunte.
