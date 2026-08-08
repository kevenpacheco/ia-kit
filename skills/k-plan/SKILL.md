---
name: k-plan
description: Segunda etapa do fluxo de trabalho. Le o spec.md, investiga o codigo com subagentes em paralelo, classifica a mudanca (legado puro vs contexto em evolucao), compara opcoes, escreve plan.md ao lado do spec.md, cria a branch a partir da main e commita spec+plan. Use depois de /k-spec.
---

# k-plan

Etapa 2 de 4: `k-spec` → `k-plan` → `k-task` → `k-execute`.

## Quando usar

Depois que `/k-spec` gravou o `spec.md`. Invocacao:

```
/k-plan                        # infere a spec mais recente sem plan.md
/k-plan corrigir-crop-banner   # por slug
/k-plan documentation/specs/20260807-143205-corrigir-crop-banner
```

Se houver mais de uma candidata, **liste e pergunte**. Nunca chute a spec.

## Objetivo

Transformar o contrato de comportamento em decisao tecnica registrada: onde a mudanca mora, qual a menor solucao que resolve, o que explicitamente nao entra, e o que pode quebrar.

O `k-plan` decide **o que fazer**. O `k-task` quebra em passos.

## Principio

**Resolver a causa, nao o sintoma. Com o minimo de codigo.**

Remendo no chamador some do radar e volta pelo proximo chamador. Correcao na origem resolve todos de uma vez. Mas "na origem" nao autoriza reescrever o modulo: a mudanca para no ponto onde a invariante foi violada.

## Procedimento

### 1. Ler a spec

Leia `spec.md` inteiro, incluindo o frontmatter. O `tipo` governa as secoes obrigatorias do plano.

Se o arquivo nao tiver as secoes do `k-spec`, pare e mande rodar `/k-spec` antes.

### 2. Investigar com subagentes em paralelo

Dispare subagentes **somente de leitura**, um por eixo, **todos na mesma mensagem** para rodarem juntos.

Eixos por tipo:

| Tipo | Eixos |
|---|---|
| `feature`, `refactor`, `chore` | fluxo atual (rota → controller → service/model → query → view); reuso (Service/Model/Helper/Library que ja faz parte do trabalho); consumidores (quais portais/temas consomem o dado ou a rota); documentacao existente |
| `bug` | caminho ate a falha (da entrada ate onde o valor errado nasce); outros chamadores do metodo/query suspeito; historico (`git log -L` ou `git blame` no trecho); cobertura existente (ja ha teste tocando isso? por que nao pegou?) |
| `docs` | o que a documentacao afirma hoje; onde o comportamento real diverge |

Cada subagente devolve **conclusao com `arquivo:linha`**, nunca despejo de codigo.

Pesquisa externa (web) so quando o codigo nao responde: contrato de integracao de terceiro (Pagar.me, Cogna) ou comportamento de biblioteca ja usada. Nunca busque "melhor pratica" generica — a resposta costuma violar as restricoes do projeto (PHP 8+, ORM, framework novo).

### 3. Grade de suspeitas (so tipo `bug`)

Antes de fechar a causa raiz, verifique explicitamente cada item. Sao os defeitos que mais aparecem neste codebase:

- [ ] null/empty nao tratado no retorno ou no parametro
- [ ] indice inexistente em array
- [ ] `if`/`else` invertido ou condicao negada errado
- [ ] SQL com filtro, join ou ordenacao errada
- [ ] dependencia implicita entre metodos (ordem de chamada obrigatoria e nao garantida)
- [ ] efeito colateral em metodo compartilhado por varios fluxos

Item descartado nao precisa aparecer no plano; item que **e** a causa precisa aparecer com a evidencia.

### 4. Provar a causa raiz (so tipo `bug`)

A causa raiz e o ponto onde o comportamento correto deixou de valer — nao o ponto onde o erro apareceu na tela. Prove com `arquivo:linha` e com a condicao de entrada que a dispara.

Se voce nao consegue provar, **nao adivinhe**: volte a investigar ou devolva ao usuario dizendo o que falta para provar.

### 5. Classificar a mudanca

Decida e justifique, conforme `.claude/rules/project-rules.md`:

- **legado puro** — priorizar compatibilidade, padrao existente e diff minimo. Nao criar camada nova.
- **contexto em evolucao** — regra pode ir para Service/objeto de negocio, com camada de isolamento em relacao ao legado.

Criterio para separar em camada: regra de negocio relevante, invariante a proteger, conceito compartilhado por varios fluxos. Criterio para **nao** separar: CRUD simples, consulta administrativa, ajuste visual, bugfix pequeno.

### 6. Comparar opcoes

Monte de 2 a 3 opcoes reais, tipicamente nesta escala:

- **remendo no sintoma** — guard no chamador; barato, mas deixa os outros chamadores quebrados
- **solucao na causa** — arruma onde a invariante e violada; costuma ser a recomendada
- **mudanca estrutural** — camada nova, mudanca de contrato, refatoracao; quase sempre fora de escopo

Para cada uma: quanto de codigo muda, o que resolve, o que **nao** resolve, e o risco de regressao. Recomende a menor que resolve a causa.

Mudanca estrutural so entra se a solucao na causa for impossivel sem ela — e nesse caso avalie se o trabalho nao deveria virar uma spec de tipo `feature` ou `refactor` propria.

