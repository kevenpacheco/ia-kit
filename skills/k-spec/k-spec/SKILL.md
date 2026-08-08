---
name: k-spec
description: Primeira etapa do fluxo de trabalho. Investiga o codigo, entrevista o usuario ate convergir e escreve documentation/specs/<timestamp>-<slug>/spec.md com a especificacao de comportamento (o que e por que). Use ao iniciar qualquer trabalho com regra de negocio nova/alterada, bug relatado, refactor, chore ou documentacao.
---

# k-spec

Etapa 1 de 4: `k-spec` → `k-plan` → `k-task` → `k-execute`.

Para procurar bugs em um alvo (diretorio, modulo, diff) em vez de partir de um pedido seu, use `k-scan` antes.

## Quando usar

Qualquer trabalho que va virar commit e PR:

- regra de negocio nova ou alterada
- erro 500, tela branca, comportamento incorreto
- refatoracao que nao muda comportamento
- tarefa operacional, config, dependencia
- documentacao

Ajuste trivial e obvio (typo em texto fixo, constante) pode ir direto, sem spec.

## Objetivo

Produzir um contrato de comportamento antes de qualquer decisao tecnica. O `spec.md` e a fonte da verdade do fluxo inteiro — substitui a issue.

## Restricao central

A spec responde **o que** e **por que**. Nunca **como corrigir** nem **onde a regra vai morar**.

Proibido em qualquer tipo:

- solucao proposta, patch, trecho de codigo corrigido
- comparacao entre opcoes de correcao
- camada onde a regra vai morar
- classificacao legado puro vs contexto em evolucao
- estimativa de esforco

Tudo isso pertence a `k-plan`.

**Regra de localizacao, por tipo:**

| Tipo | Pode citar `arquivo:linha`? |
|---|---|
| `bug` | Sim, **so para localizar** o sintoma. Nunca para dizer o que mudar. |
| `feature`, `refactor`, `chore`, `docs` | Nao. Nem nome de arquivo, classe, metodo, tabela, coluna, rota ou campo de request/response. |

Se a spec de feature ja disser onde mexer, spec e plano viram o mesmo documento e a revisao da spec deixa de ser barata.

Nunca cite caminho de storage, nome de arquivo enviado, canal de log ou metodo interno. Descreva o comportamento observavel.

## Procedimento

### 1. Sincronizar com a main

**Antes do discovery**, garanta que a investigacao acontece sobre o codigo atual:

```bash
git status --short
git checkout main
git pull origin main
```

Se `git status` mostrar alteracao nao commitada, **pare e pergunte** antes de trocar de branch. Nao faca `stash` automatico.

Nenhuma branch e criada aqui. Quem cria e o `k-plan`.

### 2. Definir titulo e tipo

O tipo governa o resto da skill. Lista fechada:

| Tipo | Quando | Prefixo de branch |
|---|---|---|
| `feature` | comportamento novo ou alterado | `feat/` |
| `bug` | divergencia entre esperado e observado | `fix/` |
| `refactor` | melhora o codigo sem mudar comportamento | `refactor/` |
| `chore` | dependencia, config, tarefa operacional | `chore/` |
| `docs` | so documentacao | `docs/` |

Se o pedido nao deixar o tipo obvio, **pergunte** usando o formato abaixo. Nao adivinhe: tipo errado leva a spec, plano e branch errados.

### 3. Ler antes de perguntar

Nunca gaste pergunta com fato que o repositorio responde. Antes da primeira pergunta, levante:

- `documentation/arquitetura.md`, `documentation/api/`, `documentation/business-rules/`, `documentation/integrations/`
- codigo do fluxo mencionado (rota, controller, service, model, view)
- comportamento atual, se o trabalho altera algo existente

Para tipo `bug`, percorra o caminho da requisicao antes de qualquer hipotese e anote `arquivo:linha` de cada ponto: entrada e portal, controller/action, services/models/helpers, query SQL, view/response.

### 4. Entrevistar ate convergir

Faca **uma pergunta por vez** e espere a resposta antes da proxima. Varias perguntas juntas confundem.

#### Formato da pergunta

Use o tool `AskUserQuestion`, com **2 a 4 alternativas**. Se ele nao existir no ambiente, escreva o mesmo conteudo em texto.

Cada rodada tem tres partes, nesta ordem:

1. **A pergunta**, direta, sem preambulo.
2. **A recomendacao e o porque**, em um bloco curto antes das opcoes: `Recomendo <opcao> porque <motivo>`.
3. **As alternativas**, a recomendada em primeiro, com `(Recomendado)` no rotulo. A descricao de cada uma diz o que se ganha **e** o que se perde.

Exemplo:

```
Bolsa expirada continua aparecendo na listagem publica?

Recomendo ocultar porque o aluno nao consegue se inscrever numa bolsa
vencida, e o botao inerte vira ticket de suporte.

[A] Ocultar da listagem (Recomendado)
    Corta a duvida do aluno. Perde o sinal de que a bolsa existiu.
[B] Mostrar riscada, sem botao de inscricao
    Transparente sobre a oferta. Gera a pergunta "por que nao consigo?".
[C] Mostrar so para quem ja tinha favoritado
    Meio-termo. Exige consultar favoritos na montagem da listagem.
```

#### Regras da entrevista

- toda alternativa precisa ser um caminho que alguem razoavel escolheria, com o trade-off real escrito. **Proibida opcao-palha** — enfeitar a recomendada e enfraquecer as outras de proposito transforma a pergunta em teatro
- se so existe um caminho viavel, **nao invente pergunta**: registre como Premissa e siga
- so pergunte o que muda o trabalho; o resto vira Premissa
- se o usuario responder "tanto faz", registre como Premissa e siga
- continue ate nao restar ambiguidade que mude o resultado

