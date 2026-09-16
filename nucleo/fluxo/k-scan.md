# k-scan — procurar bug sem sintoma

Etapa **opcional**, antes do fluxo: `k-scan` → `k-spec` → `k-plan` → `k-task` → `k-execute`.

Entrega uma lista curta de bugs **provados**, cada um com caminho de execução concreto, para
você escolher quais viram trabalho. Falso positivo custa mais que bug perdido.

| Preciso de | Leia |
|---|---|
| gravar os achados escolhidos | `.ia-kit/referencias/desvio.md` |

**Custo:** é a única etapa do kit com fan-out real. Vários subagentes em paralelo custam
ordens de grandeza mais que uma conversa comum. Use quando o alvo vale isso — auditoria de
módulo, diff antes de PR, diretório que sofreu muita mudança. Não use como varredura de
rotina.

---

## Quando não usar

| Situação | Etapa correta |
|---|---|
| sintoma conhecido | `k-spec` |
| comportamento correto, código ruim | `k-spec` tipo `refactor` |
| revisar PR por padrão de código | revisão do `k-commit`, ou a ferramenta de review do projeto |

Critério: existe divergência entre comportamento esperado e observado? Então é bug. Código
feio que funciona não é bug.

## 1. Delimitar o alvo

Alvo é **obrigatório**: caminho, módulo, fluxo, ou o diff da branch. **Nunca varra o
repositório inteiro** — o resultado é ruído caro.

Sem alvo, pergunte com alternativas concretas tiradas do estado do repositório: diff da
branch, diretório do trabalho recente, fluxo citado na última spec. Nunca opção genérica.

Liste os arquivos que entram e mostre a contagem antes de começar.

## 2. Disparar os eixos

Quatro subagentes **somente de leitura**, todos na mesma mensagem, cada um com a lista de
arquivos e um eixo. Modelo barato: é leitura e reconhecimento de padrão.

| Eixo | O que procurar |
|---|---|
| Nulos, coleções e tipos | retorno vazio ou nulo não tratado, acesso a índice ou chave inexistente, comparação frouxa onde precisa ser estrita, coerção implícita, contagem sobre valor possivelmente nulo |
| Dados e persistência | entrada concatenada em consulta, filtro ou junção errada, paginação com erro de limite, N+1, ausência de índice em coluna filtrada, escrita múltipla sem transação |
| Fluxo e estado | condição invertida, retorno antecipado faltando, efeito colateral em ponto compartilhado, dependência implícita de ordem de chamada, estado vazando entre contextos ou usuários |
| Autorização e limites | ação sem checagem de dono ou perfil, identificador do request usado sem validar posse, upload sem validar tipo ou tamanho, valor monetário ou data sem validação de borda |

Cada achado traz `arquivo:linha`, condição de entrada que dispara, e comportamento errado
resultante. **Nunca despejo de código, nunca sugestão de correção.**

## 3. Refutar

Para cada achado, um subagente adversarial cuja tarefa é **provar que o achado está errado**:
procurar o guard que o primeiro não viu, a validação a montante, o chamador que nunca passa
aquele valor, o default que impede a condição.

Sobrevive só o achado com caminho de execução concreto — existe entrada alcançável que
produz comportamento errado. **Na dúvida, refute.**

A refutação é o que separa esta etapa de um linter caro. Sem ela, o fan-out vira gerador de
ruído com aparência de rigor.

## 4. Apresentar

```
Alvo: <alvo> (<n> arquivos)
Achados: <n>  Refutados: <n>  Confirmados: <n>

1. <uma linha> — `arquivo:linha`
2. <uma linha> — `arquivo:linha`

Quais viram trabalho? (números / todos / nenhum)
```

Lista numerada com resposta livre, não menu fechado: uma varredura pode confirmar mais
achados do que cabe num conjunto de opções.

Arquivo que ficou de fora: **diga explicitamente**. Cobertura parcial silenciosa vira falso
"está tudo limpo".

## 5. Encaminhar

Para cada achado escolhido, grave um stub conforme `referencias/desvio.md` — **um stub por
bug**. Não agrupe: cada um tem causa raiz, teste de regressão e PR próprios. A verificação de
duplicata roda também entre os achados deste lote.

Não rode o `k-spec` completo aqui. Entrevistar e reproduzir N bugs numa sessão só estoura o
contexto, e a escolha de qual atacar primeiro fica melhor com a fila inteira na frente.

```
Confirmados: <n>. Escolhidos: <n>.
Stubs criados (fluxo: pendente) na branch <branch>:
- <raiz>/<ts>-<slug>/ — <titulo>
Próximo passo: /k-spec <slug>, um por vez
```

Stubs em branch nova (scan rodou na principal): diga que ela precisa de PR para entrarem na
fila.

## Nunca

- Varrer o repositório inteiro.
- Propor correção, mesmo se pedirem — correção é decidida no `/k-plan`.
- Apresentar achado refutado, ou "cheiro" de código sem comportamento errado provado.
- Rodar o `k-spec` completo por achado.
- Alterar código ou rodar `git` de escrita direto.
