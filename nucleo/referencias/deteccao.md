# Detecção de stack, comandos e validação

As tabelas que o `k-init` usa nos passos 2 a 4. Saíram do fluxo porque são consulta, não
decisão — e porque o arquivo de fluxo tem teto de 150 linhas.

---

## Detectar stack

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

## Propor comandos

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

## Validar executando

Rode cada comando candidato. Regra de leitura do resultado:

| Resultado | Decisão |
|---|---|
| Executou, saiu 0 | válido |
| Executou, saiu diferente de 0 (teste vermelho, lint sujo) | **válido** — o comando existe; o projeto é que está sujo. Reporte, não corrija |
| Comando não encontrado, dependência faltando | inválido — campo fica vazio com o motivo |

Comando quebrado não entra no contrato. Skill que confia em comando inválido falha no meio
do fluxo, que é pior do que campo vazio.

Comando de suite longo: avise o tempo estimado e pergunte antes de rodar.

