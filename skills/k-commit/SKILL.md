# Skill: k-commit

## Quando usar

Use esta skill sempre que for criar um commit no projeto.

## Objetivo

Padronizar mensagens de commit seguindo Conventional Commits, em portugues brasileiro.

## Regras obrigatorias

1. Mensagens sempre em portugues brasileiro
2. Seguir Conventional Commits: `tipo(escopo): descricao`
3. Nunca mencionar ajuda, co-participacao ou uso de LLMs, IAs ou assistentes
4. Nunca usar `Co-Authored-By` de LLMs ou IAs
5. Nunca usar `--no-verify` ou `--no-gpg-sign`
6. Nunca fazer `git add .` ou `git add -A` — adicionar apenas os arquivos relevantes pelo nome
7. Sempre verificar `git status` e `git diff` antes de commitar
8. Sempre verificar `git log --oneline -5` para manter consistencia com o historico
9. Nunca fazer commit diretamente nas branches bloqueadas `main` — verificar a branch atual antes de commitar e, se estiver em uma dessas, criar uma nova branch para receber as mudancas
10. Se a branch atual nao for bloqueada, avaliar se ela faz sentido para o contexto das modificacoes; se nao fizer, criar uma nova branch a partir de `main`
11. Sempre iniciar novas implementacoes a partir da branch `main`, exceto quando uma branch ja existente fizer sentido para as alteracoes em curso e esteja sincronizada com a main
12. Priorizar commits pequenos e focados para facilitar a revisao e aprovacao do PR
13. Nunca fazer merge automatizado — o merge para `main` e sempre feito manualmente via PR aprovado
14. Antes de commitar em uma branch nao bloqueada, verificar se ela esta atualizada com `origin/main`. Se estiver desatualizada, fazer merge/rebase primeiro. Se houver conflitos, **nunca** resolver automaticamente — listar cada conflito e perguntar explicitamente ao usuario como resolver arquivo por arquivo
15. Apos cada commit, sempre executar `git push origin <branch-atual>` para publicar no remoto. Nunca fazer push em `main` — apenas na branch de feature/fix/chore
16. Após o push, abra um PR para main

## Tipos permitidos

| Tipo       | Quando usar                                                  |
| ---------- | ------------------------------------------------------------ |
| `feat`     | Nova funcionalidade                                          |
| `fix`      | Correcao de bug                                              |
| `refactor` | Refatoracao sem alterar comportamento                        |
| `chore`    | Tarefas de manutencao, config, dependencias                  |
| `docs`     | Apenas documentacao                                          |
| `style`    | Formatacao, espacos, ponto e virgula (sem mudanca de logica) |
| `perf`     | Melhoria de performance                                      |
| `test`     | Adicao ou correcao de testes                                 |

## Formato da mensagem

```
tipo(escopo): descricao curta em portugues

Corpo opcional com mais detalhes sobre o que foi feito e por que.
```

### Regras do titulo (primeira linha)

- Maximo 72 caracteres
- Letra minuscula no inicio da descricao
- Sem ponto final
- Verbo no infinitivo (ex: "adicionar", "corrigir", "remover")
- Escopo e opcional — usar quando facilitar a compreensao (ex: `feat(api)`, `fix(banners)`)

### Regras do corpo (opcional)

- Separado do titulo por uma linha em branco
- Explicar o que e por que, nao o como
- Maximo 72 caracteres por linha

## Formato do comando

Sempre usar HEREDOC para garantir formatacao correta:

```bash
git commit -m "$(cat <<'EOF'
tipo(escopo): descricao curta

Corpo opcional.
EOF
)"
```

## Processo

1. Executar `git status` e `git branch --show-current` para ver arquivos alterados e branch atual
2. Executar `git diff` (staged e unstaged) para entender as mudancas
3. Executar `git log --oneline -5` para manter consistencia de estilo
4. Decidir a branch de destino seguindo o fluxo de decisao de branch
5. Se a branch de destino nao for bloqueada e for reutilizada: sincronizar com `origin/main` (ver "Sincronizar branch atual com `main`"). Se houver conflitos, perguntar ao usuario como resolver cada um antes de continuar
6. Adicionar apenas os arquivos relevantes com `git add <arquivo>`
7. Redigir mensagem seguindo o padrao
8. Criar o commit
9. Executar `git push origin <branch-atual>` para publicar a branch no remoto
10. Abra PR para main

