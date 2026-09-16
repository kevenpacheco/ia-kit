# Corpo do PR

Montado pelo `k-execute` a partir do `spec.md` e do `plan.md`. Conteúdo de negócio é de quem
tem o contexto; o `k-commit` só publica.

Carrega o que o diff não conta: o problema, a decisão e as opções descartadas. É o que
devolve velocidade à fila de review — a causa apontada para a fila lenta é o revisor não
conseguir reconstruir a intenção a partir do diff.

---

## Branch `feat/`, `refactor/`, `chore/`, `docs/`

```markdown
Titulo: <titulo da spec>
Base: <alvo escolhido>

Spec: `<raiz>/<ts>-<slug>/`

## O que muda
<objetivo e escopo, vindos do spec.md>

## Como testar
<testes manuais, vindos do plan.md>
```

## Branch `fix/`

```markdown
Titulo: <titulo da spec>
Base: <alvo escolhido>

Spec: `<raiz>/<ts>-<slug>/`

## Causa raiz
<arquivo:linha e por que o comportamento errado acontece, vindo do plan.md>

## Correcao escolhida
<opção adotada e por que resolve a causa, não o sintoma>

## Opcoes descartadas
<cada alternativa do plano e o motivo de não ter sido escolhida>

## Regressao coberta
<teste que falhava antes e passa depois, ou a justificativa do plano>

## Como testar
<testes manuais, vindos do plan.md>
```

## Draft

Abriu como draft: diga na primeira linha o motivo e o que falta para sair dele.

```markdown
> Draft: <motivo>. Falta: <o que>.
```

## Stubs gerados pelo fluxo

Liste no fim do corpo, quando houver:

```bash
grep -rl "^origem_spec: <slug>" <raiz-de-specs>/
```

Diga que entram na fila do `/k-spec` quando este PR mergear. Não ofereça elaborá-los agora: a
spec do desvio deve ser escrita contra o código já atualizado.

## Rodadas de revisão

Atualização vinda do `k-revisao` não reescreve o corpo. Acrescente no fim:

```markdown
## Rodada <n>
<comentário atendido> — <commit>
```

Assim o revisor vê o que mudou desde a última leitura sem reler o diff inteiro.
