---
name: k-execute
description: Etapa 3 e final do fluxo. Executa UMA tarefa pendente por invocacao com ciclo TDD dentro da tarefa, prova que o teste discrimina (injecao de falha em worktree descartavel), delega gate e commit ao k-commit e marca a tarefa como concluida. Sem tarefa pendente, encerra: suite completa, verificacao independente por subagente fresco contra os criterios de aceite, e so entao push e PR. Use depois de /k-plan.
---

Leia `.ia-kit/fluxo/k-execute.md` e siga exatamente o que está lá.

Este arquivo é apenas o ponto de entrada do Claude Code. Ele não contém regra própria: toda
a lógica vive no núcleo, para não sair de sincronia quando o kit for atualizado.

Núcleo ausente: pare e avise que o kit não está instalado neste projeto.
