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
4. Apresenta so os confirmados, numerados. Voce escolhe quais viram spec.
5. Invoca `/k-spec` uma vez por bug escolhido — **uma spec por bug**.

## O que ela nao faz

- Nao propoe correcao.
- Nao cria branch, nao commita, nao toca codigo.
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
