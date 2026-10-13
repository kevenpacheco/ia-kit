# Changelog

Uma seção por versão do núcleo, da mais nova para a mais antiga. A versão é a de
`nucleo/VERSAO`, e é ela que o `k-init` grava em `kit_versao`.

Versão é sempre `X.Y.Z`, sem sufixo. O que cada dígito promete:
`nucleo/referencias/instalacao.md`, seção 3. Passo a passo de cada MAJOR: `docs/migracao.md`.

---

## 2.1.0

Fecha a lacuna de verificação — até aqui quem dizia que o trabalho estava certo era o próprio
autor — e **encurta o fluxo de 8 etapas para 5**. Mesmo comando de instalação; rode `k-init`
depois.

### Quebra

- **`k-task` e `k-verificar` deixam de existir como skills.** O fluxo é
  `k-spec` → `k-plan` → `k-execute`, com `k-commit` delegado e `k-revisao` depois do PR.
  A quebra em tarefas virou o passo 9 do `k-plan`; a verificação virou o encerramento do
  `k-execute`. Nenhum comportamento foi perdido — veja D19.
- Shims de `k-task` e `k-verificar` são **podados** pelo `k-init` na atualização. Comando
  antigo deixa de existir; se você tinha atalho para `/k-task`, aponte para `/k-plan`.
- Campo `execucao.dimensionamento` **não existe mais** (nunca foi publicado). Se você copiou
  um pre-release com ele, o `verificar-contrato.sh` reporta como campo órfão.

### Adiciona

- **Verificação independente** no encerramento do `k-execute`: subagente **sem o histórico de
  quem escreveu o código** confere cada critério de aceite contra `<base>..HEAD` e grava
  `verificacao.md` com veredito e evidência `arquivo:linha`. Reprovado não fecha o fluxo e não
  sobe. O arquivo de fluxo nunca julga — skill roda na mesma conversa do autor, e só o
  despacho mantém autor diferente de verificador.
- **Critérios de aceite com identificador `CA-n`**, estável e nunca reaproveitado. Liga
  critério → tarefa (`criterios:`) → veredito, e torna cobertura computável.
- **Prova por injeção de falha** — reverte a implementação numa `git worktree` descartável,
  mantém o teste novo e confirma o vermelho pela asserção. Obrigatória em `tipo: bug`,
  tarefa 1. A corrida de controle antes de injetar é obrigatória: árvore sem dependência
  deixa todo teste vermelho e faria toda prova passar falsamente.
- **Quatro gates determinísticos em POSIX sh**, em `.ia-kit/scripts/`. Exit code decide, em
  vez de prosa reinterpretada a cada invocação: 0 forma ok, 1 forma violada, 2 uso, 3 não
  consigo ler, 4 reprovado.
- Campos novos, todos opcionais com default seguro: `verificacao.perfil`,
  `verificacao.rodadas_max`, `verificacao.injecao_falha`, `verificacao.preparar_arvore`,
  `execucao.verificadores`. Valor novo em `shipping.pr_draft_quando`:
  `verificacao_ressalva`.
- Referências: `verificadores.md`, `verificacao-formato.md`, `injecao-falha.md`,
  `encerramento.md`, `deteccao.md`.
- `ci/verificar.sh`: checagem ASCII vira glob por diretório e troca `grep -qP` por `tr`;
  checagem nova roda cada verificador contra fixture boa **e ruim**, conferindo exit code.
  `sh -n` sozinho não basta para um gate — script que sai 0 em tudo passa com louvor.

### Corrige

- `verificar-contrato.sh` usa `grep -F`: sem isso `comandos.lint` casaria `comandosXlint`,
  porque o ponto é metacaractere.
- `contrato.md` perdeu 27 linhas duplicadas de `gate.md`, do D7 e do D8.
- `k-init` estava em 150/150. As tabelas de detecção de stack saíram para
  `referencias/deteccao.md`.

### Nao quebra

Contrato de 2.0.0 continua válido. Campo novo ausente faz a verificação **rodar e avisar, sem
bloquear** — mesmo precedente de `comandos.seguranca` vazio. O bloqueio só liga depois do
`k-init`.

