---
name: k-prune
description: Auditoria do harness. Encontra no arquivo de instruções (CLAUDE.md/AGENTS.md) e nas skills de .claude/skills/ caminhos quebrados, comandos inválidos, regras redundantes ou obsoletas e descrições ambíguas, e propõe a poda para reduzir tokens. Use periodicamente ou quando instruções e skills crescerem; não faz parte do fluxo de uma feature.
---

# k-prune — Auditoria do Harness & Limpeza de Contexto

Regras envelhecem: o código passa a demonstrá-las, os modelos passam a segui-las sem instrução, ou o caminho citado some. Cada linha obsoleta no arquivo de instruções custa tokens em toda sessão.

## Procedimento

### 1. Auditar em paralelo
Um subagente somente de leitura por nível, todos na mesma mensagem:

| Nível | O que procurar |
|---|---|
| A — Integridade | arquivo, pasta ou skill citada que não existe; comando da seção **Comandos do Projeto & Sensores** que não roda (confira em `package.json`, `Makefile`, `pyproject.toml` etc.) |
| B — Redundância | regra que o código já demonstra de forma consistente; instrução óbvia para modelos atuais; regra repetida entre o arquivo de instruções e uma skill, ou contraditória entre eles |
| C — Skills | `description` ambígua ou sobreposta a outra skill; texto explicativo que não é passo operacional; artefato lido por uma skill e não produzido por nenhuma |

Cada achado volta com `arquivo:linha`, evidência e a edição proposta (remover, condensar ou mover).

### 2. Propor
```
| # | Arquivo:linha | Nível | Achado | Proposta | Tokens economizados (estim.) |
```

Pergunte quais aplicar (números / todos / nenhum).

### 3. Aplicar
Só os aprovados. Regra repetida fica num lugar só: o que vale em toda sessão no arquivo de instruções; o procedimento de uma fase, na skill dela. Não remova skill nem regra de segurança sem aprovação explícita.
