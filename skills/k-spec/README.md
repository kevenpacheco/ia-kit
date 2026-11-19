# k-spec

Planejamento Spec-Lean. Primeira etapa do fluxo: `/k-spec` → `/k-execute` → `/k-review` → `/k-verify` → `/k-commit`.

## O que faz

Investiga o código com subagentes de leitura, entrevista você em rodadas (só pergunta o que o repositório não responde) e grava um plano único com critérios de aceite verificáveis. Nada é gravado como aprovado sem o seu "sim".

## Quando usar

Ao iniciar qualquer feature, correção, refactor ou chore que vá virar commit.

## Uso

```
/k-spec <descrição do trabalho>
/k-spec <slug de uma spec existente>   # atualiza a spec
```

## Lê

`CLAUDE.md`/`AGENTS.md`, `roadmap.md`, `GLOSSARY.md`, `docs/adr/` e o código afetado.

## Produz

Em `docs/specs/<AAAAMMDD-HHMMSS>-<slug>/`:

- `spec.md`: escopo, regras de domínio, pontos de teste, decisões técnicas, histórico de decisões e (trabalho grande) fatias.
- `checklist.md`: itens observáveis com valor concreto, cada um com a camada entre colchetes.

Também atualiza `GLOSSARY.md` e cria ADRs quando há o que registrar.

## Tamanho do trabalho

| Tamanho | O que muda |
|---|---|
| Pequeno (até ~3 arquivos) | `spec.md` enxuto com o checklist inline, sem `checklist.md` |
| Médio | fluxo completo |
| Grande (mais de ~8 itens) | dividido em fatias verticais, uma por sessão |

## Não faz

Não altera código de aplicação, não faz commit e não decide pelo usuário.

**Próximo passo:** `/k-execute <slug>`
