# k-init — instalar o ia-kit neste projeto

Gera `.ia-kit/contrato.yml` e os shims da ferramenta em uso. Não toca código de aplicação,
não cria branch, não commita.

Esquema completo dos campos: `.ia-kit/referencias/contrato.md`. Leia sob demanda, não de
antemão.

---

## 0. Modo

| Situação | Modo |
|---|---|
| Sem `.ia-kit/contrato.yml` | instalação |
| Contrato existe, `kit_versao` igual | reconfiguração — pergunta o que revisar |
| Contrato existe, `kit_versao` diferente | atualização — diff campo a campo, preserva respostas |

Nunca sobrescrever contrato existente sem mostrar o diff e receber confirmação.

**Conferir contrato contra o esquema** (reconfiguração e atualização): compare com
`.ia-kit/esquema.yml` e reporte, antes de qualquer outra coisa:

- campo obrigatório ausente
- campo presente que o esquema não conhece (órfão)
- campo listado em `removidos` — diga a versão em que saiu e qual é o substituto

Campo órfão e campo ausente só aparecem quando uma etapa falha no meio do trabalho. Conferir
aqui é barato.

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

Para `seguranca`, consulte a tabela de candidatos em `referencias/contrato.md` e verifique se
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

**Raiz de specs:** se já existe `docs/specs/` ou `documentation/specs/`, use e não pergunte.

**Modo padrão** (decide o quanto o agente decide sozinho):

| Modo | Quando | Efeito |
|---|---|---|
| `greenfield` | base nova, poucos consumidores | tarefas maiores, autonomia alta |
| `evolucao` | base viva, em mudança | plano obrigatório, tarefas médias |
| `legado` | base antiga, alto acoplamento | tarefas mínimas, gate cheio, humano decide |

Na dúvida, recomende `evolucao`.

**Segurança ausente:** se nenhuma ferramenta foi detectada, ofereça instalar uma da tabela.
Recusa: grave `seguranca: ""` mais `seguranca_pendente` com a data, e avise que o
`k-execute` vai cobrar em toda invocação.

## 6. Gravar

Escreva `.ia-kit/contrato.yml` na ordem do esquema — ordem estável faz o arquivo servir de
prefixo de cache. Nada de timestamp, hash ou estado de git dentro do contrato.

## 7. Gerar shims

Um shim por ferramenta escolhida, a partir de `adaptadores/<ferramenta>/`. O shim aponta
para o núcleo; ele **nunca** copia regra. Regra duplicada sai de sincronia na primeira
atualização do kit.

## 8. Fechar

```
Contrato: .ia-kit/contrato.yml (kit 2.0.0-alpha.2)
Stack: TypeScript, Next.js    Modo: evolucao    Specs: docs/specs

Comandos validados:
  lint            npm run lint            ok
  teste_unit      npm test                ok (3 testes falhando hoje)
  suite           npm run test:ci         ok
  seguranca       —                       nenhuma ferramenta detectada

Shims gerados: .claude/skills/k-*/SKILL.md
Pendência: comandos.seguranca vazio — o gate 3 vai avisar a cada k-execute.
Próximo passo: revise o contrato e commite.
```

## Nunca

- Inventar comando não observado no projeto.
- Gravar comando sem ter executado.
- Sobrescrever contrato existente sem diff.
- Copiar regra do núcleo para dentro do shim.
- Commitar, criar branch ou alterar código de aplicação.
- Corrigir teste vermelho ou lint sujo encontrado na validação.
