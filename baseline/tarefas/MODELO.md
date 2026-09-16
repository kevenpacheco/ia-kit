---
id: <numero>-<slug-curto>
fatia: greenfield | evolucao | legado | bug
repositorio: <url>
commit_base: <sha completo>
gabarito: <sha do commit ou URL do PR que resolveu>
entrada: k-spec | k-scan | k-commit
---

## Pedido

O texto exato entregue ao agente, igual nas duas rodadas. Escrito como um colega pediria —
sem dizer quais arquivos tocar, sem citar a solução.

## Por que esta tarefa

O que ela exercita no kit que as outras não exercitam. Tarefa que não exercita nada de
distinto só aumenta o custo da suite.

## Resultado conhecido

O que o gabarito fez, em duas ou três linhas. Serve para julgar "resolveu" sem depender de
quem está olhando.

## Como verificar

Comando que decide se resolveu, e o resultado esperado. Precisa ser objetivo: teste que
passa, saída que bate. "Ficou bom" não é critério.

## Armadilhas conhecidas

O que costuma dar errado aqui: caminho que parece a causa e não é, arquivo que atrai a
atenção à toa, teste que passa por motivo errado. Documentar isso evita tratar como falha do
kit o que é característica da tarefa.
