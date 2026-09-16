# Achados — v2

Pontas soltas encontradas ao escrever o núcleo, e o que foi feito com cada uma.

Status em 2026-09-15: **10 levantados, 10 resolvidos.** A2 e A5 foram resolvidos no
instrumento, não no resultado — a diferença está descrita em cada um.

---

## A1 — Teto de tokens por tarefa não era verificável

**Era:** `execucao.teto_tokens_tarefa` mandava parar acima de um número de tokens. O agente
não lê o próprio consumo de forma confiável durante a execução, então a regra virava
estimativa.

**Resolvido:** campo removido, substituído por `execucao.limites_tarefa` — arquivos lidos,
rodadas de ferramenta, minutos. Três sinais observáveis sem instrumentação especial. Custo em
dinheiro passou a ser retrospectivo, no fechamento do `k-execute`, com campo vazio quando a
ferramenta não reporta.

D8 reescrito. Campo antigo registrado em `nucleo/esquema.yml`, seção `removidos`, com
substituto — quem atualizar de uma versão anterior recebe o aviso no `k-init`.

## A2 — Suite de referência não existia

**Era:** "mudança no núcleo só entra se a suite não piorar" sem suite.

**Resolvido (instrumento):** `baseline/PROTOCOLO.md` define composição obrigatória por fatia
(2 greenfield, 3 evolução, 3 legado, 2 bug), o procedimento das duas rodadas, as oito métricas
e o critério de aceite. Modelos em `baseline/tarefas/` e `baseline/resultados/`.
`nucleo/referencias/metricas.md` diz como coletar cada eixo com git e ferramenta agnóstica de
stack.

**Não resolvido (conteúdo):** a suite está vazia. Falta escolher repositórios-alvo e commits
de gabarito — trabalho que exige código real, não decisão de arquitetura. Até lá, todas as
decisões continuam apoiadas só em evidência externa.

## A3 — Segurança "no diff" dependia da ferramenta

**Era:** o gate mandava varrer o diff, sem checar se a ferramenta sabe fazer isso.

**Resolvido:** `comandos.seguranca_diff` virou campo próprio, com placeholders `{base}` e
`{arquivos}`. `gate.md` traz a invocação incremental por ferramenta (Semgrep com
`--baseline-commit`, Gitleaks com `protect --staged`, e assim por diante) e marca `npm audit`
como não incremental. O `k-init` testa o modelo contra um diff real antes de gravar; falhou,
o campo fica vazio e o gate cai para varredura completa **avisando o custo**.

## A4 — Rodapé de atribuição de IA voltava pela ferramenta

**Era:** o contrato proíbe, mas a ferramenta anexa por padrão, fora do alcance do shim.
Aconteceu nos três primeiros commits desta branch.

**Resolvido:** o `k-init` passou a conferir a configuração da ferramenta contra o contrato na
instalação e avisar onde desligar. `mensagem-commit.md` ganhou o procedimento para quando o
rodapé escapa: remover antes de commitar, ou reescrever a mensagem em commit não empurrado.

## A5 — Roteamento de modelo era parcialmente implementável

**Era:** o kit prometia economia de 30% a 50% com roteamento que não consegue impor.

**Resolvido (honestidade):** D7 ganhou a seção de limite de aplicação. Subagente costuma
aceitar modelo próprio; a etapa principal, nem sempre. Onde não dá para impor, `modelos` vale
como recomendação registrada, e a economia só é afirmada depois de aparecer no baseline.

**Não resolvido (capacidade):** continua dependendo do que cada ferramenta expõe. Isso é
limite externo, não dívida do kit.

## A6 — `k-revisao` assumia GitHub

**Era:** leitura de comentários e abertura de PR escritas em cima de `gh`, contradizendo o
D14.

**Resolvido:** `git.forja` no contrato e `nucleo/referencias/forja.md` com a tabela de
operações por plataforma — GitHub, GitLab, Bitbucket, Azure e `nenhuma`. `k-revisao`,
`shipping.md` e `k-execute` passaram a consultar a forja em vez de chamar `gh` direto. Sem
CLI, o fluxo degrada para modo manual explícito: monta o corpo, entrega para abertura manual,
e **nunca afirma ter aberto um PR que não existe**. D14 registra que a regra vale para forja
também.

## A7 — O modo de execução era decidido em dois lugares

**Era:** o `k-spec` consultava `execucao.modo_padrao` para decidir se encadeava, mas o modo
real do fluxo só nasce no `k-plan`.

**Resolvido:** campo novo `execucao.encadeamento` (`automatico` | `manual`), lido pelas duas
etapas. O modo de execução governa granularidade e autonomia; encadeamento virou decisão
separada, com campo próprio. Duas coisas diferentes, dois campos.

## A8 — Referências não tinham teto de tamanho

**Era:** teto de 150 linhas só para arquivo de fluxo. Referência sem limite foi como o v1
chegou a 434 linhas.

**Resolvido:** D3 fixa **200 linhas** para referência. `contrato.md` estourou na hora
(218 linhas) e foi cortado: candidatos de ferramenta de segurança e detalhe de invocação
migraram para `gate.md`, que é onde são usados.

## A9 — Revisão por subagente rodava em todo commit de código

**Era:** segundo maior consumo do kit, disparado inclusive em diff de três linhas, sem
medição.

**Resolvido:** `commit.revisao_subagente` com três valores (`sempre`, `por_limiar`, `nunca`),
padrão `por_limiar`, e `commit.revisao_limiar` em 3 arquivos ou 80 linhas. Abaixo do limiar a
revisão quase sempre repete o que lint e testes já disseram.

A pergunta de fundo — quanto a revisão acha que o gate não acha — continua sendo para o
baseline responder. O limiar é a aposta enquanto o dado não existe.

## A10 — Nada validava o contrato contra o núcleo

**Era:** campo órfão ou ausente só aparecia quando uma etapa falhava no meio do trabalho.

**Resolvido:** `nucleo/esquema.yml`, legível por máquina, com obrigatoriedade, tipo, valores
aceitos e quem consome cada campo, mais a seção `removidos`. O `k-init`, em reconfiguração e
atualização, compara e reporta antes de qualquer outra coisa.

---

## O que segue aberto

Nenhum achado bloqueia o kit. O que falta não é correção, é conteúdo e medição:

| Pendência | De onde vem |
|---|---|
| Popular a suite de referência com tarefas reais | A2 |
| Medir o valor da revisão por subagente | A9 |
| Confirmar a economia do roteamento de modelo | A5 |

As três dependem do mesmo trabalho: rodar o baseline pelo menos uma vez.
