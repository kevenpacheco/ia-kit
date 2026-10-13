# Encerramento do fluxo

O que o `k-execute` faz quando não resta tarefa pendente. Saiu do arquivo de fluxo porque é
sequência longa, consultada uma vez por fluxo — e porque o fluxo tem teto de 150 linhas.

A ordem importa: **a verificação vem antes de marcar o fluxo como concluído**, e marcar vem
antes de subir. Inverter faz o kit afirmar conclusão que ninguém conferiu.

---

## 1. Suite completa

`comandos.suite` do contrato. Vermelha: pare e reporte, sem push e sem verificação. Suite
vermelha não é candidata a verificação; é trabalho inacabado.

## 2. Verificação independente

**Regra central: você não emite o veredito.** Esta etapa monta contexto, despacha um
verificador e registra o que voltou. Julgar aqui dentro "porque já tenho o contexto" é
auto-avaliação com outro nome — e skill roda na mesma conversa de quem escreveu o código, por
isso só o despacho para subagente mantém autor diferente de verificador.

Automático, sem perguntar: é porta de conclusão, não opção.

### Montar o contexto

Resolva a base para **SHA fixo**, nunca `<principal>..HEAD`:

```
git merge-base <git.branch_principal> HEAD
```

A principal pode andar no meio da verificação, e aí o range muda de significado entre o que o
verificador leu e o que você registrou.

O prompt do verificador recebe, nesta ordem:

1. **Papel.** "Você verifica, não corrige. Você não escreveu este código e não tem a sessão
   de quem escreveu. Veredito sem evidência `arquivo:linha` não é veredito."
2. **Perfil** (`verificacao.perfil`) e o que ele autoriza executar.
3. **Caminhos para ler**, nunca conteúdo colado: `spec.md`, `plan.md`, `tasks/*.md` e
   `.ia-kit/referencias/verificacao-formato.md`.
4. **Range** `<sha-base>..HEAD` e os comandos de leitura liberados: `git diff`, `git log`,
   `git show`, `git merge-base --is-ancestor`.
5. **Comandos do contrato** que o perfil autoriza: `comandos.suite`, `comandos.lint`,
   `verificacao.preparar_arvore`.
6. **Saída**: caminho do `verificacao.md` e o número da rodada.

**Nunca entra:** o histórico desta sessão; seu resumo do que foi feito; diff colado; trecho
de código; a lista de dificuldades da execução; sua opinião sobre o resultado.

*Verificador que recebe a narrativa do autor verifica a narrativa, não o código.*

### Despachar

**Um subagente, contexto limpo, `modelos.forte`.** Não paralelize por critério: critérios da
mesma spec sobre o mesmo diff não são direções independentes, e relatório coerente precisa de
um autor só. É a exceção consciente ao D7 — verificação é julgamento, não busca.

Não continue o verificador de uma rodada anterior: ele ancora no próprio veredito.

### Conferir a forma do que voltou

```
sh .ia-kit/scripts/verificar-verificacao.sh <pasta-da-spec> --perfil-esperado <perfil>
```

Exit 1 ou 3: o relatório não dá para conferir. Devolva ao verificador **uma vez**, dizendo o
que falta. Segunda falha: veredito `reprovado` por relatório incompleto — não conserte você.

### Veredito

| Veredito | Efeito |
|---|---|
| `aprovado` | siga para o passo 3 |
| `aprovado-com-ressalva` | siga; o PR sai draft se `verificacao_ressalva` estiver em `shipping.pr_draft_quando` |
| `reprovado` | **pare aqui**: sem `fluxo: concluido`, sem push, sem PR |

`sem-evidencia` num critério conta como reprovado. Ausência de evidência não é evidência de
conformidade — é essa linha que impede o relatório de virar teatro.

Commite o relatório via `k-commit`, mensagem `docs(spec): verificacao de <titulo> (rodada
<n>)`, **inclusive quando reprova**. Reprovação não commitada é reprovação que não aconteceu.

Contrato sem `verificacao` (kit anterior à 2.1.0): a verificação roda e avisa, mas não
bloqueia, até o `k-init` gravar os campos.

### Quando reprova

Cada critério reprovado carrega uma **causa**, e a causa decide o destino:

| Causa | Destino |
|---|---|
| `codigo` | o critério é verificável e o código não o atende: vira **uma tarefa** em `tasks/`, numerada na sequência, `status: pendente`, `criterios: [CA-n]`, com veredito e evidência no corpo |
| `criterio` | o critério é ambíguo, não falsificável, ou contradiz o plano: **nunca vira tarefa.** Pare e pergunte — o conserto é na spec |

A distinção não é enfeite. Sem ela, spec vaga vira fila de tarefa impossível, e o time
desliga a verificação na segunda semana.

**Teto:** `verificacao.rodadas_max`, padrão 2. Atingido, não abra rodada nova: marque as
tarefas dos critérios ainda reprovados como `status: bloqueada`, `motivo: reprovado na
verificacao rodada <n>`, deixe `fluxo: ativo` e pare.

*O agente não se cansa de aceitar pedido. Verificador que aceita conserto até passar é
verificador sendo otimizado contra.*

Rodada seguinte roda com **verificador novo**, depois de o `k-execute` fechar as tarefas.

## 3. Marcar o fluxo

`fluxo: concluido` no `spec.md` — significa tarefas fechadas, suite verde **e verificação
aprovada**, não "mergeado". É o último ponto em que dá para escrever dentro da história do
próprio fluxo: depois do merge a branch já foi deletada.

Commite só esse arquivo, mensagem `docs(spec): concluir <titulo>`.

## 4. Subir

Conforme `shipping.automatico`:

- `false`: pergunte se é hora de subir. Não: pare, tudo commitado localmente.
- `true`: siga sem perguntar, desde que as condições de `shipping.md` estejam satisfeitas.

**Alvo do PR**: `shipping.alvo_pr`, se preenchido. Vazio: pergunte, sem default fixo.

**Título e corpo**: monte conforme `pr-corpo.md`. Este conteúdo é responsabilidade do
`k-execute` — o `k-commit` publica, não inventa.

**Delegue ao `k-commit`**: push único, PR (draft se bater `shipping.pr_draft_quando`), URL
impressa. Merge só com aprovação explícita. Forja em modo manual (`forja.md`): apresente
corpo e comando de push prontos para copiar, e **não diga que abriu**.

## 5. Listar os stubs

Os que este fluxo gerou entram na fila do `/k-spec` quando o PR mergear.

Depois do PR, comentário de revisor entra pelo `/k-revisao`.
