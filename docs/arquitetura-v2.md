# ia-kit v2 — Arquitetura

Documento de decisões. Define o que o kit é, o que entra no núcleo, e por que cada regra
existe. Toda decisão aqui tem um dado por trás — quando o dado mudar, a decisão é revisada.

Status: proposta. Nada implementado ainda.

---

## 1. O que é o kit

Um conjunto versionado de skills e regras que instala em qualquer repositório e entrega um
fluxo de desenvolvimento assistido por IA com spec, plano, tarefas, execução com TDD, gates
de verificação e commit.

O que o v1 provou que funciona fica. O que a evidência contradiz muda. Esta seção lista o
que **não** muda:

| Peça | Por que fica |
|---|---|
| Spec antes de código | Única técnica com ganho de qualidade medido: +9,8 p.p. em detecção de bug contra agente de teste tradicional |
| Teste e implementação na mesma tarefa, sem commit vermelho | Ataca churn de duas semanas, que subiu 15% na era da IA |
| Uma tarefa por invocação | Contexto curto reduz token e evita degradação por contexto longo |
| `k-scan` com subagentes por eixo + refutador adversarial | Uso correto de paralelismo: direções independentes, leitura pura |
| Escrita restrita aos arquivos declarados; `git add .` proibido | Contém duplicação de código, que subiu 81% desde 2023 |
| Spec no corpo do PR | Reviewer não reconstrói intenção a partir do diff |

---

## 2. Princípios

1. **O gargalo não é gerar código, é verificar.** Métricas individuais sobem (+21% tarefas,
   +98% PRs merged) sem mover a entrega da organização. O kit investe em verificação.
2. **Contexto é curadoria, não acúmulo.** Arquivo de contexto gerado por LLM custa +20% e
   reduz sucesso em 3%. Escrito à mão e curto melhora 4%.
3. **Token é decisão de arquitetura.** 76% dos tokens de uma tarefa são leitura. Layout de
   arquivo e ordem de prompt definem a conta.
4. **Autonomia é proporcional ao tipo de trabalho.** Greenfield simples rende +30–40%.
   Brownfield complexo rende 0–10%, às vezes negativo.
5. **Segurança é gate, não instrução.** Modelo sem instrução de segurança introduz
   vulnerabilidade em cerca de 44% das gerações, e esse número não melhora com modelo novo.
6. **Sem baseline, o kit é opinião.** Mudança no núcleo precisa passar por suite de referência.

---

## 3. Decisões

### D1 — Três camadas com fronteira explícita

```
nucleo/        invariável entre projetos    -> prefixo estável, cacheável
adaptadores/   shim por ferramenta de IA    -> gerado na instalação
taticas/       skills do próprio projeto    -> vivem no repo do projeto
```

No repositório do kit, `nucleo/` e `adaptadores/` são a fonte. No projeto que instala, o
núcleo vira `.ia-kit/` e os adaptadores viram os arquivos que cada ferramenta espera:

```
repositório do kit            projeto que instala
nucleo/         ---------->   .ia-kit/          núcleo + contrato.yml
adaptadores/    ---------->   .claude/skills/   shim (Claude Code)
                              AGENTS.md         bloco (demais ferramentas)
```

**Regra de fronteira:** se muda de projeto para projeto, não entra no núcleo. Entra como
detecção ou como ponto de extensão declarado. Núcleo com condicional por projeto é núcleo
quebrado.

O v1 já fazia isso implicitamente (detecção de `docs/specs` vs `documentation/specs`, campo
`skill` lendo `.claude/skills/` do projeto). O v2 torna explícito, que é o que permite
instalar em repositório novo sem editar o núcleo.

### D2 — Contrato do projeto em vez de prosa

Cada projeto declara suas capacidades em `.ia-kit/contrato.yml`: stack, comandos de lint,
teste, suite e segurança, convenções de git, modo de execução, teto de tokens e escolha de
modelos. Esquema completo em `nucleo/referencias/contrato.md`.

**Motivo:** prosa do tipo "use o comando de teste do projeto" é reinterpretada a cada
invocação e gasta leitura. Campo é lido uma vez.

**Implicação:** skill que precisa rodar algo lê o contrato. Skill que não acha o campo para e
pergunta, em vez de adivinhar comando.

**Validação:** o `k-init` executa cada comando antes de gravar. Comando que não roda fica
fora. Contrato com comando quebrado é pior que campo vazio, porque a skill confia nele e
falha no meio do fluxo. Comando que roda e sai diferente de zero conta como válido — o
comando existe, o projeto é que está sujo.

### D3 — Teto de contexto por skill, com divulgação progressiva

