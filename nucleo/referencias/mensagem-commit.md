# Mensagem de commit

Padrão: Conventional Commits, em português brasileiro.

```
tipo(escopo): descricao curta

Corpo opcional: o que mudou e por que. Nunca o como — isso o diff já conta.
```

---

## Tipos

| Tipo | Quando |
|---|---|
| `feat` | funcionalidade nova |
| `fix` | correção de bug |
| `refactor` | refatoração sem mudar comportamento |
| `chore` | manutenção, configuração, dependência |
| `docs` | apenas documentação |
| `style` | formatação, sem mudança de lógica |
| `perf` | desempenho |
| `test` | teste sem mudança de comportamento |

## Título

- Máximo 72 caracteres.
- Minúscula no início da descrição, sem ponto final.
- Verbo no infinitivo: adicionar, corrigir, remover, extrair.
- Escopo é opcional; use quando esclarece (`fix(cupom)`, `feat(api)`).

## Corpo

- Linha em branco separando do título, máximo 72 caracteres por linha.
- Só existe quando acrescenta. Corpo que parafraseia o título é ruído.
- Decisão não óbvia tomada no caminho entra aqui — é o que o revisor não extrai do diff.

## Atribuição de IA

**Proibido** mencionar IA, LLM, assistente ou co-participação de ferramenta na mensagem.
Sem `Co-Authored-By` de modelo, sem rodapé de ferramenta, sem "gerado com".

Motivo: o histórico registra o que mudou e por quê. Quem operou o teclado não é informação
de engenharia, e poluir toda mensagem com isso degrada o valor do `git log` como documento.

Essa regra vale mesmo quando a ferramenta em uso pede o contrário por padrão. O contrato do
projeto tem precedência sobre o padrão da ferramenta.

**Atenção:** algumas ferramentas anexam o rodapé por conta própria, fora do alcance do kit. O
`k-init` confere isso na instalação e avisa onde desligar. Se o rodapé aparecer mesmo assim,
remova antes de commitar — e, em commit já feito e não empurrado, reescreva a mensagem.

`commit.atribuicao_ia: true` libera o rodapé. Só então ele é permitido.

## Comando

HEREDOC sempre, para não quebrar a formatação de múltiplas linhas:

```bash
git commit -F - <<'MSG'
tipo(escopo): descricao curta

Corpo opcional.
MSG
```

Nunca `--no-verify`. Nunca `--no-gpg-sign`.

## Nome de branch

`<prefixo>/<slug>`, prefixo vindo de `git.prefixos` no contrato:

| Tipo | Prefixo padrão |
|---|---|
| feature | `feat` |
| bug | `fix` |
| refactor | `refactor` |
| chore | `chore` |
| docs | `docs` |

Slug em minúsculas, separado por hífen, descrevendo o contexto — não o arquivo tocado.

## Exemplos

```
feat(api): adicionar endpoint de listagem de banners
```

```
fix(cupom): corrigir cupom aplicado duas vezes nas compras via site

O desconto era somado no carrinho e de novo no fechamento. A regra passa a
viver so no fechamento, que e onde o valor final e calculado.
```

```
refactor(auth): extrair validacao de token para service
```

```
chore: atualizar dependencias do composer
```
