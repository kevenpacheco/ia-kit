---
name: k-spec
description: Planejamento Spec-Lean. Investiga o código, entrevista o usuário em rodadas e grava spec.md (plano único com escopo, regras de domínio, pontos de teste e decisões técnicas) e checklist.md (critérios de aceite verificáveis), com aprovação explícita do usuário. Use ao iniciar qualquer feature, correção, refactor ou chore que vá virar commit. Primeira etapa do fluxo; a seguinte é /k-execute.
argument-hint: "[descrição do trabalho | slug de spec existente]"
---

# k-spec — Planejamento Spec-Lean

Fluxo: **k-spec** → k-execute → k-review → k-verify → k-commit.

Substitui a decomposição em micro-tarefas (spec → design → tasks) por um plano único e um checklist de aceite. O executor implementa a partir do plano; o checklist é o contrato que o `k-verify` prova.

## Procedimento

### 1. Resolver o alvo e o tamanho
- Argumento que casa com uma pasta em `docs/specs/` → atualizar aquela spec.
- Texto livre → trabalho novo. Sem argumento → pergunte o que será feito.

Tamanho do trabalho:
- **Pequeno** (até ~3 arquivos, cabe numa frase): `spec.md` de uma linha de contexto, checklist inline na seção `## Checklist` do mesmo arquivo (sem `checklist.md`), sem varredura do passo 4; pule a sessão nova.
- **Médio**: fluxo completo.
- **Grande** (mais de ~8 itens no checklist ou não cabe numa sessão): divida em fatias (passo 5).

### 2. Descobrir antes de perguntar
Leia o arquivo de instruções do projeto (`CLAUDE.md`/`AGENTS.md`), o `roadmap.md`, o `GLOSSARY.md` e `docs/adr/`, quando existirem. Para o código, dispare subagentes somente de leitura em paralelo, um por eixo: fluxo atual afetado, reuso disponível, testes existentes, documentação. Cada um devolve conclusões com `arquivo:linha`, nunca despejo de código.

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
- Descobrir *fatos* é trabalho seu, nunca do usuário. Quando uma pergunta da fronteira precisa de fato do ambiente (arquivos, ferramentas etc.), dispare um subagente de contexto limpo; não pergunte o que você mesmo pode levantar. Não trave a rodada: a exploração em andamento é pré-requisito em aberto, então só as perguntas que dependem dela esperam; faça o resto da fronteira agora. As *decisões* são do usuário: coloque-as e espere.
- Não existe "premissa registrada": o que não foi decidido pelo usuário nem respondido pelo repositório vira pergunta.
- A entrevista termina quando a fronteira está vazia: todo ramo da árvore visitado e nada assumido em silêncio. Só avance para gravar quando o usuário confirmar que o entendimento comum foi alcançado.

Domínio:
- Aponte termo do usuário que conflita com o `GLOSSARY.md`, proponha termo preciso para palavra vaga, teste fronteiras com cenários concretos e confronte o que o usuário diz com o que o código faz.
- Grave o termo resolvido no `GLOSSARY.md` na hora: **termo** em negrito, definição de 1–2 frases do que é, `_Evitar_:` sinônimos. Só conceito do domínio, sem implementação. Use os termos do glossário na spec.
- Ofereça ADR só quando os três valem: difícil de reverter, surpreendente sem contexto e fruto de escolha real entre alternativas. Formato em `docs/adr/NNNN-slug.md`: título + 1–3 frases (contexto, decisão, porquê). Crie os arquivos só quando houver o que escrever.
- Se a spec contradiz um ADR, diga explicitamente.

### 4. Fechar lacunas antes de gravar
Trabalho médio ou grande. Resolva cada dimensão em regra ou `N/A porque <motivo>`, **perguntando ao usuário** (rodada no formato do passo 3) em vez de decidir sozinho; só vale `N/A` que o usuário ou o repositório confirmem: validação de entrada e limites; falha e falha parcial; idempotência, retry e duplicidade; autorização e rate limit; concorrência e ordem; ciclo de vida e expiração dos dados; observabilidade; falha de dependência externa; integridade das transições de estado.

