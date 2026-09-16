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
