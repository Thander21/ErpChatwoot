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

- [x] **Refatoração Geral**: Botões manuais substituídos por `<woot-button>` no módulo Kanban e Modais.
- [x] **Formulários**: Inputs e Botões padronizados usando `WootInput` e `WootButton` nos modais do Kanban (`KanbanCardModal`, `KanbanColumnModal`).
- [x] **UI/UX**: Implementadas abas padrão do Chatwoot e corrigido layout de altura total no Kanban Comercial.
- [ ] **Testes**: Adicionar testes unitários (Vitest) para composables complexos como `useContacts`.
