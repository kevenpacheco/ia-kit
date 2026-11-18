# CODING_STANDARDS.md

> Modelo do ia-kit. Copie para a raiz do projeto como `CODING_STANDARDS.md`. É lido pelo `/k-review` (revisor de arquitetura), não carregado em toda sessão. Aqui vão só padrões de julgamento que lint e formatador não forçam; o `/k-retro` acrescenta o que os reviews reais encontrarem.

## Arquitetura
* Separe lógica de domínio, casos de uso e infraestrutura; dependências apontam para o domínio.

## Erros
* Trate exceções explicitamente e registre logs contextuais sem expor dados sensíveis.

## Testes
* Toda funcionalidade ou alteração vem com teste unitário ou de integração, escrito nos pontos de teste da spec.

## Padrões do projeto
<!-- Acrescente aqui, uma linha por padrão. -->
