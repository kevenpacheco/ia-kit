---
name: k-execute
description: Etapa final do fluxo de trabalho. Executa UMA tarefa pendente por invocacao, delegando para a skill tatica indicada no frontmatter, roda lint e testes do projeto, commita e marca a tarefa como concluida. Na ultima tarefa roda a suite completa, faz push e abre o PR. Use depois de /k-task.
---

# k-execute

Etapa 4 de 4: `k-spec` → `k-plan` → `k-task` → `k-execute`.

## Quando usar

Depois que `/k-task` gravou as tarefas. Invocacao:

```
/k-execute                        # infere pela branch atual
/k-execute corrigir-crop-banner   # por slug
```

## Regra central

**Uma tarefa por invocacao.** Pegar a proxima `pendente`, concluir, commitar, parar. Nao encadeie tarefas na mesma execucao — e isso que impede o contexto de estourar e o padrao do projeto de se perder no meio do caminho.

## Procedimento

### 1. Localizar a spec

Se o slug veio por argumento, use. Senao, resolva pela branch: `git branch --show-current` → `<prefixo>/<slug>` → `<raiz-de-specs>/*-<slug>`, tentando `docs/specs/` e `documentation/specs/`.

Se o glob achar mais de um diretorio, ou a branch nao tiver slug reconhecivel, **liste e pergunte**. Nao chute.

Se estiver numa branch protegida do projeto (ex.: `main`), **pare** — a branch e criada pelo `k-plan`.

### 2. Escolher a tarefa

Liste `tasks/*.md` em ordem numerica e pegue a **primeira** com `status: pendente`.

- Se houver alguma `em-andamento`, ela e a escolhida — a execucao anterior foi interrompida. Verifique o estado do working tree antes de continuar.
- Se houver alguma `bloqueada` antes da primeira `pendente`, **pare** e mostre o motivo registrado. Nao pule tarefa bloqueada.
- Se nao houver nenhuma pendente, siga para "Encerramento".

Marque `status: em-andamento` antes de comecar.

### 3. Executar

- Leia `spec.md`, `plan.md` e o arquivo da tarefa **antes de tocar em arquivo**. O contexto vem dos arquivos, nao da memoria da sessao.
- Se o frontmatter tiver `skill`, invoque essa skill tatica e siga o padrao dela.
- Altere **apenas** os arquivos listados em `arquivos`. Se faltar arquivo, atualize o frontmatter da tarefa e explique o porque; nao alargue o escopo em silencio.
- Respeite o `## Nao faca` da tarefa e o `## Nao entra neste trabalho` do plano.
- TDD: tarefa de teste termina com o teste falhando pelo motivo certo; tarefa de implementacao termina com ele passando.

### 4. Gate de conclusao

Obrigatorio antes do commit. Extraia o comando de lint e de teste da documentacao do projeto (`CLAUDE.md`, `README`); se nao estiver documentado, pergunte ao usuario uma vez. Rode no ambiente que o projeto define (container, local, etc.) — nunca fora dele quando o projeto exigir um ambiente especifico.

Rode **apenas a suite/camada de teste afetada** pela tarefa. Camadas que dependem de infraestrutura externa (ex.: integracao, E2E) exigem o ambiente correspondente de pe.

Se falhar: corrija e rode de novo, no maximo **2 tentativas**. Na terceira falha, **pare**: marque `status: bloqueada`, registre no corpo da tarefa a linha decisiva da saida e o diagnostico, e devolva ao usuario. Nao commite.

### 5. Commitar

Use a skill `k-commit`. Ela cuida da mensagem em Conventional Commits e das regras de branch.

**Override desta skill:** a skill `k-commit` faz push apos cada commit; aqui o push acontece **uma unica vez**, no encerramento. Commite sem push durante as tarefas.

Adicione somente os arquivos da tarefa, mais o arquivo da propria tarefa e os `docker-compose` quando o bump se aplicar. Nunca `git add .`.

### 6. Fechar a tarefa

No frontmatter do arquivo da tarefa:

- `status: concluida`
- `commit: <SHA curto>`

Isso entra no mesmo commit da tarefa.

### 7. Reportar e parar

```
Tarefa <n> concluida: <resumo em uma linha>
Commit: <tipo(escopo): descricao>
Restam <k> tarefas. Proximo passo: /k-execute
```

## Achado fora do escopo

Bug ou problema descoberto no caminho que **nao** faz parte da spec atual:

1. Acrescente ao `spec.md` da spec corrente, no fim, uma secao `## Achados fora do escopo` com um item por achado: `arquivo:linha`, condicao de entrada e comportamento errado.
2. **Nao corrija.** Nao vira tarefa, nao vira commit carona.
3. Continue a tarefa em andamento.

No encerramento, liste os achados e pergunte se o usuario quer rodar `/k-spec` para cada um.

## Encerramento

Quando nao restar tarefa `pendente` nem `em-andamento`:

1. **Suite completa**, com o comando de teste do projeto (o mesmo identificado no gate da etapa 4), no ambiente que o projeto define:

Falhou: pare e reporte. Nao faca push com suite vermelha.

2. **Push unico**:

```bash
git push origin <branch-atual>
```

3. **Perguntar o alvo do PR**, sem sugerir um default fixo — depende do fluxo de branches do projeto. Espere a resposta antes de abrir.

4. **Abrir o PR.** Detecte o mecanismo do projeto: CLI (`gh`, `glab`) se disponivel, senao monte o corpo abaixo e instrua o usuario a abrir manualmente. Corpo montado a partir do `spec.md` e do `plan.md`.

Branch `feat/`, `refactor/`, `chore/`, `docs/`:

```
Titulo: <titulo da spec>
Base: <alvo>

Spec: `<raiz-de-specs>/<ts>-<slug>/`

## O que muda

<objetivo e escopo, vindos do spec.md>

## Como testar

<testes manuais, vindos do plan.md>
```

Branch `fix/`:

```
Titulo: <titulo da spec>
Base: <alvo>

Spec: `<raiz-de-specs>/<ts>-<slug>/`

## Causa raiz

<arquivo:linha e por que o comportamento errado acontece, vindo do plan.md>

## Correcao escolhida

<opcao adotada e por que ela resolve a causa, nao o sintoma>

## Opcoes descartadas

<cada alternativa do plano e o motivo de nao ter sido escolhida>

## Regressao coberta

<teste que falhava antes e passa depois, ou a justificativa do plano para nao haver teste automatizado>

## Como testar

<testes manuais, vindos do plan.md>
```

Com `gh` disponivel, equivalente a `gh pr create --base <alvo> --title "<titulo>" --body-file -` com o corpo acima via heredoc.

5. Imprima a URL do PR (ou a confirmacao de abertura manual) e, se houver, a lista de `## Achados fora do escopo`.

## Restricoes

- **Nunca faca merge.** O fluxo termina no PR aberto. O merge para as branches protegidas do projeto e manual, feito pela equipe.
- **Nunca faca push nas branches protegidas do projeto (ex.: `main`).**
- Nunca use `--no-verify`, `git add .` ou `git add -A`.
- Nao pule o gate de teste "porque a mudanca e pequena".
- Nao execute tarefa que nao existe como arquivo em `tasks/`. Se surgir trabalho novo, volte ao `/k-task`.
- Nao pule tarefa `bloqueada`.
- Nao proponha recursos de linguagem/versao alem do que o projeto ja usa.
