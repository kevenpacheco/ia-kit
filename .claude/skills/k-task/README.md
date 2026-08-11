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
2. Quebra a implementacao em tarefas pequenas, **uma por unidade de commit**, na ordem teste → dados/regra → controller → view → documentacao.
3. Grava `tasks/NN-titulo-curto.md`, um arquivo por tarefa.
4. Mostra a lista e espera sua confirmacao.
5. Commita `docs(spec): tarefas de <titulo>`.

## Anatomia de um arquivo de tarefa

```markdown
---
numero: 2
titulo: Corrigir calculo de offset no crop
tipo: fix
status: pendente
skill: <skill tatica do projeto, se houver uma aplicavel>
arquivos:
  - caminho/relativo/do/arquivo.ext
commit:
---

## O que fazer
## Como verificar
## Contexto necessario
## Nao faca
```

`status`: `pendente` → `em-andamento` → `concluida`, ou `bloqueada`.
`commit`: preenchido pelo `k-execute` com o SHA.

## Campo `skill`

Preenchido dinamicamente: a skill olha `.claude/skills/` do projeto e escolhe a que casa com a natureza da tarefa (teste, camada de dados, apresentacao, documentacao, refactor). Sem match, fica vazio.

## O que ela nao faz

- Nao toca codigo de aplicacao.
- Nao toma decisao tecnica nova. Se faltar decisao no plano, ela manda voce voltar ao `/k-plan`.
- Nao cria tarefa de documentacao se o plano disse `Nenhuma`.

## Saida

```
3 tarefas criadas em docs/specs/20260807-143205-corrigir-crop-banner/tasks/
1. Teste que reproduz o crop deslocado — tests/crop-image-from-center.test.ts
2. Corrigir calculo de offset — src/helpers/crop.ts
3. Atualizar regra de negocio de banners — docs/business-rules/banners.md
Proximo passo: /k-execute
```
