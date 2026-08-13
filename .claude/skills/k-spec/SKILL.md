---
name: k-spec
description: Primeira etapa do fluxo de trabalho. Em modo normal, investiga o codigo com subagentes em paralelo, entrevista o usuario ate convergir e escreve spec.md (contrato de comportamento) na pasta de specs do fluxo, com fluxo ativo. Em modo desvio, chamado por outra skill do fluxo, grava um stub fluxo pendente de um achado fora do escopo, sem git, sem entrevista e sem investigacao, e devolve o controle. Use ao iniciar qualquer trabalho com regra de negocio nova/alterada, bug relatado, refactor, chore ou documentacao.
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

## Modos de uso

### 1. Normal (invocado por voce)

```
/k-spec                                       # lista os stubs pendentes e pergunta
/k-spec erro 500 ao salvar banner sem imagem  # trabalho novo, a partir da descricao
/k-spec 20260812-093000-cpf-invalido          # elabora um stub pendente ja existente
```

Roda o procedimento inteiro (etapas 1 a 8) e termina com a spec em `fluxo: ativo`.

### 2. Desvio (chamado internamente por outra skill do fluxo)

Nao e invocado por voce. `k-spec`, `k-plan`, `k-task`, `k-execute` e `k-scan` chamam este modo quando encontram um achado fora do escopo do trabalho em andamento: ele grava um stub `fluxo: pendente` e devolve o controle na hora, sem tocar no fluxo em curso. Ver `## Modo desvio` no fim desta skill.

## Estado do fluxo

Todo `spec.md` carrega `fluxo:` no frontmatter. E a unica fonte de verdade sobre o ciclo de vida do trabalho:

| Valor | Significado | Quem escreve |
|---|---|---|
| `pendente` | achado capturado, ninguem elaborou ainda; `tipo` vazio | `k-spec` modo desvio |
| `ativo` | spec elaborada, contrato de comportamento escrito | `k-spec` modo normal (etapa 7) |
| `concluido` | todas as tarefas fechadas e suite completa verde | `k-execute` (encerramento) |
| `descartado` | nao procede, ou foi absorvido por outro fluxo | `k-spec` modo normal; `k-execute` na absorcao |

Spec sem o campo `fluxo:` (anterior a esta convencao) le-se como `ativo`. **Nao preencha retroativamente** — escreva o campo apenas quando ja for gravar aquele arquivo por outro motivo.

`fluxo:` **nao** diz qual e o trabalho corrente. Pode haver varios `ativo` ao mesmo tempo, um por branch aberta. "Qual fluxo estou tocando agora" continua sendo `git branch --show-current`.

Dependencia entre fluxos **nao e estado, e relacao**: vive no campo opcional `depende_de: <slug>`, escrito pelo `k-execute` quando este fluxo fica parado esperando outro entrar. Um fluxo com `depende_de:` continua `ativo` — ele so nao e o proximo. Nao existe valor `bloqueado`: se fosse estado, alguem teria que desbloquear na mao, e ninguem lembra. Quem escreveu tambem nao limpa; o `k-execute` resolve ao retomar o fluxo.

## Objetivo

Produzir um contrato de comportamento antes de qualquer decisao tecnica. O `spec.md` e a fonte da verdade do fluxo inteiro.

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

| Tipo                                   | Pode citar `arquivo:linha`?                                                                  |
| -------------------------------------- | -------------------------------------------------------------------------------------------- |
| `bug`                                  | Sim, **so para localizar** o sintoma. Nunca para dizer o que mudar.                          |
| `feature`, `refactor`, `chore`, `docs` | Nao. Nem nome de arquivo, classe, metodo, tabela, coluna, rota ou campo de request/response. |

Se a spec de feature ja disser onde mexer, spec e plano viram o mesmo documento e a revisao da spec deixa de ser barata.

Nunca cite caminho de storage, nome de arquivo enviado, canal de log ou metodo interno. Descreva o comportamento observavel.

