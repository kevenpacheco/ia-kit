# Domínio, glossário e ADR

- Aponte termo do usuário que conflita com o `GLOSSARY.md`, proponha termo preciso para palavra vaga, teste fronteiras com cenários concretos e confronte o que o usuário diz com o que o código faz.
- Grave o termo resolvido no `GLOSSARY.md` na hora: **termo** em negrito, definição de 1–2 frases do que é, `_Evitar_:` sinônimos. Só conceito do domínio, sem implementação. Use os termos do glossário na spec.
- Ofereça ADR só quando os três valem: difícil de reverter, surpreendente sem contexto e fruto de escolha real entre alternativas. Formato em `docs/adr/NNNN-slug.md`: título + 1–3 frases (contexto, decisão, porquê). Crie os arquivos só quando houver o que escrever.
- Se a spec contradiz um ADR, diga explicitamente.
