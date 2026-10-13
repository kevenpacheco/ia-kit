# k-init — instalar o ia-kit neste projeto

Gera `.ia-kit/contrato.yml` e os shims da ferramenta em uso. Não toca código de aplicação,
não cria branch, não commita.

Campos: `referencias/contrato.md`. Detecção de stack: `referencias/deteccao.md`.
Versão, atualização e poda de shim:
`referencias/instalacao.md`. Leia sob demanda, não de antemão.

---

## 0. Modo

Compare `kit_versao` do contrato com `.ia-kit/VERSAO` — a versão do núcleo instalado.

| Situação | Modo |
|---|---|
| Sem `.ia-kit/contrato.yml` | instalação |
| `kit_versao` igual ao `VERSAO` | reconfiguração — pergunta o que revisar |
| `kit_versao` diferente do `VERSAO` | atualização — diff campo a campo, preserva respostas |

Nunca sobrescrever contrato existente sem mostrar o diff e receber confirmação.

Na atualização, diga o que a diferença de versão promete antes de mexer em campo: leia a
tabela de semver em `referencias/instalacao.md` e o `CHANGELOG.md` do kit, se acessível.

**Conferir contrato contra o esquema** (reconfiguração e atualização), antes de qualquer
outra coisa: `sh .ia-kit/scripts/verificar-contrato.sh`. Exit 0 segue; 1 lista campo
ausente, órfão e removido, e você corrige com o usuário; 3 é contrato fora do subconjunto
YAML do kit. O que cada código significa, e o que o script **não** confere:
`referencias/verificadores.md`.

## 1. Detectar ferramenta

Procure: `.claude/` → `claude-code`. `AGENTS.md` → `agents-md`. `.cursor/` → `cursor`.
Nenhuma encontrada, ou mais de uma: pergunte quais shims gerar.

**Conferir a configuração da ferramenta contra o contrato.** Padrão da ferramenta que
contradiz o contrato precisa aparecer aqui, não num commit revisado depois. O caso conhecido:
`commit.atribuicao_ia: false` enquanto a ferramenta anexa rodapé de IA por padrão. Avise e
diga onde desligar.

**Detectar a forja** pela URL do remoto, e confirmar que o CLI correspondente existe e
responde (`referencias/forja.md`). Sem CLI: grave a forja e marque o modo manual.

**Detectar `sh`.** Os gates de forma são POSIX sh. Ausente do PATH (Windows sem Git Bash):
grave `execucao.verificadores: quando_disponivel` e diga que o gate vai avisar sem rodar.
Presente: recomende `obrigatorio`.

## 2. Detectar stack e propor comandos

Arquivo-marcador na raiz define a stack e onde procurar comando. Tabela de marcadores, fontes
de comando por stack e a regra do monorepo: `referencias/deteccao.md`.

Não invente comando que não aparece em script, alvo ou convenção da stack. Para `seguranca` e
`seguranca_diff`, os candidatos e os modelos incrementais estão em `referencias/gate.md`;
teste o incremental contra um diff real antes de gravar.

## 3. Validar executando

Rode cada candidato. Comando que executa e sai diferente de zero é **válido** — o comando
existe, o projeto é que está sujo; reporte sem corrigir. Comando não encontrado é inválido e
o campo fica vazio com o motivo.

Comando quebrado não entra no contrato: skill que confia nele falha no meio do fluxo, o que é
pior que campo vazio. Suite longa: avise o tempo estimado e pergunte antes de rodar.

## 4. Entrevistar o que faltou

Uma pergunta por vez. Sempre com recomendação e o trade-off escrito. Só pergunte o que a
detecção não resolveu.

Ordem: raiz de specs → branch principal e protegidas → modo padrão →
encadeamento → limites de tarefa → verificação → modelos.

Recomendação e trade-off de cada um desses campos: `referencias/entrevista.md`, seção
`k-init`. Leia antes da primeira pergunta.

## 5. Gravar

Escreva `.ia-kit/contrato.yml` na ordem do esquema — ordem estável faz o arquivo servir de
prefixo de cache. Nada de timestamp, hash ou estado de git dentro do contrato.

`kit_versao` vem de `.ia-kit/VERSAO`, nunca de memória. `kit_origem` é a URL do repositório
de onde o núcleo veio; recomende `https://github.com/kevenpacheco/ia-kit` e só pergunte se o
projeto usa espelho interno. Sem `kit_origem`, ninguém sabe de onde atualizar.

## 6. Reconciliar shims

Um shim por ferramenta do contrato, a partir de `adaptadores/<ferramenta>/`. O shim aponta
para o núcleo; ele **nunca** copia regra. Regra duplicada sai de sincronia na primeira
atualização do kit.

**Podar o órfão:** shim sem `fluxo/k-*.md` correspondente é removido, com aviso de qual e
por quê — fluxo removido deixa comando morto apontando para arquivo inexistente. Poda só o
que o kit gera. Os três casos em `referencias/instalacao.md`.

## 7. Fechar

```
Contrato: .ia-kit/contrato.yml (kit 2.1.0)   verificar-contrato.sh: ok
Stack: TypeScript, Next.js    Modo: evolucao    Specs: docs/specs

Comandos validados:
  lint            npm run lint            ok
  teste_unit      npm test                ok (3 testes falhando hoje)
  suite           npm run test:ci         ok
  seguranca       -                       nenhuma ferramenta detectada

Shims: .claude/skills/k-*/SKILL.md (9 gravados, 0 podados)
Pendencia: comandos.seguranca vazio - o gate 3 vai avisar a cada k-execute.
Proximo passo: revise o contrato e commite.
```

## Nunca

- Inventar comando não observado no projeto.
- Gravar comando sem ter executado.
- Sobrescrever contrato existente sem diff.
- Gravar contrato sem o `verificar-contrato.sh` sair 0.
- Copiar regra do núcleo para dentro do shim.
- Deixar shim órfão apontando para fluxo que não existe mais.
- Commitar, criar branch ou alterar código de aplicação.
- Corrigir teste vermelho ou lint sujo encontrado na validação.
