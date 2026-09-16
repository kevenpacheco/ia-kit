---
data: <AAAA-MM-DD>
nucleo: <versao>
agente: <ferramenta e versao>
modelo: <id>
operador: <quem conduziu>
---

## Resumo

| Tarefa | Resolveu (sem / com) | Rodadas (sem / com) | Intervenções (sem / com) | Minutos (sem / com) |
|---|---|---|---|---|
| 01-... | não / sim | 34 / 21 | 4 / 1 | 18 / 12 |

Medianas: rodadas <n>/<n>, intervenções <n>/<n>.

## Veredito

Contra a rodada anterior (`<arquivo>`), aplicando o critério do protocolo:

- [ ] nenhuma tarefa que resolvia deixou de resolver
- [ ] mediana de intervenções não subiu
- [ ] mediana de rodadas não subiu mais de 10%

**Entra / não entra.**

## Por tarefa

### 01-<slug>

**Sem o kit:** o que aconteceu, onde travou.

**Com o kit:** o que aconteceu, qual etapa ajudou, qual atrapalhou.

**Achados do gate:** quantos, de qual camada, quantos eram reais.

**Observação:** o que surpreendeu. É daqui que sai achado para `docs/achados-v2.md`.

## Custo

O que a ferramenta reportou. Não preencha por estimativa — campo vazio é resultado honesto,
número inventado contamina a comparação seguinte.

## Condições da rodada

O que fugiu do protocolo: repositório em commit diferente, operador distinto, interrupção no
meio. Sem isso, a rodada seguinte compara coisas que não são comparáveis.
