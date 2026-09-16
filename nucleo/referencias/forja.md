# Forja — PR e comentários por plataforma

O kit é agnóstico de ferramenta de IA (D14) e precisa ser agnóstico de forja pelo mesmo
motivo: escrever o fluxo em cima de um comando específico amarra o kit a uma plataforma.

`git.forja` no contrato decide qual coluna vale. Detectado pelo `k-init` a partir da URL do
remoto e do CLI instalado.

---

## Operações

| Operação | `github` | `gitlab` | `bitbucket` / `azure` | `nenhuma` |
|---|---|---|---|---|
| abrir PR | `gh pr create` | `glab mr create` | CLI própria, se houver | monta o corpo e entrega para abertura manual |
| abrir como draft | `gh pr create --draft` | `glab mr create --draft` | idem | diz no corpo que é rascunho |
| ler comentários abertos | `gh pr view --json reviews,comments` + `gh api` para os threads | `glab mr note list` | idem | pede que você cole os comentários |
| responder comentário | `gh pr comment` / `gh api` no thread | `glab mr note create` | idem | entrega o texto para você colar |
| resolver thread | `gh api` no thread | `glab api` no thread | idem | você resolve na interface |
| mesclar | `gh pr merge` | `glab mr merge` | idem | você mescla na interface |

Nenhuma dessas operações é inventada a partir do nome da plataforma: o `k-init` confirma que
o CLI existe e responde antes de gravar `git.forja`. CLI ausente com remoto conhecido grava a
forja e marca o modo manual.

## Modo manual

`git.forja: nenhuma`, ou CLI ausente. O fluxo não trava: ele degrada.

- `k-execute` monta título e corpo do PR e os apresenta prontos para copiar, junto do comando
  de push. Não há URL para imprimir.
- `k-revisao` pede que você cole os comentários do PR. A classificação, as tarefas e os stubs
  funcionam igual — o que muda é de onde vem o texto.
- Nada é publicado automaticamente, o que aliás já era a regra para resposta em thread.

Degradação explícita vale mais que suporte fingido: o pior resultado seria o kit acreditar
que abriu um PR que não existe.

## O que não muda entre forjas

Regras de decisão são do núcleo, não da plataforma:

- um PR por fluxo
- draft quando bate `shipping.pr_draft_quando`
- correção por commit novo, nunca force-push com review em andamento
- merge só com aprovação explícita para aquele PR
- resposta em thread só depois da aprovação do usuário
- teto de três rodadas por PR

Adaptador de forja cuida do **como**. O **o quê** continua no fluxo.
