# k-execute — executar uma tarefa

Etapa 4 de 4: `k-spec` → `k-plan` → `k-task` → **k-execute**.

**Regra central: uma tarefa por invocação.** Pega a próxima `pendente`, conclui, commita,
para. Você reinvoca até acabar. É isso que impede o contexto de estourar e o padrão do
projeto de se perder no meio do caminho.

| Preciso de | Leia |
|---|---|
| gate e commit | delegue ao `k-commit` (`.ia-kit/fluxo/k-commit.md`) |
| achado fora do escopo | `.ia-kit/referencias/desvio.md` |
| corpo do PR | `.ia-kit/referencias/pr-corpo.md` |
| push, PR, merge | `.ia-kit/referencias/shipping.md` |

---

## 1. Localizar a spec

Pelo argumento, ou pela branch: `<prefixo>/<slug>` → `<raiz>/*-<slug>`. Ambíguo: liste e
pergunte. Branch protegida: pare.

Leia o frontmatter do `spec.md` antes de escolher tarefa:

- `fluxo: pendente` — é stub. Pare e mande rodar `/k-spec <slug>`.
- `depende_de: <slug>` — cheque a spec apontada. `concluido` ou `descartado`: a dependência
  caiu; limpe o campo, devolva a tarefa parada para `pendente` com `motivo` vazio e siga.
  Ainda aberta: **pare** e mostre o que falta.

## 2. Escolher a tarefa

Ordem numérica, primeira com `status: pendente`.

- Alguma `em-andamento`: é ela — a execução anterior foi interrompida. Verifique o working
  tree antes de continuar.
- Alguma `bloqueada` antes da primeira `pendente`: **pare** e mostre o `motivo`. Não pule
  tarefa bloqueada.
- Nenhuma pendente: vá para o encerramento.

Marque `em-andamento` antes de começar.

## 3. Executar

- Leia `spec.md`, `plan.md` e o arquivo da tarefa **antes de tocar em arquivo**. O contexto
  vem dos arquivos, não da memória da sessão.
- Invoque a skill tática do campo `skill`, se houver.
- Altere **apenas** os arquivos de `arquivos`. Faltou arquivo: atualize o frontmatter da
  tarefa e explique. Não alargue escopo em silêncio.
- Respeite `## Nao faca` da tarefa e `## Nao entra neste trabalho` do plano.
- TDD dentro da tarefa: para cada item de `## Ciclos TDD`, escreva o teste, rode, confirme
  que falha **pelo motivo certo**, só então implemente até passar. O vermelho nunca vira
  commit.
- Autonomia pelo `modo_execucao` do plano: em `legado`, qualquer desvio do que o plano
  escreveu para e pergunta. Em `greenfield`, decisões de implementação equivalentes seguem
  sem perguntar.

Consumo acima de `execucao.teto_tokens_tarefa`: pare, registre o consumo e devolva. Tarefa
que estoura o teto quase sempre está mal quebrada.

## 4. Fechar a tarefa

Commite via `k-commit`, passando os arquivos da tarefa mais o próprio arquivo da tarefa com
`status: concluida`. O gate roda lá dentro — lint, testes dos arquivos tocados e segurança no
diff. Esta etapa **não** roda gate próprio.

Gate vermelho depois de `execucao.tentativas_gate` tentativas: marque `status: bloqueada`,
preencha `motivo` com uma linha, registre no corpo da tarefa a linha decisiva da saída, o
diagnóstico e **quais ciclos ficaram verdes**. Não commite.

O trabalho parcial fica **no working tree, não commitado**. É o preço de nunca ter suite
vermelha no histórico — diga isso ao usuário, para ele saber onde o código está.

Antes de dar a falha por perdida, verifique se ela vem de problema fora do escopo desta spec.
Se vier, siga `referencias/desvio.md`, caminho bloqueante.

```
Tarefa <n> concluída: <resumo em uma linha>
Commit: <tipo(escopo): descricao>
Restam <k> tarefas. Próximo passo: /k-execute
```

## 5. Encerramento — quando não resta tarefa

1. **Suite completa**, comando `comandos.suite` do contrato. Vermelha: pare e reporte, sem
   push.
2. **Marcar o fluxo**: `fluxo: concluido` no `spec.md` — significa tarefas fechadas e suite
   verde, não "mergeado". Este é o último ponto em que dá para escrever dentro da história do
   próprio fluxo: depois do merge a branch já foi deletada. Commite só esse arquivo,
   mensagem `docs(spec): concluir <titulo>`.
3. **Subir**, conforme `shipping.automatico` do contrato:
   - `false`: pergunte se é hora de subir. Não: pare, tudo commitado localmente.
   - `true`: siga sem perguntar, desde que as condições de `referencias/shipping.md` estejam
     satisfeitas.
4. **Alvo do PR**: pergunte, sem default fixo. Com `shipping.automatico: true`, use o alvo
   registrado no contrato ou pergunte uma vez e registre.
5. **Título e corpo**: monte conforme `referencias/pr-corpo.md`. Este conteúdo é
   responsabilidade desta etapa — o `k-commit` publica, não inventa.
6. **Delegue ao `k-commit`**: push único, PR (draft se bater `shipping.pr_draft_quando`),
   URL impressa. Merge só com aprovação explícita.
7. **Liste os stubs** que este fluxo gerou. Entram na fila do `/k-spec` quando o PR mergear.

Depois do PR, comentário de revisor entra pelo `/k-revisao`.

## Nunca

- Rodar gate próprio ou `git` de escrita direto — tudo pelo `k-commit`.
- Commitar com teste vermelho.
- Pular o gate "porque a mudança é pequena".
- Pular tarefa `bloqueada`.
- Executar tarefa que não existe como arquivo em `tasks/`.
- Corrigir achado fora do escopo, ou transformá-lo em tarefa deste fluxo por conta própria.
- Encadear várias tarefas na mesma invocação.
