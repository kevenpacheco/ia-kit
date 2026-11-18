---
name: k-review
description: Code review por quatro subagentes especialistas em paralelo (segurança, arquitetura, regressão/escopo, performance/testes) sobre o diff contra a main, consolidado em review.md com blockers, should-fix e nice-to-have. Use depois de /k-execute e antes de /k-verify, ou para revisar mudanças locais antes de commitar.
argument-hint: "[slug]"
---

# k-review — Review Multi-Agente Paralelo

Fluxo: k-spec → k-execute → **k-review** → k-verify → k-commit.

Quem implementou tem viés de confirmação. Revisores isolados em subagentes auditam o diff sem poluir o contexto principal.

## Procedimento

### 1. Isolar a mudança
- `git diff main` (inclui o que ainda não foi commitado) e `git status --short` para arquivos novos.
- Localize a spec pelo slug ou pela pasta mais recente em `docs/specs/`: ela define o escopo esperado.

### 2. Disparar os revisores
Quatro subagentes **somente de leitura**, todos na mesma mensagem. Cada um recebe o diff, a lista de arquivos novos e os caminhos do `spec.md` e do arquivo de instruções do projeto:

| Revisor | Foco |
|---|---|
| Segurança | OWASP Top 10, segredos/credenciais no diff, sanitização de entrada, autenticação e autorização |
| Arquitetura | aderência às convenções do arquivo de instruções, separação entre domínio, casos de uso e infraestrutura, injeção de dependência |
| Regressão & escopo | alteração ou exclusão fora do escopo do `spec.md`, código não relacionado tocado por engano |
| Performance & testes | consultas N+1, perda de desempenho, caminho novo sem teste unitário ou de integração |

Cada achado volta com `arquivo:linha`, problema e severidade.

### 3. Consolidar em `review.md`
Grave na pasta da spec, sobrescrevendo a versão anterior. Remova duplicatas entre revisores.

```markdown
# Review — <AAAA-MM-DD HH:MM>

## 🔴 Blockers
- `arquivo:linha` — <problema> (<revisor>)

## 🟡 Should fix

## 🔵 Nice to have
```

Blocker é só o que impede o commit: vulnerabilidade, quebra de comportamento, mudança fora do escopo, caminho novo sem teste.

### 4. Encaminhar
- **Com blockers:** `Próximo passo: /k-execute` para corrigir, depois `/k-review` de novo.
- **Sem blockers:** mostre os should-fix ao usuário (aplicá-los é decisão dele) e indique `Próximo passo: /k-verify`.
