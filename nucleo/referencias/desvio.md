# Modo desvio — achado fora do escopo

Qualquer etapa do fluxo (`k-spec`, `k-plan`, `k-task`, `k-execute`, `k-scan`) que topa com um
problema fora do escopo do trabalho em andamento grava um **stub** e devolve o controle no
ponto exato onde parou.

O objetivo é **preservar o contexto de quem chamou**. Por isso o modo desvio não sincroniza
com a principal, não troca de branch, não entrevista e **não dispara subagente de
investigação** — investigar aqui queimaria justamente o contexto que o stub existe para
proteger. O stub registra o que a etapa já viu, nada além.

---

## 1. Verificar duplicata

```bash
grep -rlE "^fluxo: (pendente|descartado)" <raiz-de-specs>/
```

Nos arquivos encontrados, procure os caminhos citados no achado:

- casou com stub `pendente`: mostre e pergunte se é o mesmo problema. Se for, **não grave
  stub novo** — acrescente a evidência ao `## Evidencia` do existente.
- casou com stub `descartado`: avise que aquele arquivo já gerou achado descartado, com o
  motivo, e pergunte se grava assim mesmo.

`concluido` fica fora da busca de propósito: bug corrigido que volta é achado novo.

Limite conhecido: pega duplicata que cita o mesmo arquivo, não o mesmo bug visto de outro
arquivo.

Chamador que grava vários de uma vez (`k-scan`): a verificação roda **também entre os
achados do próprio lote**.

## 2. Gravar o stub

Mesma raiz e convenção de pasta `<ts>-<slug>` da spec normal. Título e slug são gerados do
sintoma pela etapa que detectou, sem confirmação — o `k-spec` normal corrige depois.

```yaml
---
titulo: <curto, gerado do sintoma>
tipo:
fluxo: pendente
criado_em: <AAAA-MM-DD HH:MM:SS>
origem_etapa: k-spec | k-plan | k-task | k-execute | k-scan
origem_spec: <slug da spec em andamento; vazio quando veio do k-scan>
origem_task: <NN-slug da tarefa; vazio quando não veio do k-execute>
origem_commit: <SHA curto do HEAD no momento do desvio>
---
```

`tipo` fica **vazio** de propósito: é ele que obriga o stub a passar pelo `k-spec` normal
antes do `k-plan`. Não chute — nem todo desvio é bug.

`origem_commit` é âncora temporal, não reprodução: no `k-execute` o desvio quase sempre
acontece com a árvore suja.

Corpo, três seções e nada mais:

```markdown
## Achado
`arquivo:linha`, condição de entrada que dispara, comportamento errado resultante.

## Evidencia
O que foi observado de fato: linha decisiva da saída, log, ou o trecho que prova a
condição. Nunca suposição.

## Por que nao entrou no fluxo atual
Uma linha. "fora do escopo da spec <slug>", "toca outro módulo", "exige decisão de produto".
```

Documento de captura, não rascunho de spec. **Não** use os cabeçalhos do `spec.md` completo:
stub parecido com spec pronta é lido como contrato duas semanas depois.

## 3. Commitar

Chame o `k-commit` com o arquivo do stub, mensagem `docs(spec): registrar achado <titulo>` e
a **branch atual fixada como destino** — o stub tem contexto diferente do da branch de
propósito, e trocar de branch no meio quebraria o trabalho em andamento. Sem push, sem PR.

Exceção: desvio acontecendo em branch protegida (típico do `k-scan`) faz o `k-commit` criar
uma branch para receber o stub. Avise em qual branch os stubs ficaram e que ela precisa de PR
para entrarem na fila.

## 4. Devolver o controle

```
Achado registrado: <raiz-de-specs>/<ts>-<slug>/spec.md (fluxo: pendente)
Retomando: <o ponto exato onde a etapa chamadora parou>
```

Volte para a etapa chamadora, no ponto exato. **Nunca** mude de etapa, nunca corrija o
achado, nunca transforme o achado em tarefa do fluxo atual.

## Quando o achado bloqueia

Só o `k-execute` distingue isso, pela evidência do gate:

- **Não bloqueia** (gate passa apesar dele): grave o stub e volte à tarefa.
- **Bloqueia** (o gate falha por causa dele): grave o stub, marque a tarefa `bloqueada` com
  `motivo: bloqueada por <slug-do-stub>`, **pare** e apresente duas saídas ao usuário:

| Saída | O que acontece |
|---|---|
| Absorver no escopo atual | stub vira `descartado` apontando quem absorveu; volta ao `/k-plan` e `/k-task` |
| Inverter a prioridade | grava `depende_de: <slug>` na spec deste fluxo; o desvio vira o próximo trabalho |

**Não decida sozinho.** Alargar escopo é decisão do usuário.

## A fila só enxerga o que já entrou

Stub gravado numa branch aberta não aparece na fila do `/k-spec` até aquele PR mergear. É
proposital: a spec do desvio deve ser escrita contra o código **depois** que o fluxo pai
entrou, não contra um código que ainda vai mudar.
