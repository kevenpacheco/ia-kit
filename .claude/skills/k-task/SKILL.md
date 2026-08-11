---
name: k-task
description: Terceira etapa do fluxo de trabalho. Le spec.md e plan.md e quebra a implementacao em tarefas pequenas e focadas, uma por unidade de commit, cada uma em tasks/NN-titulo-curto.md (na pasta de specs do fluxo) com frontmatter de status, arquivos exatos e skill tatica. Use depois de /k-plan.
---

# k-task

Etapa 3 de 4: `k-spec` → `k-plan` → `k-task` → `k-execute`.

## Quando usar

Depois que `/k-plan` gravou o `plan.md` e criou a branch. Invocacao:

```
/k-task                        # infere pela branch atual
/k-task corrigir-crop-banner   # por slug
/k-task docs/specs/20260807-143205-corrigir-crop-banner   # ou documentation/specs/..., conforme a raiz detectada pelo k-spec
```

Sem argumento, resolva pelo nome da branch: `<prefixo>/<slug>` → `<raiz-de-specs>/*-<slug>`, tentando `docs/specs/` e `documentation/specs/`. Se o glob achar mais de um diretorio, **liste e pergunte**. Nunca chute.

## Objetivo

Converter a decisao tecnica do plano em um roteiro executavel por um agente que **nao vai investigar nada**. Cada arquivo de tarefa precisa ser suficiente sozinho: o executor le a tarefa, o `spec.md` e o `plan.md`, e sabe exatamente o que fazer.

## Procedimento

### 1. Ler spec e plano

Leia `spec.md` e `plan.md` inteiros. O `tipo` da spec e a `Escolhida` do plano governam a quebra.

Se nao houver `plan.md`, pare e mande rodar `/k-plan` antes.

Confirme que voce esta na branch da spec. Se estiver numa branch protegida do projeto (ex.: `main`), **pare** — a branch e criada pelo `k-plan`.

### 2. Quebrar em tarefas

**Ordem obrigatoria:** teste → dados/regra de negocio → controller → view → documentacao.

TDD e obrigatorio (`CLAUDE.md` §2.7), entao a primeira tarefa de cada comportamento e o teste que falha.

Em tipo `bug`, a **tarefa 1 e sempre o teste de regressao que falha**. Unica excecao: o plano registrou `## Sem teste automatizado` com o motivo.

Regras de tamanho:

- **uma tarefa = uma unidade de commit.** Se nao cabe em um commit pequeno e focado, quebre.
- uma tarefa toca um proposito so. "Criar Service e o Controller que o chama" sao duas tarefas.
- se uma tarefa precisa de decisao que o plano nao tomou, **volte ao `k-plan`** em vez de deixar a decisao para o executor.

### 3. Escrever os arquivos de tarefa

Um arquivo por tarefa, em `<raiz-de-specs>/<ts>-<slug>/tasks/`, numerado em ordem de execucao com dois digitos:

```
tasks/01-teste-crop-preserva-proporcao.md
tasks/02-corrigir-calculo-de-offset.md
tasks/03-atualizar-doc-de-banners.md
```

Frontmatter obrigatorio:

```yaml
---
numero: 2
titulo: Corrigir calculo de offset no crop
tipo: fix
status: pendente
skill: testing
arquivos:
  - caminho/relativo/do/arquivo.ext
commit:
---
```

| Campo | Conteudo |
|---|---|
| `numero` | inteiro, igual ao prefixo do nome do arquivo |
| `titulo` | frase curta, imperativa |
| `tipo` | tipo de Conventional Commit desta tarefa: `feat`, `fix`, `refactor`, `chore`, `docs`, `test` |
| `status` | `pendente` \| `em-andamento` \| `concluida` \| `bloqueada` — sempre nasce `pendente` |
| `skill` | skill tatica que executa (tabela abaixo). Vazio se nenhuma se aplica |
| `arquivos` | lista dos **arquivos exatos** que a tarefa pode tocar |
| `commit` | vazio; o `k-execute` preenche com o SHA ao concluir |

Corpo:

```markdown
## O que fazer

Descricao imperativa e concreta do trabalho. Sem "investigar", sem "avaliar" —
a investigacao acabou no k-plan.

## Como verificar

Comando exato de lint e testsuite, e o resultado esperado.
Em tarefa de teste (TDD): o teste precisa **falhar** pelo motivo certo.
Em tarefa de implementacao: o teste da tarefa anterior precisa **passar**.

## Contexto necessario

`arquivo:linha` que o executor precisa ler antes de editar, e por que.
Referencia a secao do plan.md quando a decisao ja estiver la.

## Nao faca

Herdado de `## Nao entra neste trabalho` do plano, filtrado para o que e
tentador nesta tarefa especifica.
```

### 4. Skills taticas

Preencha o campo `skill` de forma dinamica: olhe as skills disponiveis em `.claude/skills/` do projeto atual e escolha a que casa com a natureza da tarefa (ex.: uma skill de teste para tarefa de teste, uma skill de camada de dados para tarefa de query, uma skill de documentacao para tarefa de doc). Se nenhuma existente casar, deixe o campo vazio — o executor segue o padrao existente no arquivo.

### 5. Tarefa de documentacao

Crie somente se o `## Documentacao afetada` do plano apontar um destino. Se o plano disse `Nenhuma`, nao invente tarefa de doc.

### 6. Confirmar e commitar

Mostre a lista numerada ao usuario (numero, titulo, arquivos, skill) e **confirme antes de gravar**.

Toda operacao de git e responsabilidade exclusiva da skill `k-commit` — o `k-task` nunca roda `git` diretamente. Depois de confirmado, pergunte ao usuario: comitar `tasks/` agora (via `k-commit`, modo 2b — commit) ou seguir pra `/k-execute` sem comitar?

- Se comitar: chame `k-commit` (modo 2b) com o diretorio `<raiz-de-specs>/<ts>-<slug>/tasks/` e a mensagem sugerida `docs(spec): tarefas de <titulo>`. Sem push — o `k-commit` para depois do commit.
- Se nao: os arquivos ficam pendentes na branch; o `k-execute` (ou uma chamada futura ao `k-commit`) lida com eles depois.

### 7. Encerrar

```
<n> tarefas criadas em <raiz-de-specs>/<ts>-<slug>/tasks/
1. <titulo> — <arquivos>
2. ...
Commit: <feito via k-commit: docs(spec): tarefas de <titulo> | pendente>
Proximo passo: /k-execute
```

## Restricoes

- Nao altere codigo de aplicacao nesta etapa. O `k-task` descreve; o `k-execute` implementa.
- Nao tome decisao tecnica que o plano nao tomou. Se faltar decisao, volte ao `/k-plan`.
- Nunca rode `git` diretamente para commit, push, PR ou merge — sempre delegue ao `k-commit` (ver etapa 6).
- Nao crie tarefa que exija investigacao — o executor roda com contexto minimo e nao vai pesquisar.
- Nao agrupe propositos diferentes numa tarefa so para reduzir o numero de arquivos.
- Nao proponha recursos de linguagem/versao alem do que o projeto ja usa nas instrucoes — respeite as convencoes documentadas (`CLAUDE.md`).