Se so existe um caminho viavel, **nao invente opcoes**. Registre o unico caminho e o porque.

### 7. Confirmar com o usuario

Mostre classificacao, causa raiz (se `bug`) e opcoes, e **espere a escolha** antes de gravar o plano. Esta e a decisao central do fluxo; nao a tome sozinho.

Formato: `AskUserQuestion`, 2 a 4 alternativas, recomendada em primeiro com `(Recomendado)`, cada descricao dizendo o que se ganha **e** o que se perde. Proibida opcao-palha.

### 8. Escrever o plan.md

Grave em `documentation/specs/<ts>-<slug>/plan.md`:

```markdown
---
spec: spec.md
tipo_de_mudanca: legado puro | contexto em evolucao
---

## Classificacao

**<legado puro | contexto em evolucao>** — <justificativa em uma linha>

## Fluxo atual

Entrada → controller/action → service/model/helper → query → response/view, com `arquivo:linha`.

## Causa raiz

Somente tipo `bug`. `arquivo:linha` — o que viola a invariante e sob qual condicao de entrada.

## Alcance do defeito

Somente tipo `bug`. Quem mais e afetado pelo mesmo ponto (outros chamadores, portais, rotas).

## Opcoes

A. <descricao> — <n> linhas — resolve <o que> / nao resolve <o que> — risco <...>
B. <descricao> — <n> linhas — ... ← recomendada
C. <descricao> — <n> linhas — ...

**Escolhida:** <letra> — <por que resolve a causa>

## Onde a regra deve morar

Camada escolhida e por que. Se for camada nova, qual dor concreta justifica.

## Reuso identificado

O que ja existe e sera aproveitado (`arquivo:linha`). Se nada, dizer que foi procurado.

## Banco de dados

Tabelas e colunas envolvidas, alteracao de schema necessaria, indice, impacto em volume.
Omitir a secao se o trabalho nao toca banco.

## Dependencias externas

Integracoes de terceiro, contrato, credencial, timeout, comportamento em falha.
Omitir a secao se nao houver.

## Nao entra neste trabalho

Lista explicita: renomeacao, extracao de classe, formatacao, melhoria de nome, bug vizinho, otimizacao. Serve para o executor recusar carona.

## Regressao coberta

Qual teste falha antes e passa depois, e em qual testsuite.
Se nao houver teste automatizado possivel, a secao vira `## Sem teste automatizado` com o motivo (view, asset, config, comportamento de browser) e os testes manuais que cobrem o caso.

## Riscos de regressao

O que pode quebrar e quem consome o ponto alterado.

## Testes manuais sugeridos

Passo a passo verificavel por portal afetado. Em tipo `bug`, inclua o caso que reproduzia o bug.

## Documentacao afetada

Qual documento muda e por que, ou `Nenhuma` com a justificativa. Gatilhos:

- muda contrato de endpoint → `documentation/api/`
- muda regra de negocio → `documentation/business-rules/`
- muda camada, fluxo ou decisao estrutural → `documentation/arquitetura.md`
- a documentacao descrevia o comportamento bugado como correto → corrigir a doc
- o bug revelou regra de negocio nao documentada → registrar a regra

Se a doc ja dizia o certo e o codigo e que estava errado, `Nenhuma`.
```

Omita as secoes que nao se aplicam ao tipo. Nao deixe secao vazia com "N/A".

### 9. Criar a branch e commitar

A branch nasce aqui, sempre a partir da `main` atualizada. Prefixo pelo `tipo` do frontmatter da spec:

| Tipo | Prefixo |
|---|---|
| `feature` | `feat/` |
| `bug` | `fix/` |
| `refactor` | `refactor/` |
| `chore` | `chore/` |
| `docs` | `docs/` |

```bash
git checkout main
git pull origin main
git checkout -b <prefixo>/<slug>
git add documentation/specs/<ts>-<slug>/spec.md documentation/specs/<ts>-<slug>/plan.md
git commit -m "docs(spec): <titulo>"
```

O slug da branch e o mesmo do diretorio da spec, **sem o timestamp** — e assim que o `k-task` e o `k-execute` reencontram a spec.

Se houver alteracao local nao commitada de outro trabalho, **pare e pergunte** antes de trocar de branch. Nao faca `stash` automatico.

Sem push. O push acontece uma unica vez, no encerramento do `k-execute`.

### 10. Encerrar

```
Plano criado: documentation/specs/<ts>-<slug>/plan.md
Branch <prefixo>/<slug> criada. Commit: docs(spec): <titulo>
Proximo passo: /k-task
```

## Restricoes

- Nao altere codigo de aplicacao nesta etapa. O plano descreve; o `k-execute` implementa.
- Nao quebre em tarefas aqui. Isso e `k-task`.
- Nunca faca push nem merge em `main`, `homolog` ou `dev`.
- Nao proponha PHP 8+, ORM, container de DI, framework ou biblioteca nova sem dor concreta e pedido explicito.
- Nao invente camada nova em CRUD simples, consulta administrativa ou bugfix pequeno em area legada.
- Nao misture bugfix com refatoracao. Melhoria que apareceu no caminho vai para `## Nao entra neste trabalho`.
- Bug vizinho descoberto na investigacao vira spec nova via `/k-spec`, nunca item deste plano.
- Se a causa raiz nao puder ser provada, ou a spec estiver ambigua a ponto de impedir a decisao tecnica, pergunte ao usuario — nao chute.
