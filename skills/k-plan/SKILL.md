---
name: k-plan
description: "Plano de execução a partir de uma spec aprovada. Lê spec.md, checklist.md e contexto.md, grava plan.md (o como: mapa de arquivos, padrão a copiar, interfaces, comandos exatos, passos ligados aos IDs do checklist), cria a branch e escreve os testes de aceite falhando, travados por hash, e valida o plano com uma simulação fria. Use depois de /k-discover, ou quando a spec mudou e o plan.md ficou inválido. A etapa seguinte é /k-build."
argument-hint: "[slug] [fatia]"
---

# k-plan — Plano de Execução & Testes de Aceite

Fluxo: k-discover → **k-plan** → k-build → k-review → k-verify → k-commit.

Rode com o modelo mais forte, em sessão nova: você só conhece o que está escrito, e é isso que o executor vai conhecer. O executor roda num modelo menor e não decide nada — se você precisou adivinhar, ele também vai precisar, e vai errar. Seu produto é um plano que dispensa julgamento e testes que provam a spec.

## Procedimento

### 1. Localizar a spec
Slug por argumento → `docs/specs/*-<slug>/`. Sem argumento: a única spec aprovada sem `plan.md` válido; senão liste as candidatas e pergunte.

- Sem `aprovado_em` no `spec.md`: recuse e mande rodar `/k-discover`.
- `duvidas.md` pendente com dúvida de produto: recuse e mande rodar `/k-discover <slug>`.
- `plan.md` existente com `spec_hash` igual ao atual (`git hash-object <spec.md>`): o plano vale; só refaça se o argumento pedir ou se houver dúvida técnica em `duvidas.md` a resolver.
- Trabalho grande: planeje uma fatia por vez (`<slug> <fatia>`), respeitando `bloqueado por`; cada fatia ganha sua seção no `plan.md`.

### 2. Carregar
`spec.md`, `checklist.md`, `contexto.md`, `duvidas.md` (se houver dúvida técnica) e só os arquivos de código que o `contexto.md` cita. Fato que falta: confirme no código e acrescente ao `contexto.md`. Decisão que falta (produto, contrato, regra): não decida — grave em `duvidas.md` e pare (passo 7).

### 3. Garantir a branch
Crie ou confirme `<tipo>/<slug>` (`tipo` do `spec.md`: `feat/`, `fix/`, `refactor/`, `chore/`, `docs/`), partindo de `origin/main` atualizado. Árvore suja na `main`: não faça `git pull`; crie a branch com as alterações e siga.

### 4. Escrever os testes de aceite
Para cada ID do checklist, pelo menos um teste num **Ponto de teste** da spec, seguindo como o projeto já escreve testes (`contexto.md`):
- O nome do teste começa pelo ID: `"C3: exibe 'E-mail inválido' sem @"`. É assim que o `/k-verify` encontra a evidência.
- Asserção no valor literal que a regra fixa, nos casos que ela nomeia, com os exemplos da spec. Nunca `toBeDefined()`, "não lançou erro" ou contagem de chamadas no lugar do estado resultante.
- Mock só em fronteira do sistema.
- Rode e confirme **vermelho pelo motivo certo**: asserção falhando ou símbolo de produção ausente. Erro de sintaxe, import errado do próprio teste ou fixture quebrada é defeito seu: corrija.
- Se a linguagem exige que o símbolo exista para o teste carregar, crie só o esqueleto da interface (assinatura que lança "não implementado") e marque-o como esqueleto no mapa de arquivos. Nenhuma lógica.

Grave o hash de cada arquivo de teste de aceite (`git hash-object <arquivo>`) no frontmatter do `plan.md`. Dali em diante esses arquivos só mudam por um novo `/k-plan`.

### 5. Gravar `plan.md`
Na pasta da spec. Teto de ~150 linhas por fatia. Não repita regra da spec: cite o ID. Sem código além de assinaturas.

```markdown
---
spec_hash: <git hash-object spec.md>
gerado_em: <AAAA-MM-DD HH:MM>
testes_aceite:
  - caminho: <arquivo de teste>
    hash: <git hash-object>
---

## Mapa de arquivos
| Arquivo | Símbolo | Mudança |
|---|---|---|
| src/x/service.ts | `criarPedido` | nova função; valida C1–C3 |

Fora do mapa, nada muda. Arquivos de teste novos de unidade podem ser criados ao lado dos que o mapa cita.

### Proibido tocar
Arquivos de teste de aceite (frontmatter), e <arquivos ou módulos sensíveis próximos que o executor poderia tentar mudar>.

## Padrões a copiar
- Rota nova: siga `src/routes/pedidos.ts` (`listarPedidos`).
- Teste unitário: siga `src/x/service.test.ts`.

## Interfaces novas
Assinaturas, tipos e contratos exatos que os testes de aceite já usam.

## Comandos
- Testes de aceite: `<comando exato>`
- Um arquivo: `<comando exato>`
- Suíte, lint, tipos: `<comandos exatos>`

## Passos
1. <ação concreta em um arquivo do mapa> → deixa verde C1, C2.
2. ...

## Armadilhas
Só o que o executor erraria sem aviso (ordem de migração, efeito colateral conhecido, padrão parecido que NÃO deve ser copiado).

## Execução
Preenchido pelo /k-build: progresso, decisões do usuário durante a execução e achados fora do escopo. O spec.md não muda depois de aprovado.
```

### 6. Simulação fria
Dispare um subagente somente de leitura com `model: sonnet` (o modelo do executor), sem o seu raciocínio. Ele recebe só os caminhos de `plan.md`, `spec.md`, `checklist.md` e dos testes de aceite, e responde: "para implementar seguindo este plano, o que você teria que adivinhar ou decidir?". Lista objetiva, até 300 palavras.

- Lacuna técnica (arquivo, padrão, comando, ordem): corrija o `plan.md` e repita a simulação, no máximo duas vezes.
- Lacuna de produto (regra, valor, comportamento não especificado): passo 7.

### 7. Dúvidas de produto
Grave em `duvidas.md` na pasta da spec, uma por item: pergunta, onde surgiu (ID ou trecho do plano), opções. Pare: `Próximo passo: /k-discover <slug>`. Não escreva o plano em cima de uma escolha sua.

### 8. Encerrar
Mostre o resumo:
```
Plano: docs/specs/<ts>-<slug>/plan.md (<n> passos, <n> arquivos)
Testes de aceite: <n> testes, vermelhos pelo motivo certo
Simulação fria: sem lacunas
Próximo passo: /k-build <slug> em sessão nova
```

## Restrições
- Não implemente código de produção além de esqueletos de interface, e não faça commit.
- Não altere `spec.md` nem `checklist.md`: mudança de quê é do `/k-discover`.
- Nunca tome decisão de produto; registre em `duvidas.md`.
