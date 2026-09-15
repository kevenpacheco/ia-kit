---
name: k-init
description: Instala o ia-kit neste projeto — detecta stack e comandos, valida executando, entrevista o que faltou e grava .ia-kit/contrato.yml mais os shims da ferramenta. Use ao adotar o kit em um repositório novo, ao reconfigurar o contrato ou ao atualizar a versão do núcleo.
---

Leia `.ia-kit/fluxo/k-init.md` e siga exatamente o que está lá.

Este arquivo é apenas o ponto de entrada do Claude Code. Ele não contém regra própria: toda
a lógica vive no núcleo, para não sair de sincronia quando o kit for atualizado.

Núcleo ausente: pare e avise que o kit não está instalado neste projeto.
