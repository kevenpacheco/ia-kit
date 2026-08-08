# k-spec — como usar

Etapa 1 de 4: **k-spec** → `k-plan` → `k-task` → `k-execute`.

## Invocacao

```
/k-spec erro 500 ao salvar banner sem imagem
/k-spec permitir que o parceiro edite a bolsa depois de publicada
/k-spec
```

Sem argumento, a skill pergunta o que voce quer fazer.

## O que ela faz

1. Vai para `main` e da `pull` — o discovery roda sobre o codigo atual.
2. Define **titulo** e **tipo** (`feature`, `bug`, `refactor`, `chore`, `docs`). Se o tipo nao for obvio, ela pergunta.
3. Le a documentacao e o codigo do fluxo antes de perguntar qualquer coisa.
4. Entrevista voce **uma pergunta por vez**, sempre com recomendacao e trade-off escrito.
5. Em tipo `bug`, prova que o bug existe e tenta reproduzir.
6. Escreve `spec.md` na pasta de specs do fluxo (`docs/specs/<AAAAMMDD-HHMMSS>-<slug>/` ou `documentation/specs/...`, conforme detectado).

## O que ela nao faz

- Nao cria branch e nao commita nada. O `spec.md` fica untracked ate o `k-plan`.
- Nao propoe solucao tecnica, nem diz onde mexer. Isso e `k-plan`.
- Nao cria issue no GitHub. O `spec.md` e o artefato.

## Regra de localizacao

| Tipo | Pode citar `arquivo:linha`? |
|---|---|
| `bug` | Sim, so para localizar o sintoma |
| Os outros | Nao |

## Se voce nao tem um pedido, e sim um alvo

Para procurar bugs em um diretorio, modulo ou no diff da branch, comece por `/k-scan`.

## Saida

```
Spec criada: docs/specs/20260807-143205-corrigir-crop-banner/spec.md
Tipo: bug
Proximo passo: /k-plan
```
