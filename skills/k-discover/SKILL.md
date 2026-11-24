---
name: k-discover
description: "Discovery e especificação. Investiga o código, entrevista o usuário em rodadas até não restar decisão aberta e grava contexto.md (fatos do repositório), spec.md (o quê: escopo, regras com exemplos literais, pontos de teste, decisões) e checklist.md (critérios de aceite com ID), com aprovação explícita do usuário. Use ao iniciar qualquer feature, correção, refactor ou chore que vá virar commit, ou para responder um duvidas.md. Primeira etapa do fluxo; a seguinte é /k-plan."
argument-hint: "[descrição do trabalho | slug de spec existente]"
---

# k-discover — Discovery & Spec

Fluxo: **k-discover** → k-plan → k-build → k-review → k-verify → k-commit.

Esta é a etapa onde se gasta: rode-a com o modelo mais forte disponível. Tudo que exigiria julgamento depois precisa ser resolvido aqui, porque as etapas seguintes rodam em modelos menores e não decidem nada. A spec diz **o quê**; o **como** é do `/k-plan`.

## Procedimento

### 1. Resolver o alvo e o tamanho
- Argumento que casa com uma pasta em `docs/specs/` → atualizar aquela spec. Se ela tiver `duvidas.md` pendente, comece por ele (passo 3, uma rodada com as dúvidas), atualize a spec, apague as dúvidas respondidas e avise que o `plan.md` ficou inválido: `Próximo passo: /k-plan <slug>`.
- Texto livre → trabalho novo. Sem argumento → pergunte o que será feito.

Tamanho do trabalho:
- **Pequeno** (até ~3 arquivos, cabe numa frase): `spec.md` enxuto com `## Checklist` e `## Plano` inline (passo 6), sem `checklist.md`, `contexto.md` nem varredura do passo 4. Pula o `/k-plan`.
- **Médio**: fluxo completo.
- **Grande** (mais de ~8 itens no checklist ou não cabe numa sessão): divida em fatias; leia `referencias/fatias.md`.

### 2. Descobrir antes de perguntar
Leia o arquivo de instruções do projeto (`CLAUDE.md`/`AGENTS.md`), o `roadmap.md`, o `GLOSSARY.md` e `docs/adr/`, quando existirem. Para o código, dispare subagentes somente de leitura em paralelo, um por eixo: fluxo atual afetado, reuso disponível, testes existentes. Cada um devolve conclusões com `arquivo:linha`, nunca despejo de código.

Grave os achados em `contexto.md` na pasta da spec (passo 5): só fatos verificados, cada um com `arquivo:linha` — onde o fluxo mora, padrões existentes a reutilizar, como os testes são escritos e rodados. O `/k-plan` lê esse arquivo para não redescobrir.

Mostre uma síntese curta dos achados antes da primeira pergunta. Nunca pergunte o que o repositório responde.

### 3. Entrevistar sem assumir nada
**Nunca assuma premissa.** Toda decisão que o repositório não responde é do usuário: pergunte, mesmo quando houver uma resposta "óbvia". Entreviste sem pressa até chegar a um entendimento comum, mapeando as decisões como uma **árvore de decisão**: cada decisão ramifica nas decisões que dependem dela.

Trabalhe a árvore em **rodadas**. A **fronteira** é toda decisão cujos pré-requisitos já estão resolvidos: as perguntas que dá para fazer *agora* sem chutar respostas que ainda não ouviu. Faça a fronteira inteira numa rodada: numere cada pergunta e dê a sua resposta recomendada. Depois espere as respostas antes da rodada seguinte.

Formato da rodada:

```
❓ **P1** - **<título da pergunta>**: <corpo da pergunta; pode ter vários parágrafos, inclusive alternativas>

➡️ <sua resposta recomendada>

---

❓ **P2** - **<título da pergunta>**: <corpo da pergunta>

➡️ <sua resposta recomendada>
```

- Redija cada pergunta para que "sim" aceite a recomendação. Quando houver alternativas reais, diga o que se ganha e o que se perde em cada uma.
- Cada resposta remodela a árvore: decisões resolvidas empurram a fronteira para fora e liberam perguntas que dependiam delas. Recalcule a fronteira e faça a rodada seguinte. Pergunta cuja resposta depende de outra ainda aberta na rodada fica para uma rodada *posterior*.
- Descobrir *fatos* é trabalho seu, nunca do usuário. Quando uma pergunta da fronteira precisa de fato do ambiente, dispare um subagente de contexto limpo e acrescente o fato ao `contexto.md`. Não trave a rodada: só as perguntas que dependem da exploração esperam. As *decisões* são do usuário: coloque-as e espere.
- Peça exemplos concretos: para cada regra, um caso com entrada e saída literais (payload, mensagem, número). Regra sem exemplo é regra que o executor vai interpretar.
- Não existe "premissa registrada": o que não foi decidido pelo usuário nem respondido pelo repositório vira pergunta.
- A entrevista termina quando a fronteira está vazia: todo ramo da árvore visitado e nada assumido em silêncio. Só avance para gravar quando o usuário confirmar que o entendimento comum foi alcançado.

