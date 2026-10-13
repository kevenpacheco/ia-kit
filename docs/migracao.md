# Migração entre versões do kit

Roteiro geral da atualização, e um bloco por versão que quebra contrato.

O que mudou em cada versão: `CHANGELOG.md`.
O que cada dígito da versão promete: `nucleo/referencias/instalacao.md`, seção 3.

---

## Roteiro geral

Vale para qualquer atualização. Os blocos abaixo só acrescentam o que é específico.

1. **Commite ou guarde o trabalho em andamento.** A atualização substitui `.ia-kit/` inteiro;
   trabalho não commitado no núcleo se perde.
2. **Rode o instalador** com a versão alvo:

   ```sh
   sh instalador/instalar.sh --versao <X.Y.Z>
   ```

   ```powershell
   .\instalador\instalar.ps1 -Versao <X.Y.Z>
   ```

   Ele preserva `.ia-kit/contrato.yml`, `.ia-kit/taticas/` e `.ia-kit/metricas/`. Todo o resto
   é substituído.
3. **Rode o `k-init`.** Ele detecta `kit_versao` diferente de `.ia-kit/VERSAO`, entra em modo
   atualização, confere o contrato contra o esquema novo, pergunta só o que mudou e
   reconcilia os shims.
4. **Leia o resumo do `k-init`** antes de aceitar: campo novo, campo órfão, campo removido e
   shim podado aparecem lá.
5. **Commite `.ia-kit/` e os shims em um commit só**, separado de mudança de código. O diff
   da atualização é o registro de qual regra mudou — misturado com feature, ninguém revisa.

**Se algo der errado:** `git checkout -- .ia-kit` volta ao estado anterior. É a vantagem de o
núcleo ser commitado.

---

## Para 2.1.0

MINOR no contrato, mas **o fluxo encurtou**: `k-task` e `k-verificar` deixaram de existir
como skills. Nada do comportamento se perdeu — a quebra em tarefas virou passo do `k-plan`,
e a verificação virou o encerramento do `k-execute`.

1. Rode o instalador e depois o `k-init`. Ele **poda os shims órfãos** de `k-task` e
   `k-verificar`, com aviso de qual e por quê.
2. Atalho ou alias para `/k-task`: aponte para `/k-plan`. Para `/k-verificar`: não precisa de
   nada, o `k-execute` faz no encerramento.
3. Revise o resumo do `k-init` antes de aceitar: campo novo, campo órfão e shim podado
   aparecem lá.

**O que muda de verdade depois do `k-init`:**

- A verificação é porta de conclusão. Fluxo com critério sem evidência não sobe.
- Critérios de aceite passam a exigir `CA-n`.
- Em `tipo: bug`, a tarefa 1 precisa provar que o teste discrimina.

**Spec escrita antes da 2.1.0** reprova no `verificar-spec.sh` por falta de `CA-n`. Numere os
critérios na ordem em que já estão, sem reescrever o texto — é edição mecânica, sem
julgamento. Specs com `fluxo: concluido` não precisam de nada: elas não voltam ao fluxo.

**Windows sem Git Bash:** os gates de forma são POSIX sh e não rodam. O `k-init` detecta e
grava `execucao.verificadores: quando_disponivel`; o kit avisa em toda invocação, sem
bloquear. Instale Git Bash e rode `k-init` de novo para subir para `obrigatorio`.

---

## Para 2.0.0

Primeira versão publicada. Não há migração: o v1 não tinha contrato, núcleo versionado nem
shim, então adotar o 2.0.0 é **instalação nova**.

```sh
curl -fsSL https://raw.githubusercontent.com/kevenpacheco/ia-kit/main/instalador/instalar.sh | sh
```

Depois, `k-init`. Ele detecta a stack, valida cada comando executando, entrevista o que
faltou e grava o contrato.

**Vindo do v1, o que sai do repositório:** as skills antigas em `.claude/skills/` que o v1
instalava à mão. O `k-init` gera os shims novos; remova os arquivos do v1 que sobraram, para
não ficar com dois fluxos concorrentes na mesma ferramenta.
