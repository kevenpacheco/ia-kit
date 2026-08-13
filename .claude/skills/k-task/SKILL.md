---
name: k-task
description: Terceira etapa do fluxo de trabalho. Le spec.md e plan.md e quebra a implementacao em tarefas pequenas e focadas, uma por comportamento observavel e por unidade de commit, com teste e implementacao juntos (ciclo TDD dentro da tarefa) para nunca commitar testsuite vermelha. Grava tasks/NN-titulo-curto.md (na pasta de specs do fluxo) com frontmatter de status, arquivos exatos e skill tatica. Use depois de /k-plan.
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

Se nao houver `plan.md`, ou se o `spec.md` estiver com `fluxo: pendente`, pare e mande rodar `/k-plan` (ou `/k-spec`, no caso do stub) antes.

Confirme que voce esta na branch da spec. Se estiver numa branch protegida do projeto (ex.: `main`), **pare** — a branch e criada pelo `k-plan`.

### 2. Quebrar em tarefas

**Uma tarefa = um comportamento observavel.** Teste e implementacao daquele comportamento ficam na **mesma** tarefa, no mesmo commit. Nunca separe "escrever o teste" de "fazer o teste passar" em tarefas diferentes: isso comita testsuite vermelha.

TDD e obrigatorio (`CLAUDE.md` §2.7), mas o ciclo acontece **dentro** da tarefa:

**Ordem dentro da tarefa:** teste que falha → implementacao minima (dados/regra de negocio → controller → view, so as camadas que o comportamento exige) → refactor. A tarefa termina com tudo verde.

**Ordem entre tarefas:** por dependencia de comportamento — o comportamento base antes do que depende dele. Documentacao por ultimo.

Em tipo `bug`, a **tarefa 1 e sempre a que contem o teste de regressao e a correcao**: o teste falha no inicio da tarefa e passa no fim. Unica excecao: o plano registrou `## Sem teste automatizado` com o motivo.

Regras de tamanho:

- **uma tarefa = uma unidade de commit.** Se nao cabe em um commit pequeno e focado, quebre.
- quebre por **comportamento**, nunca por camada. Se um comportamento so atravessa Service e Controller, e uma tarefa; se sao dois comportamentos que o consumidor distingue, sao duas tarefas — cada uma com seus proprios testes e implementacao.
- sem teto de ciclos por tarefa. O limite e o comportamento, nao a contagem de testes.
- se uma tarefa precisa de decisao que o plano nao tomou, **volte ao `k-plan`** em vez de deixar a decisao para o executor.

Tarefas sem comportamento novo — doc, chore, refactor puro, migracao — continuam sendo tarefas proprias e **nao** ganham teste novo. A regra e *toda tarefa termina verde*, nao *toda tarefa tem teste*: o refactor puro termina verde porque os testes existentes seguem passando.

### 3. Escrever os arquivos de tarefa

Um arquivo por tarefa, em `<raiz-de-specs>/<ts>-<slug>/tasks/`, numerado em ordem de execucao com dois digitos. Nomeie pelo **comportamento**, nunca pela camada nem com a palavra "teste":

```
tasks/01-crop-preserva-proporcao.md
tasks/02-crop-respeita-area-segura.md
tasks/03-atualizar-doc-de-banners.md
```

Frontmatter obrigatorio:

```yaml
---
numero: 1
titulo: Crop preserva a proporcao original
tipo: fix
status: pendente
motivo:
skill: <skill tatica da implementacao>
arquivos:
  - caminho/relativo/do/arquivo.ext
  - caminho/relativo/do/teste.ext
commit:
---
```

| Campo | Conteudo |
|---|---|
| `numero` | inteiro, igual ao prefixo do nome do arquivo |
| `titulo` | frase curta. Em tarefa de comportamento, nomeia o comportamento ("Crop preserva a proporcao original"); nas demais, imperativa ("Atualizar doc de banners") |
| `tipo` | tipo de Conventional Commit desta tarefa: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`. Comportamento novo ou corrigido e `feat`/`fix` — o teste vai no mesmo commit. Use `test` so quando a tarefa adiciona teste **sem** mudar comportamento (caracterizar legado, cobrir buraco existente) |
| `status` | `pendente` \| `em-andamento` \| `concluida` \| `bloqueada` — sempre nasce `pendente` |
| `motivo` | vazio; o `k-execute` preenche com uma linha ao marcar `bloqueada` (falha no gate, ou `bloqueada por <slug-do-stub>`). E o que o `k-execute` mostra ao encontrar tarefa bloqueada |
| `skill` | skill tatica que executa (ver etapa 4). Uma so, referente a natureza da **implementacao**. Vazio se nenhuma se aplica |
| `arquivos` | lista dos **arquivos exatos** que a tarefa pode tocar, **incluindo os arquivos de teste** |
| `commit` | vazio; o `k-execute` preenche com o SHA ao concluir |

Corpo:

```markdown
## O que fazer

