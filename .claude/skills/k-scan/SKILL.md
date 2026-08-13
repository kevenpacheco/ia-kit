---
name: k-scan
description: Etapa opcional antes do fluxo. Varre um alvo delimitado (diretorio, modulo, fluxo ou diff da branch) com subagentes em paralelo por eixo de defeito, refuta cada achado com um subagente adversarial e apresenta so os confirmados para o usuario escolher quais viram stub de spec (fluxo pendente), gravados via k-spec modo desvio. Use ao procurar bugs sem ter um sintoma relatado.
---

# k-scan

Etapa opcional, antes do fluxo: `k-scan` → `k-spec` → `k-plan` → `k-task` → `k-execute`.

## Quando usar

Quando voce **nao tem um sintoma**, e sim um alvo para auditar:

- procurar bugs em um modulo ou fluxo
- revisar o diff da branch antes de abrir PR
- auditar um diretorio que sofreu muita mudanca

Se voce ja sabe o que deu errado, pule direto para `/k-spec`.

## Quando NAO usar

| Situacao | Skill correta |
|---|---|
| Sintoma conhecido | `k-spec` |
| Comportamento correto, mas codigo ruim | `k-spec` tipo `refactor` |
| Revisar um PR inteiro por padrao de codigo | skill de code review do projeto, se existir |

O criterio e: existe divergencia entre comportamento esperado e observado? Entao e bug. Codigo feio que funciona nao e bug.

## Objetivo

Entregar uma lista curta de bugs **provados**, cada um com caminho de execucao concreto, para voce escolher quais viram spec. Falso positivo custa mais que bug perdido.

## Restricao central

O `k-scan` **nao propoe correcao** e **nao elabora spec**. Ele localiza e prova. Cada achado escolhido vira um stub proprio (`fluxo: pendente`), via `k-spec` modo desvio; o contrato de comportamento so nasce depois, no `k-spec` normal.

Nao cria branch e nao altera codigo. A unica escrita em git e o commit do stub, feito pelo modo desvio via `k-commit` — o `k-scan` nunca roda `git`/`gh` diretamente.

## Procedimento

### 1. Delimitar o alvo

Alvo e **obrigatorio**: caminho de arquivo/diretorio, nome de modulo/fluxo, ou `--diff` (branch atual vs `main`). **Nunca varra o repositorio inteiro** — o resultado e ruido caro.

```bash
git diff --name-only main...HEAD
```

Se o usuario nao der alvo, pergunte com alternativas concretas tiradas do estado atual do repositorio (diff da branch, diretorio do trabalho recente, fluxo citado na ultima spec) — nunca com opcoes genericas.

Liste os arquivos que entram na varredura e mostre a contagem antes de comecar.

### 2. Disparar os subagentes em paralelo

Quatro subagentes **somente de leitura**, todos na mesma mensagem. Cada um recebe a lista de arquivos do alvo e um eixo:

| Eixo | O que procurar |
|---|---|
| Nulos, colecoes e tipos | retorno vazio/nulo nao tratado, acesso a indice/chave inexistente, comparacao de tipo frouxa onde precisa de igualdade estrita, coercao de tipo implicita, chamada de tamanho/contagem em valor possivelmente nulo |
| Dados e persistencia | input concatenado em consulta (SQL ou equivalente), filtro/join errado, paginacao off-by-one, N+1, ausencia de indice em coluna filtrada, escrita multipla sem transacao |
| Fluxo e estado | `if`/`else` invertido, early return faltando, efeito colateral em metodo compartilhado, dependencia implicita de ordem de chamada, estado vazando entre contextos/usuarios |
| Autorizacao e limites | action sem checagem de dono/perfil, ID vindo do request usado sem validar posse, upload sem validar tipo/tamanho, valor monetario ou data sem validacao de borda |

Cada subagente devolve, por achado: `arquivo:linha`, condicao de entrada que dispara o problema, e comportamento errado resultante. **Nunca despejo de codigo, nunca sugestao de correcao.**

### 3. Refutar

Para cada achado, dispare um subagente adversarial cuja tarefa e **provar que o achado esta errado**. Ele procura o guard que o primeiro nao viu, a validacao a montante, o caller que nunca passa aquele valor, o default que impede a condicao.

Sobrevive apenas o achado com **caminho de execucao concreto**: existe entrada alcancavel que produz comportamento errado. Na duvida, refute.

### 4. Apresentar

```
Alvo: <alvo> (<n> arquivos)
Achados: <n>  Refutados: <n>  Confirmados: <n>

1. <uma linha> — `arquivo:linha`
2. <uma linha> — `arquivo:linha`
3. <uma linha> — `arquivo:linha`

Quais viram spec? (numeros / todos / nenhum)
```

Lista numerada com resposta livre, nao `AskUserQuestion`: uma varredura pode confirmar mais achados do que cabe em um conjunto de opcoes.

Se algum arquivo ficou de fora por limite de alvo ou por nao ter sido lido, **diga explicitamente**. Cobertura parcial silenciosa vira falso "esta tudo limpo".

### 5. Encaminhar

Para cada achado escolhido, chame `k-spec` no **modo desvio** — **um stub por bug**. Nao agrupe bugs diferentes num stub: cada um tem causa raiz, teste de regressao e PR proprios.

Cada stub nasce com `fluxo: pendente`, `tipo` vazio e `origem_etapa: k-scan` (sem `origem_spec`: o scan nao parte de spec nenhuma). A verificacao de duplicata do modo desvio roda **tambem entre os achados deste lote**, nao so contra a fila ja existente.

Nao rode o `k-spec` completo aqui. Entrevista e reproducao de N bugs numa sessao so estouram o contexto, e a decisao de qual atacar primeiro fica melhor com a fila inteira na frente. O `k-spec` normal roda depois, um por vez, e e la que a divergencia e confirmada e a reproducao tentada — o achado do scan entra como ponto de partida, nao como conclusao.

### 6. Encerrar

```
Confirmados: <n>. Escolhidos: <n>.
Stubs criados (fluxo: pendente) na branch <branch>:
- <raiz-de-specs>/<ts>-<slug>/ — <titulo>
Proximo passo: /k-spec <slug>, um por vez
```

Se os stubs foram parar numa branch nova (porque o scan rodou na `main`), diga que ela precisa de PR para eles entrarem na fila do `/k-spec`.

## Restricoes

- Nao altere codigo e nao crie branch. Nunca rode `git`/`gh` diretamente: o commit do stub e do `k-commit`, chamado pelo modo desvio.
- Nao rode o `k-spec` completo por achado. Um scan pode confirmar mais bugs do que cabe em uma sessao de entrevista.
- Nao proponha correcao mesmo que o usuario peca — a correcao e decidida em `/k-plan`.
- Nao apresente achado refutado nem "cheiro" de codigo sem comportamento errado provado.
- Nao varra o repositorio inteiro.
- Nao cite caminho de storage, nome de arquivo enviado, canal de log ou metodo interno na descricao do achado.
