<!-- ia-kit:inicio — bloco gerado pelo k-init. Não edite à mão; edite o núcleo. -->
## ia-kit

Fluxo de desenvolvimento deste projeto. O núcleo vive em `.ia-kit/` e é a fonte de verdade.

| Pedido do usuário | Leia e siga |
|---|---|
| instalar, reconfigurar ou atualizar o kit | `.ia-kit/fluxo/k-init.md` |
| iniciar um trabalho: feature, bug, refactor, chore, docs | `.ia-kit/fluxo/k-spec.md` |
| decidir como resolver, provar causa raiz, criar a branch | `.ia-kit/fluxo/k-plan.md` |
| quebrar o plano em tarefas | `.ia-kit/fluxo/k-task.md` |
| executar a próxima tarefa pendente | `.ia-kit/fluxo/k-execute.md` |
| commitar, criar branch, push, PR ou merge | `.ia-kit/fluxo/k-commit.md` |
| tratar comentários de revisor em um PR aberto | `.ia-kit/fluxo/k-revisao.md` |
| procurar bug num alvo, sem sintoma relatado | `.ia-kit/fluxo/k-scan.md` |

Ordem do fluxo: `k-scan` (opcional) → `k-spec` → `k-plan` → `k-task` → `k-execute`, com
`k-commit` em todo commit e `k-revisao` depois do PR.

Regras que valem sempre:

- `.ia-kit/contrato.yml` declara stack, comandos, convenções de git e limites de execução.
  Leia o contrato antes de rodar qualquer comando. Campo vazio = pare e pergunte; não
  adivinhe comando.
- Git que muda estado passa pelo `k-commit`, sempre — inclusive em mudança manual ou
  trabalho fora do fluxo. É lá que o gate roda.
- Subagente em paralelo só para leitura com direções independentes. Escrita em código roda
  sequencial.
- Achado fora do escopo do trabalho atual vira stub, nunca correção de carona:
  `.ia-kit/referencias/desvio.md`.
- Não copie regra do núcleo para cá. Este bloco é ponteiro.

<!-- ia-kit:fim -->
