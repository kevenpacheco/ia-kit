# Fatias (trabalho grande)

- Cada fatia atravessa todas as camadas (dados, API, tela, testes) e pode ser demonstrada sozinha; cabe numa sessão; declara `bloqueado por` (dependência real, não preferência de ordem).
- Refatoração preparatória vem primeiro ("deixe a mudança fácil, depois faça a mudança fácil"); refatoração ampla e mecânica segue expandir (nova forma ao lado da velha) → migrar em lotes → contrair (apagar a velha).
- O usuário aprova a divisão.
- O checklist é agrupado por fatia, com IDs contínuos entre fatias.
- Na spec, `## Fatias` lista cada fatia: nome, IDs do checklist que ela entrega, `bloqueado por`.