Releia o pedido frase por frase: cada frase cai numa regra, em "Fora do escopo" ou numa pergunta aberta.

Tela: mockup, captura ou link do pedido vale como especificação, salvo se o usuário disser que é só inspiração. Guarde o arquivo na pasta da spec; cada estado desenhado vira item do checklist citando o arquivo; textos do mockup são copiados exatamente (desvio: pergunte); toda tela cobre os estados vazio, carregando, erro e sem permissão, e cada controle diz o que acontece quando usado.

### 5. Gravar `spec.md`
Pasta: `docs/specs/<AAAAMMDD-HHMMSS>-<slug>/` (use `documentation/specs/` se o projeto já usa `documentation/`). Slug curto, kebab-case, sem acento.

```markdown
---
titulo: <título curto>
tipo: feat | fix | refactor | chore | docs
criado_em: <AAAA-MM-DD HH:MM>
aprovado_em: <preenchido no passo 7>
---

## Contexto & Escopo
Problema que o trabalho resolve e o que entra.

### Fora do escopo

## Regras de Domínio
Cenários no formato: dado <contexto>, quando <ação>, então <resultado observável>.
Inclua casos de borda e de erro.

## Pontos de teste
Interfaces públicas onde o comportamento é observado sem olhar por dentro: prefira as que já existem, as mais altas, idealmente uma só. Cada uma com uma linha do que pega e do que não pega. Mock só em fronteira do sistema (API externa, tempo, aleatoriedade, às vezes banco/arquivos), nunca em colaborador interno. Confirme com o usuário.

## Decisões Técnicas
Onde a mudança mora (arquivo + nome do símbolo: função, classe, rota; sem número de linha), modelagem de dados, rotas/contratos, estratégia de erros e reuso identificado.

## Fatias
Só no trabalho grande. Veja abaixo.

## Histórico de Decisões
Escolha feita na entrevista, alternativa descartada e motivo, com as palavras do usuário.
```

Mantenha só o essencial: o executor lê o `spec.md` inteiro em contexto zerado.

**Fatias** (trabalho grande): cada fatia atravessa todas as camadas (dados, API, tela, testes) e pode ser demonstrada sozinha; cabe numa sessão; declara `bloqueado por` (dependência real, não preferência de ordem). Refatoração preparatória vem primeiro ("deixe a mudança fácil, depois faça a mudança fácil"); refatoração ampla e mecânica segue expandir (nova forma ao lado da velha) → migrar em lotes → contrair (apagar a velha). O usuário aprova a divisão. O checklist é agrupado por fatia.

### 6. Gravar `checklist.md`
Converta cada regra e decisão do `spec.md` em um item que é um comportamento observável com valor concreto (status, mensagem, número, limite), com a camada entre colchetes:

```markdown
- [ ] [API] GET /api/v1/resource retorna 200 com array de dados para usuário autenticado.
- [ ] [API] POST /api/v1/resource sem autenticação retorna 401 Unauthorized.
- [ ] [Front-end] Tela de cadastro exibe "E-mail inválido" ao submeter formulário com e-mail sem "@".
```

Item que não dá para provar ("código limpo", "boa performance") nem item que só prova que um teste existe não entra: reescreva com critério mensurável ou remova.

### 7. Aprovar e encerrar
Apresente a spec e o checklist e pergunte se o usuário aprova. Só com o "sim", grave em `aprovado_em` `<AAAA-MM-DD> — usuário: "<palavras dele>"`. Nunca registre aprovação que ele não deu.

```
Spec: docs/specs/<ts>-<slug>/spec.md
Checklist: docs/specs/<ts>-<slug>/checklist.md (<n> itens)
Próximo passo: /k-execute <slug> (sessão nova se o contexto já estiver pesado)
```

## Restrições
- Não altere código de aplicação nem faça commit nesta etapa.
- Sem micro-tarefas: não quebre a implementação em passos de instrução de código; fatias são entregas verticais, não passos.
- Nunca assuma premissa nem tome decisão que o usuário não tomou; pergunte sempre. A spec não tem seção de premissas.
