# Métricas do repositório

Os eixos que o código gerado por IA degrada, e como medir cada um com o que já existe no
repositório. Sem coleta, o D13 é intenção.

Frequência sugerida: mensal, ou a cada fechamento de versão do kit. O valor absoluto importa
pouco; a **tendência** é tudo.

---

## Por que estes eixos

Não são escolhidos por gosto. São os que a pesquisa de mercado mostrou piorando desde a
adoção em massa de IA, medidos sobre centenas de milhões de mudanças:

| Eixo | Tendência observada no mercado |
|---|---|
| Duplicação de bloco | +81% desde 2023 |
| Churn de duas semanas | +15% |
| Reuso entre arquivos | −35% |
| Movimentos de refatoração | −70% |
| Latência do primeiro review | 4,6x maior em código de IA |

Se o kit funciona, a tendência local não acompanha a do mercado.

## Como medir

### Duplicação de bloco

Ferramenta de detecção de clone rodando sobre o código de aplicação, com o mesmo limiar entre
rodadas. Registre a porcentagem de linhas duplicadas.

Candidatos agnósticos de stack: `jscpd`, `pmd cpd`, `simian`. Escolha um e não troque — mudar
de ferramenta zera a comparação.

### Churn de duas semanas

Linhas introduzidas e reescritas ou removidas em até 14 dias.

```bash
git log --since='6 months ago' --numstat --format='%H %ad' --date=short
```

Cruze cada linha adicionada com a data em que foi tocada de novo (`git log -L` por arquivo, ou
uma passada de `git blame` por commit). Registre a razão entre linhas com vida curta e total
de linhas adicionadas no período.

### Reuso entre arquivos

Proporção de chamadas a símbolos definidos em outro arquivo, sobre o total de chamadas.
Queda significa código se repetindo em vez de reaproveitar.

Aproximação barata: contar importações por arquivo ao longo do tempo. Grosseiro, mas a
tendência aparece.

### Movimentos de refatoração

Commits em que linhas mudam de lugar sem mudar conteúdo.

```bash
git log --since='6 months ago' --format='%H' | while read c; do
  git show --find-renames --find-copies -M "$c" --numstat
done
```

Registre a proporção de commits com renomeação ou movimentação detectada.

### Latência do primeiro review

Tempo entre abertura do PR e o primeiro comentário humano. Vem da forja
(`referencias/forja.md`), não do git.

Separe PR gerado pelo fluxo dos demais. É a métrica que diz se automatizar push e PR
melhorou ou piorou a fila — e a que manda desligar `shipping.automatico` se piorar.

### Custo por tarefa

O que a ferramenta reportar no fechamento do `k-execute`. Campo vazio quando ela não reporta;
nunca estimativa.

## Onde registrar

`.ia-kit/metricas/<AAAA-MM>.md` no projeto que usa o kit, uma linha por eixo, com a
ferramenta e o limiar usados. Mudou de ferramenta ou de limiar: registre, e trate como início
de série nova.

## O que não medir

Frequência de deploy e lead time perdem significado quando a IA escreve de 30% a 70% do
commit — sobem com volume, não com entrega. Continuam úteis para a organização; não servem
como métrica do kit.

Contagem de linhas ou de commits por pessoa não entra. Mede volume, que é exatamente o que a
IA infla sem mover entrega.
