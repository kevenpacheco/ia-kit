# ia-kit

Fluxo de desenvolvimento assistido por IA, versionado e agnóstico de ferramenta: spec antes
de código, plano, tarefas, execução com TDD, gate antes do commit e revisão humana no PR.

O núcleo vive em `nucleo/` e é instalado como `.ia-kit/` no projeto que usa o kit. Cada
ferramenta de IA recebe um shim — um ponteiro para o núcleo, nunca uma cópia da regra.

---

## Instalar num projeto

Na raiz do projeto que vai usar o kit:

```sh
curl -fsSL https://raw.githubusercontent.com/kevenpacheco/ia-kit/main/instalador/instalar.sh | sh
```

```powershell
irm https://raw.githubusercontent.com/kevenpacheco/ia-kit/main/instalador/instalar.ps1 | iex
```

Depois, **rode `k-init`** na sua ferramenta de IA. É ele que detecta a stack, valida os
comandos executando cada um, entrevista o que faltou, grava `.ia-kit/contrato.yml` e gera os
shims. O instalador só copia arquivo.

Commite `.ia-kit/` e os shims. O núcleo é vendorizado de propósito — detalhe em
`nucleo/referencias/instalacao.md`.

## Atualizar

Mesmo comando, e depois `k-init` de novo. O instalador preserva `contrato.yml`, `taticas/` e
`metricas/`; o `k-init` reconcilia o contrato com o esquema novo e poda shim órfão.

Versão fixa em vez da última: `--versao 2.0.0` (sh) ou `-Versao 2.0.0` (ps1).

O que mudou: `CHANGELOG.md`. Passo a passo por versão: `docs/migracao.md`.

## Onde fica o quê

| Caminho | O que é |
|---|---|
| `nucleo/fluxo/` | um arquivo por skill: `k-spec`, `k-plan`, `k-task`, `k-execute`, `k-commit`, `k-revisao`, `k-scan`, `k-init` |
| `nucleo/referencias/` | detalhe carregado sob demanda: contrato, gate, formatos, métricas, instalação |
| `nucleo/esquema.yml` | esquema do contrato, legível por máquina |
| `nucleo/VERSAO` | fonte única da versão do núcleo |
| `adaptadores/` | shim por ferramenta: Claude Code, `AGENTS.md`, Cursor |
| `instalador/` | copia o núcleo para `.ia-kit/`. Não entrevista, não gera shim, não commita |
| `baseline/` | protocolo da suite de referência (ainda **vazia**) |
| `ci/verificar.sh` | invariantes do repositório; roda em todo push e barra o release |
| `docs/arquitetura-v2.md` | as decisões e o dado por trás de cada uma |

## Desenvolver no kit

```sh
bash ci/verificar.sh
```

Checa versão contra tag, teto de linha por arquivo, campo de esquema apontando para fluxo
inexistente, caminho `.ia-kit/` quebrado, fluxo sem shim e shim sem fluxo, seção de CHANGELOG
para a versão atual, e script fora de ASCII.

**Script em `instalador/` e `ci/` é ASCII puro.** O PowerShell 5.1 lê `.ps1` sem BOM como
CP1252: um em dash em UTF-8 vira três caracteres, e o último deles é uma aspa curva que fecha
string — o resto do script vira conteúdo de texto e não roda, sem erro de sintaxe. Prosa com
acento e travessão fica nos `.md`, que ninguém executa.

**Publicar:** atualize `nucleo/VERSAO` e a seção correspondente do `CHANGELOG.md`, depois
`git tag v<versao> && git push --tags`. O workflow verifica, prova que o pacote instala e
atualiza preservando o que é do projeto, e publica o release.