## Procedimento

### 1. Sincronizar e escolher o alvo

**Antes do discovery**, garanta que a investigacao acontece sobre o codigo atual:

```bash
git status --short
git checkout main
git pull origin main
```

Se `git status` mostrar alteracao nao commitada, **pare e pergunte** antes de trocar de branch. Nao faca `stash` automatico.

Nenhuma branch e criada aqui. Quem cria e o `k-plan`.

Sincronizado, detecte a raiz de specs (regra na etapa 7) e resolva o alvo:

```bash
grep -rl "^fluxo: pendente" <raiz-de-specs>/
```

- **Argumento que casa com uma pasta em `<raiz-de-specs>/`** — e um stub. Elabore-o: pasta, slug, `criado_em` e campos `origem_*` ficam como estao; voce preenche o `tipo` (etapa 2) e substitui o corpo inteiro (etapa 7).
- **Argumento em texto livre** — trabalho novo. Se o texto casar com uma pasta existente por acidente, confirme com o usuario antes de seguir.
- **Sem argumento** — mostre a fila de stubs `pendente` (slug, titulo, `criado_em`, origem) e pergunte: elaborar um destes ou comecar algo novo? Fila vazia, pergunte o que ele quer fazer.

A fila so enxerga stubs cujo fluxo de origem ja foi mergeado. Stub gravado numa branch ainda aberta nao aparece — e proposital: a spec do desvio deve ser escrita contra o codigo **depois** que o fluxo pai entrar, nao contra um codigo que ainda vai mudar.

Ao elaborar um stub, leia `## Achado`, `## Evidencia` e os campos de origem antes de qualquer coisa: e o unico contexto que sobrou do momento em que o problema foi visto. Se a investigacao mostrar que o achado **nao procede** (falso positivo, ja corrigido, duplicata de outro fluxo), nao crie spec: marque `fluxo: descartado`, escreva no corpo uma secao `## Por que foi descartado` com o motivo, e pare. Descarte sem motivo registrado faz o mesmo achado voltar a fila pela mao da proxima pessoa que tropecar nele.

### 2. Definir titulo e tipo

O tipo governa o resto da skill. Lista fechada:

| Tipo       | Quando                                   | Prefixo de branch |
| ---------- | ---------------------------------------- | ----------------- |
| `feature`  | comportamento novo ou alterado           | `feat/`           |
| `bug`      | divergencia entre esperado e observado   | `fix/`            |
| `refactor` | melhora o codigo sem mudar comportamento | `refactor/`       |
| `chore`    | dependencia, config, tarefa operacional  | `chore/`          |
| `docs`     | so documentacao                          | `docs/`           |

Se o pedido nao deixar o tipo obvio, **pergunte** usando o formato abaixo. Nao adivinhe: tipo errado leva a spec, plano e branch errados.

Ao elaborar um stub, o `tipo` vem vazio — e por isso que ele nao pode seguir direto para o `k-plan`. Defina-o aqui, com a mesma pergunta. O titulo do stub foi gerado sem entrevista: corrija-o se estiver ruim, mas **mantenha o slug e a pasta**, que ja estao commitados e referenciados.

### 3. Investigar com subagentes em paralelo

Nunca gaste pergunta com fato que o repositorio responde. Antes da primeira pergunta, dispare subagentes **somente de leitura**, um por eixo, **todos na mesma mensagem** para rodarem juntos.

Eixos por tipo:

| Tipo | Eixos |
|---|---|
| `feature`, `refactor`, `chore`, `docs` | documentacao existente do projeto, por categoria (arquitetura; regras de negocio; contratos de API; integracoes externas) — o subagente localiza onde cada categoria vive neste repo e reporta a ausencia quando nao encontrar; comportamento atual do fluxo mencionado, se o trabalho altera algo existente; specs/plans anteriores relacionados na pasta de specs do fluxo |
| `bug` | caminho de execucao completo ate o sintoma, com `arquivo:linha` em cada ponto (entrada, camada de controle, regra de negocio/servico, acesso a dados, saida/resposta) — um unico subagente, trace sequencial, nao paralelizavel dentro dele; documentacao/regra que define o comportamento esperado; specs/plans anteriores relacionados na pasta de specs do fluxo |

