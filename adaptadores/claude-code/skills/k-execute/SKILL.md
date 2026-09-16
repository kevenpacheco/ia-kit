---
name: k-execute
description: Etapa 4 do fluxo. Executa UMA tarefa pendente por invocação com ciclo TDD dentro da tarefa, delega gate e commit ao k-commit e marca a tarefa como concluída. Na última tarefa roda a suite completa, marca o fluxo como concluído e conduz push e PR conforme o contrato. Use depois do k-task.
---

Leia `.ia-kit/fluxo/k-execute.md` e siga exatamente o que está lá.

Este arquivo é apenas o ponto de entrada do Claude Code. Ele não contém regra própria: toda
a lógica vive no núcleo, para não sair de sincronia quando o kit for atualizado.

Núcleo ausente: pare e avise que o kit não está instalado neste projeto.
