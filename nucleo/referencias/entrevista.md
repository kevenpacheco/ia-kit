# Entrevista

Como o kit pergunta. Vale para o `k-spec` (comportamento) e para o `k-plan` (decisão
técnica).

---

## Regra base

**Uma pergunta por vez.** Espere a resposta antes da próxima. Várias perguntas juntas
confundem e produzem resposta rasa.

Nunca gaste pergunta com fato que o repositório responde. Investigue primeiro, pergunte
depois.

## Formato

Use o mecanismo de pergunta com alternativas da ferramenta em uso, com **2 a 4 opções**. Sem
mecanismo disponível, escreva o mesmo conteúdo em texto.

Três partes, nesta ordem:

1. **A pergunta**, direta, sem preâmbulo.
2. **A recomendação e o porquê**, em bloco curto antes das opções.
3. **As alternativas**, a recomendada em primeiro, marcada `(Recomendado)`. Cada descrição
   diz o que se ganha **e** o que se perde.

```
Bolsa expirada continua aparecendo na listagem publica?

Recomendo ocultar porque o aluno nao consegue se inscrever numa bolsa
vencida, e o botao inerte vira ticket de suporte.

[A] Ocultar da listagem (Recomendado)
    Corta a duvida do aluno. Perde o sinal de que a bolsa existiu.
[B] Mostrar riscada, sem botao de inscricao
    Transparente sobre a oferta. Gera a pergunta "por que nao consigo?".
[C] Mostrar so para quem ja tinha favoritado
    Meio-termo. Exige consultar favoritos na montagem da listagem.
```

## Regras

- Toda alternativa precisa ser um caminho que alguém razoável escolheria, com o trade-off
  real escrito. **Proibida opção-palha** — enfeitar a recomendada e enfraquecer as outras de
  propósito transforma a pergunta em teatro.
- Só existe um caminho viável: **não invente pergunta**. Registre como premissa e siga.
- Só pergunte o que muda o trabalho. O resto vira premissa.
- "Tanto faz" é resposta: registre como premissa e siga.
- Continue até não restar ambiguidade que mude o resultado.

## O que perguntar, por tipo

| Tipo | Perguntas que valem |
|---|---|
| `feature` | comportamento em caso de borda, o que fica fora do escopo, quais partes do sistema são afetadas, o que acontece em erro, quem pode fazer a ação |
| `bug` | em qual parte do sistema e com qual perfil ocorre, qual entrada exata reproduz, qual é o comportamento correto quando a documentação não diz, o quanto dói na prática |
| `refactor` | qual o incômodo concreto, qual o limite do que pode ser tocado, o que precisa continuar idêntico |
| `chore`, `docs` | qual o gatilho e o que conta como pronto |

## Antes da primeira pergunta

Mostre uma síntese curta dos achados da investigação, com `arquivo:linha`. O usuário pode
corrigir um achado errado antes que ele vire premissa da entrevista inteira.

## Quantas perguntas

Não há número certo, mas há sinal de excesso: se duas perguntas seguidas não mudariam nada
no resultado, a entrevista acabou. Perguntar além disso gasta a paciência que a pergunta
importante vai precisar.

## k-init: campos do contrato

O `k-init` também entrevista, e as regras acima valem inteiras. Só pergunte o que a detecção
e a validação por execução não resolveram. O que muda é o conteúdo:

**Raiz de specs:** se já existe `docs/specs/` ou `documentation/specs/`, use e não pergunte.

**Modo padrão** (decide o quanto o agente decide sozinho):

| Modo | Quando | Efeito |
|---|---|---|
| `greenfield` | base nova, poucos consumidores | tarefas maiores, autonomia alta |
| `evolucao` | base viva, em mudança | plano obrigatório, tarefas médias |
| `legado` | base antiga, alto acoplamento | tarefas mínimas, gate cheio, humano decide |

Na dúvida, recomende `evolucao`.

**Segurança ausente:** se nenhuma ferramenta foi detectada, ofereça instalar uma dos
candidatos de `gate.md`. Recusa: grave `seguranca: ""` mais `seguranca_pendente` com a data,
e avise que o `k-execute` vai cobrar em toda invocação.

**Origem do kit:** recomende `https://github.com/kevenpacheco/ia-kit` e só pergunte se o
projeto usa espelho interno. Ver `instalacao.md`.

**Na atualização, não reabra o que já foi respondido.** Pergunte só o campo novo ou o campo
cujo significado mudou na versão. Entrevista repetida do zero é o jeito mais rápido de
ensinar o time a nunca atualizar o kit.
