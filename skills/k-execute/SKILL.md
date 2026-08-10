---
name: k-execute
description: Etapa final do fluxo de trabalho. Executa UMA tarefa pendente por invocacao, delegando para a skill tatica indicada no frontmatter, roda lint e testes do projeto, commita (via k-commit) e marca a tarefa como concluida. Na ultima tarefa roda a suite completa e pergunta se quer subir agora; se sim, delega ao k-commit o push, a revisao, o PR e o merge. Nunca roda git/gh diretamente. Use depois de /k-task.
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

Toda operacao de git e responsabilidade exclusiva da skill `k-commit` — o `k-execute` nunca roda `git`/`gh` diretamente. Chame `k-commit` no **modo 2b (commit)**: ela cuida da mensagem em Conventional Commits e das regras de branch, e para depois do commit — sem push, sem PR, sem merge. Push, revisao, PR e merge ficam com o Encerramento abaixo, depois da ultima tarefa, via `k-commit` no **modo 2c (ciclo de shipping)**.

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

Toda operacao de git/gh a partir daqui e responsabilidade exclusiva da skill `k-commit` — o `k-execute` nunca roda `git`/`gh` diretamente. O `k-execute` decide o **que** (alvo, titulo, corpo do PR, a partir do contexto de negocio de `spec.md`/`plan.md`); o `k-commit` decide o **como**.

Quando nao restar tarefa `pendente` nem `em-andamento`:

1. **Suite completa**, com o comando de teste do projeto (o mesmo identificado no gate da etapa 4), no ambiente que o projeto define:

Falhou: pare e reporte. Nao chame o `k-commit` com suite vermelha.

2. **Perguntar se e hora de subir**: todas as tarefas ja estao comitadas localmente (uma por uma, via `k-commit` modo 2b). Pergunte ao usuario: "quer subir agora (push + revisao + PR + merge, via `k-commit`) ou parar aqui?"

- Se nao: pare. As tarefas ficam comitadas localmente, nada e pushado. Nao ha proxima etapa `k-*` pra sugerir — a decisao de subir fica pra depois (manual, ou chamando `/k-execute` de novo).
- Se sim: continue para os passos seguintes.

3. **Perguntar o alvo do PR**, sem sugerir um default fixo — depende do fluxo de branches do projeto. Espere a resposta antes de abrir.

4. **Montar o titulo e o corpo do PR** a partir do `spec.md` e do `plan.md` — esse conteudo de negocio e responsabilidade do `k-execute`, nao do `k-commit`.

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

5. **Chamar o `k-commit`** no **modo 2c (ciclo de shipping)**, passando: branch atual, alvo escolhido (passo 3) e o titulo/corpo montados (passo 4, template acima). O `k-commit` executa, nessa ordem: revisao automatizada -> push unico -> abertura do PR (imprimindo a URL) -> pergunta de merge, so se o alvo for uma branch protegida do projeto (ex.: `main`) -> limpeza da branch se aprovado. Sem `gh` disponivel, o `k-commit` monta o corpo com o conteudo recebido e instrui a abertura manual.

6. Se houver achados fora do escopo registrados durante as tarefas, liste-os e pergunte se o usuario quer rodar `/k-spec` para cada um. Isso e paralelo ao passo 5 e nao depende dele.

## Restricoes

- Nunca rode `git`/`gh` diretamente para commit, branch, push, PR, CI ou merge — sempre delegue ao `k-commit` (etapa "Commitar" e passo 5 do Encerramento).
- Nao pule o gate de teste "porque a mudanca e pequena".
- Nao execute tarefa que nao existe como arquivo em `tasks/`. Se surgir trabalho novo, volte ao `/k-task`.
- Nao pule tarefa `bloqueada`.
- Nao proponha recursos de linguagem/versao alem do que o projeto ja usa.