- Arquivo de fluxo contém apenas o fluxo de decisão. Teto: **150 linhas**.
- Arquivo de referência: teto de **200 linhas**, carregado sob demanda. Estourou, quebre por
  assunto. "Sem teto" foi como o v1 chegou a 434 linhas num arquivo carregado sempre.
- Tabelas longas, exemplos e casos de borda vão para referência.
- Proibido no núcleo: gerar automaticamente arquivo de contexto do projeto.

**Motivo:** contexto gerado por LLM reduz sucesso em 3% e aumenta custo em mais de 20%
(14% a 22% mais tokens de raciocínio). Contexto curto escrito à mão melhora 4%.

**Dívida herdada:** `k-spec/SKILL.md` tinha 434 linhas no v1, carregadas inteiras a cada
invocação. É o primeiro alvo da divisão.

### D4 — Ordem de prompt estável para aproveitar cache

Ordem obrigatória do que é montado em contexto:

```
1. núcleo do kit          (imutável)
2. contrato do projeto    (muda raramente)
3. spec e plano do fluxo  (muda por fluxo)
4. tarefa e diff          (muda por invocação)
```

**Motivo:** leitura de prefixo em cache custa 0,1x do input normal. Prefixo estável é o maior
redutor de custo disponível, e é apenas uma decisão de layout.

**Implicação:** nada volátil (timestamp, branch, estado de git) pode aparecer antes do passo 3.

### D5 — Leitura dirigida, nunca despejo

Subagente de leitura devolve `arquivo:linha` mais conclusão. Não devolve trecho de código
copiado, não lista árvore de diretório inteira, não lê arquivo inteiro quando a busca por
símbolo resolve.

**Motivo:** leitura é 76% do custo de uma tarefa.

### D6 — Paralelismo condicional (revoga a regra do v1)

O `modelo-CLAUDE.md` do v1 mandava "usar o máximo de subagentes possível". Isso é revogado.

**Regra nova:** paralelizar apenas quando as direções são independentes **e** o trabalho é
leitura. Escrita em código roda sequencial.

**Motivo:** sistema multi-agente consome cerca de 15x os tokens de uma conversa simples, e
agente comum já consome cerca de 4x. O ganho de paralelismo cai conforme falhas de
coordenação acumulam; preservar a informação crítica pesa mais do que somar agentes.

**Onde continua valendo:** `k-scan` (eixos de defeito independentes, leitura pura),
investigação do `k-plan`, refutação adversarial. São exatamente os casos de alto valor e
direções independentes em que o multiplicador se paga.

### D7 — Roteamento de modelo por etapa

| Etapa | Modelo |
|---|---|
| `k-plan`, `k-execute` | forte |
| `k-scan`, sumarização, refutação, busca | barato |

**Motivo:** roteamento por tier economiza 30% a 50% sozinho; combinado com cache passa de
70%. A varredura é a etapa de maior volume e a que menos exige raciocínio profundo.

**Limite de aplicação:** depende do que cada ferramenta expõe. Subagente costuma aceitar
modelo próprio; a etapa principal, nem sempre. Onde não dá para impor, o campo `modelos` vale
como recomendação registrada — e a economia só é afirmada depois de aparecer no baseline.
Prometer número que o kit não controla é como a economia vira folclore.

### D8 — Limite de tarefa por sinal observável

Cada tarefa tem limite de **arquivos lidos, rodadas de ferramenta e minutos**. Estourou
qualquer um: para, diz qual estourou, devolve para o humano.

**Por que não contagem de token:** a versão anterior desta decisão fixava um teto de tokens
por tarefa. O agente não lê o próprio consumo de forma confiável durante a execução, então a
regra virava estimativa — e regra que ninguém consegue cumprir ensina o executor a ignorar
regras. Os três sinais são observáveis sem instrumentação especial.

**Custo em dinheiro é retrospectivo.** O fechamento do `k-execute` informa o que a ferramenta
reportar; campo vazio quando ela não reporta. Uma tarefa agentic consome tipicamente de 1 a
3,5 milhões de tokens, e o custo observado no mercado vai de US$ 0,03 a US$ 2,60 — medir
depois e de verdade vale mais que prever antes e errar.

**Uso real do limite:** tarefa que estoura quase sempre está mal quebrada. O sinal serve mais
como diagnóstico do `k-task` do que como controle de custo.

### D9 — Uma tarefa por invocação é política de token e de qualidade

Mantido do v1, agora com justificativa registrada para não ser "otimizado" fora: o desempenho
de todos os modelos testados degrada conforme a entrada cresce, e janelas maiores adiam a
degradação sem eliminá-la. Em monitoramento de agentes, ações perigosas passam despercebidas
de 2 a 30 vezes mais quando aparecem depois de 800 mil tokens de contexto benigno.

