# k-plan — decisão técnica

Etapa 2 de 3: `k-spec` → **k-plan** → `k-execute`.

Transforma o contrato de comportamento em decisão registrada: decide **o que fazer** e quebra
em tarefas executáveis.

| Preciso de | Leia |
|---|---|
| seções do plano, classificação, escala de opções | `.ia-kit/referencias/plan-formato.md` |
| formato e regras de quebra da tarefa | `.ia-kit/referencias/tarefa-formato.md` |
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

Pesquisa externa só quando o código não responde. Nunca busque "melhor prática" genérica — a
resposta costuma violar restrição de stack já documentada no projeto.

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

Não consegue provar: **não adivinhe**. Volte a investigar, ou devolva dizendo o que falta.

## 5. Classificar e escolher o modo

Classifique a mudança conforme `referencias/plan-formato.md` e derive o `modo_execucao`:

| Classificação e tamanho | Modo |
|---|---|
| código novo, poucos consumidores | `greenfield` |
| base viva, em mudança | `evolucao` |
| legado puro, alto acoplamento | `legado` |

O modo governa granularidade da quebra e autonomia do executor. Em base legada a IA rende
perto de zero quando decide sozinha — é por isso que o modo existe.

## 6. Comparar opções

2 a 3 opções reais. Para cada uma: quanto de código muda, o que resolve, o que **não**
resolve, risco de regressão. Recomende a menor que resolve a causa.

## 7. Confirmar com o usuário

Mostre classificação, causa raiz e opções, e **espere a escolha**. Esta é a decisão central
do fluxo; não a tome sozinho — em nenhum modo.

## 8. Escrever o plan.md

Formato em `referencias/plan-formato.md`. Grave direto, sem pedir confirmação.

## 9. Quebrar em tarefas

Uma tarefa = um comportamento observável = uma unidade de commit, com teste e implementação
**juntos**. Em `tipo: bug`, a tarefa 1 é a do teste de regressão mais a correção.

Grave `tasks/NN-titulo-curto.md` conforme `referencias/tarefa-formato.md` — regras de quebra,
granularidade por modo e frontmatter estão lá. Preencha `arquivos` com os caminhos exatos e
`criterios` com os `CA-n` que a tarefa fecha.

A quebra **não toma decisão nova**. Faltou decisão: volte ao passo 6, não empurre para o
executor — ele roda com contexto mínimo e não vai investigar.

Antes de commitar: `sh .ia-kit/scripts/verificar-tarefas.sh <pasta-da-spec>`. Vermelho:
corrija. Todo `CA-n` precisa de tarefa que o cubra.

## 10. Criar a branch e commitar

Peça ao `k-commit` a branch `<prefixo>/<slug>`, a partir da principal atualizada. O slug é o
mesmo da pasta da spec, **sem o timestamp** — é assim que o `k-execute` reencontra a spec.
Automático, sem perguntar: a etapa seguinte precisa da branch de pé.

Alteração local não commitada de outro trabalho: **pare e pergunte**. Sem `stash` automático.

Depois, commite `spec.md`, `plan.md` e `tasks/` via `k-commit`, mensagem
`docs(spec): <titulo>`.

## 11. Encerrar

```
Plano criado: <raiz>/<ts>-<slug>/plan.md
Branch <prefixo>/<slug> criada.   Modo: <modo_execucao>   Tarefas: <n>

| # | Titulo | CA |
|---|---|---|
| 1 | <titulo> | CA-1, CA-2 |

Próximo passo: /k-execute
```

Pare aqui. O `k-execute` roda em invocação própria — uma tarefa por vez.

## Nunca

- Alterar código de aplicação. O plano descreve; o `k-execute` implementa.
- Tomar decisão na quebra que o plano não tomou, ou criar tarefa que exija investigação — o
  executor roda com contexto mínimo e não vai pesquisar.
- Separar teste e implementação do mesmo comportamento em tarefas diferentes.
- Fechar a quebra deixando `CA-n` sem tarefa.
- Rodar `git` de escrita diretamente — sempre pelo `k-commit`.
- Inventar camada nova em CRUD simples, consulta administrativa ou bugfix pequeno em área
  legada.
- Misturar bugfix com refatoração, ou propor versão de linguagem e biblioteca além do que o
  projeto já usa. Melhoria que apareceu no caminho vai para `## Nao entra neste trabalho`.
- Transformar achado fora do escopo em item deste plano — vai para o modo desvio, e você
  volta ao passo 6 no ponto exato onde parou.
