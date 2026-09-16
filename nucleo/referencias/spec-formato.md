# Formato do `spec.md`

Contrato de comportamento do fluxo. Responde **o que** e **por quê**. Nunca **como corrigir**
nem **onde a regra vai morar** — isso é do `k-plan`.

---

## Estado do fluxo

`fluxo:` no frontmatter é a única fonte de verdade sobre o ciclo de vida.

| Valor | Significado | Quem escreve |
|---|---|---|
| `pendente` | achado capturado, ninguém elaborou; `tipo` vazio | `k-spec` modo desvio |
| `ativo` | spec elaborada | `k-spec` modo normal |
| `concluido` | tarefas fechadas e suite verde | `k-execute` |
| `descartado` | não procede, ou absorvido por outro fluxo | `k-spec`, `k-execute` |

`fluxo:` não diz qual é o trabalho corrente — isso é `git branch --show-current`, e pode
haver vários `ativo` ao mesmo tempo, um por branch.

Dependência entre fluxos **não é estado, é relação**: vive em `depende_de: <slug>`, escrito
pelo `k-execute` quando este fluxo fica esperando outro. O fluxo continua `ativo`; ele só
não é o próximo. Não existe valor `bloqueado` — estado exigiria alguém desbloquear na mão, e
ninguém lembra.

Fila de pendentes:

```bash
grep -rl "^fluxo: pendente" <raiz-de-specs>/
```

## Tipos

| Tipo | Quando | Prefixo de branch |
|---|---|---|
| `feature` | comportamento novo ou alterado | `feat/` |
| `bug` | divergência entre esperado e observado | `fix/` |
| `refactor` | melhora o código sem mudar comportamento | `refactor/` |
| `chore` | dependência, configuração, tarefa operacional | `chore/` |
| `docs` | só documentação | `docs/` |

Tipo não óbvio: pergunte. Tipo errado leva a spec, plano e branch errados.

## Regra de localização

| Tipo | Pode citar `arquivo:linha`? |
|---|---|
| `bug` | Sim, **só para localizar** o sintoma. Nunca para dizer o que mudar |
| os outros | Não. Nem arquivo, classe, método, tabela, coluna, rota ou campo |

Spec de feature que já diz onde mexer vira o mesmo documento que o plano, e a revisão barata
da spec deixa de existir.

## Frontmatter

```yaml
---
titulo: <curto e descritivo>
tipo: feature | bug | refactor | chore | docs
fluxo: ativo
criado_em: <AAAA-MM-DD HH:MM:SS>
---
```

Campos escritos por outras etapas, nunca aqui: `depende_de:` (pelo `k-execute`) e os
`origem_*` de um stub.

## Corpo — `feature`, `refactor`, `chore`, `docs`

```markdown
## Objetivo
Problema real que o trabalho resolve. Uma ou duas frases.

## Escopo
O que entra.

### Fora do escopo
O que explicitamente não entra. Protege contra crescimento silencioso.

## Atores e ambientes afetados
Quem executa e em qual parte do sistema.

## Comportamento esperado
### Caminho feliz
### Casos de borda
### Casos de erro
Cada cenário: dado <contexto>, quando <ação>, então <resultado observável>.
Em `refactor`, esta seção afirma o que precisa continuar idêntico.

## Regras de negócio e invariantes
O que precisa ser sempre verdade, independente do caminho.

## Critérios de aceite
Lista verificável, cada item comprovável por teste ou observação.
- [ ] ...

## Premissas
O que foi assumido sem confirmação. Omita a seção se não houver nada.
```

## Corpo — `bug`

```markdown
## Problema
O que está errado, em termos observáveis.

## Arquivos de referência
- `caminho/arquivo:42` — o que esse ponto faz no fluxo
Localização apenas. Não diga o que deve mudar.

## Como reproduzir
Teste, passos numerados, ou `Não reproduzido` com o caminho de execução.

## Comportamento atual vs esperado
**Atual:** ...
**Esperado:** ... (e de onde vem a expectativa)

## Impactos
Quem sofre, com qual frequência, e o que se perde.

## Critérios de aceite
- [ ] ...

## Premissas
Omita a seção se não houver nada.
```

## Raiz de specs

`specs.raiz` do contrato. Pasta por fluxo: `<raiz>/<AAAAMMDD-HHMMSS>-<slug>/`. O slug é
curto, kebab-case, sem acento, e vira o nome da branch no `k-plan`.
