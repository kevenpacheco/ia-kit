# k-scan — como usar

Etapa opcional, antes do fluxo: **k-scan** → `k-spec` → `k-plan` → `k-task` → `k-execute`.

## Invocacao

```
/k-scan src/services/
/k-scan fluxo de checkout
/k-scan --diff
```

Alvo e obrigatorio. Sem alvo, a skill pergunta com opcoes tiradas do estado do repositorio.

## Quando usar

Quando voce **nao tem sintoma**, so um alvo pra auditar. Se ja sabe o que deu errado, va direto pro `/k-spec`.

## O que ela faz

1. Lista os arquivos do alvo e mostra a contagem.
2. Dispara **4 subagentes em paralelo**, um por eixo de defeito:
   - nulos, colecoes e tipos
   - dados e persistencia
   - fluxo e estado
   - autorizacao e limites
3. Para cada achado, dispara um subagente **adversarial** que tenta refutar. Na duvida, refuta.
4. Apresenta so os confirmados, numerados. Voce escolhe quais viram trabalho.
5. Grava um **stub** por bug escolhido (`fluxo: pendente`), via `k-spec` modo desvio — **um stub por bug**.

Os stubs formam uma fila. Voce puxa um por vez com `/k-spec <slug>`, quando quiser: e la que a entrevista acontece e o stub vira spec de verdade. Rodar o `k-spec` completo N vezes na mesma sessao estouraria o contexto, e a escolha de qual bug atacar fica melhor com a fila inteira na frente.

## O que ela nao faz

- Nao propoe correcao.
- Nao entrevista voce nem elabora spec — isso e do `/k-spec`.
- Nao cria branch e nao toca codigo. A unica escrita em git e o commit do stub, feito pelo `k-commit`.
- Nao varre o repositorio inteiro.
- Nao apresenta "cheiro" de codigo sem comportamento errado provado.

## Cobertura parcial

Se algum arquivo ficou de fora, a skill diz explicitamente. Cobertura parcial silenciosa vira falso "esta tudo limpo".

## Saida

```
Alvo: src/services/ (23 arquivos)
Achados: 9  Refutados: 6  Confirmados: 3

1. Retorno vazio de findByToken usado sem guard — `src/services/auth-service.ts:88`
2. Filtro de titular ausente na listagem — `src/services/account-service.ts:142`
3. Upload sem validar mime — `src/controllers/upload-controller.ts:31`

Quais viram spec? (numeros / todos / nenhum)
```

Escolhidos, vira:

```
Confirmados: 3. Escolhidos: 2.
Stubs criados (fluxo: pendente):
- docs/specs/20260812-0930-retorno-vazio-find-by-token/ — Retorno vazio de findByToken usado sem guard
- docs/specs/20260812-0931-listagem-sem-filtro-de-titular/ — Filtro de titular ausente na listagem
Proximo passo: /k-spec <slug>, um por vez
```