### D10 — Gate em camadas, falha barato primeiro

```
1. lint
2. testes afetados
3. segurança        (SAST + pós-processamento por LLM dos achados)
4. review por IA    (apenas camada mecânica)
5. review humano    (lógica de negócio e arquitetura)
```

Passos 1 a 3 rodam dentro do `k-commit`, antes de gravar o commit. Passos 4 e 5 rodam no PR.

**O gate pertence ao commit, não ao fluxo.** No v1 ele vivia no `k-execute`, então mudança
manual, ajuste pequeno e trabalho da IA fora do ciclo entravam no repositório sem lint, sem
teste e sem verificação de segurança — exatamente onde ninguém está olhando. No v2 o
`k-commit` é a porta única de git que muda estado, e o `k-execute` delega a ele.

O gate se dimensiona pelo diff: commit avulso roda lint, testes dos arquivos tocados e
segurança sobre o diff; a suite completa fica no encerramento do fluxo. Varredura de
segurança no diff leva segundos — é o que permite rodar sempre sem que o time desligue o
gate.

**Contra o desvio de processo:** acima de `execucao.limiar_promocao`, o `k-commit` sugere
abrir um fluxo. Sugere, não bloqueia. Processo que atrapalha é processo contornado.

**Sobre o passo 3.** O gate do v1 era lint mais testes. Isso não cobre o risco medido:
modelos geram código que compila em praticamente 100% dos casos, mas cerca de 44% das tarefas
de geração introduzem uma vulnerabilidade quando não há instrução de segurança explícita, e a
taxa de aprovação em segurança está estagnada em 56% desde 2023 — modelo mais novo não
resolve. SAST isolado gera ruído alto; ferramenta baseada em LLM isolada varia de 6% a 82% de
acurácia em vulnerabilidade real. A combinação de SAST com pós-processamento por LLM reduziu
falsos positivos em 91% frente ao scan isolado, e é a configuração com melhor evidência
disponível hoje.

**Sobre o passo 5.** Times que eliminaram o review humano registraram mais defeitos. O kit
reduz o custo do review humano — PR pequeno, spec anexada, causa raiz escrita — e nunca o
substitui. Ferramenta de IA cobre de 40% a 60% do trabalho mecânico de review e é fraca
justamente em lógica de negócio e arquitetura.

**Contexto do gargalo:** código gerado por IA espera 4,6x mais pelo primeiro review. Gerar
mais sem ampliar capacidade de review piora o lead time.

### D11 — Modo de execução escolhido pelo tipo de trabalho

| Contexto | Ganho medido | Modo |
|---|---|---|
| Greenfield simples | +30% a +40% | autonomia alta, tarefas maiores |
| Greenfield complexo | +10% a +15% | plano obrigatório, tarefas médias |
| Brownfield complexo | 0% a 10%, às vezes negativo | humano decide, tarefas mínimas, gate cheio |

O `k-plan` já classificava "legado puro" contra "contexto em evolução". No v2 essa
classificação passa a **selecionar o modo**: tamanho da tarefa, profundidade do gate e quanto
o agente decide sozinho.

### D12 — Instalação e versionamento

- Núcleo com versão semântica, fonte única em `nucleo/VERSAO`. O contrato grava a versão que
  gerou ele, em `kit_versao`, e a URL de onde ele veio, em `kit_origem`.
- **O núcleo é vendorizado:** `.ia-kit/` é cópia commitada no repositório do projeto. Não é
  submodule, não é pacote de linguagem, não é symlink.
- Instalar e atualizar = mesmo comando. O instalador (`instalador/instalar.sh` e `.ps1`) só
  troca arquivo, preservando `contrato.yml`, `taticas/` e `metricas/`. Quem reconcilia
  contrato e shims é o `k-init`.
- `kit_versao` diferente de `.ia-kit/VERSAO`: `k-init` roda em modo atualização, com diff
  campo a campo, as respostas anteriores preservadas, e poda de shim órfão.

**Por que vendorizado:** o agente precisa ler os arquivos. Submodule some em clone raso e em
worktree; pacote de linguagem amarra um kit agnóstico a um ecossistema; arquivo fora do repo
não existe no CI. Como efeito colateral, a atualização aparece no diff do PR — quem revisa vê
qual regra mudou, e `git checkout -- .ia-kit` desfaz.

**Por que script burro e skill esperta:** o instalador não entrevista e não gera shim. Lógica
duplicada entre um script e um fluxo sai de sincronia, e aí o script passa a instalar uma
versão do processo que o núcleo não descreve.

