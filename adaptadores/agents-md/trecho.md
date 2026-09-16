<!-- ia-kit:inicio — bloco gerado pelo k-init. Não edite à mão; edite o núcleo. -->
## ia-kit

Fluxo de desenvolvimento deste projeto. O núcleo vive em `.ia-kit/` e é a fonte de verdade.

| Pedido do usuário | Leia e siga |
|---|---|
| instalar, reconfigurar ou atualizar o kit | `.ia-kit/fluxo/k-init.md` |
| commitar, criar branch, push, PR ou merge | `.ia-kit/fluxo/k-commit.md` |
| tratar comentários de revisor em um PR aberto | `.ia-kit/fluxo/k-revisao.md` |

Regras que valem sempre:

- `.ia-kit/contrato.yml` declara stack, comandos, convenções de git e limites de execução.
  Leia o contrato antes de rodar qualquer comando. Campo vazio = pare e pergunte; não
  adivinhe comando.
- Git que muda estado passa pelo `k-commit`, sempre — inclusive em mudança manual ou
  trabalho fora do fluxo. É lá que o gate roda.
- Não copie regra do núcleo para cá. Este bloco é ponteiro.

<!-- ia-kit:fim -->