Cada subagente devolve **conclusao com `arquivo:linha`**, nunca despejo de codigo. Para o eixo de specs anteriores, se a pasta de specs nao existir ou nada relacionado for encontrado, o subagente reporta isso explicitamente — nao e erro.

Mostre ao usuario uma sintese curta dos achados, com `arquivo:linha`, **antes da primeira pergunta** da etapa seguinte. Ele pode corrigir um achado errado antes que vire premissa da entrevista.

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

- `feature`: comportamento em caso de borda, o que fica fora do escopo, quais partes do sistema sao afetadas, o que acontece em erro, quem pode fazer a acao
- `bug`: em qual parte do sistema e com qual perfil ocorre, qual dado de entrada exato reproduz, qual e o comportamento correto quando a documentacao nao diz, o quanto dói na pratica
- `refactor`: qual o incomodo concreto, qual o limite do que pode ser tocado, o que precisa continuar identico
- `chore` / `docs`: qual o gatilho e o que conta como pronto

### 5. Confirmar a divergencia (so tipo `bug`)

Estabeleca, com evidencia no codigo:

- **comportamento esperado** — de onde vem essa expectativa (documentacao, regra de negocio, contrato de endpoint, coerencia com fluxo irmao)
- **comportamento atual** — o que o codigo faz de fato no caminho mapeado

Se as duas coisas coincidirem, **nao ha bug**. Diga isso ao usuario e pare — nao crie spec.

### 6. Reproduzir (so tipo `bug`)

Siga a escada, do mais forte para o mais fraco. Pare no primeiro degrau que funcionar.

1. **Teste automatizado** — se o bug e alcancavel por logica pura, escreva um teste descartavel que falhe, na linguagem/framework do projeto. Extraia o comando de teste da documentacao do projeto (`CLAUDE.md`, `README`); se nao estiver documentado, pergunte ao usuario uma vez. Rode o teste filtrando so o caso novo e cole a **linha decisiva** da saida na spec. Apague o teste depois; o teste definitivo e tarefa do `k-task`.

2. **Passos manuais** — se depende de interacao do usuario, sessao ou estado externo, escreva passos numerados que qualquer pessoa consiga seguir, com o resultado errado observado no ultimo passo.

3. **Nao reproduzido** — se nem isso, registre a secao como `Nao reproduzido` e descreva o **caminho de execucao no codigo** que leva ao erro, com `arquivo:linha` e a condicao de entrada necessaria.

Nunca invente passos que voce nao executou nem verificou no codigo.

### 7. Escrever o spec.md

Detecte a pasta de specs do fluxo: se o repositorio ja tem uma pasta `docs/` na raiz, a raiz e `docs/specs/`; senao, `documentation/specs/`. Use a mesma raiz em todo o resto desta skill.

Crie o diretorio com timestamp e slug:

```bash
TS=$(date +%Y%m%d-%H%M%S)
SLUG=<slug-kebab-case-curto>
mkdir -p <raiz-detectada>/specs/$TS-$SLUG
```

O slug e curto, em kebab-case, sem acento, e vai virar o nome da branch no `k-plan`.

Frontmatter obrigatorio em todo tipo:

```yaml
---
titulo: <titulo curto e descritivo>
tipo: feature | bug | refactor | chore | docs
fluxo: ativo
criado_em: <AAAA-MM-DD HH:MM:SS>
---
```

Campos opcionais, escritos por outras etapas e nunca por voce aqui: `depende_de:` (pelo `k-execute`, ver "Estado do fluxo") e os `origem_*` de um stub.

