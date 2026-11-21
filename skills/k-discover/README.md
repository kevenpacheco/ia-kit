# k-discover

Discovery e especificação. Primeira etapa do fluxo: **`/k-discover`** → `/k-plan` → `/k-build` → `/k-review` → `/k-verify` → `/k-commit`.

## O que faz

Investiga o código com subagentes de leitura e entrevista você em rodadas numeradas, cada uma com a resposta recomendada. Só pergunta o que o repositório não responde, e nunca assume premissa: o que não foi decidido vira pergunta. Grava o **quê** (não o como) com critérios de aceite numerados. Nada é gravado como aprovado sem o seu "sim".

É a etapa onde vale gastar: rode numa sessão com o modelo mais forte (Opus). As etapas seguintes rodam em modelos menores e dependem de a spec não deixar nada para interpretar.

## Quando usar

- Ao iniciar qualquer feature, correção, refactor ou chore que vá virar commit.
- Quando o `/k-plan` ou o `/k-build` pararem com um `duvidas.md` de produto.

## Uso

```
/k-discover <descrição do trabalho>
/k-discover <slug de uma spec existente>   # atualiza a spec ou responde o duvidas.md
```

## Lê

`CLAUDE.md`/`AGENTS.md`, `roadmap.md`, `GLOSSARY.md`, `docs/adr/` e o código afetado.

## Produz

Em `docs/specs/<AAAAMMDD-HHMMSS>-<slug>/`:

- `contexto.md`: fatos do repositório com `arquivo:linha` (onde o fluxo mora, padrões a reutilizar, como os testes rodam).
- `spec.md`: escopo, regras de domínio com exemplos literais, pontos de teste, decisões técnicas, histórico de decisões e (trabalho grande) fatias.
- `checklist.md`: itens observáveis com ID (`C1`, `C2`…), camada e valor concreto.

Também atualiza `GLOSSARY.md` e cria ADRs quando há o que registrar.

## Tamanho do trabalho

| Tamanho | O que muda |
|---|---|
| Pequeno (até ~3 arquivos) | `spec.md` com checklist e plano inline; pula o `/k-plan` |
| Médio | fluxo completo |
| Grande (mais de ~8 itens) | dividido em fatias verticais, uma por sessão |

## Não faz

Não altera código, não escreve testes, não decide como implementar e não faz commit.

**Próximo passo:** `/k-plan <slug>` em sessão nova (pequeno: `/k-build <slug>`)