**O que cada dígito promete** está escrito e é verificado: tabela de semver em
`nucleo/referencias/instalacao.md`, uma seção por versão em `CHANGELOG.md`, passo a passo por
MAJOR em `docs/migracao.md`. `ci/verificar.sh` barra o release quando a tag não bate com
`nucleo/VERSAO`, quando falta seção de CHANGELOG, quando um teto de linha do D3 estoura, ou
quando fluxo e shim saem de sincronia.

**Motivo:** sem instalação e atualização definidas, cada projeto vira um fork silencioso e o
kit deixa de ser kit. E promessa de compatibilidade que ninguém verifica vira folclore do
mesmo jeito que número de economia sem baseline.

### D13 — Suite de referência e métricas

**Suite de referência:** protocolo em `baseline/PROTOCOLO.md` — composição obrigatória por
fatia, procedimento das duas rodadas, o que medir e o critério de aceite de uma mudança no
núcleo. Modelos de tarefa e de resultado em `baseline/tarefas/` e `baseline/resultados/`.

**Coleta das métricas:** `nucleo/referencias/metricas.md` — como medir cada eixo com git e
ferramenta agnóstica de stack, onde registrar, e o que não medir.

A suite está **vazia**: o instrumento existe, o conteúdo depende de escolher repositórios-alvo
e commits de gabarito. Enquanto isso, toda decisão deste documento está apoiada só em
evidência externa — menos do que o kit exige de si mesmo.

**Métricas de repositório**, coletadas desde o primeiro dia:

| Métrica | Por que esta |
|---|---|
| Duplicação de bloco | Subiu 81% no agregado do mercado |
| Churn de duas semanas | Subiu 15% |
| Reuso entre arquivos | Caiu 35% |
| Movimentos de refatoração | Caíram 70% |
| Latência do primeiro review | 4,6x maior em código de IA |
| Custo por tarefa | Único número que liga o kit a dinheiro |

Frequência de deploy e lead time perdem significado quando a IA escreve de 30% a 70% do
commit. Não servem como métrica principal do kit.

**Regra:** mudança no núcleo só entra se a suite de referência não piorar.

### D14 — Agnóstico de ferramenta

O kit não pode depender do Claude Code. Núcleo e contrato vivem em `.ia-kit/`, diretório
neutro. Cada ferramenta de IA recebe um **shim**: arquivo no formato que ela espera, cujo
corpo aponta para o arquivo de fluxo no núcleo.

| Ferramenta | Shim |
|---|---|
| Claude Code | `.claude/skills/k-*/SKILL.md` |
| Codex, Copilot e afins | bloco delimitado em `AGENTS.md` |
| Cursor | `.cursor/rules/*` |

**A mesma regra vale para a forja.** Escrever o fluxo em cima de `gh` amarrava o kit ao
GitHub com a mesma força com que `.claude/` o amarrava a uma ferramenta de IA. `git.forja` no
contrato e `nucleo/referencias/forja.md` isolam o **como**; o **o quê** — um PR por fluxo,
draft com ponta solta, merge humano — fica no fluxo. Sem CLI de forja, o kit degrada para
modo manual explícito, e nunca afirma ter aberto um PR que não existe.

**Regra:** shim é ponteiro, nunca cópia. Regra duplicada em adaptador sai de sincronia na
primeira atualização do núcleo, e aí cada ferramenta passa a seguir uma versão diferente do
fluxo.

**Motivo:** kit preso a `.claude/` morre se o time trocar de ferramenta, e força os artefatos
do próprio kit — contrato, métricas do D13, baseline — a morarem dentro da pasta de
configuração de outra ferramenta.

**Custo aceito:** uma leitura de indireção por invocação. O shim é curto e fica antes do
conteúdo volátil, então continua dentro do prefixo cacheável do D4.

---

### D15 — O PR é o ponto de revisão humana

O humano entra uma vez, no fim, com o trabalho inteiro na frente — não a cada etapa do
fluxo. Ao encerrar, a ferramenta faz push e abre o PR; o revisor comenta; `k-revisao` lê os
comentários, classifica e transforma o que for mudança pedida em tarefas; `k-execute`
corrige; commits novos atualizam o PR.

**Por que o PR e não o chat:** aprovação em conversa não deixa rastro. Comentário em PR é
assíncrono, auditável e é onde o revisor já trabalha. E concentra o humano exatamente onde a
IA é fraca — lógica de negócio e arquitetura —, em vez de gastá-lo confirmando etapas.

