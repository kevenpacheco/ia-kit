# k-commit — gate e commit

Porta única do projeto para operações de git que mudam estado: branch, commit, push, PR,
merge. Vale com fluxo (`k-execute` delega para cá) ou sem fluxo (mudança manual, ajuste
pequeno, trabalho da IA fora do ciclo).

Leituras que não mudam estado (`git status`, `git diff`, `git log`) não passam por aqui.

Referências, carregadas só quando a etapa chegar:

| Preciso de | Leia |
|---|---|
| rodar o gate | `.ia-kit/referencias/gate.md` |
| escrever a mensagem | `.ia-kit/referencias/mensagem-commit.md` |
| push, PR ou merge | `.ia-kit/referencias/shipping.md` |

---

## 1. Ler o contrato

`.ia-kit/contrato.yml` define comandos do gate, branches protegidas, prefixos, limiar de
promoção e política de mensagem. Campo vazio: pare e pergunte. Não adivinhe comando.

## 2. Ver o que mudou

`git status`, `git diff` (staged e unstaged), `git branch --show-current`,
`git log --oneline -5` para o estilo do histórico.

Classifique o diff — isso decide o escopo do gate e da revisão:

| Conteúdo do diff | Classe |
|---|---|
| só documentação, spec, plano, tarefa | `docs` |
| código de aplicação ou de teste | `codigo` |
| configuração, dependência, lockfile | `config` |

## 3. Resolver a branch

1. Branch atual está em `git.branches_protegidas`? Crie uma nova a partir da principal
   atualizada. **Commit direto em branch protegida não acontece**, em nenhuma hipótese.
2. Chamador fixou a branch atual? Use essa e pule o passo 3.
3. Branch atual combina com o contexto do diff? Combina: siga. Não combina: volte para a
   principal, atualize e ramifique.

Branch não protegida e reutilizada: sincronize com a principal antes de commitar. Conflito:
**nunca resolva sozinho** — liste arquivo por arquivo e pergunte.

Nome da branch: `<prefixo>/<slug>`, prefixo vindo de `git.prefixos`.

## 4. Selecionar arquivos

`git add <arquivo>`, um a um, só o que pertence a este commit. `git add .` e `git add -A`
são proibidos — arrastam arquivo de outro contexto para dentro do commit.

## 5. Gate

Rode conforme `referencias/gate.md`. Escopo pelo diff:

| Classe do diff | Gate |
|---|---|
| `docs` | lint de formato, se o projeto tiver |
| `codigo` | lint no diff + testes dos arquivos tocados + segurança no diff |
| `config` | lint + segurança no diff (dependência nova entra por aqui) |

Segurança roda sobre o **diff**, não sobre o repositório inteiro. É o que torna viável
rodar em todo commit.

Gate vermelho: pare, mostre a linha decisiva da saída, não commite. Não "conserte" o
projeto por conta própria — corrigir é decisão de quem está no comando.

`comandos.seguranca` vazio no contrato: avise a pendência nesta invocação e siga. Avisar
sempre mantém a dívida visível; bloquear empurraria o time a arrancar o gate.

## 6. Revisão automatizada

Governada por `commit.revisao_subagente`:

| Valor | Dispara |
|---|---|
| `sempre` | todo diff de classe `codigo` |
| `por_limiar` (padrão) | diff `codigo` acima de `commit.revisao_limiar` |
| `nunca` | nada |

Disparando: subagentes em paralelo, um por eixo — aderência às convenções do projeto,
aderência ao pedido, simplificação e reuso. Leitura pura com direções independentes é o caso
em que o paralelismo se paga.

Diff `docs` ou `config`, ou abaixo do limiar: não dispare. Num diff de três linhas a revisão
repete o que lint e testes já disseram, e é o segundo maior consumo do kit.

A revisão é **informativa, não bloqueante**. Mostre os achados junto com a mensagem
proposta; quem decide corrigir é o usuário.

## 7. Limiar de promoção

Diff acima de `execucao.limiar_promocao` (arquivos ou linhas): **sugira** abrir um fluxo.

```
Diff com 9 arquivos e 340 linhas, acima do limiar (5 arquivos, 150 linhas).
Considere /k-spec antes de seguir. Commitar assim mesmo? (s/n)
```

Sugestão, não bloqueio. Processo que atrapalha é processo que o time contorna.

## 8. Mensagem e commit

Redija conforme `referencias/mensagem-commit.md`. Mensagem sugerida pelo chamador: ajuste
só o necessário para bater com o padrão, sem reescrever o contexto de negócio.

Use HEREDOC. Nunca `--no-verify`, nunca `--no-gpg-sign`.

Pare aqui. Push, PR e merge são etapa separada, e só acontecem quando pedidos.

## 9. Shipping (só quando pedido)

`referencias/shipping.md`. Push é único, depois do último commit da mudança. Merge em
branch protegida exige aprovação explícita para aquele PR — aprovação anterior não vale
como permissão permanente.

## Nunca

- Commitar em branch protegida.
- `git add .`, `git add -A`, `--no-verify`, `--no-gpg-sign`.
- Commitar com o gate vermelho.
- Resolver conflito de merge sem perguntar.
- Fazer merge sem aprovação explícita para aquele PR.
- Inventar contexto de negócio que não recebeu.