Ao elaborar um stub, nao recrie o arquivo: preserve `criado_em` (a data do achado, nao a de hoje) e os campos `origem_*`, troque `fluxo: pendente` por `fluxo: ativo`, preencha o `tipo` e **substitua o corpo inteiro** pelo formato do tipo escolhido. O corpo do stub e captura, nao rascunho — nao tente aproveita-lo secao por secao.

#### Corpo — tipos `feature`, `refactor`, `chore`, `docs`

```markdown
## Objetivo

Problema real que o trabalho resolve. Uma ou duas frases.

## Escopo

O que entra.

### Fora do escopo

O que explicitamente nao entra (protege contra crescimento silencioso).

## Atores e ambientes afetados

Quem executa a acao e em qual parte do sistema (ex.: interface principal, painel administrativo, API, processo em background) — adapte a realidade do projeto.

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

- `caminho/arquivo:42` — o que esse ponto faz no fluxo
- `caminho/outro:88` — ...

Localizacao apenas. Nao diga o que deve mudar.

## Como reproduzir

Teste, passos numerados ou `Nao reproduzido` com o caminho de execucao — conforme a escada da etapa 6.

## Comportamento atual vs esperado

**Atual:** ...
**Esperado:** ... (e de onde vem a expectativa)

## Impactos

- quem sofre e em qual parte do sistema
- frequencia (todo acesso, so em caso de borda, so com dado especifico)
- severidade: o que se perde ou quebra

## Criterios de aceite

- [ ] ...

## Premissas

Omita a secao inteira se nao houver nada.
```

Grave o arquivo direto, **sem pedir confirmacao**. Nao mostre o conteudo da spec no chat — informe apenas o caminho, conforme a etapa 8.

### 8. Encerrar

```
Spec criada: <raiz-detectada>/specs/<ts>-<slug>/spec.md
Tipo: <tipo>
Fluxo: ativo
Proximo passo: /k-plan
```

Se o alvo era um stub e voce concluiu que nao procede, o encerramento e outro:

```
Stub descartado: <raiz-de-specs>/<ts>-<slug>/spec.md
Motivo: <uma linha>
Nenhuma spec criada.
```

## Modo desvio (chamado internamente)

Acionado por `k-spec`, `k-plan`, `k-task`, `k-execute` ou `k-scan` quando aparece um achado fora do escopo do trabalho em andamento. O objetivo e **preservar o contexto de quem chamou**: registrar o achado e devolver o controle no mesmo ponto.

Este modo **nao** sincroniza com a `main`, **nao** troca de branch, **nao** entrevista e **nao** dispara subagente de investigacao. Subagente devolve resultado no contexto de quem chamou — investigar aqui queimaria exatamente o contexto que o stub existe para proteger. O stub registra o que a etapa chamadora **ja viu**, nada alem.

### 1. Verificar duplicata

Antes de gravar, procure o mesmo problema no que ja foi capturado:

```bash
grep -rlE "^fluxo: (pendente|descartado)" <raiz-de-specs>/
```

Nos arquivos encontrados, procure os caminhos citados no achado:

- casou com um stub `pendente`: mostre-o e pergunte se e o mesmo problema. Se for, **nao grave stub novo** — acrescente a nova evidencia ao `## Evidencia` do existente e siga.
- casou com um stub `descartado`: avise `esse arquivo ja gerou um achado descartado em <criado_em>, motivo: <motivo>. Gravar mesmo assim?`

`concluido` fica fora da busca de proposito: bug corrigido pode voltar, e nesse caso e achado novo.

Limite conhecido: isso pega duplicata que cita o mesmo arquivo, nao o mesmo bug visto de outro arquivo.

Quando o chamador for o `k-scan`, que grava varios de uma vez, a verificacao roda **tambem entre os achados do proprio lote**.

### 2. Gravar o stub

