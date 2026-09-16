# k-task — quebrar em tarefas

Etapa 3 de 4: `k-spec` → `k-plan` → **k-task** → `k-execute`.

Converte a decisão técnica em roteiro executável por um agente que **não vai investigar
nada**. Normalmente roda encadeada pelo `k-plan`, em invocação separada — assim não herda o
contexto de investigação da etapa anterior.

| Preciso de | Leia |
|---|---|
| frontmatter e corpo da tarefa, granularidade | `.ia-kit/referencias/tarefa-formato.md` |
| achado fora do escopo | `.ia-kit/referencias/desvio.md` |

---

## 1. Ler spec e plano

Inteiros. O `tipo` da spec e a opção `Escolhida` do plano governam a quebra. O
`modo_execucao` do plano governa a granularidade.

Sem `plan.md`, ou spec com `fluxo: pendente`: pare e mande rodar a etapa anterior.

Branch protegida: **pare**. A branch é criada pelo `k-plan`.

## 2. Quebrar

**Uma tarefa = um comportamento observável = uma unidade de commit.**

Teste e implementação do mesmo comportamento ficam na **mesma** tarefa. Nunca separe
"escrever o teste" de "fazer o teste passar" em tarefas diferentes: isso commita suite
vermelha, que é exatamente o que este fluxo evita.

**Dentro da tarefa:** teste que falha → implementação mínima (dados e regra → controller →
view, só as camadas que o comportamento exige) → refactor. Termina verde.

**Entre tarefas:** ordem por dependência de comportamento. Documentação por último.

Em `bug`, a **tarefa 1 é sempre a que contém o teste de regressão e a correção** — falha no
início, passa no fim. Exceção única: o plano registrou `## Sem teste automatizado`.

Regras de tamanho:

- Não cabe num commit pequeno e focado: quebre.
- Quebre por comportamento, nunca por camada.
- Sem teto de ciclos por tarefa. O limite é o comportamento, não a contagem de testes.
- Falta decisão que o plano não tomou: **volte ao `/k-plan`**. Não empurre decisão para o
  executor.

Tarefa sem comportamento novo — doc, chore, refactor puro, migração — é tarefa própria e
**não** ganha teste novo. A regra é *toda tarefa termina verde*, não *toda tarefa tem teste*.

## 3. Escrever os arquivos

Formato em `referencias/tarefa-formato.md`. Grave direto, **sem pedir confirmação** — a
revisão é a tabela do passo 5.

Preencha `arquivos` com os caminhos exatos, incluindo os de teste. É essa lista que limita o
executor.

## 4. Tarefa de documentação

Só se `## Documentacao afetada` do plano apontar um destino. Plano disse `Nenhuma`: não
invente tarefa de doc.

## 5. Commitar e encerrar

Commite `tasks/` via `k-commit`, mensagem `docs(spec): tarefas de <titulo>`. Sem push.

```
<n> tarefas criadas em <raiz>/<ts>-<slug>/tasks/

| # | Titulo | Doc |
|---|---|---|
| 1 | <titulo> | <caminho> |

Modo: <modo_execucao>
Próximo passo: /k-execute
```

Pare aqui. O `k-execute` roda em invocação própria — uma tarefa por vez.

## Nunca

- Alterar código de aplicação. O `k-task` descreve; o `k-execute` implementa.
- Tomar decisão técnica que o plano não tomou.
- Criar tarefa que exija investigação — o executor roda com contexto mínimo e não vai
  pesquisar.
- Separar teste e implementação do mesmo comportamento em tarefas diferentes.
- Agrupar comportamentos distintos numa tarefa só para reduzir o número de arquivos.
- Rodar `git` de escrita diretamente — sempre pelo `k-commit`.
- Transformar achado fora do escopo em tarefa deste fluxo — vai para o modo desvio, e você
  retoma a tarefa que estava montando.