## Fluxo de decisao de branch

Antes de commitar, seguir esta arvore de decisao:

1. **A branch atual e bloqueada (`main`)?**
   - Sim: criar uma nova branch a partir de `main` (seguindo obrigatoriamente o passo "Atualizar `main` antes de criar nova branch") com nome descritivo do contexto da mudanca (`tipo/descricao-curta`, ex.: `feat/visualizacao-condicional-relatorios`) e commitar nela.
   - Nao: seguir para o proximo passo.

2. **A branch atual faz sentido para o contexto das mudancas?**
   - Sim (mesma feature/fix em andamento): antes de commitar, executar a verificacao "Sincronizar branch atual com `main`" abaixo. So prosseguir com o commit apos a branch estar atualizada e sem conflitos.
   - Nao (contexto diferente, tema novo): voltar para `main`, atualizar (ver "Atualizar `main` antes de criar nova branch") e criar nova branch a partir dela.

### Sincronizar branch atual com `main`

**Regra obrigatoria** antes de qualquer commit em branch nao bloqueada:

```bash
git fetch origin main
git merge-base --is-ancestor origin/main HEAD || echo "DESATUALIZADA"
```

- Se a branch ja contem `origin/main` (esta atualizada): pode prosseguir para o commit.
- Se estiver desatualizada: fazer `git merge origin/main` (ou `git rebase origin/main`, se for o padrao da branch) para trazer as mudancas da `main` para a branch atual antes do commit.

**Tratamento de conflitos**:

- Se o merge/rebase gerar conflitos, **NAO resolver automaticamente**. Listar cada arquivo em conflito com `git status` e, para cada conflito encontrado, **perguntar explicitamente ao usuario como resolver** (qual lado manter, se deve combinar, etc.). Mostrar o trecho do conflito (`<<<<<<<` ... `=======` ... `>>>>>>>`) quando necessario.
- Nunca assumir a resolucao sem confirmacao. Nunca usar `-X ours`/`-X theirs` sem o usuario pedir.
- Depois de cada resolucao confirmada pelo usuario: `git add <arquivo>` e seguir para o proximo conflito.
- Apos resolver todos, finalizar com `git merge --continue` ou `git rebase --continue` (conforme o caso) e so entao prosseguir com o fluxo normal de commit.

### Atualizar `main` antes de criar nova branch

**Regra obrigatoria**: toda vez que for criar uma nova branch a partir de `main`, atualizar a `main` local com o remoto antes de ramificar:

```bash
git checkout main
git pull origin main
git checkout -b <tipo>/<descricao>
```

Nao pular essa etapa — ramificar a partir de uma `main` desatualizada gera conflitos desnecessarios e PRs divergentes. Se houver mudancas locais nao commitadas, usar `git stash` antes do `checkout main` e `git stash pop` apos criar a nova branch.

3. **Priorizar commits pequenos e focados**: preferir varios commits pequenos (um por unidade logica de mudanca) em vez de um commit grande misturando escopos. Isso facilita a revisao e a aprovacao do PR.

4. **Nao fazer merge**: apos o commit e o push, abrir PR. O merge para as branches protegidas do projeto (ex.: `main`) e feito manualmente pela equipe.

### Nomenclatura de branch

- `feat/<descricao>` — nova funcionalidade
- `fix/<descricao>` — correcao de bug
- `refactor/<descricao>` — refatoracao
- `chore/<descricao>` — manutencao/config
- `docs/<descricao>` — documentacao

## Exemplos

```
feat(api): adicionar endpoint de listagem de banners
```

```
fix(cupom): corrigir cupom aplicado duas vezes nas compras via site
```

```
refactor(auth): extrair validacao de token para service
```

```
docs(api): documentar endpoint de banners
```

```
chore: atualizar dependencias do composer
```
