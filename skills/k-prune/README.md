# k-prune

Auditoria do harness e limpeza de contexto. Fora do fluxo de uma feature.

## O que faz

Regras envelhecem: o código passa a demonstrá-las, os modelos passam a segui-las sem instrução ou o caminho citado some. Cada linha obsoleta no arquivo de instruções custa tokens em toda sessão.

Três subagentes somente de leitura auditam, em paralelo, o `CLAUDE.md`/`AGENTS.md` e as skills em `.claude/skills/`:

| Nível | O que procura |
|---|---|
| A — Integridade | caminhos e skills citados que não existem; comandos de **Comandos do Projeto & Sensores** que não rodam |
| B — Redundância | regras que o código já demonstra, instruções óbvias, regras repetidas ou contraditórias |
| C — Skills | `description` ambígua ou sobreposta, texto que não é passo operacional, artefato lido por uma skill e não produzido por nenhuma |

## Quando usar

Periodicamente, ou quando instruções e skills crescerem.

## Uso

```
/k-prune
```

## Resultado

Uma tabela com `arquivo:linha`, nível, achado, proposta e estimativa de tokens economizados. Você escolhe quais aplicar (números / todos / nenhum). Só os aprovados são aplicados; regra repetida fica num lugar só. Nenhuma skill nem regra de segurança é removida sem aprovação explícita.
