# k-task — como usar

Etapa 3 de 4: `k-spec` → `k-plan` → **k-task** → `k-execute`.

## Invocacao

```
/k-task
/k-task corrigir-crop-banner
```

Sem argumento, resolve pela branch atual (`fix/corrigir-crop-banner` → `docs/specs/*-corrigir-crop-banner`, ou `documentation/specs/...` conforme a raiz detectada).

## O que ela faz

1. Le `spec.md` e `plan.md`.
2. Quebra a implementacao em tarefas pequenas, **uma por comportamento observavel e por unidade de commit**, com teste e implementacao **juntos** na mesma tarefa.
3. Grava `tasks/NN-titulo-curto.md`, um arquivo por tarefa — **sem pedir confirmacao**.
4. Mostra a tabela de tarefas com o caminho de cada doc.
5. Pergunta se voce quer commitar `docs(spec): tarefas de <titulo>` agora ou seguir pro `/k-execute`.

## TDD dentro da tarefa

O ciclo red→green→refactor acontece **dentro** de uma tarefa so, nunca entre tarefas. Motivo: teste numa tarefa e implementacao na seguinte significa um commit com testsuite vermelha. Nao existe commit vermelho neste fluxo.

- **Ordem dentro da tarefa:** teste falha → implementacao minima (dados/regra → controller → view, so as camadas que o comportamento exige) → refactor. Termina verde.
- **Ordem entre tarefas:** por dependencia de comportamento. Documentacao por ultimo.
- **Criterio de quebra:** comportamento, nunca camada. Um comportamento que atravessa Service e Controller e uma tarefa; dois comportamentos que o consumidor distingue sao duas tarefas.
- Tarefa sem comportamento novo (doc, chore, refactor puro) nao ganha teste novo — mas ainda termina verde, com os testes existentes passando.

## Anatomia de um arquivo de tarefa

```markdown
---
numero: 1
titulo: Crop preserva a proporcao original
tipo: fix
status: pendente
motivo:
skill: <skill tatica do projeto, se houver uma aplicavel>
arquivos:
  - caminho/relativo/do/arquivo.ext
  - caminho/relativo/do/teste.ext
commit:
---

## O que fazer
## Ciclos TDD
## Como verificar
## Contexto necessario
## Nao faca
```

`status`: `pendente` → `em-andamento` → `concluida`, ou `bloqueada`.
`motivo`: preenchido pelo `k-execute` ao bloquear (falha no gate, ou `bloqueada por <slug-do-stub>`). E o que ele te mostra ao reencontrar a tarefa.
`commit`: preenchido pelo `k-execute` com o SHA.
`tipo`: comportamento novo/corrigido e `feat`/`fix` — o teste vai no mesmo commit. `test` so para teste sem mudanca de comportamento (caracterizar legado, cobrir buraco existente).
`## Ciclos TDD`: um item por ciclo red→green — nome do teste, comportamento esperado, arquivo de teste. Omitido em tarefa sem teste novo.

## Campo `skill`

Preenchido dinamicamente: a skill olha `.claude/skills/` do projeto e escolhe **uma** que casa com a natureza da **implementacao** (camada de dados, apresentacao, documentacao, refactor). Nao aponta skill de teste — toda tarefa de comportamento tem testes, e o TDD ja esta em `## Ciclos TDD`. Sem match, fica vazio.

## O que ela nao faz

- Nao toca codigo de aplicacao.
- Nao toma decisao tecnica nova. Se faltar decisao no plano, ela manda voce voltar ao `/k-plan`.
- Nao cria tarefa de documentacao se o plano disse `Nenhuma`.
- Nao separa teste e implementacao do mesmo comportamento em tarefas diferentes.
- Nao pede permissao pra gravar os arquivos.
- Nao transforma achado fora do escopo em tarefa. Ele vira stub via `k-spec` modo desvio, e ela retoma a quebra na tarefa que estava montando.

## Saida

```
2 tarefas criadas em docs/specs/20260807-143205-corrigir-crop-banner/tasks/

| # | Titulo | Doc |
|---|---|---|
| 1 | Crop preserva a proporcao original | docs/specs/20260807-143205-corrigir-crop-banner/tasks/01-crop-preserva-proporcao.md |
| 2 | Atualizar regra de negocio de banners | docs/specs/20260807-143205-corrigir-crop-banner/tasks/02-atualizar-doc-de-banners.md |

Commit: pendente
Proximo passo: /k-execute
```