**Autorização durável, não decisão da ferramenta.** Push e PR são ação externa: notificam
pessoas, disparam CI. Ficam atrás de `shipping.automatico`, padrão `false`, que o projeto
liga uma vez no contrato.

**Guarda-corpos, todos obrigatórios:**

| Regra | Motivo |
|---|---|
| Um PR por fluxo, nunca por tarefa | É o que impede a fila de review de estourar |
| Só com suite verde e tarefas fechadas | PR quebrado consome revisor à toa |
| Draft quando há achado aberto ou modo legado | Draft não convoca o revisor para trabalho com ponta solta |
| Correção por commit novo, nunca force-push | Force-push deixa comentário órfão e o revisor perde o rastro |
| Merge sempre humano | Volume de PR merged sobe sem mover a entrega; a aprovação é o que liga as duas coisas |
| Teto de três rodadas por PR | Acima disso o problema é de escopo, não de correção — e o agente não se cansa de aceitar pedido |

**Como saber se deu errado:** as métricas do D13 já cobrem — latência do primeiro review e
rodadas por PR. Se a latência subir depois de ligar o automático, o kit está produzindo
ruído, não entrega, e `shipping.automatico` volta para `false`.

## 4. Ordem de construção

| # | Entrega | Destrava |
|---|---|---|
| 1 | Contrato do projeto + `k-init` (D1, D2, D12, D14) | Portabilidade e cache |
| 2 | Divisão de `SKILL.md` em núcleo + referências (D3, D4) | Custo por invocação |
| 3 | Gate no `k-commit`, porta única de git (D10) | Risco não coberto |
| 4 | `k-revisao`: comentário de PR vira tarefa (D15) | Revisão humana no lugar certo |
| 5 | Revogação da regra de subagentes (D6) | Custo de token |
| 5 | Roteamento de modelo + orçamento (D7, D8) | Custo por tarefa |
| 6 | Modos por tipo de trabalho (D11) | Ganho onde rende |
| 7 | Suite de referência + métricas (D13) | Prova de que funciona |

---

## 5. Riscos assumidos

- **Curva J.** A adoção piora antes de melhorar: aprendizado, imposto de verificação e ajuste
  de processo. O orçamento precisa suportar o vale.
- **Dívida de IA é persistente.** De 464.900 issues introduzidas por IA em 6.299 repositórios,
  22,7% continuavam presentes na versão mais recente. O que não é corrigido no fluxo tende a
  não ser corrigido depois. Daí o gate antes do commit, não depois do PR.
- **Confiança do time.** A adoção de ferramentas de IA está em 84%, mas só 29% dos
  desenvolvedores confiam na precisão do código gerado, contra 40% no ano anterior. O kit
  precisa produzir artefatos auditáveis — spec, causa raiz, ciclos de teste — e não apenas
  código.

---

## 6. Fontes

- METR — RCT com desenvolvedores experientes: https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/
- METR — revisão do desenho experimental (fev/2026): https://metr.org/blog/2026-02-24-uplift-update/
- DORA 2026 — ROI e capacidades organizacionais: https://www.infoq.com/news/2026/05/dora-roi-ai-assisted-dev-report/
- GitHub e Accenture — RCT empresarial: https://github.blog/news-insights/research/research-quantifying-github-copilots-impact-in-the-enterprise-with-accenture/
- Stanford — 100 mil desenvolvedores, produtividade e rework: https://proxify.io/articles/stanford-study-of-100000-developers-on-engineering-productivity
- Veracode 2026 — segurança de código gerado: https://www.veracode.com/blog/2026-genai-code-security-report-ai-risk/
- GitClear 2026 — manutenibilidade, 623 milhões de mudanças: https://www.gitclear.com/the_ai_code_quality_maintainability_gap
- arXiv 2602.11988 — avaliação de AGENTS.md (ETH Zurich): https://arxiv.org/pdf/2602.11988
- arXiv 2608.17177 — geração de testes guiada por especificação: https://arxiv.org/abs/2608.17177
- arXiv 2605.12366 — degradação por contexto longo: https://arxiv.org/abs/2605.12366
- arXiv 2607.25656 — OrchBench, orquestração multi-agente: https://arxiv.org/abs/2607.25656
- Anthropic — economia de token em sistema multi-agente: https://blog.bytebytego.com/p/how-anthropic-built-a-multi-agent
- Vantage — custo de sessões de codificação agentic: https://www.vantage.sh/blog/agentic-coding-costs
- DeepSource — comparativo de ferramentas de review por IA: https://deepsource.com/resources/ai-code-review-tools
- Stack Overflow — lacuna de confiança: https://stackoverflow.blog/2026/02/18/closing-the-developer-ai-trust-gap/
