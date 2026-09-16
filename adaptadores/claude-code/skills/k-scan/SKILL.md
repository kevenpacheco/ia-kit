---
name: k-scan
description: Etapa opcional antes do fluxo. Varre um alvo delimitado (diretório, módulo, fluxo ou diff da branch) com subagentes por eixo de defeito, refuta cada achado com um subagente adversarial e apresenta só os confirmados para você escolher quais viram trabalho. Use ao procurar bugs sem ter um sintoma relatado. Custa caro — é a única etapa com fan-out.
---

Leia `.ia-kit/fluxo/k-scan.md` e siga exatamente o que está lá.

Este arquivo é apenas o ponto de entrada do Claude Code. Ele não contém regra própria: toda
a lógica vive no núcleo, para não sair de sincronia quando o kit for atualizado.

Núcleo ausente: pare e avise que o kit não está instalado neste projeto.
