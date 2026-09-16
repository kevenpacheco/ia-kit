# Gate de verificação

Crivo por onde todo diff passa antes de virar commit. Vale para trabalho vindo do fluxo e
para mudança avulsa — inclusive alteração escrita à mão.

Usado por `k-commit` (sempre) e por `k-execute` (que delega ao `k-commit`).

---

## Camadas, na ordem

Ordem é por custo crescente. Falhar barato primeiro evita gastar minutos para descobrir um
erro que o lint pegaria em segundos.

| # | Camada | Comando | Escopo |
|---|---|---|---|
| 1 | lint | `comandos.lint` | arquivos do diff |
| 2 | testes | `comandos.teste_unit` (+ `teste_integracao`, se a camada foi tocada) | arquivos tocados e seus testes |
| 3 | segurança | `comandos.seguranca` | diff |
| 4 | suite completa | `comandos.suite` | repositório — **só no encerramento do fluxo** |

Camadas 1 a 3 rodam em todo commit. A camada 4 não: rodar suite inteira em commit de uma
linha inviabiliza o uso avulso, e o uso avulso é justamente o que não pode ficar sem crivo.

## Escopo por classe de diff

| Classe | 1 lint | 2 testes | 3 segurança |
|---|---|---|---|
| `docs` | formato, se houver | não | não |
| `codigo` | sim | sim | sim |
| `config` | sim | não | sim |

`config` inclui dependência nova e lockfile — é por onde entra vulnerabilidade de terceiro,
então a camada 3 não é opcional aí.

## Segurança roda no diff

Não no repositório inteiro. Varredura completa leva minutos e faz o gate ser desligado;
varredura do diff leva segundos e sobrevive ao uso diário.

Motivo de a camada existir: código gerado por IA compila em praticamente 100% dos casos,
mas cerca de 44% das gerações introduzem uma vulnerabilidade quando não há instrução de
segurança explícita — e essa taxa não melhorou com modelos mais novos. Instrução em prompt
ajuda, mas não é auditável nem reprodutível. Gate é.

Ferramenta isolada erra muito: LLM sozinho varia de 6% a 82% de acurácia em vulnerabilidade
real; SAST sozinho enche a tela de falso positivo. A combinação recomendada é SAST mais
pós-processamento por LLM dos achados, que corta falso positivo de forma expressiva sem
perder o verdadeiro.

### Pós-processamento dos achados

Achado do SAST vai para triagem antes de virar bloqueio:

1. O achado toca linha presente **neste diff**? Não: fora — é dívida preexistente, e o
   commit atual não é o lugar de discutir isso.
2. O caminho é alcançável a partir de entrada não confiável? Justifique com `arquivo:linha`.
3. Sem alcance demonstrável: reporte como informativo, não bloqueie.

Na dúvida sobre alcance, **bloqueie**. Falso positivo custa uma conversa; falso negativo
custa um incidente.

## Sem ferramenta de segurança

`comandos.seguranca` vazio: avise em toda invocação e siga.

```
Aviso: comandos.seguranca vazio desde <data>. A camada 3 não rodou neste commit.
```

Não bloqueie. Fluxo travado por falta de ferramenta vira gate arrancado na semana seguinte.
Aviso persistente mantém a dívida visível sem criar incentivo para contorná-la.

## Leitura do resultado

| Saída | Decisão |
|---|---|
| Tudo verde | commite |
| Camada vermelha | pare, mostre a linha decisiva, não commite |
| Comando não existe | pare, aponte o campo do contrato, não improvise outro comando |

Tentativas: `execucao.tentativas_gate` (padrão 2). Esgotou: pare e devolva para o humano com
o diagnóstico. Não fique tentando variações do mesmo comando.

## Fronteira

O gate **verifica**. Não conserta. Teste vermelho encontrado no gate de um commit de
documentação não é do escopo daquele commit — reporte e siga. Corrigir de carona esconde
trabalho dentro de um commit que diz outra coisa.
