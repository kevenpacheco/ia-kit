# CLAUDE.md

> Template base de instruções para agentes de IA (Claude Code, etc.) neste projeto.
> Adapte as seções específicas do projeto ao final; as regras gerais abaixo são fixas.

---

## 1. Regras Gerais

Estas regras são **inegociáveis** e se aplicam a qualquer tarefa, em qualquer projeto.

### 1.1. Pense antes de codar
- **Declare suas presunções explicitamente** antes de escrever qualquer código.
- Se houver **incerteza**, **pergunte**. Nunca adivinhe.
- Não inicie a implementação enquanto o objetivo e o escopo não estiverem claros.

### 1.2. Simplicidade primeiro
- Use o **mínimo de código possível** para resolver o problema.
- Priorize sempre **legibilidade** e **manutenibilidade** sobre esperteza.
- Não adicione abstrações, camadas ou generalizações que o problema atual não exige (YAGNI).

### 1.3. Mudanças cirúrgicas
- Altere **apenas o necessário** para cumprir o objetivo.
- Não refatore, renomeie ou reformate código fora do escopo da tarefa sem permissão.
- Mantenha os diffs pequenos e revisáveis.

### 1.4. Execução baseada em objetivos
- Toda ação deve servir a um **objetivo declarado**.
- Antes de codar, deixe claro: *o que* será feito, *por que*, e *como* o sucesso será verificado.
- Se a tarefa se desviar do objetivo, pare e realinhe.

### 1.5. Testes verificam intenção e comportamento
- Escreva testes que validem **intenções e comportamentos**, não detalhes de implementação.
- Um teste deve falhar por uma razão clara e ligada ao comportamento esperado.

### 1.6. TDD é obrigatório
- **TDD é obrigatório em qualquer operação**: escreva o teste antes da implementação.
- Ciclo: **Red → Green → Refactor**.
  1. Escreva um teste que falha (Red).
  2. Implemente o mínimo para passar (Green).
  3. Refatore mantendo os testes verdes (Refactor).

### 1.7. Nunca delete testes sem permissão
- **Não remova nem desabilite** testes existentes sem autorização explícita.
- Se um teste parece incorreto ou obsoleto, **sinalize e pergunte** antes de alterá-lo.

### 1.8. Código autoexplicativo
- **Não faça comentários desnecessários.** Comente apenas o que for realmente necessário (o *porquê*, não o *o quê*).
- Nomes de **variáveis, funções, classes e métodos** devem ser descritivos e expressar com clareza o que fazem.
- Prefira um nome claro a um comentário que explique um nome ruim.

### 1.9. Documentação sempre atualizada
- Em **qualquer alteração**, mantenha a documentação técnica e/ou de usabilidade atualizada.
- Documentação desatualizada conta como trabalho incompleto.
- Atualize READMEs, comentários relevantes e os documentos referenciados na Seção 3.

---

## 2. Contexto do Projeto

> Preencha por projeto. Substitua os placeholders abaixo.

- **Nome do projeto:** `<nome>`
- **Descrição / propósito:** `<o que é e qual problema resolve>`
- **Stack principal:** `<linguagens, frameworks, banco de dados>`
- **Como rodar localmente:** `<comandos de setup e execução>`
- **Como rodar os testes:** `<comando de testes>`
- **Como fazer build / deploy:** `<comandos / pipeline>`
- **Convenções específicas:** `<padrões de código, commits, branches>`

---

## 3. Referências de Documentação

> Última seção: links para a documentação das demais partes do código.

- **Arquitetura:** `<link / caminho>`
- **Documentação técnica:** `<link / caminho>`
- **Documentação de usabilidade / produto:** `<link / caminho>`
- **API / contratos:** `<link / caminho>`
- **Decisões de arquitetura (ADRs):** `<link / caminho>`
- **Guia de contribuição:** `<link / caminho>`
