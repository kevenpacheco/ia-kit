# k-execute — como usar

Etapa 4 de 4: `k-spec` → `k-plan` → `k-task` → **k-execute**.

## Invocacao

```
/k-execute
/k-execute corrigir-crop-banner
```

Sem argumento, resolve pela branch atual.

## Regra central

**Uma tarefa por invocacao.** Roda a proxima `pendente`, commita, para. Voce reinvoca ate acabar.

## O que ela faz, por invocacao

1. Localiza a spec pela branch.
2. Pega a primeira tarefa `pendente` (ou retoma a `em-andamento`), marca `em-andamento`.
3. Le `spec.md`, `plan.md` e o arquivo da tarefa. Invoca a skill tatica do campo `skill`.
4. Altera **apenas** os arquivos listados em `arquivos`.
5. Gate: lint + a suite de teste afetada, com os comandos do projeto. 2 tentativas.
6. Commita via skill `k-commit` (sem push).
7. Marca `status: concluida` e preenche `commit: <SHA>`.

## Quando falha

Terceira falha no gate: marca `status: bloqueada`, registra a linha decisiva da saida e o diagnostico no corpo da tarefa, e devolve pra voce. Nao commita, nao pula pra proxima.

## Achado fora do escopo

Bug descoberto no caminho vai para `## Achados fora do escopo` no `spec.md` atual. **Nao e corrigido.** No encerramento, a skill lista os achados e pergunta se voce quer rodar `/k-spec` pra cada um.

## Encerramento (ultima tarefa)

1. Suite completa, com o comando do projeto. Vermelha = para, sem push.
2. Push unico da branch.
3. Pergunta o alvo do PR (sem default fixo) e espera.
4. Abre o PR com corpo montado do `spec.md` + `plan.md`. Em branch `fix/`, o corpo traz causa raiz, correcao escolhida e opcoes descartadas.

## Nunca

- merge
- push nas branches protegidas do projeto (ex.: `main`)
- `git add .`, `git add -A`, `--no-verify`
- pular o gate de teste
- executar tarefa que nao existe como arquivo em `tasks/`