**Spec escrita antes da 2.1.0** não tem `CA-n` e reprova no `verificar-spec.sh`. Numere os
critérios na ordem em que já estão, sem reescrever o texto.

### Sem baseline

Esta versão entra **sem** a suite de referência do D13, que continua vazia. Se o verificador
independente acha defeito que o gate não acha é pergunta em aberto, registrada em
`docs/achados-v2.md`, A11. O ganho é aposta apoiada em evidência externa, não medição.

## 2.0.0

Primeira versão publicada do v2. Reescrita do kit inteiro, com instalação e atualização
executáveis. Vindo do v1, é instalação nova: o v1 não tinha contrato nem núcleo versionado.

### Estrutura

- Três camadas com fronteira explícita: `nucleo/` (invariável entre projetos),
  `adaptadores/` (shim por ferramenta), `taticas/` (do projeto).
- Núcleo vendorizado: `.ia-kit/` é cópia commitada no repositório do projeto.
- Shim por ferramenta — Claude Code, `AGENTS.md`, Cursor — sempre ponteiro, nunca cópia de
  regra.

### Fluxo

- `k-spec`, `k-plan`, `k-task`, `k-execute`, `k-scan`, `k-commit`, `k-revisao`, `k-init`,
  cada um dividido em fluxo curto mais referência sob demanda.
- Gate movido do `k-execute` para o `k-commit`, que vira a porta única de git: mudança manual
  e trabalho fora do fluxo passam pelo mesmo lint, teste e varredura de segurança.
- `k-revisao`: comentário de revisor em PR aberto vira tarefa.

### Contrato

- `.ia-kit/contrato.yml` declara stack, comandos, convenções de git, limites de execução e
  escolha de modelos. Esquema legível por máquina em `nucleo/esquema.yml`.
- `kit_versao` e `kit_origem` gravam a versão do núcleo e de onde atualizar.
- Limite de tarefa por sinal observável — arquivos lidos, rodadas de ferramenta, minutos —
  em vez de teto de tokens, que o agente não consegue medir durante a execução.
- `comandos.seguranca_diff`: varredura incremental, gravada só depois de o `k-init` testá-la
  contra um diff real.

### Instalação e versionamento

- `instalador/instalar.sh` e `instalador/instalar.ps1` baixam uma versão do núcleo e
  substituem `.ia-kit/`, preservando `contrato.yml`, `taticas/` e `metricas/`. Não
  entrevistam, não geram shim, não commitam — quem reconcilia é o `k-init`.
- `k-init` em modo atualização: diff campo a campo, respostas anteriores preservadas, e poda
  de shim órfão (shim sem `fluxo/k-*.md` correspondente vira comando morto).
- `nucleo/referencias/instalacao.md` — modelo vendorizado, tabela de semver, o que o
  instalador preserva, reconciliação de shim.
- `ci/verificar.sh` e `.github/workflows/verificar.yml` — versão contra tag, teto de linha do
  D3, campo de esquema sem fluxo que o use, caminho `.ia-kit/` quebrado, shim sem fluxo e
  fluxo sem shim, seção de CHANGELOG para a versão atual, e script fora de ASCII. Em tag, o
  workflow instala o pacote num projeto vazio e atualiza por cima, provando que o que é do
  projeto sobrevive.
- Script em `instalador/` e `ci/` é ASCII puro: o PowerShell 5.1 lê `.ps1` sem BOM como
  CP1252, e o terceiro byte de um em dash UTF-8 é uma aspa curva que fecha string. Custou 39
  linhas do instalador executando como texto, sem erro de sintaxe.

### Medição

- `baseline/PROTOCOLO.md` e os modelos em `baseline/tarefas/` e `baseline/resultados/` — o
  instrumento da suite de referência. A suite está **vazia**: falta escolher repositórios-alvo
  e commits de gabarito.
- `nucleo/referencias/metricas.md` — como coletar cada métrica do D13 com git e ferramenta
  agnóstica de stack.
