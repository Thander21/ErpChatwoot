# Relatório de Frontend (Vue.js & Tailwind)

**Status:** 🟢 Moderno e Padronizado (Pós-Refatoração)
**Data da Última Atualização:** 06/Fevereiro/2026

## 1. Design System & CSS

- ✅ **Tokens**: O projeto usa corretamente os tokens `n-brand`, `n-slate-12`, mantendo consistência com o tema.
- ✅ **Tailwind**: Uso de classes utilitárias está limpo e segue o padrão do projeto.

## 2. Componentes e Reuso

- **WootButton**: Implementado em `ContactsList.vue`. Substituiu HTML manual duplicado.
- **WootInput**: Deve ser adotado para formulários futuros.

### 🚨 Biblioteca Oculta

Não recrie componentes. Use a biblioteca `components-next`:
| Componente | Caminho |
| :--- | :--- |
| Button | `dashboard/components-next/button/Button.vue` |
| Input | `dashboard/components-next/input/Input.vue` |
| Spinner | `dashboard/components-next/spinner/Spinner.vue` |

## 3. Backlog Técnico (Frontend)

- [ ] **Refatoração Geral**: Varrer outros módulos (além de Kanban/Contatos) para substituir botões HTML manuais por `<woot-button>`.
- [ ] **Formulários**: Padronizar inputs usando o componente oficial.
- [ ] **Testes**: Adicionar testes unitários (Vitest) para composables complexos como `useContacts`.
