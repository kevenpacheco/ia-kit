## 1. Contexto do Projeto

> Preencha por projeto. Substitua os placeholders abaixo.

- **Projeto:** `<nome do projeto>`
- **Descrição:** `<descrição curta: o que é e qual problema resolve>`
- **Stack principal:** `<linguagens, frameworks, banco de dados>`
- **Como rodar localmente:** `<comandos de setup e execução>`
- **Como rodar os testes:** `<comando de testes>`
- **Como fazer build / deploy:** `<comandos / pipeline>`
- **Convenções específicas:** `<padrões de código, commits, branches>`

---

## 2. Regras Gerais

Estas regras são **inegociáveis** e se aplicam a qualquer tarefa, em qualquer projeto.

### 2.1. Pense antes de codar
- **Declare suas presunções explicitamente** antes de escrever qualquer código.
- Se houver **incerteza**, **ambiguidade**, **conflitos**, **pergunte**. Nunca adivinhe.
- Não inicie a implementação enquanto o objetivo e o escopo não estiverem claros.

### 2.2. Simplicidade primeiro
- Use o **mínimo de código possível** para resolver o problema.
- Priorize sempre **legibilidade** e **manutenibilidade** sobre esperteza.
- Não adicione abstrações, camadas ou generalizações que o problema atual não exige (YAGNI).

### 2.3. Mudanças cirúrgicas
- Altere **apenas o necessário** para cumprir o objetivo.
- Não refatore, renomeie ou reformate código fora do escopo da tarefa sem permissão.
- Mantenha os diffs pequenos e revisáveis.

### 2.4. Use o máximo de subagentes possível
- Sempre que a tarefa permitir paralelização, use o **máximo de subagentes possível** para executá-la.
- Prefira decompor o trabalho em partes independentes e distribuí-las entre subagentes em vez de executar tudo sequencialmente em um único fluxo.

### 2.5. Execução baseada em objetivos
- Toda ação deve servir a um **objetivo declarado**.
- Antes de codar, deixe claro: *o que* será feito, *por que*, e *como* o sucesso será verificado.
- Se a tarefa se desviar do objetivo, pare e realinhe.

### 2.6. Testes verificam intenção e comportamento
- Escreva testes que validem **intenções e comportamentos**, não detalhes de implementação.
- Um teste deve falhar por uma razão clara e ligada ao comportamento esperado.

### 2.7. TDD é obrigatório
- **TDD é obrigatório em qualquer operação**: escreva o teste antes da implementação.
- Ciclo: **Red → Green → Refactor**.
  1. Escreva um teste que falha (Red).
  2. Implemente o mínimo para passar (Green).
  3. Refatore mantendo os testes verdes (Refactor).

### 2.8. Nunca delete testes sem permissão
- **Não remova nem desabilite** testes existentes sem autorização explícita.
- Se um teste parece incorreto ou obsoleto, **sinalize e pergunte** antes de alterá-lo.

### 2.9. Código autoexplicativo
- **Não faça comentários desnecessários.** Comente apenas o que for realmente necessário (o *porquê*, não o *o quê*).
- Nomes de **variáveis, funções, classes e métodos** devem ser descritivos e expressar com clareza o que fazem.
- Prefira um nome claro a um comentário que explique um nome ruim.

### 2.10. Documentação sempre atualizada
- Em **qualquer alteração**, mantenha a documentação técnica e/ou de usabilidade atualizada.
- Documentação desatualizada conta como trabalho incompleto.
- Atualize READMEs, comentários relevantes e os documentos referenciados na Seção 3.

### 2.11. Erros esperados como valores
- Modele **erros esperados e recuperáveis** como valores de retorno, não como exceptions.
- Use exceptions apenas para falhas realmente inesperadas, bugs, invariantes violadas ou problemas críticos de infraestrutura.
- Não use exceptions como fluxo normal de negócio. Casos como validação inválida, entidade não encontrada, permissão negada, conflito de estado ou operação recusada devem ser retornados explicitamente.
- Prefira retornos tipados e explícitos, como `Result<T, E>`, unions discriminadas ou estruturas equivalentes da linguagem usada.
- Quem chama a função deve conseguir entender, pelo contrato, quais erros esperados podem acontecer e tratá-los sem depender de `try/catch` genérico.

---

## 3. Referências de Documentação

> Links para a documentação das demais partes do código.

- **Arquitetura:** `<link / caminho>`
- **Documentação técnica:** `<link / caminho>`
- **Documentação de usabilidade / produto:** `<link / caminho>`
- **API / contratos:** `<link / caminho>`
- **Decisões de arquitetura (ADRs):** `<link / caminho>`
- **Guia de contribuição:** `<link / caminho>`