Termos do domínio, `GLOSSARY.md` e ADR: leia `referencias/dominio.md` na primeira vez que surgir termo novo ou decisão difícil de reverter. Pedido com tela, mockup ou captura: leia `referencias/tela.md`.

### 4. Fechar lacunas antes de gravar
Trabalho médio ou grande. Resolva cada dimensão em regra ou `N/A porque <motivo>`, **perguntando ao usuário** (rodada no formato do passo 3) em vez de decidir sozinho; só vale `N/A` que o usuário ou o repositório confirmem: validação de entrada e limites; falha e falha parcial; idempotência, retry e duplicidade; autorização e rate limit; concorrência e ordem; ciclo de vida e expiração dos dados; observabilidade; falha de dependência externa; integridade das transições de estado.

Releia o pedido frase por frase: cada frase cai numa regra, em "Fora do escopo" ou numa pergunta aberta.

### 5. Gravar `spec.md`
Pasta: `docs/specs/<AAAAMMDD-HHMMSS>-<slug>/` (use `documentation/specs/` se o projeto já usa `documentation/`). Slug curto, kebab-case, sem acento.

```markdown
---
titulo: <título curto>
tipo: feat | fix | refactor | chore | docs
tamanho: pequeno | medio | grande
criado_em: <AAAA-MM-DD HH:MM>
aprovado_em: <preenchido no passo 7>
---

## Contexto & Escopo
Problema que o trabalho resolve e o que entra.

### Fora do escopo

## Regras de Domínio
Cenários: dado <contexto>, quando <ação>, então <resultado observável>.
Cada regra com pelo menos um exemplo literal (entrada → saída exata). Inclua bordas e erros.

## Pontos de teste
Interfaces públicas onde o comportamento é observado sem olhar por dentro: prefira as que já existem, as mais altas, idealmente uma só. Cada uma com uma linha do que pega e do que não pega. Mock só em fronteira do sistema (API externa, tempo, aleatoriedade, às vezes banco/arquivos), nunca em colaborador interno. Confirme com o usuário.

## Decisões Técnicas
Só o que foi decidido com o usuário ou imposto pelo repositório: contratos (rotas, payloads, códigos), modelagem de dados, estratégia de erros. Onde cada mudança mora e em que ordem é trabalho do /k-plan.

## Fatias
Só no trabalho grande (referencias/fatias.md).

## Histórico de Decisões
Escolha feita na entrevista, alternativa descartada e motivo, com as palavras do usuário.
```

Mantenha só o essencial: o planejador e o executor leem o `spec.md` inteiro em contexto zerado.

### 6. Gravar `checklist.md`
Converta cada regra e decisão do `spec.md` em um item que é um comportamento observável com valor concreto (status, mensagem, número, limite), com **ID sequencial** e a camada entre colchetes. O ID amarra o item ao teste de aceite (o `/k-plan` põe o ID no nome do teste) e à evidência do `/k-verify`:

```markdown
- [ ] C1 [API] GET /api/v1/resource retorna 200 com array de dados para usuário autenticado.
- [ ] C2 [API] POST /api/v1/resource sem autenticação retorna 401 Unauthorized.
- [ ] C3 [Front-end] Tela de cadastro exibe "E-mail inválido" ao submeter formulário com e-mail sem "@".
```

Item que não dá para provar ("código limpo", "boa performance") nem item que só prova que um teste existe não entra: reescreva com critério mensurável ou remova. IDs nunca são reaproveitados: item removido deixa o número vago.

Trabalho pequeno: checklist em `## Checklist` no `spec.md`, e um `## Plano` de até 10 linhas com arquivos a tocar, padrão a copiar e comando de teste.

### 7. Aprovar e encerrar
Apresente a spec e o checklist e pergunte se o usuário aprova. Só com o "sim", grave em `aprovado_em` `<AAAA-MM-DD> — usuário: "<palavras dele>"`. Nunca registre aprovação que ele não deu.

```
Spec: docs/specs/<ts>-<slug>/spec.md
Checklist: docs/specs/<ts>-<slug>/checklist.md (<n> itens)
Próximo passo: /k-plan <slug> em sessão nova (pequeno: /k-build <slug>)
```

## Restrições
- Não altere código de aplicação nem de teste, nem faça commit nesta etapa.
- Não decida como implementar além do que o usuário decidiu: mapa de arquivos, ordem e testes são do `/k-plan`.
- Nunca assuma premissa nem tome decisão que o usuário não tomou; pergunte sempre. A spec não tem seção de premissas.
