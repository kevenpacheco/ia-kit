---
name: k-commit
description: Porta única do projeto para git que muda estado — roda o gate (lint, testes afetados, segurança no diff), escreve a mensagem em Conventional Commits e commita. Também cuida de branch, push, PR e merge. Use sempre que for commitar, com ou sem fluxo: mudança manual, ajuste pequeno, ou chamada por outra skill do kit. Nenhuma outra skill roda git de escrita por conta própria.
---

Leia `.ia-kit/fluxo/k-commit.md` e siga exatamente o que está lá.

Este arquivo é apenas o ponto de entrada do Claude Code. Ele não contém regra própria: toda
a lógica vive no núcleo, para não sair de sincronia quando o kit for atualizado.

Núcleo ausente: pare e avise que o kit não está instalado neste projeto.
