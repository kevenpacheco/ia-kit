---
name: k-revisao
description: Lê os comentários não resolvidos do PR da branch atual, classifica cada um (mudança pedida, dúvida, fora de escopo, conflito com a spec) e transforma o que for mudança em tarefas do fluxo. Use depois que um revisor humano comentou no PR e as correções precisam voltar para o ciclo.
---

Leia `.ia-kit/fluxo/k-revisao.md` e siga exatamente o que está lá.

Este arquivo é apenas o ponto de entrada do Claude Code. Ele não contém regra própria: toda
a lógica vive no núcleo, para não sair de sincronia quando o kit for atualizado.

Núcleo ausente: pare e avise que o kit não está instalado neste projeto.
