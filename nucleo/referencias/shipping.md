# Shipping — push, PR e merge

Etapa separada do commit. Só acontece quando pedida, nunca de carona.

---

## Push

Único, depois do último commit da mudança. Nunca a cada commit.

- **Uso avulso:** não há lista de tarefas sinalizando o fim. Pergunte antes: "sem mais
  mudanças pendentes, posso seguir para push e PR?". Não decida sozinho.
- **Chamado por um fluxo, `shipping.automatico: false`:** a pergunta já foi feita por quem
  chamou. Vá direto ao push.
- **Chamado por um fluxo, `shipping.automatico: true`:** suba sem perguntar, desde que as
  condições abaixo estejam satisfeitas.

Push em branch protegida não acontece. Nem com `--force`, nem em nenhuma variação.

### Shipping automático

`shipping.automatico: true` é autorização durável, dada uma vez no contrato. Ela cobre push
e abertura de PR — nunca merge.

Condições, todas obrigatórias:

1. Todas as tarefas do fluxo fechadas.
2. Suite completa verde.
3. Um PR por fluxo. Nunca um PR por tarefa — é essa regra que impede a fila de review de
   estourar.

Qualquer condição falhando: pare e pergunte, como se `automatico` fosse `false`.

**Por que um PR por fluxo.** Código gerado por IA já espera cerca de 4,6x mais pelo primeiro
review, e a maior parte dos PRs abertos por agente demora muito ou nunca é revisada. Abrir
PR automático multiplica o volume; um por fluxo mantém o volume igual ao do trabalho real.

**Por que merge nunca.** Volume de PR merged sobe sem que a entrega da organização se mova.
A aprovação humana é o que liga uma coisa à outra.

## Revisão antes do push

Diff acumulado da branch (`<principal>...HEAD`) com conteúdo de código: dispare subagentes
de revisão em paralelo, um por eixo — convenções do projeto, aderência ao pedido,
simplificação e reuso.

Branch só de documentação: não dispare. Cada commit já passou pelo gate.

Informativa, não bloqueante. Mostre os achados junto do resumo e siga.

## Pull request

Abra depois do push e imprima a URL.

- Alvo: pergunte. Sem padrão fixo — assumir `main` cria PR errado em projeto com branch de
  release ou de integração.
- Título e corpo: quando vieram de um fluxo, use os que foram entregues. Não reconstrua
  contexto de negócio a partir do diff.
- Uso avulso: monte a partir dos commits da branch.

Corpo de PR carrega o que o diff não conta: o problema, a decisão tomada e as opções
descartadas. Em correção de bug, a causa raiz com `arquivo:linha`.

Motivo: a causa apontada para a fila lenta de review é o revisor não conseguir reconstruir
a intenção a partir do diff. Corpo bem escrito é o que devolve velocidade à fila.

### Draft

Abra como draft quando bater qualquer item de `shipping.pr_draft_quando`:

| Gatilho | Significa |
|---|---|
| `achado_aberto` | a revisão automatizada levantou algo que não foi resolvido |
| `modo_legado` | `execucao.modo_padrao: legado` — base de alto acoplamento |
| `suite_instavel` | suite passou, mas com teste intermitente conhecido |

Draft não entra na fila do revisor. Ele decide quando olhar, em vez de ser convocado para
um trabalho que ainda tem ponta solta.

Diga na abertura o motivo do draft e o que falta para sair dele.

### Atualizar um PR aberto

Sempre com **commits novos** empilhados na branch. Nunca `--force`, nunca reescrita de
histórico enquanto houver review em andamento: force-push deixa os comentários órfãos e o
revisor perde o próprio rastro do que já analisou.

O loop de correção a partir dos comentários é o `k-revisao`.

## Merge

Só pergunte sobre merge se o alvo for branch protegida. Outros alvos: pare no PR aberto.

Merge exige **aprovação explícita para aquele PR**. Aprovação anterior, em outro PR, não
vale como permissão permanente.

Aprovado:

```bash
gh pr merge <numero-ou-url> --merge --delete-branch
git checkout <principal>
git pull origin <principal>
```

Não há espera proativa de CI. Se a branch protegida exige checks e eles não passaram, o
comando falha: reporte o motivo a partir da saída do `gh` e pare. Sem repetir
automaticamente, sem contornar proteção. Esperar ou corrigir é decisão do usuário.

Recusado: pare. PR aberto, branch intacta, decisão segue manual.

## Nunca

- Push ou merge em branch protegida sem aprovação explícita.
- `--force` em branch compartilhada.
- Merge silencioso, ou apoiado em aprovação de outro PR.
- Contornar check obrigatório.
