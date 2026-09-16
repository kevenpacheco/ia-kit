# Instalação, versão e atualização do kit

Como o núcleo chega num projeto, como ele é atualizado, e o que cada dígito da versão
promete. O `k-init` é quem aplica isto; este arquivo é a regra.

---

## 1. O núcleo é vendorizado

`.ia-kit/` é **cópia commitada** no repositório do projeto. Não é submodule, não é symlink,
não é dependência de gerenciador de pacote.

**Motivo:** o agente precisa ler os arquivos. Submodule some em clone raso e em worktree;
pacote de linguagem amarraria um kit agnóstico a um ecossistema; arquivo fora do repo não
existe no CI. Cópia commitada também faz `git log .ia-kit/` mostrar exatamente quando o
projeto mudou de versão do kit, e faz a atualização aparecer no diff do PR — quem revisa vê
qual regra mudou.

## 2. O que é do kit e o que é do projeto

| Caminho | Dono | Na atualização |
|---|---|---|
| `.ia-kit/fluxo/`, `.ia-kit/referencias/`, `.ia-kit/esquema.yml`, `.ia-kit/VERSAO` | kit | **substituído inteiro** |
| `.ia-kit/contrato.yml` | projeto | preservado |
| `.ia-kit/taticas/` | projeto | preservado |
| `.ia-kit/metricas/` | projeto | preservado |

Arquivo do kit editado à mão é fork silencioso: some na próxima atualização, sem aviso.
Precisa mudar regra? Muda no repositório do kit. Precisa de regra só deste projeto? Vai para
`.ia-kit/taticas/`, que o instalador não toca.

Medição acumulada (`metricas.md`) também é do projeto: perder série histórica numa
atualização de kit apagaria justamente o dado que decide se o kit funciona.

## 3. Versão semântica — o que cada dígito promete

Fonte única: `.ia-kit/VERSAO`. O contrato grava em `kit_versao` a versão que o gerou.

| Bump | Gatilho | Efeito no projeto |
|---|---|---|
| MAJOR | campo obrigatório novo, campo renomeado ou removido, fluxo removido ou renomeado, formato de shim mudou | `k-init` em modo atualização é **obrigatório** antes do próximo fluxo |
| MINOR | campo opcional novo, fluxo novo, referência nova, valor novo em enum | `k-init` recomendado |
| PATCH | prosa, exemplo, tabela corrigida — nenhuma mudança de contrato | copiar e seguir |

**Versão é sempre `X.Y.Z`, sem sufixo.** Nada de `-alpha.N` ou `-rc.N`. Sufixo obriga toda
ferramenta que lê a versão a tratar dois formatos, e a regra "aqui nada é prometido" só adia
a decisão de prometer. O que não está pronto não vira release; o que vira release segue a
tabela acima.

**Como saber sem ler o diff:** `CHANGELOG.md` do kit tem uma seção por versão, com `Quebra`,
`Adiciona` e `Corrige`. `docs/migracao.md` tem um bloco por MAJOR, passo a passo.

## 4. Instalar e atualizar

Mesmo comando nos dois casos. O instalador não entrevista, não gera shim e não commita — ele
só troca arquivo. A inteligência fica no `k-init`.

```sh
curl -fsSL https://raw.githubusercontent.com/kevenpacheco/ia-kit/main/instalador/instalar.sh | sh
```

```powershell
irm https://raw.githubusercontent.com/kevenpacheco/ia-kit/main/instalador/instalar.ps1 | iex
```

Versão fixa em vez da última: `--versao 2.0.0` (sh) ou `-Versao 2.0.0` (ps1).
Baixando o script antes de rodar, os mesmos argumentos valem.

O que ele faz, em ordem: resolve a versão alvo, baixa o pacote daquela tag, confere que o
pacote tem `nucleo/VERSAO`, guarda o que é do projeto, substitui `.ia-kit/`, devolve o que
guardou, imprime a versão anterior e a nova.

**Depois do instalador, sempre `k-init`.** Foi o instalador que trocou os arquivos; é o
`k-init` que reconcilia o contrato com o esquema novo e regenera os shims.

Sem rede, ou com o repositório do kit espelhado internamente: clone o kit e copie
`nucleo/` para `.ia-kit/` à mão, preservando os dois caminhos da tabela da seção 2. O
instalador não é obrigatório — é conveniência.

## 5. De onde atualizar: `kit_origem`

O contrato grava a URL do repositório do kit. Sem ela, cada projeto depende de alguém lembrar
o endereço, e fork interno de empresa fica impossível de atualizar.

```yaml
kit_versao: 2.0.0
kit_origem: https://github.com/kevenpacheco/ia-kit
```

**Não grave commit sha, timestamp nem estado de git no contrato.** O contrato é prefixo de
cache (D4); conteúdo volátil ali invalida o cache a cada invocação. A tag em `kit_versao`
basta para reproduzir.

## 6. Shims: gerar e podar

Shim é ponteiro para o núcleo, nunca cópia de regra. Na atualização ele precisa ser
reconciliado nos dois sentidos:

| Situação | Ação |
|---|---|
| Fluxo existe, shim existe | regravar o shim a partir de `adaptadores/<ferramenta>/` |
| Fluxo existe, shim não existe | gerar |
| **Shim existe, fluxo não existe** | **remover, avisando qual e por quê** |

O terceiro caso é o que quebra em silêncio: fluxo removido numa versão nova deixa um shim
apontando para arquivo inexistente, e a ferramenta continua oferecendo o comando morto.

Correspondência: `.claude/skills/k-<nome>/SKILL.md` ↔ `.ia-kit/fluxo/k-<nome>.md`. No
`AGENTS.md` e no Cursor, o bloco é único e delimitado — regravar o bloco inteiro já poda a
linha do fluxo removido.

Shim de ferramenta que não está em `ferramentas` no contrato **não** é podado. Pode ser de
outra ferramenta ou de outro kit; o `k-init` só mexe no que ele gerou.

## 7. Nunca

- Editar arquivo do núcleo dentro do projeto. Some na atualização.
- Copiar regra do núcleo para dentro do shim.
- Atualizar `.ia-kit/` sem rodar o `k-init` em seguida.
- Gravar sha, data ou branch dentro do contrato.
- Deixar a versão do núcleo em dois lugares.
