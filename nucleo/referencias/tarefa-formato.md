# Formato do arquivo de tarefa

Um arquivo por tarefa, em `<raiz>/<ts>-<slug>/tasks/`, numerado em ordem de execução com dois
dígitos. Nome pelo **comportamento**, nunca pela camada, nunca com a palavra "teste":

```
tasks/01-crop-preserva-proporcao.md
tasks/02-crop-respeita-area-segura.md
tasks/03-atualizar-doc-de-banners.md
```

A tarefa precisa ser suficiente sozinha: o executor lê a tarefa, o `spec.md` e o `plan.md`, e
sabe exatamente o que fazer — sem investigar nada.

---

## Frontmatter

```yaml
---
numero: 1
titulo: Crop preserva a proporcao original
tipo: fix
status: pendente
motivo:
skill: <skill tática do projeto, se houver uma aplicável>
arquivos:
  - caminho/relativo/do/arquivo.ext
  - caminho/relativo/do/teste.ext
---
```

| Campo | Conteúdo |
|---|---|
| `numero` | inteiro, igual ao prefixo do nome do arquivo |
| `titulo` | tarefa de comportamento nomeia o comportamento; as demais, imperativa |
| `tipo` | tipo de commit desta tarefa: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`. Comportamento novo ou corrigido é `feat`/`fix`, com o teste no mesmo commit. `test` só quando adiciona teste **sem** mudar comportamento |
| `status` | `pendente` → `em-andamento` → `concluida`, ou `bloqueada`. Nasce `pendente` |
| `motivo` | vazio; o `k-execute` preenche ao bloquear (falha no gate, ou `bloqueada por <slug>`) |
| `skill` | skill tática do projeto que casa com a natureza da **implementação**. Vazia se nenhuma casar |
| `arquivos` | os arquivos exatos que a tarefa pode tocar, **incluindo os de teste** |

## Corpo

```markdown
## O que fazer
Descrição imperativa e concreta. Sem "investigar", sem "avaliar" — a investigação acabou no
k-plan.

## Ciclos TDD
Um item por ciclo vermelho→verde, na ordem de execução: nome do teste, comportamento
esperado, arquivo de teste.

1. `nome_do_teste` — <comportamento esperado> — `caminho/do/teste.ext`

Obrigatório em tarefa de comportamento (`feat`, `fix`, `test`). Omitido em tarefa sem teste
novo (`docs`, `chore`, `refactor` puro).

## Como verificar
Resultado esperado. Os comandos saem do contrato do projeto, não daqui.

Para cada ciclo, nesta ordem: escreva o teste, rode e confirme que falha **pelo motivo
certo**, só então implemente até passar. O vermelho existe dentro da tarefa e nunca vira
commit.

## Contexto necessario
`arquivo:linha` que o executor precisa ler antes de editar, e por quê. Referencie a seção do
plan.md quando a decisão já estiver lá.

## Nao faca
Herdado de `## Nao entra neste trabalho` do plano, filtrado para o que é tentador nesta
tarefa específica.
```

## Granularidade por modo

`modo_execucao` do `plan.md` decide o tamanho:

| Modo | Tarefa |
|---|---|
| `greenfield` | pode agrupar comportamentos próximos que caem no mesmo commit |
| `evolucao` | um comportamento observável por tarefa |
| `legado` | a menor unidade que ainda termina verde; contexto necessário mais detalhado |

O critério de quebra continua sendo **comportamento, nunca camada**. Um comportamento que
atravessa service e controller é uma tarefa; dois comportamentos que o consumidor distingue
são duas tarefas.

## Skill tática

Olhe as skills do projeto e escolha **uma** que case com a natureza da implementação: camada
de dados, apresentação, documentação, refatoração. Não aponte skill de teste só porque a
tarefa tem testes — toda tarefa de comportamento tem, e o TDD já está em `## Ciclos TDD`.
Nenhuma casou: deixe vazio, e o executor segue o padrão existente no arquivo.