Mesma raiz e mesma convencao de pasta `<ts>-<slug>` da etapa 7. Titulo e slug sao gerados a partir do sintoma pela etapa que detectou o achado, sem confirmacao do usuario — o `k-spec` normal corrige o titulo depois, junto com o tipo.

```yaml
---
titulo: <titulo curto, gerado do sintoma>
tipo:
fluxo: pendente
criado_em: <AAAA-MM-DD HH:MM:SS>
origem_etapa: k-spec | k-plan | k-task | k-execute | k-scan
origem_spec: <slug da spec em andamento; vazio quando a origem e k-scan>
origem_task: <NN-slug da tarefa; vazio quando nao veio do k-execute>
origem_commit: <SHA curto do HEAD no momento do desvio>
---
```

`tipo` fica **vazio** de proposito: e ele que obriga o stub a passar pelo `k-spec` normal antes do `k-plan`. Nao chute — nem todo desvio e bug.

`origem_commit` e o ultimo commit, nao o estado exato que voce estava vendo (no `k-execute`, o desvio quase sempre acontece com a arvore suja). Serve como ancora temporal, nao como reproducao.

Corpo, tres secoes e nada mais:

```markdown
## Achado

`arquivo:linha`, condicao de entrada que dispara o problema, e comportamento errado resultante.

## Evidencia

O que foi observado de fato: a linha decisiva da saida do teste, o log, ou o trecho de codigo que prova a condicao. Nunca suposicao.

## Por que nao entrou no fluxo atual

Uma linha. Ex.: "fora do escopo da spec <slug>", "toca outro modulo", "exige decisao de produto".
```

Documento de captura, nao rascunho de spec. **Nao** use os cabecalhos do `spec.md` completo: stub que se parece com spec pronta e lido como contrato daqui a duas semanas.

### 3. Commitar

Chame `k-commit` no **modo 2b (commit)** com o arquivo do stub, a mensagem `docs(spec): registrar achado <titulo>` e a branch atual **fixada como destino** — o stub tem contexto diferente do da branch de proposito, e sem isso o `k-commit` trocaria de branch no meio do trabalho. Sem push, sem PR.

O stub fica na branch do fluxo em andamento e chega na `main` quando aquele PR mergear. Ate la nao aparece na fila do `k-spec` — proposital.

Unica excecao: se o desvio acontecer estando na `main` (tipico do `k-scan`, que nao exige branch), o `k-commit` cria uma branch para receber o stub — commit direto na `main` nao acontece. Nesse caso avise o usuario em qual branch os stubs ficaram e que ela precisa de PR para eles entrarem na fila.

### 4. Devolver o controle

```
Achado registrado: <raiz-de-specs>/<ts>-<slug>/spec.md (fluxo: pendente)
Retomando: <o ponto exato onde a etapa chamadora parou>
```

Volte para a etapa chamadora, no ponto exato onde ela parou. **Nunca** mude de etapa, nunca corrija o achado, nunca transforme o achado em tarefa do fluxo atual.

## Restricoes

- Em modo normal: nao crie branch, nao altere codigo de aplicacao, nao commite nada. O `spec.md` fica untracked ate o `k-plan`.
- Em modo desvio: nao investigue, nao entreviste, nao toque na `main` e nao troque de branch. Grave o stub, commite via `k-commit` e devolva.
- Teste descartavel de reproducao nao entra em commit. Apague depois de colar a linha decisiva.
- Nao proponha solucao tecnica mesmo que o usuario peca — registre a preferencia dele em Premissas e trate no `k-plan`.
- Nao crie spec de "cheiro" de codigo sem comportamento errado provado quando o tipo for `bug`. Codigo feio que funciona e `refactor`, nao `bug`.
- Achado fora do escopo do trabalho em discussao, encontrado na investigacao da etapa 3, vai para o **modo desvio** — nunca vira secao extra desta spec, nem pergunta da entrevista.
