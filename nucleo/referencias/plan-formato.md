# Formato do `plan.md`

Decisão técnica registrada: onde a mudança mora, qual a menor solução que resolve, o que não
entra, e o que pode quebrar.

Gravado ao lado do `spec.md`, na mesma pasta do fluxo.

---

## Frontmatter

```yaml
---
spec: spec.md
tipo_de_mudanca: legado puro | contexto em evolucao
modo_execucao: greenfield | evolucao | legado
---
```

`modo_execucao` sai da classificação desta etapa e governa o resto do fluxo: granularidade
das tarefas no `k-task` e quanto o `k-execute` decide sozinho. Ele sobrescreve, para este
fluxo, o `execucao.modo_padrao` do contrato.

## Corpo

Omita as seções que não se aplicam ao tipo. Não deixe seção vazia com "N/A".

```markdown
## Classificacao
**<legado puro | contexto em evolucao>** — justificativa em uma linha.

## Fluxo atual
Entrada → controller/action → service/model/helper → query → resposta/view, com
`arquivo:linha`.

## Causa raiz
Só `bug`. `arquivo:linha` — o que viola a invariante e sob qual condição de entrada.

## Alcance do defeito
Só `bug`. Quem mais é afetado pelo mesmo ponto: outros chamadores, portais, rotas.

## Opcoes
A. <descricao> — <n> linhas — resolve <o que> / não resolve <o que> — risco <...>
B. <descricao> — ... ← recomendada
C. <descricao> — ...

**Escolhida:** <letra> — por que resolve a causa.

## Onde a regra deve morar
Camada escolhida e por quê. Camada nova exige dor concreta que a justifique.

## Reuso identificado
O que já existe e será aproveitado (`arquivo:linha`). Nada encontrado: diga que procurou.

## Banco de dados
Tabelas, colunas, alteração de schema, índice, impacto em volume. Omita se não toca banco.

## Dependencias externas
Integração de terceiro, contrato, credencial, timeout, comportamento em falha. Omita se não
houver.

## Nao entra neste trabalho
Lista explícita: renomeação, extração de classe, formatação, melhoria de nome, bug vizinho,
otimização. Serve para o executor recusar carona.

## Regressao coberta
Qual teste falha antes e passa depois, e em qual camada. Sem teste automatizado possível, a
seção vira `## Sem teste automatizado` com o motivo e os testes manuais que cobrem o caso.

## Riscos de regressao
O que pode quebrar e quem consome o ponto alterado.

## Testes manuais sugeridos
Passo a passo verificável. Em `bug`, inclua o caso que reproduzia o problema.

## Documentacao afetada
Qual documento muda e por quê, ou `Nenhuma` com justificativa.
```

## Gatilhos de documentação afetada

| Mudou | Documento |
|---|---|
| contrato de endpoint | documentação de API |
| regra de negócio | documentação de regras |
| camada, fluxo ou decisão estrutural | documentação de arquitetura |
| a doc descrevia o comportamento bugado como correto | corrigir a doc |
| o bug revelou regra não documentada | registrar a regra |

Doc já dizia o certo e o código é que estava errado: `Nenhuma`.

## Classificação da mudança

Convenção documentada do projeto prevalece. Na ausência dela:

| Classe | Significa |
|---|---|
| legado puro | priorizar compatibilidade, padrão existente e diff mínimo. Não criar camada nova |
| contexto em evolução | regra pode ir para service ou objeto de negócio, com isolamento em relação ao legado |

Separar em camada quando: regra de negócio relevante, invariante a proteger, conceito
compartilhado por vários fluxos. **Não** separar quando: CRUD simples, consulta
administrativa, ajuste visual, bugfix pequeno.

## Escala das opções

| Opção | Característica |
|---|---|
| remendo no sintoma | guard no chamador; barato, deixa os outros chamadores quebrados |
| solução na causa | arruma onde a invariante é violada; costuma ser a recomendada |
| mudança estrutural | camada nova, mudança de contrato, refatoração; quase sempre fora de escopo |

Mudança estrutural só entra se a solução na causa for impossível sem ela — e aí avalie se o
trabalho não deveria virar uma spec própria de `feature` ou `refactor`.

Só existe um caminho viável: não invente opções. Registre o caminho único e o porquê.