Descricao imperativa e concreta do trabalho. Sem "investigar", sem "avaliar" —
a investigacao acabou no k-plan.

## Ciclos TDD

Um item por ciclo red→green, na ordem de execucao. Cada item traz:
nome do teste, comportamento esperado e o arquivo de teste onde ele mora.

1. `nome_do_teste` — <comportamento esperado> — `caminho/do/teste.ext`
2. ...

Obrigatorio em tarefa de comportamento (`feat`, `fix`, `test`). Omitido em
tarefa sem teste novo (`docs`, `chore`, `refactor` puro).

## Como verificar

Comando exato de lint e testsuite, e o resultado esperado.

Para cada ciclo, nesta ordem: escreva o teste, rode-o e confirme que **falha
pelo motivo certo**, so entao implemente ate ele passar. O vermelho existe
dentro da tarefa e nunca vira commit.

A tarefa so termina quando **todos os ciclos estao verdes** e as camadas de
teste afetadas passam. Tarefa nunca termina vermelha.

## Contexto necessario

`arquivo:linha` que o executor precisa ler antes de editar, e por que.
Referencia a secao do plan.md quando a decisao ja estiver la.

## Nao faca

Herdado de `## Nao entra neste trabalho` do plano, filtrado para o que e
tentador nesta tarefa especifica.
```

### 4. Skills taticas

Preencha o campo `skill` de forma dinamica: olhe as skills disponiveis em `.claude/skills/` do projeto atual e escolha **uma** que case com a natureza da **implementacao** da tarefa (ex.: uma skill de camada de dados para tarefa de query, uma skill de apresentacao para tarefa de view, uma skill de documentacao para tarefa de doc). Nao aponte skill de teste so porque a tarefa tem testes — toda tarefa de comportamento tem. O TDD ja esta prescrito em `## Ciclos TDD`. Se nenhuma existente casar, deixe o campo vazio — o executor segue o padrao existente no arquivo.

### 5. Tarefa de documentacao

Crie somente se o `## Documentacao afetada` do plano apontar um destino. Se o plano disse `Nenhuma`, nao invente tarefa de doc.

### 6. Gravar e commitar

**Grave os arquivos direto, sem pedir confirmacao.** A revisao e a tabela da etapa 7.

Toda operacao de git e responsabilidade exclusiva da skill `k-commit` — o `k-task` nunca roda `git` diretamente. Depois de gravar, pergunte ao usuario: comitar `tasks/` agora (via `k-commit`, modo 2b — commit) ou seguir pra `/k-execute` sem comitar?

- Se comitar: chame `k-commit` (modo 2b) com o diretorio `<raiz-de-specs>/<ts>-<slug>/tasks/` e a mensagem sugerida `docs(spec): tarefas de <titulo>`. Sem push — o `k-commit` para depois do commit.
- Se nao: os arquivos ficam pendentes na branch; o `k-execute` (ou uma chamada futura ao `k-commit`) lida com eles depois.

### 7. Encerrar

Tabela com uma linha por tarefa, na ordem de execucao:

```
<n> tarefas criadas em <raiz-de-specs>/<ts>-<slug>/tasks/

| # | Titulo | Doc |
|---|---|---|
| 1 | <titulo> | <raiz-de-specs>/<ts>-<slug>/tasks/01-<slug-da-tarefa>.md |
| 2 | <titulo> | <raiz-de-specs>/<ts>-<slug>/tasks/02-<slug-da-tarefa>.md |

Commit: <feito via k-commit: docs(spec): tarefas de <titulo> | pendente>
Proximo passo: /k-execute
```

O caminho em `Doc` e relativo a raiz do repositorio.

## Restricoes

- Nao altere codigo de aplicacao nesta etapa. O `k-task` descreve; o `k-execute` implementa.
- Nao tome decisao tecnica que o plano nao tomou. Se faltar decisao, volte ao `/k-plan`.
- Nunca rode `git` diretamente para commit, push, PR ou merge — sempre delegue ao `k-commit` (ver etapa 6).
- Nao crie tarefa que exija investigacao — o executor roda com contexto minimo e nao vai pesquisar.
- Achado fora do escopo notado durante a quebra vira stub via `k-spec` no **modo desvio**, nunca tarefa deste fluxo. Depois de registrar, volte para a etapa 2 (quebrar em tarefas), retomando da tarefa que voce estava montando quando o achado apareceu.
- **Nunca separe teste e implementacao do mesmo comportamento em tarefas diferentes.** Isso comita testsuite vermelha, que e exatamente o que este fluxo evita.
- Nao agrupe comportamentos diferentes numa tarefa so para reduzir o numero de arquivos.
- Nao proponha recursos de linguagem/versao alem do que o projeto ja usa nas instrucoes — respeite as convencoes documentadas (`CLAUDE.md`).
