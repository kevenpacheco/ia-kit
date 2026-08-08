---
name: k-scan
description: Etapa opcional antes do fluxo. Varre um alvo delimitado (diretorio, modulo, fluxo ou diff da branch) com subagentes em paralelo por eixo de defeito, refuta cada achado com um subagente adversarial e apresenta so os confirmados para o usuario escolher quais viram spec. Use ao procurar bugs sem ter um sintoma relatado.
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
| Revisar um PR inteiro por padrao de codigo | `review-pr-php7-mysql` |

O criterio e: existe divergencia entre comportamento esperado e observado? Entao e bug. Codigo feio que funciona nao e bug.

## Objetivo

Entregar uma lista curta de bugs **provados**, cada um com caminho de execucao concreto, para voce escolher quais viram spec. Falso positivo custa mais que bug perdido.

## Restricao central

O `k-scan` **nao propoe correcao** e **nao cria spec sozinho**. Ele localiza e prova. Cada achado escolhido vira uma spec propria via `/k-spec`.

Nao toca em git: nao cria branch, nao commita, nao altera codigo.

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
| Nulos, arrays e tipos | retorno `null` nao tratado, indice de array inexistente, `==` onde precisa `===`, coercao de tipo do PHP 7, `count()` em possivel `null` |
| SQL e dados | input concatenado em query, filtro/join errado, `LIMIT`/`OFFSET` off-by-one, N+1, ausencia de indice em coluna filtrada, escrita multipla sem transacao |
| Fluxo e estado | `if`/`else` invertido, early return faltando, efeito colateral em metodo compartilhado, dependencia implicita de ordem de chamada, estado de sessao vazando entre portais |
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

Para cada achado escolhido, invoque `/k-spec` com o achado como entrada — **uma spec por bug**. Nao agrupe bugs diferentes numa spec: cada um tem causa raiz, teste de regressao e PR proprios.

O `k-spec` refaz a confirmacao da divergencia e tenta reproduzir; o achado do scan entra como ponto de partida, nao como conclusao.

### 6. Encerrar

```
Confirmados: <n>. Escolhidos: <n>.
Specs criadas:
- documentation/specs/<ts>-<slug>/ — <titulo>
Proximo passo: /k-plan
```

## Restricoes

- Nao altere codigo, nao crie branch, nao commite nada.
- Nao proponha correcao mesmo que o usuario peca — a correcao e decidida em `/k-plan`.
- Nao apresente achado refutado nem "cheiro" de codigo sem comportamento errado provado.
- Nao varra o repositorio inteiro.
- Nao cite caminho de storage, nome de arquivo enviado, canal de log ou metodo interno na descricao do achado.
