# k-revisao — comentários do PR viram tarefas

Fecha o ciclo: o revisor humano comenta no PR, esta etapa lê, classifica e transforma o que
for mudança pedida em tarefa do fluxo. Quem executa continua sendo o `k-execute`.

Não altera código, não commita, não responde no PR por conta própria.

---

## 1. Localizar o PR

Pela branch atual. Sem PR aberto: pare e diga que não há o que revisar.

Colete, com `gh`:

- threads de review não resolvidos
- corpo das reviews (aprovada, mudanças pedidas, comentário)
- comentários soltos na conversa do PR

Ignore o que já foi resolvido e o que veio de bot de CI — ruído de pipeline não é pedido de
revisor.

## 2. Reler o contexto do fluxo

`spec.md` e `plan.md` da spec correspondente à branch. Sem isso não dá para julgar se um
pedido pertence a este trabalho ou não.

## 3. Classificar cada comentário

| Classe | Critério | Destino |
|---|---|---|
| `mudanca` | pede alteração concreta, dentro do escopo da spec | vira tarefa |
| `duvida` | pergunta, pedido de contexto | rascunho de resposta |
| `fora-de-escopo` | problema real, mas de outro trabalho | vira stub de spec |
| `conflito` | contradiz decisão registrada na spec ou no plano | **para e pergunta** |
| `ruido` | elogio, nota sem ação | ignora |

`conflito` nunca vira tarefa em silêncio. O revisor pode estar certo e a spec
desatualizada, ou o contrário — quem decide é o usuário, não esta etapa.

## 4. Apresentar e confirmar

Mostre a tabela antes de gravar qualquer coisa:

```
PR #42 — 6 comentários não resolvidos

| # | Autor   | Classe         | Resumo                                    |
|---|---------|----------------|-------------------------------------------|
| 1 | revisor | mudanca        | extrair validacao repetida para o service |
| 2 | revisor | duvida         | por que o guard ficou no controller?      |
| 3 | revisor | fora-de-escopo | upload sem validar mime em outro modulo   |
| 4 | revisor | conflito       | pede exception onde a spec definiu Result |

Confirma a classificação? (ok / corrigir N=classe)
```

Classificação errada aqui custa caro: pedido tratado como `mudanca` quando era `conflito`
faz o fluxo desfazer uma decisão registrada sem ninguém perceber.

## 5. Gravar

- `mudanca` → uma tarefa por comportamento em `tasks/NN-*.md`, seguindo a anatomia de tarefa
  do `k-task`. Registre o número do comentário no corpo, para fechar o thread depois.
- `fora-de-escopo` → stub de spec (`fluxo: pendente`), como no modo desvio. **Não** entra de
  carona neste PR.
- `duvida` → rascunho de resposta, apresentado ao usuário. Nada é publicado sem aprovação:
  resposta em PR é comunicação com outra pessoa, não operação interna.
- `conflito` → nada é gravado até o usuário decidir.

## 6. Devolver

```
PR #42: 2 tarefas criadas, 1 stub, 1 resposta aguardando sua aprovação, 1 conflito aberto.
Próximo passo: /k-execute
```

## Depois da correção

O `k-execute` roda tarefa a tarefa, cada commit com o gate. No fim, push incremental
atualiza o PR — **commits novos, nunca force-push**, senão os comentários do revisor ficam
órfãos.

Thread só é marcado como resolvido depois que a correção está commitada e empurrada. Marcar
antes transforma a revisão em teatro.

## Limite de rodadas

Acima de três rodadas de comentário no mesmo PR, pare e sinalize: ou a spec está errada, ou
o PR está grande demais e deveria ter sido dois. Continuar corrigindo indefinidamente
mascara um problema de escopo — e o agente, diferente do humano, não se cansa de aceitar
pedido.

## Nunca

- Publicar resposta no PR sem aprovação.
- Aceitar pedido que contradiz a spec sem sinalizar como `conflito`.
- Corrigir achado fora do escopo dentro deste PR.
- `--force` em branch com review em andamento.
- Marcar thread resolvido antes de a correção estar empurrada.
