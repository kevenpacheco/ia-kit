# Achados abertos — v2

Pontas soltas encontradas ao escrever o núcleo do v2. Nenhuma bloqueia o kit; todas merecem
decisão antes de considerar o v2 fechado.

Ordem: impacto decrescente.

---

## A1 — `execucao.teto_tokens_tarefa` não é verificável hoje

**Onde:** D8; `nucleo/fluxo/k-execute.md`, passo 3.

O kit manda parar quando o consumo da tarefa passa do teto, mas o agente não tem leitura
confiável do próprio consumo em tempo real durante a execução. Na prática a regra vira
estimativa, ou é ignorada.

**Saídas possíveis:** medir por proxy observável (número de arquivos lidos, rodadas de
ferramenta, tempo de parede); coletar o custo real depois da execução e usar o teto só como
alarme retroativo; ou remover o campo até existir leitura confiável.

**Risco de não decidir:** regra que ninguém consegue cumprir ensina o executor a ignorar
regras.

## A2 — Suite de referência não existe

**Onde:** D13; item 7 da ordem de construção.

Todo o v2 está escrito em cima de evidência externa, mas nenhuma decisão foi validada neste
kit. Sem a suite, "mudança no núcleo só entra se a suite não piorar" é regra sem instrumento.

**Falta definir:** quais 5 a 10 tarefas reais entram, onde vive o repositório de teste, e
como comparar rodadas com e sem o kit.

## A3 — Segurança "no diff" depende da ferramenta

**Onde:** D10; `nucleo/referencias/gate.md`.

O gate manda rodar segurança sobre o diff, não sobre o repositório. Nem toda ferramenta faz
isso de forma direta: exige comparação com um commit base, ou uma lista explícita de arquivos
alterados. O `k-init` hoje detecta se a ferramenta existe, mas não se ela sabe operar em modo
incremental.

**Consequência se ignorado:** o gate roda varredura completa, leva minutos, e o time desliga
— exatamente o cenário que a decisão tentava evitar.

## A4 — Rodapé de atribuição de IA pode voltar pela ferramenta

**Onde:** `nucleo/referencias/mensagem-commit.md`; `commit.atribuicao_ia`.

A regra proíbe atribuição de IA na mensagem, e o contrato registra isso. Mas a ferramenta em
uso pode reinserir o rodapé por padrão, fora do alcance do shim. Aconteceu nos três primeiros
commits desta branch, que precisaram ser reescritos.

**Saída provável:** o `k-init` verificar a configuração da ferramenta durante a instalação e
avisar quando ela contradiz o contrato.

## A5 — Roteamento de modelo é parcialmente implementável

**Onde:** D7; `modelos.forte` / `modelos.barato`.

Escolher modelo por etapa depende do que cada ferramenta expõe. Subagente costuma aceitar
modelo próprio; a etapa principal, nem sempre. Hoje o kit escreve a intenção ("modelo barato
serve aqui") sem poder garantir.

**Saída:** tratar como recomendação explícita no texto da etapa, e medir o efeito real na
suite de referência antes de prometer economia.

## A6 — `k-revisao` assume GitHub

**Onde:** `nucleo/fluxo/k-revisao.md`; `nucleo/referencias/shipping.md`.

Leitura de comentários e abertura de PR estão escritas em cima de `gh`. Projeto em GitLab,
Bitbucket ou Azure DevOps não tem esse comando.

**Contradição com D14:** o kit se diz agnóstico de ferramenta de IA, mas ficou acoplado a uma
forja. Precisa do mesmo tratamento: um campo no contrato (`git.forja`) e um adaptador por
forja, ou uma degradação explícita para modo manual.

## A7 — O modo de execução é decidido em dois lugares

**Onde:** `execucao.modo_padrao` no contrato; `modo_execucao` no `plan.md`.

O `k-spec` consulta o modo do contrato para decidir se encadeia direto no `k-plan`, mas o modo
real do fluxo só é definido pelo `k-plan`, depois da classificação. Nos casos em que os dois
divergem, o encadeamento do `k-spec` usou informação desatualizada.

**Impacto:** baixo — erra no sentido seguro (encadeia menos do que poderia). Vale simplificar:
ou o `k-spec` para de consultar o modo, ou o contrato passa a ser a única fonte e o `k-plan`
só confirma.

## A8 — Referências não têm teto de tamanho

**Onde:** D3.

O teto de 150 linhas vale para arquivo de fluxo. As referências ficaram sem limite declarado,
e `contrato.md` já está perto de 150. Como referência é carregada sob demanda, o custo é
menor — mas "sem teto" é como o v1 chegou a 434 linhas.

**Sugestão:** teto próprio, mais folgado, e quebra por assunto quando estourar.

## A9 — Revisão automatizada por subagente em todo commit de código

**Onde:** `nucleo/fluxo/k-commit.md`, passo 6.

Diff de código dispara subagentes de revisão a cada commit. É leitura com direções
independentes, então respeita o D6 — mas continua sendo o segundo maior consumo do kit,
depois do `k-scan`, e ainda não foi medido.

**A responder com dado:** a revisão por subagente pega o que o gate já não pegou? Se a maior
parte dos achados for redundante com lint e testes, o custo não se paga.

## A10 — Nada valida o contrato contra o núcleo

Campo do contrato que o núcleo não usa mais, ou campo novo do núcleo ausente no contrato, só
aparece quando uma etapa falha no meio do trabalho.

**Sugestão:** o `k-init`, em modo atualização, comparar o contrato com o esquema da versão
instalada e reportar campos órfãos e ausentes.
