# Suite de referência

Instrumento da regra do D13: **mudança no núcleo só entra se a suite não piorar.** Sem isso,
o kit inteiro é opinião com bibliografia.

---

## O que é

De 5 a 10 tarefas reais, com resultado conhecido, rodadas **com** e **sem** o kit. O que
importa não é o número absoluto — é a diferença entre as duas colunas, e a diferença entre a
versão atual do núcleo e a anterior.

## Composição obrigatória

A suite precisa cobrir onde a IA rende e onde ela não rende. Suite só de greenfield mede o
caso fácil e conclui o que já se sabia.

| Fatia | Quantas | Por quê |
|---|---|---|
| Greenfield simples | 2 | onde o ganho medido é de 30% a 40% |
| Evolução, base viva | 3 | o caso mais comum no dia a dia |
| Legado, alto acoplamento | 3 | onde o ganho cai para perto de zero e às vezes fica negativo |
| Bug com causa raiz não óbvia | 2 | exercita `k-plan`, que é a etapa mais cara do kit |

Toda tarefa precisa de resultado conhecido: alguém já resolveu, e existe um commit ou um PR
que serve de gabarito.

## Onde as tarefas moram

Cada tarefa é um diretório em `baseline/tarefas/`, com o formato de `MODELO.md`. O código-alvo
é um repositório real, referenciado por URL e commit fixo — não copiado para cá. Congelar o
commit é o que mantém a rodada de hoje comparável com a de seis meses atrás.

## Como rodar

1. Fixe o repositório-alvo no commit declarado na tarefa.
2. **Rodada sem o kit:** mesmo agente, mesmo modelo, sem `.ia-kit/`. Prompt igual ao
   `## Pedido` da tarefa.
3. **Rodada com o kit:** `.ia-kit/` instalado e configurado, entrando pela etapa que a tarefa
   indica.
4. Registre em `baseline/resultados/<AAAA-MM-DD>-<versao-do-nucleo>.md`.
5. Descarte a árvore e repita. Nunca rode a segunda condição em cima da primeira.

Quem responde às perguntas do kit é a mesma pessoa, com o mesmo critério, nas duas rodadas.
Entrevistador diferente muda o resultado mais que qualquer mudança no núcleo.

## O que medir

| Métrica | Como |
|---|---|
| Resolveu | o gabarito passa? sim ou não |
| Rodadas de ferramenta | contagem até terminar |
| Arquivos lidos | contagem |
| Intervenções humanas | quantas vezes a pessoa teve que corrigir o rumo |
| Minutos de parede | do início ao commit final |
| Custo | o que a ferramenta reportar; vazio se ela não reportar |
| Achados do gate | quantos e de qual camada |
| Retrabalho | linhas reescritas nos 3 commits seguintes |

Custo vazio é resultado honesto. Preencher com estimativa contamina a comparação seguinte.

## Critério de aceite de uma mudança no núcleo

A mudança entra se:

- nenhuma tarefa que resolvia deixou de resolver, **e**
- a mediana de intervenções humanas não subiu, **e**
- a mediana de rodadas de ferramenta não subiu mais de 10%.

Empate técnico conta como não piorar. Regra que exige melhora em tudo trava o kit.

## Quando rodar

- Antes de fechar uma versão do núcleo.
- Depois de qualquer mudança em `nucleo/fluxo/`.
- Nunca depois de mudança só em `docs/`.

## Estado atual

**Vazia.** Nenhuma tarefa cadastrada, nenhuma rodada executada. O protocolo existe; o
conteúdo depende de escolher os repositórios-alvo e os commits de gabarito.

Enquanto estiver vazia, toda decisão do v2 continua apoiada apenas em evidência externa — o
que está registrado em `docs/arquitetura-v2.md`, e é menos do que o kit exige de si mesmo.
