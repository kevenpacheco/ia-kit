# k-plan — decisão técnica

Etapa 2 de 4: `k-spec` → **k-plan** → `k-task` → `k-execute`.

Transforma o contrato de comportamento em decisão registrada. Decide **o que fazer**; o
`k-task` quebra em passos.

| Preciso de | Leia |
|---|---|
| seções do plano, classificação, escala de opções | `.ia-kit/referencias/plan-formato.md` |
| como perguntar | `.ia-kit/referencias/entrevista.md` |
| achado fora do escopo | `.ia-kit/referencias/desvio.md` |

**Princípio: resolver a causa, não o sintoma, com o mínimo de código.** Remendo no chamador
some do radar e volta pelo próximo chamador. Mas "na origem" não autoriza reescrever o
módulo: a mudança para no ponto onde a invariante foi violada.

---

## 1. Ler a spec

Inteira, com frontmatter. O `tipo` governa as seções obrigatórias do plano.

`fluxo: pendente` ou `tipo` vazio: pare e mande rodar `/k-spec <slug>` antes. Stub fica fora
da inferência automática mesmo sendo a pasta mais recente sem `plan.md` — sem `tipo` não há
prefixo de branch.

Mais de uma candidata: **liste e pergunte**. Nunca chute a spec.

## 2. Investigar

Subagentes **somente de leitura**, um por eixo, todos na mesma mensagem.

| Tipo | Eixos |
|---|---|
| `feature`, `refactor`, `chore` | fluxo atual (rota → controller → service → query → view); reuso já existente; consumidores do dado ou da rota; documentação existente |
| `bug` | caminho até a falha, da entrada até onde o valor errado nasce; outros chamadores do ponto suspeito; histórico (`git log -L`, `git blame`); cobertura existente — já há teste tocando isso, e por que não pegou? |
| `docs` | o que a documentação afirma hoje; onde o comportamento real diverge |

Conclusão com `arquivo:linha`, nunca despejo de código.

Pesquisa externa só quando o código não responde: contrato de integração de terceiro,
comportamento de biblioteca já usada. Nunca busque "melhor prática" genérica — a resposta
costuma violar restrição de stack já documentada no projeto.

## 3. Grade de suspeitas — só `bug`

Verifique explicitamente cada item antes de fechar a causa:

- [ ] nulo ou vazio não tratado, no retorno ou no parâmetro
- [ ] índice ou chave inexistente
- [ ] condição invertida ou negada errado
- [ ] consulta com filtro, junção ou ordenação errada
- [ ] dependência implícita de ordem de chamada
- [ ] efeito colateral em ponto compartilhado por vários fluxos

Item descartado não precisa aparecer no plano. O item que **é** a causa aparece com a
evidência.

## 4. Provar a causa raiz — só `bug`

A causa raiz é onde o comportamento correto deixou de valer, não onde o erro apareceu na
tela. Prove com `arquivo:linha` e a condição de entrada que dispara.

Não consegue provar: **não adivinhe**. Volte a investigar ou devolva ao usuário dizendo o que
falta.

## 5. Classificar e escolher o modo

Classifique a mudança (legado puro ou contexto em evolução) conforme
`referencias/plan-formato.md`, e derive o `modo_execucao` deste fluxo:

| Classificação e tamanho | Modo |
|---|---|
| código novo, poucos consumidores | `greenfield` |
| base viva, em mudança | `evolucao` |
| legado puro, alto acoplamento | `legado` |

O modo governa granularidade de tarefa e autonomia do executor. Em base legada a IA rende
perto de zero quando decide sozinha — é por isso que o modo existe.

## 6. Comparar opções

2 a 3 opções reais. Para cada uma: quanto de código muda, o que resolve, o que **não**
resolve, risco de regressão. Recomende a menor que resolve a causa.

## 7. Confirmar com o usuário

Mostre classificação, causa raiz e opções, e **espere a escolha**. Esta é a decisão central
do fluxo; não a tome sozinho — em nenhum modo.

## 8. Escrever o plan.md

Formato em `referencias/plan-formato.md`. Grave direto, sem pedir confirmação.

## 9. Criar a branch e commitar

Peça ao `k-commit` a branch `<prefixo>/<slug>`, a partir da principal atualizada. O slug é o
mesmo da pasta da spec, **sem o timestamp** — é assim que `k-task` e `k-execute` reencontram
a spec. Automático, sem perguntar: as etapas seguintes precisam da branch de pé.

Alteração local não commitada de outro trabalho: **pare e pergunte**. Sem `stash` automático.

Depois, commite `spec.md` + `plan.md` via `k-commit`, mensagem `docs(spec): <titulo>`.

## 10. Encerrar

```
Plano criado: <raiz>/<ts>-<slug>/plan.md
Branch <prefixo>/<slug> criada.   Modo: <modo_execucao>
Próximo passo: /k-task
```

Encadeie direto para o `k-task`, sem perguntar: a quebra em tarefas não toma decisão nova, e
roda em invocação separada para não herdar o contexto de investigação desta etapa.

## Nunca

- Alterar código de aplicação. O plano descreve; o `k-execute` implementa.
- Quebrar em tarefas aqui.
- Rodar `git` de escrita diretamente — sempre pelo `k-commit`.
- Inventar camada nova em CRUD simples, consulta administrativa ou bugfix pequeno em área
  legada.
- Misturar bugfix com refatoração. Melhoria que apareceu no caminho vai para `## Nao entra
  neste trabalho`.
- Propor versão de linguagem, framework ou biblioteca além do que o projeto já usa.
- Transformar achado fora do escopo em item deste plano — vai para o modo desvio, e você
  volta ao passo 6 no ponto exato onde parou.
