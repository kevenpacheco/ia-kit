---
name: k-plan
description: Etapa 2 do fluxo. Le o spec.md, investiga o codigo com subagentes de leitura, prova a causa raiz em bug, classifica a mudanca, compara opcoes reais e espera a escolha do usuario. Depois grava plan.md, quebra em tarefas (tasks/NN-*.md, uma por comportamento observavel, com teste e implementacao juntos), cria a branch e commita spec, plano e tarefas. Use depois de /k-spec.
---

Leia `.ia-kit/fluxo/k-plan.md` e siga exatamente o que está lá.

Este arquivo é apenas o ponto de entrada do Claude Code. Ele não contém regra própria: toda
a lógica vive no núcleo, para não sair de sincronia quando o kit for atualizado.

Núcleo ausente: pare e avise que o kit não está instalado neste projeto.
