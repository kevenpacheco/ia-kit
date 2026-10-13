# Prova por injeção de falha

"Confirme que o teste falha pelo motivo certo" depende do relato do agente e não sobrevive à
sessão. Isto prova, e o registro fica commitado no arquivo da tarefa.

A pergunta que a injeção responde: **este teste ficaria vermelho sem a correção?** Teste que
passa dos dois jeitos não cobre regressão nenhuma, mesmo estando verde.

---

## Quando

| `verificacao.injecao_falha` | Efeito |
|---|---|
| `obrigatoria_bug` (padrão) | obrigatória em `tipo: bug`, **tarefa 1** — a que contém o teste de regressão e a correção. Nos demais tipos, não roda |
| `sempre` | toda tarefa com `## Ciclos TDD` |
| `nunca` | não roda; a tarefa registra `injecao: nao_executada`, `motivo: desligada no contrato` |

Vira `nao_aplicavel`, sem tentar: plano com `## Sem teste automatizado`; tarefa sem
`## Ciclos TDD` (`docs`, `chore`, `refactor` puro, migração).

**Por que obrigatória só em bug.** Tarefa de `feature` que introduz símbolo público novo faz
o teste copiado falhar no *import*, não na asserção — vermelho pelo motivo errado, que
contaria como prova falsa. O teste de regressão de bug exercita ponto de entrada que **já
existe** na âncora. É por isso que `sempre` costuma devolver `nao_executada` em série.

## A árvore real nunca é tocada

Invariante, sem exceção: nada é revertido, escondido ou restaurado na árvore de trabalho.
Proibido aqui: `git checkout`, `git stash`, `git reset`, `git restore`.

A reversão acontece só dentro de uma worktree descartável, fora do repositório.

## Procedimento

```
0. Ancora. No inicio da tarefa, com a arvore limpa:
     git rev-parse HEAD                      -> <ancora>
   Arvore suja no inicio: nao injete. Registre nao_executada com o motivo.

1. Limpar resto de execucao anterior:
     git worktree list                       # entradas 'ia-kit-injecao-' sao lixo
     git worktree remove --force <caminho>   # uma por uma
     git worktree prune

2. Criar a arvore isolada, destacada, FORA do repositorio:
     TMP="$(mktemp -d)/ia-kit-injecao-<slug>-<NN>"
     git worktree add --detach "$TMP" <ancora>

3. Corrida de controle - a arvore e viavel?
     verificacao.preparar_arvore, se preenchido, roda dentro de $TMP
     <comando de teste> em $TMP, sem nenhum arquivo copiado
   Vermelho: a arvore nao e viavel. Registre nao_executada com a linha decisiva
   e SIGA. Nao invente prova.
   Verde: siga.

4. Injetar: copie os arquivos de TESTE da tarefa, da arvore real para $TMP.
   So os testes: a implementacao continua a de <ancora>. E isso que caracteriza
   a injecao - teste do depois, implementacao do antes.

5. Rodar o teste novo em $TMP, filtrado ao caso da tarefa.
   Esperado: VERMELHO, com a mensagem sendo a ASSERCAO falhando.

6. Limpar - SEMPRE:
     git worktree remove --force "$TMP"
     git worktree prune
```

**A corrida de controle do passo 3 não é opcional.** Worktree limpa sem dependência
instalada faz todo teste ficar vermelho, e aí toda injeção "passa" — prova falsa no sentido
otimista, que é o pior resultado possível.

**O passo 6 não é condicional.** Roda com sucesso, com falha, com resultado inconclusivo e
depois de interrupção. Nunca apague a pasta só com `rm`: sem `git worktree remove` sobra
registro em `.git/worktrees` e o próximo `add` falha com "already exists" — é para isso que
o passo 1 existe, e é por isso que ele vem antes de tudo.

## `git worktree add` é git de escrita?

Sim, escreve em disco. Não, não muda a história nem o estado compartilhado.

A regra do D14 protege uma coisa específica: nada entra na história do repositório nem sai
para outra pessoa sem passar pelo gate. Branch, commit, push, PR e merge fazem isso.
`worktree add --detach` num caminho temporário não cria commit, não move ref, não toca o
índice nem a árvore atual, e some inteiro no passo 6.

**Por que não rotear pelo `k-commit`:** não há diff, não há mensagem, não há nada para o gate
crivar. Rotear daria ao `k-commit` uma segunda responsabilidade sem relação com a primeira.

A regra não ganha exceção — ela fica precisa: *git que muda a história ou o estado
compartilhado passa pelo `k-commit`.* A lista do que o `k-execute` roda sozinho é **fechada**:

| Comando | Por quê |
|---|---|
| `rev-parse`, `merge-base`, `worktree list`, `status`, `diff`, `log`, `show` | leitura |
| `worktree add --detach <tmp> <sha>` | cria árvore descartável fora do repositório |
| `worktree remove --force <tmp>`, `worktree prune` | desfaz a de cima |

Qualquer outro git de escrita — `checkout`, `stash`, `reset`, `commit`, `add`, `push`,
`branch` — continua exclusivo do `k-commit`.

## Registro

Frontmatter da tarefa: `injecao: aprovada | falhou | nao_executada | nao_aplicavel`.

Corpo da tarefa:

```markdown
## Prova de injecao
Ancora: <sha curto>          Arvore: descartada em <AAAA-MM-DD HH:MM:SS>
Testes injetados: `caminho/do/teste.ext`
Controle (sem o teste novo): verde    — `<linha decisiva>`
Injecao (com o teste novo):  vermelho — `<linha decisiva da assercao>`
```

Commitado junto com a tarefa, via `k-commit`. *Prova que só existiu no chat não aconteceu.*

O que o verificador cruza depois: o arquivo de teste nomeado existe em `base..HEAD` e está
em `arquivos` da tarefa; a âncora é ancestral de `HEAD`; e, no perfil `rigoroso`, a
reexecução a partir da mesma âncora.

## O que fazer com cada resultado

| Resultado | `k-execute` |
|---|---|
| `aprovada` | siga e feche a tarefa |
| `falhou` | **não feche a tarefa.** O teste passaria sem a correção. Reescreva-o até discriminar, dentro da mesma tarefa, e injete de novo. Esgotou `execucao.tentativas_gate`: `bloqueada`, `motivo: teste nao discrimina` |
| `nao_executada` | siga, registrando o motivo. Em `tipo: bug`, vira **ressalva** na verificação — não bloqueio |
| `nao_aplicavel` | tarefa sem ciclo TDD |

Erro de import ou de coleta no passo 5 é **inconclusivo**, não aprovação. Trate como
`falhou` e diga por quê.

## Nunca

- Reverter, esconder ou restaurar qualquer coisa na árvore de trabalho real.
- Pular a corrida de controle.
- Deixar worktree para trás, ou apagá-la sem `git worktree remove`.
- Registrar prova que você não rodou.
- Contar vermelho de import como prova.