O que perguntar, por tipo:

- `feature`: comportamento em caso de borda, o que fica fora do escopo, quais portais sao afetados, o que acontece em erro, quem pode fazer a acao
- `bug`: em qual portal e com qual perfil ocorre, qual dado de entrada exato reproduz, qual e o comportamento correto quando a documentacao nao diz, o quanto dói na pratica
- `refactor`: qual o incomodo concreto, qual o limite do que pode ser tocado, o que precisa continuar identico
- `chore` / `docs`: qual o gatilho e o que conta como pronto

### 5. Confirmar a divergencia (so tipo `bug`)

Estabeleca, com evidencia no codigo:

- **comportamento esperado** — de onde vem essa expectativa (documentacao, regra de negocio, contrato de endpoint, coerencia com fluxo irmao)
- **comportamento atual** — o que o codigo faz de fato no caminho mapeado

Se as duas coisas coincidirem, **nao ha bug**. Diga isso ao usuario e pare — nao crie spec.

### 6. Reproduzir (so tipo `bug`)

Siga a escada, do mais forte para o mais fraco. Pare no primeiro degrau que funcionar.

1. **Teste automatizado** — se o bug e alcancavel por logica pura, escreva um teste PHPUnit descartavel que falhe, rode no container e cole a **linha decisiva** da saida na spec. Apague o teste depois; o teste definitivo e tarefa do `k-task`.

```bash
docker compose -p bolsamaisbrasil-local -f docker-compose-local.yml exec php vendor/bin/phpunit --filter <NomeDoTeste>
```

2. **Passos manuais** — se depende de HTTP, sessao, upload ou portal, escreva passos numerados que qualquer pessoa consiga seguir, com o resultado errado observado no ultimo passo.

3. **Nao reproduzido** — se nem isso, registre a secao como `Nao reproduzido` e descreva o **caminho de execucao no codigo** que leva ao erro, com `arquivo:linha` e a condicao de entrada necessaria.

Nunca invente passos que voce nao executou nem verificou no codigo.

### 7. Escrever o spec.md

Crie o diretorio com timestamp e slug:

```bash
TS=$(date +%Y%m%d-%H%M%S)
SLUG=<slug-kebab-case-curto>
mkdir -p documentation/specs/$TS-$SLUG
```

O slug e curto, em kebab-case, sem acento, e vai virar o nome da branch no `k-plan`.

Frontmatter obrigatorio em todo tipo:

```yaml
---
titulo: <titulo curto e descritivo>
tipo: feature | bug | refactor | chore | docs
criado_em: <AAAA-MM-DD HH:MM:SS>
---
```

#### Corpo — tipos `feature`, `refactor`, `chore`, `docs`

```markdown
## Objetivo

Problema real que o trabalho resolve. Uma ou duas frases.

## Escopo

O que entra.

### Fora do escopo

O que explicitamente nao entra (protege contra crescimento silencioso).

## Atores e portais afetados

Quem executa e onde (site, area do aluno, portal do parceiro, admin, API, afiliado).

## Comportamento esperado

### Caminho feliz
### Casos de borda
### Casos de erro

Cada cenario no formato: dado <contexto>, quando <acao>, entao <resultado observavel>.

Em tipo `refactor`, esta secao afirma o que precisa continuar **identico** apos a mudanca.

## Regras de negocio e invariantes

O que precisa ser sempre verdade, independente do caminho.

## Criterios de aceite

Lista verificavel. Cada item deve ser comprovavel por teste ou por observacao direta.

- [ ] ...

## Premissas

O que foi assumido sem confirmacao. Se alguma estiver errada, o plano muda.
Omita a secao inteira se nao houver nada.
```

#### Corpo — tipo `bug`

```markdown
## Problema

O que esta errado, em uma ou duas frases, em termos observaveis.

## Arquivos de referencia

- `caminho/Arquivo.php:42` — o que esse ponto faz no fluxo
- `caminho/Outro.php:88` — ...

Localizacao apenas. Nao diga o que deve mudar.

## Como reproduzir

Teste, passos numerados ou `Nao reproduzido` com o caminho de execucao — conforme a escada da etapa 6.

## Comportamento atual vs esperado

**Atual:** ...
**Esperado:** ... (e de onde vem a expectativa)

## Impactos

- quem sofre e em qual portal
- frequencia (todo acesso, so em caso de borda, so com dado especifico)
- severidade: o que se perde ou quebra

## Criterios de aceite

- [ ] ...

## Premissas

Omita a secao inteira se nao houver nada.
```

Mostre a spec ao usuario e **confirme antes de gravar**.

### 8. Encerrar

```
Spec criada: documentation/specs/<ts>-<slug>/spec.md
Tipo: <tipo>
Proximo passo: /k-plan
```

## Restricoes

- Nao crie branch, nao altere codigo de aplicacao, nao commite nada nesta etapa. O `spec.md` fica untracked ate o `k-plan`.
- Teste descartavel de reproducao nao entra em commit. Apague depois de colar a linha decisiva.
- Nao proponha solucao tecnica mesmo que o usuario peca — registre a preferencia dele em Premissas e trate no `k-plan`.
- Nao crie spec de "cheiro" de codigo sem comportamento errado provado quando o tipo for `bug`. Codigo feio que funciona e `refactor`, nao `bug`.
