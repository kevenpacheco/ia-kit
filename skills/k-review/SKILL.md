---
name: k-review
description: Code review por quatro subagentes especialistas em paralelo (segurança, arquitetura, aderência à spec, performance/testes) sobre o diff contra o merge-base com a main, consolidado em review.md com blockers, should-fix e nice-to-have. Use depois de /k-execute e antes de /k-verify, ou para revisar mudanças locais antes de commitar.
argument-hint: "[slug]"
---

# k-review — Review Multi-Agente Paralelo

Fluxo: k-spec → k-execute → **k-review** → k-verify → k-commit.

Quem implementou tem viés de confirmação. Revisores isolados em subagentes auditam o diff sem poluir o contexto principal.

## Procedimento

### 1. Isolar a mudança
- `git diff $(git merge-base origin/main HEAD)` (inclui o que ainda não foi commitado) e `git status --short` para arquivos novos. Não compare com a ponta da `main`: commits novos dela apareceriam como revertidos.
- Diff vazio ou ref inválida: pare e avise.
- Localize a spec pelo slug ou pela pasta mais recente em `docs/specs/`: ela define o escopo esperado.

### 2. Disparar os revisores
Quatro subagentes **somente de leitura**, todos na mesma mensagem, cada um com resposta de até 400 palavras. Cada um recebe o diff, a lista de arquivos novos e os caminhos do `spec.md`, do `CODING_STANDARDS.md` (se existir) e do arquivo de instruções do projeto:

| Revisor | Foco |
|---|---|
| Segurança | OWASP Top 10, segredos/credenciais no diff, sanitização de entrada, autenticação e autorização |
| Arquitetura (eixo padrões) | aderência às convenções do arquivo de instruções e do `CODING_STANDARDS.md`, separação entre domínio, casos de uso e infraestrutura, injeção de dependência; smells como julgamento (abaixo) |
| Aderência à spec (eixo spec) | (a) o que o `spec.md` pede e está faltando ou pela metade; (b) comportamento que ninguém pediu ou alteração fora do escopo; (c) o que parece implementado mas está errado. Cada achado cita a linha da spec |
| Performance & testes | consultas N+1, perda de desempenho, caminho novo sem teste unitário ou de integração |

**Smells** (questão de julgamento, nunca violação dura): Mysterious Name, Duplicated Code, Feature Envy, Data Clumps, Primitive Obsession, Repeated Switches, Shotgun Surgery, Divergent Change, Speculative Generality, Message Chains, Middle Man, Refused Bequest. A regra documentada do repositório tem precedência; o que lint ou formatador já força fica de fora.

Trabalho pequeno (spec de uma linha): dispare só o revisor de aderência à spec.

Cada achado volta com `arquivo:linha`, problema e severidade.

### 3. Consolidar em `review.md`
Grave na pasta da spec, sobrescrevendo a versão anterior. Remova duplicatas entre revisores. Marque o eixo de cada achado (padrões | spec) para um não esconder o outro.

```markdown
# Review — <AAAA-MM-DD HH:MM> — rodada <n>

## 🔴 Blockers
- `arquivo:linha` — <problema> (<revisor>, eixo <padrões|spec>)

## 🟡 Should fix

## 🔵 Nice to have
```

Blocker é só o que impede o commit: vulnerabilidade, quebra de comportamento, mudança fora do escopo, requisito da spec faltando, caminho novo sem teste.

### 4. Encaminhar
- **Com blockers:** `Próximo passo: /k-execute` para corrigir, depois `/k-review` de novo. Limite de duas rodadas de correção por spec: blockers na rodada 2, pare e leve ao usuário o que ainda falha.
- **Sem blockers:** mostre os should-fix ao usuário (aplicá-los é decisão dele) e indique `Próximo passo: /k-verify`.
