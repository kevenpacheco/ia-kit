# k-execute — como usar

Etapa 4 de 4: `k-spec` → `k-plan` → `k-task` → **k-execute**.

## Invocacao

```
/k-execute
/k-execute corrigir-crop-banner
```

Sem argumento, resolve pela branch atual.

## Regra central

**Uma tarefa por invocacao.** Roda a proxima `pendente`, commita, para. Voce reinvoca ate acabar.

## O que ela faz, por invocacao

1. Localiza a spec pela branch. Para se ela for um stub (`fluxo: pendente`) ou se tiver `depende_de:` apontando um fluxo que ainda nao entrou; se a dependencia ja caiu, limpa o campo e desbloqueia a tarefa.
2. Pega a primeira tarefa `pendente` (ou retoma a `em-andamento`), marca `em-andamento`.
3. Le `spec.md`, `plan.md` e o arquivo da tarefa. Invoca a skill tatica do campo `skill`.
4. Altera **apenas** os arquivos listados em `arquivos`, rodando o ciclo TDD de cada item de `## Ciclos TDD`: teste falha → implementa ate passar.
5. Gate: lint + as camadas de teste afetadas, com os comandos do projeto. 2 tentativas.
6. Commita via skill `k-commit` (sem push).
7. Marca `status: concluida` e preenche `commit: <SHA>`.

## Quando falha

Terceira falha no gate: marca `status: bloqueada`, registra a linha decisiva da saida, o diagnostico e os ciclos ja verdes no corpo da tarefa, e devolve pra voce. Nao commita, nao pula pra proxima.

Como teste e implementacao vivem na mesma tarefa, o trabalho parcial fica **no working tree, nao comitado**. E o preco de nunca ter testsuite vermelha no historico.

## Achado fora do escopo

Bug ou pendencia descoberta no caminho vira um **stub** de spec proprio, via `k-spec` modo desvio (`fluxo: pendente`), commitado na branch atual. **Nao e corrigido**, nao vira tarefa deste fluxo e nao entra de carona em commit.

O que acontece depois depende de o achado bloquear ou nao a tarefa em andamento:

- **Nao bloqueia** (o gate passa) — grava o stub e volta pra tarefa, no ponto exato onde parou.
- **Bloqueia** (o gate falha por causa dele) — grava o stub, marca a tarefa `bloqueada` com `motivo`, **para** e te pergunta: absorver o achado no escopo atual (voltando ao `/k-plan`) ou inverter a prioridade (grava `depende_de:` na spec e o desvio vira o proximo trabalho). A skill nao decide isso sozinha.

No encerramento ela lista os stubs que este fluxo gerou. Eles entram na fila do `/k-spec` **quando o PR mergear** — de proposito: a spec do desvio deve ser escrita contra o codigo ja atualizado.

## Encerramento (ultima tarefa)

1. Suite completa, com o comando do projeto. Vermelha = para, sem push.
2. Marca `fluxo: concluido` no `spec.md` (= tarefas fechadas + suite verde, nao "mergeado") e commita so esse arquivo.
3. Pergunta se e hora de subir. "Nao" = para, com tudo commitado localmente.
4. Push unico da branch.
5. Pergunta o alvo do PR (sem default fixo) e espera.
6. Abre o PR com corpo montado do `spec.md` + `plan.md`. Em branch `fix/`, o corpo traz causa raiz, correcao escolhida e opcoes descartadas.
7. Lista os stubs de desvio gerados por este fluxo.

## Nunca

- merge
- push nas branches protegidas do projeto (ex.: `main`)
- `git add .`, `git add -A`, `--no-verify`
- pular o gate de teste
- commitar com teste vermelho
- executar tarefa que nao existe como arquivo em `tasks/`
