# Changelog

Uma seção por versão do núcleo, da mais nova para a mais antiga. A versão é a de
`nucleo/VERSAO`, e é ela que o `k-init` grava em `kit_versao`.

Versão é sempre `X.Y.Z`, sem sufixo. O que cada dígito promete:
`nucleo/referencias/instalacao.md`, seção 3. Passo a passo de cada MAJOR: `docs/migracao.md`.

---

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
