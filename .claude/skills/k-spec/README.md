# k-spec — como usar

Etapa 1 de 4: **k-spec** → `k-plan` → `k-task` → `k-execute`.

## Invocacao

```
/k-spec erro 500 ao salvar banner sem imagem
/k-spec permitir que o parceiro edite a bolsa depois de publicada
/k-spec 20260812-093000-cpf-invalido-no-cadastro
/k-spec
```

Argumento que casa com uma pasta de spec = elaborar aquele stub. Texto livre = trabalho novo. Sem argumento, a skill mostra a fila de stubs pendentes e pergunta se voce quer elaborar um deles ou comecar algo novo.

## O que ela faz

1. Vai para `main` e da `pull` — o discovery roda sobre o codigo atual. Depois resolve o alvo (stub da fila ou trabalho novo).
2. Define **titulo** e **tipo** (`feature`, `bug`, `refactor`, `chore`, `docs`). Se o tipo nao for obvio, ela pergunta.
3. Le a documentacao e o codigo do fluxo antes de perguntar qualquer coisa.
4. Entrevista voce **uma pergunta por vez**, sempre com recomendacao e trade-off escrito.
5. Em tipo `bug`, prova que o bug existe e tenta reproduzir.
6. Escreve `spec.md` na pasta de specs do fluxo (`docs/specs/<AAAAMMDD-HHMMSS>-<slug>/` ou `documentation/specs/...`, conforme detectado), com `fluxo: ativo`.

## Estado do fluxo

Todo `spec.md` tem `fluxo:` no frontmatter — a unica fonte de verdade sobre o ciclo de vida:

| Valor | Significado | Quem escreve |
|---|---|---|
| `pendente` | achado capturado, ninguem elaborou; `tipo` vazio | `k-spec` modo desvio |
| `ativo` | spec elaborada | `k-spec` modo normal |
| `concluido` | tarefas fechadas e suite verde | `k-execute` |
| `descartado` | nao procede, ou absorvido por outro fluxo | `k-spec` / `k-execute` |

Spec antiga sem o campo le-se como `ativo`. `fluxo:` nao diz qual e o trabalho corrente — isso continua sendo `git branch --show-current`, e pode haver varios `ativo` ao mesmo tempo.

Listar a fila:

```bash
grep -rl "^fluxo: pendente" docs/specs/
```

## Modo desvio

Quando uma etapa do fluxo (`k-spec`, `k-plan`, `k-task`, `k-execute`, `k-scan`) topa com um bug ou pendencia **fora do escopo** do trabalho em andamento, ela chama o `k-spec` em modo desvio. Ele grava um **stub** — `fluxo: pendente`, `tipo` vazio, tres secoes (`## Achado`, `## Evidencia`, `## Por que nao entrou no fluxo atual`) e os campos de origem — commita via `k-commit` e devolve o controle no ponto exato onde a etapa parou.

O modo desvio **nao** sincroniza com a `main`, nao troca de branch, nao entrevista e nao investiga: ele existe justamente para nao consumir o contexto do trabalho em curso.

O stub fica na branch do fluxo em andamento. Ele so aparece na fila do `/k-spec` depois que aquele PR mergear — de proposito: a spec do desvio deve ser escrita contra o codigo ja atualizado.

## O que ela nao faz

- Em modo normal, nao cria branch e nao commita nada. O `spec.md` fica untracked ate o `k-plan`.
- Nao propoe solucao tecnica, nem diz onde mexer. Isso e `k-plan`.
- Nao cria issue no GitHub. O `spec.md` e o artefato.
- Nao corrige o achado do desvio, nem o transforma em tarefa do fluxo atual.

## Regra de localizacao

| Tipo | Pode citar `arquivo:linha`? |
|---|---|
| `bug` | Sim, so para localizar o sintoma |
| Os outros | Nao |

## Se voce nao tem um pedido, e sim um alvo

Para procurar bugs em um diretorio, modulo ou no diff da branch, comece por `/k-scan`.

## Saida

```
Spec criada: docs/specs/20260807-143205-corrigir-crop-banner/spec.md
Tipo: bug
Fluxo: ativo
Proximo passo: /k-plan
```

Em modo desvio:

```
Achado registrado: docs/specs/20260812-093000-cpf-invalido-no-cadastro/spec.md (fluxo: pendente)
Retomando: tarefa 02 do fluxo corrigir-crop-banner
```
