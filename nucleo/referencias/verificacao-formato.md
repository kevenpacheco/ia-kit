# Formato do `verificacao.md`

O relatório do verificador independente: onde mora, o que precisa conter, e o que a
verificação nunca pega.

---

## Onde mora

`<raiz>/<ts>-<slug>/verificacao.md`, um por fluxo.

Rodadas **acumulam no mesmo arquivo**, uma seção `## Rodada n` por passada. O histórico de
reprovação precisa ficar visível: fluxo que reprovou duas vezes e passou na terceira conta
uma história diferente de fluxo que passou de primeira.

## Frontmatter

```yaml
---
spec: spec.md
rodada: 1
veredito: aprovado           # aprovado | aprovado-com-ressalva | reprovado
perfil: padrao               # rapido | padrao | rigoroso
base: <sha da merge-base>
head: <sha do topo da branch>
verificado_em: <AAAA-MM-DD HH:MM:SS>
---
```

SHA e timestamp são proibidos no `contrato.yml` e **legítimos aqui**: o contrato é a camada 2
do D4, prefixo de cache que não pode variar; este relatório é camada 3, muda a cada fluxo por
definição.

`base` e `head` são dois campos, nunca um `range: a..b`. Separar `..` de um SHA em sh é
ambíguo.

## Corpo

Uma linha por critério, forma fixa para ser conferível por script:

```
- CA-<n> <veredito> <arquivo:linha> <uma linha de texto>
```

```markdown
## Rodada 1

- CA-1 aprovado src/crop/area.ts:42 proporcao preservada no caso 16:9
- CA-2 reprovado test/crop.spec.ts:17 caso 4:3 ainda arredonda para baixo
- CA-3 nao-aplicavel - comportamento removido do escopo pelo plano

## Fora dos criterios
Achado real que nenhum `CA-n` cobre. Vira stub, nunca correção de carona.

## Prova de injecao
O que foi conferido das provas registradas nas tarefas.

## O que nao foi verificado
Arquivo, caminho ou comportamento que ficou de fora, e por quê.
```

`## O que nao foi verificado` não é opcional. Cobertura parcial silenciosa vira falso
"está tudo limpo".

## Vereditos por critério

| Veredito | Quando | Exige evidência |
|---|---|---|
| `aprovado` | o diff atende o critério | sim |
| `reprovado` | o diff contradiz o critério, ou não o atende | sim |
| `sem-evidencia` | não foi possível achar o que prova | não |
| `nao-aplicavel` | o critério saiu do escopo por decisão registrada | não |

**`sem-evidencia` conta como reprovado no veredito global.** Ausência de evidência não é
evidência de conformidade. É esta linha que impede o arquivo inteiro de virar teatro.

## Regra de evidência

Evidência é uma de duas coisas:

- `arquivo:linha` **dentro do range `base..head`**
- linha decisiva da saída de um comando que **o próprio verificador** rodou

Não é evidência: "passei os olhos e está ok"; citação da spec ou do plano — isso é o
requisito repetido, não prova de que foi cumprido; nem despejo de código (D5).

## Perfis

| Perfil | O verificador faz | Custo | O que este perfil **NÃO** pega |
|---|---|---|---|
| `rapido` | Lê o diff, spec, plano e tarefas. Casa cada `CA-n` com o código e o teste que o atendem, por `arquivo:linha`. **Não executa nada.** | 1 subagente | Teste que não roda — arquivo órfão, suite que não coleta. Teste verde por acidente. Teste que não discrimina. Regressão fora do diff. Qualquer coisa só observável em runtime |
| `padrao` | Tudo do `rapido`, mais executar `comandos.suite` e conferir que o teste citado por cada `CA-n` **aparece na saída como executado e verde** | 1 subagente + 1 suite | Teste que passa mesmo sem a implementação — a prova de injeção continua sendo o relato do autor. Regressão em código sem cobertura. Vulnerabilidade, que é a camada 3 do gate. Qualidade de design |
| `rigoroso` | Tudo do `padrao`, mais **reexecutar** a injeção de falha de cada tarefa com `injecao: aprovada`, a partir do SHA âncora registrado | mais 1 worktree e 1 suite por tarefa provada | Comportamento que nenhum critério expressa. **Erro na própria spec** — critério errado verificado com sucesso sai `aprovado`. Requisito não-funcional. Acoplamento e dívida estrutural |

Em fluxo `tipo: bug` o perfil sobe para `rigoroso` automaticamente, sem consultar o contrato.
É uma tarefa por fluxo, e é exatamente onde a prova importa.

## O que a verificação nunca pega

Vale para os três perfis:

- **Spec errada verificada com sucesso.** O verificador confere o código contra o critério,
  nunca o critério contra a realidade.
- Comportamento que nenhum `CA-n` expressa.
- Requisito não-funcional: desempenho, acessibilidade, custo, acoplamento.
- Segurança — é a camada 3 do gate, no `k-commit`.
- Lógica de negócio e arquitetura — é o review humano, D10 passo 5, e o kit nunca o
  substitui.
- **Verificador e autor rodam no mesmo modelo e carregam os mesmos pontos cegos.** Contexto
  independente reduz auto-justificação; não torna o verificador mais capaz que o autor.

## Custo

Um subagente forte mais uma suite, **por fluxo** — não por commit.

Contraste com `commit.revisao_subagente`, que é por commit, mecânica e informativa. As duas
coexistem sem sobrepor. Pagando só uma: deixe `commit.revisao_subagente: nunca` e mantenha a
verificação — ela é a que bloqueia.

`shipping.md` não dispara a revisão pré-push quando existe `verificacao.md` da rodada atual:
a verificação já olhou o mesmo range com critério e evidência.
