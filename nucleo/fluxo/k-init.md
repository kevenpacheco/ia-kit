# k-init — instalar o ia-kit neste projeto

Gera `.ia-kit/contrato.yml` e os shims da ferramenta em uso. Não toca código de aplicação,
não cria branch, não commita.

Campos: `referencias/contrato.md`. Versão, atualização e poda de shim:
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

**Conferir contrato contra o esquema** (reconfiguração e atualização): compare com
`.ia-kit/esquema.yml` e reporte, antes de qualquer outra coisa:

- campo obrigatório ausente
- campo presente que o esquema não conhece (órfão)
- campo listado em `removidos` — diga a versão em que saiu e qual é o substituto

Campo órfão e ausente só aparecem quando uma etapa falha no meio do trabalho — conferir aqui
é barato.

## 1. Detectar ferramenta

Procure: `.claude/` → `claude-code`. `AGENTS.md` → `agents-md`. `.cursor/` → `cursor`.
Nenhuma encontrada, ou mais de uma: pergunte quais shims gerar.

**Conferir a configuração da ferramenta contra o contrato.** Padrão da ferramenta que
contradiz o contrato precisa aparecer aqui, não num commit revisado depois. O caso conhecido:
`commit.atribuicao_ia: false` enquanto a ferramenta anexa rodapé de IA por padrão. Avise e
diga onde desligar.

**Detectar a forja** pela URL do remoto, e confirmar que o CLI correspondente existe e
responde (`referencias/forja.md`). Sem CLI: grave a forja e marque o modo manual.

## 2. Detectar stack

Arquivo-marcador na raiz define a stack e onde procurar comando:

| Marcador | Stack | Fonte de comandos |
|---|---|---|
| `package.json` | JS/TS | campo `scripts` |
| `pyproject.toml` | Python | `[tool.poetry.scripts]`, `[tool.pdm.scripts]`, tox |
| `go.mod` | Go | convenção `go test ./...`, `go vet ./...` |
| `composer.json` | PHP | campo `scripts` |
| `Gemfile` | Ruby | `Rakefile` |
| `*.csproj`, `*.sln` | .NET | convenção `dotnet test`, `dotnet format` |
| `Makefile` | qualquer | alvos do arquivo |

Mais de um marcador: monorepo. Pergunte qual raiz o kit governa antes de seguir.

## 3. Propor comandos

Monte candidatos para `lint`, `formato`, `teste_unit`, `teste_integracao`, `suite` a partir
da fonte detectada. Não invente comando que não aparece em script, alvo ou convenção da
stack.

Para `seguranca`, consulte a tabela de candidatos em `referencias/gate.md` e verifique se
a ferramenta está instalada.

Para `seguranca_diff`, teste se a ferramenta detectada sabe operar de forma incremental,
usando os modelos de `referencias/gate.md`. Rode o modelo contra um diff real do repositório.
Não funcionou de forma confiável: deixe o campo vazio — o gate cai para varredura completa e
avisa o custo. Prometer incremental que não existe faz o gate demorar minutos e ser
desligado na primeira semana.

## 4. Validar executando

Rode cada comando candidato. Regra de leitura do resultado:

| Resultado | Decisão |
|---|---|
| Executou, saiu 0 | válido |
| Executou, saiu diferente de 0 (teste vermelho, lint sujo) | **válido** — o comando existe; o projeto é que está sujo. Reporte, não corrija |
| Comando não encontrado, dependência faltando | inválido — campo fica vazio com o motivo |

Comando quebrado não entra no contrato. Skill que confia em comando inválido falha no meio
do fluxo, que é pior do que campo vazio.

Comando de suite longo: avise o tempo estimado e pergunte antes de rodar.

## 5. Entrevistar o que faltou

Uma pergunta por vez. Sempre com recomendação e o trade-off escrito. Só pergunte o que a
detecção não resolveu.

Ordem: raiz de specs → branch principal e protegidas → modo padrão de execução →
encadeamento → limites de tarefa → modelos forte e barato.

Recomendação e trade-off de cada um desses campos: `referencias/entrevista.md`, seção
`k-init`. Leia antes da primeira pergunta.

## 6. Gravar

Escreva `.ia-kit/contrato.yml` na ordem do esquema — ordem estável faz o arquivo servir de
prefixo de cache. Nada de timestamp, hash ou estado de git dentro do contrato.

`kit_versao` vem de `.ia-kit/VERSAO`, nunca de memória. `kit_origem` é a URL do repositório
de onde o núcleo veio; recomende `https://github.com/kevenpacheco/ia-kit` e só pergunte se o
projeto usa espelho interno. Sem `kit_origem`, ninguém sabe de onde atualizar.

## 7. Reconciliar shims

Um shim por ferramenta do contrato, a partir de `adaptadores/<ferramenta>/`. O shim aponta
para o núcleo; ele **nunca** copia regra. Regra duplicada sai de sincronia na primeira
atualização do kit.

**Podar o órfão:** shim sem `fluxo/k-*.md` correspondente é removido, com aviso de qual e
por quê — fluxo removido deixa comando morto apontando para arquivo inexistente. Poda só o
que o kit gera. Os três casos em `referencias/instalacao.md`.

## 8. Fechar

```
Contrato: .ia-kit/contrato.yml (kit 2.0.0)
Stack: TypeScript, Next.js    Modo: evolucao    Specs: docs/specs

Comandos validados:
  lint            npm run lint            ok
  teste_unit      npm test                ok (3 testes falhando hoje)
  suite           npm run test:ci         ok
  seguranca       —                       nenhuma ferramenta detectada

Shims: .claude/skills/k-*/SKILL.md (8 gravados, 0 podados)
Pendência: comandos.seguranca vazio — o gate 3 vai avisar a cada k-execute.
Próximo passo: revise o contrato e commite.
```

## Nunca

- Inventar comando não observado no projeto.
- Gravar comando sem ter executado.
- Sobrescrever contrato existente sem diff.
- Copiar regra do núcleo para dentro do shim.
- Deixar shim órfão apontando para fluxo que não existe mais.
- Commitar, criar branch ou alterar código de aplicação.
- Corrigir teste vermelho ou lint sujo encontrado na validação.
