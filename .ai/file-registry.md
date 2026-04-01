# 📋 File Registry - ErpChatwoot

## 🎯 Propósito
Este arquivo é o **Mapa de Intercepção** do projeto. Ele correlaciona arquivos do core (`chatwoot-base`) com suas customizações em `MenuPdvDmais/`.

> [!IMPORTANT]
> **DIRETRIZ PARA IA**: Antes de modificar qualquer arquivo, verifique se ele consta neste registro. Se for um arquivo do core não registrado, siga o [Workflow de Patch](file:///home/thander/Projetos/ErpChatwoot/.ai/rules/refactoring-executor.md) e adicione-o aqui.

---

## 🔧 Core Patches (Arquivos Sobrescritos)
Estes arquivos são cópias modificadas do core. **Sempre edite a versão em MenuPdvDmais/**.

| Origem (chatwoot-base/) | Path do Patch (MenuPdvDmais/core-patches/) | Propósito da Modificação |
| :--- | :--- | :--- |
| `app/javascript/dashboard/components/layout/Sidebar.vue` | `app/javascript/dashboard/components/layout/Sidebar.vue` | Injeção de menus: Kanban, Financeiro, Contatos. |
| `app/javascript/dashboard/routes/dashboard/dashboard.routes.js` | `app/javascript/dashboard/routes/dashboard/dashboard.routes.js` | Merge de `routeExtensions` Enterprise. |
| `config/routes.rb` | `config/routes.rb` | Namespace `enterprise` e rotas de API customizadas. |
| `app/javascript/dashboard/i18n/locale/en/settings.json` | `settings.json` | Customização de labels da interface, como `GESTAO_CONTATOS`. |
| `docker/entrypoints/rails.sh` | `docker/entrypoints/rails.sh` | Customização do entrypoint do Rails para injetar lógica ou ignorar migrações específicas. |

---

## ✨ Enterprise Originals (Módulos Novos)
Arquivos 100% proprietários, organizados por domínio.

### 📋 Módulo: Kanban
- **Página**: `MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/kanban/Index.vue`
- **Componentes**:
  - `KanbanBoard.vue`, `KanbanColumn.vue`, `KanbanCard.vue`, `KanbanComercial.vue`, `KanbanTarefa.vue`, `ArchivedReport.vue`
- **Modais**: `KanbanColumnModal.vue`, `KanbanCardModal.vue`
- **Backend**:
  - Models: `kanban_column.rb`, `kanban_card.rb`
  - Controllers: `kanban_columns_controller.rb`, `kanban_cards_controller.rb`

### 🏢 Módulo: Gestão de Contatos
- **Página**: `MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/Index.vue`
- **Componentes**:
  - `ContactsHeader.vue`, `ContactsFilterBar.vue`, `ContactsList.vue`, `ContactItem.vue`, `ContactsStats.vue`
- **Modais**: `ContactFormModal.vue`, `BulkEditModal.vue`, `BulkDeleteModal.vue`

### 💰 Módulo: Financeiro
- **Página**: `MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/boletos/Index.vue`
- **Propósito**: Renderização de Iframe para sistemas financeiros externos.

### 🔌 Core Extensions (Composables/API)
- **Composables**: `useEnterpriseSidebar.js`, `useKanban.js`, `useContacts.js`
- **API Clients**: `kanbanColumns.js`, `kanbanCards.js`, `customContacts.js`
- **Routes**: `initializeRoutes.js`, `routeExtensions.js`

---

## 💾 Database Migrations (MenuPdvDmais/db/migrate/)

| Timestamp / Nome | Objetivo |
| :--- | :--- |
| `20260203100000_create_kanban_columns.rb` | Estrutura de colunas do Kanban. |
| `20260203110000_create_kanban_cards.rb` | Estrutura de cards (vinculados a conversas). |
| `20260204022600_add_fields_to_kanban_cards.rb` | Campos extras: empresa, nome do contato. |
| `20260207022000_add_prio_due_date_to_kanban_cards.rb` | Prioridade e data de vencimento. |
| `20260209211000_add_archive_fields_to_kanban_cards.rb` | Arquivamento: metadata e responsável. |
| `20231211010807_add_cached_labels_list.rb` | Cache de labels para performance. |

---

## 📊 Estatísticas Rápidas
- **Patches**: 3
- **Componentes Vue**: ~25
- **Backend (Models/Controllers/Migrations)**: 12
- **TOTAL**: ~46 arquivos customizados.

---
**Última Atualização**: 2026-03-17 | **Status**: Sincronizado com Regras de IA
t/Dockerfile)

---

**Última atualização**: 2026-02-12  
**Versão Chatwoot Base**: [verificar em chatwoot-base]  
**Mantido por**: Equipe ErpChatwoot
