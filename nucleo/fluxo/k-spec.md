# k-spec — contrato de comportamento

Etapa 1 de 4: **k-spec** → `k-plan` → `k-task` → `k-execute`.

Produz o `spec.md`: o que muda e por quê. Nunca como corrigir nem onde a regra vai morar —
isso é do `k-plan`.

| Preciso de | Leia |
|---|---|
| frontmatter, corpo por tipo, estados | `.ia-kit/referencias/spec-formato.md` |
| como perguntar | `.ia-kit/referencias/entrevista.md` |
| achado fora do escopo | `.ia-kit/referencias/desvio.md` |

Sem sintoma, só um alvo para auditar: comece pelo `k-scan`.

---

## 1. Sincronizar e escolher o alvo

O discovery roda sobre o código atual. Vá para a branch principal e atualize.

Alteração local não commitada: **pare e pergunte**. Sem `stash` automático.

Nenhuma branch é criada aqui — quem cria é o `k-plan`.

Resolva o alvo:

| Argumento | Significa |
|---|---|
| casa com pasta em `specs.raiz` | é um stub; elabore-o |
| texto livre | trabalho novo |
| nenhum | mostre a fila de `pendente` e pergunte: elaborar um destes ou começar algo novo |

Ao elaborar um stub, leia `## Achado`, `## Evidencia` e os campos `origem_*` primeiro — é o
único contexto que sobrou de quando o problema foi visto. Preserve pasta, slug e
`criado_em`; você preenche o `tipo` e substitui o corpo inteiro.

Se a investigação mostrar que o achado **não procede**, não crie spec: marque
`fluxo: descartado` e escreva `## Por que foi descartado`. Descarte sem motivo registrado faz
o mesmo achado voltar à fila pela mão da próxima pessoa.

## 2. Definir título e tipo

Tipo governa o resto da skill e o prefixo da branch. Lista fechada em
`referencias/spec-formato.md`. Não óbvio: pergunte.

## 3. Investigar antes de perguntar

Dispare subagentes **somente de leitura**, um por eixo, todos na mesma mensagem. Leitura com
direções independentes é o caso em que o paralelismo se paga.

| Tipo | Eixos |
|---|---|
| `feature`, `refactor`, `chore`, `docs` | documentação existente por categoria (arquitetura, regras de negócio, contratos de API, integrações); comportamento atual do fluxo citado; specs anteriores relacionadas |
| `bug` | caminho de execução completo até o sintoma com `arquivo:linha` em cada ponto — **um único subagente**, trace sequencial, não paralelizável; documentação que define o esperado; specs anteriores relacionadas |

Cada subagente devolve **conclusão com `arquivo:linha`**, nunca despejo de código. Ausência
de documentação é resultado válido, não erro.

Modelo barato serve aqui: é busca e leitura, não decisão.

## 4. Entrevistar até convergir

Conforme `referencias/entrevista.md`. Mostre a síntese dos achados antes da primeira
pergunta.

## 5. Confirmar a divergência — só `bug`

Estabeleça com evidência no código:

- **esperado** — de onde vem a expectativa (documentação, regra, contrato, coerência com
  fluxo irmão)
- **atual** — o que o código faz de fato no caminho mapeado

Coincidiram: **não há bug**. Diga e pare, sem criar spec.

## 6. Reproduzir — só `bug`

Escada, do mais forte ao mais fraco. Pare no primeiro degrau que funcionar.

1. **Teste automatizado** — bug alcançável por lógica pura: escreva um teste descartável que
   falhe, rode filtrando só o caso novo, cole a **linha decisiva** na spec. Apague depois; o
   teste definitivo é do `k-task`.
2. **Passos manuais** — depende de interação, sessão ou estado externo: passos numerados que
   qualquer pessoa consiga seguir, com o resultado errado no último.
3. **Não reproduzido** — registre assim e descreva o caminho de execução com `arquivo:linha`
   e a condição de entrada necessária.

Nunca invente passo que você não executou nem verificou no código.

## 7. Escrever o spec.md

Formato em `referencias/spec-formato.md`. Grave direto, **sem pedir confirmação**, e não
despeje o conteúdo no chat — informe só o caminho.

## 8. Encerrar

```
Spec criada: <raiz>/<ts>-<slug>/spec.md
Tipo: <tipo>   Fluxo: ativo
Próximo passo: /k-plan
```

`execucao.encadeamento: automatico`: siga direto para o `k-plan`, sem perguntar. `manual`:
pare aqui.

## Nunca

- Propor solução técnica, comparar opções de correção, dizer onde a regra vai morar ou
  estimar esforço. Tudo isso é `k-plan`.
- Criar branch, commitar ou alterar código. O `spec.md` fica untracked até o `k-plan`.
- Criar spec de "cheiro" de código como `bug`. Código feio que funciona é `refactor`.
- Deixar teste descartável de reprodução entrar em commit.
- Transformar achado fora do escopo em seção extra desta spec ou em pergunta da entrevista —
  vai para o modo desvio.
