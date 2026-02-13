# 📋 File Registry - ErpChatwoot

## 🎯 Propósito

Este arquivo documenta **TODOS** os arquivos customizados do ErpChatwoot, separando:

- 🔧 **Core Patches**: Arquivos copiados do `chatwoot-base` e modificados
- ✨ **Enterprise Originals**: Arquivos novos criados exclusivamente para o ErpChatwoot
- 💾 **Database Migrations**: Migrações de banco de dados customizadas

**Uso crítico**: Durante atualizações do upstream (`chatwoot-base`), este registro serve como checklist para validar se patches precisam ser atualizados.

---

## 🔧 Core Patches (Arquivos Modificados do Chatwoot Base)

Estes arquivos **SOBRESCREVEM** arquivos originais do `chatwoot-base`. Durante updates do upstream, **cada um deles DEVE ser revisado**.

### Frontend (Vue.js/JavaScript)

#### 1. [`MenuPdvDmais/core-patches/Sidebar.vue`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/core-patches/Sidebar.vue)

- **Arquivo original**: `chatwoot-base/app/javascript/dashboard/components/layout/Sidebar.vue`
- **Modificações**:
  - Adicionados 3 novos menus enterprise (Kanban, Financeiro, Gestão de Contatos)
  - Integração com `useEnterpriseSidebar` composable
- **Validação necessária no update**:
  - Verificar se estrutura do sidebar mudou
  - Verificar se há novos menus conflitantes
  - Re-aplicar adições de menus enterprise

#### 2. [`MenuPdvDmais/core-patches/dashboard.routes.js`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/core-patches/dashboard.routes.js)

- **Arquivo original**: `chatwoot-base/app/javascript/dashboard/routes/dashboard/dashboard.routes.js`
- **Modificações**:
  - Importação de rotas enterprise (`routeExtensions`)
  - Merge de rotas customizadas com rotas base
- **Validação necessária no update**:
  - Verificar se estrutura de rotas mudou
  - Verificar conflitos de nome de rotas
  - Re-aplicar merge de rotas enterprise

### Backend (Ruby on Rails)

#### 3. [`MenuPdvDmais/core-patches/config/routes.rb`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/core-patches/config/routes.rb)

- **Arquivo original**: `chatwoot-base/config/routes.rb`
- **Modificações**:
  - Adicionado namespace `enterprise` com rotas API
  - Rotas para Kanban Columns e Cards
  - Rotas para Gestão de Contatos
- **Validação necessária no update**:
  - Verificar se estrutura principal de rotas mudou
  - Verificar conflitos de namespace
  - Re-aplicar rotas enterprise

---

## ✨ Enterprise Originals (Arquivos Novos)

Estes arquivos são **100% originais** do ErpChatwoot. Não existem no `chatwoot-base`. Durante updates, geralmente **não precisam de modificação**, mas devem ser testados para garantir compatibilidade.

### 🎨 Frontend Enterprise

#### Composables & Utilities

1. [`MenuPdvDmais/enterprise/app/javascript/dashboard/composables/useEnterpriseSidebar.js`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/app/javascript/dashboard/composables/useEnterpriseSidebar.js)
   - Composable para gerenciar menus enterprise no sidebar
2. [`MenuPdvDmais/enterprise/app/javascript/dashboard/routes/initializeRoutes.js`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/app/javascript/dashboard/routes/initializeRoutes.js)
   - Inicializador de rotas enterprise

3. [`MenuPdvDmais/enterprise/app/javascript/dashboard/routes/routeExtensions.js`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/app/javascript/dashboard/routes/routeExtensions.js)
   - Extensões de rotas (merge com rotas base)

#### API Clients

4. [`MenuPdvDmais/enterprise/app/javascript/dashboard/api/kanbanColumns.js`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/app/javascript/dashboard/api/kanbanColumns.js)
   - Client API para Kanban Columns

5. [`MenuPdvDmais/enterprise/app/javascript/dashboard/api/kanbanCards.js`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/app/javascript/dashboard/api/kanbanCards.js)
   - Client API para Kanban Cards

6. [`MenuPdvDmais/enterprise/app/javascript/dashboard/api/customContacts.js`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/app/javascript/dashboard/api/customContacts.js)
   - Client API para Gestão de Contatos

---

### 📋 Módulo: Kanban

#### Rotas

7. [`MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/kanban/kanban.routes.js`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/kanban/kanban.routes.js)

#### Composables

8. [`MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/kanban/composables/useKanban.js`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/kanban/composables/useKanban.js)

#### Páginas

9. [`MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/kanban/Index.vue`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/kanban/Index.vue)

#### Componentes

10. [`MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/kanban/components/KanbanBoard.vue`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/kanban/components/KanbanBoard.vue)
11. [`MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/kanban/components/KanbanColumn.vue`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/kanban/components/KanbanColumn.vue)
12. [`MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/kanban/components/KanbanCard.vue`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/kanban/components/KanbanCard.vue)
13. [`MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/kanban/components/KanbanComercial.vue`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/kanban/components/KanbanComercial.vue)
14. [`MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/kanban/components/KanbanTarefa.vue`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/kanban/components/KanbanTarefa.vue)
15. [`MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/kanban/components/ArchivedReport.vue`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/kanban/components/ArchivedReport.vue)

#### Modais

16. [`MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/kanban/components/modais/KanbanColumnModal.vue`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/kanban/components/modais/KanbanColumnModal.vue)
17. [`MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/kanban/components/modais/KanbanCardModal.vue`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/kanban/components/modais/KanbanCardModal.vue)

---

### 🏢 Módulo: Gestão de Contatos

#### Rotas

18. [`MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/gestao-contatos.routes.js`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/gestao-contatos.routes.js)

#### Composables

19. [`MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/composables/useContacts.js`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/composables/useContacts.js)

#### Páginas

20. [`MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/Index.vue`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/Index.vue)

#### Componentes

21. [`MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ContactsHeader.vue`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ContactsHeader.vue)
22. [`MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ContactsFilterBar.vue`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ContactsFilterBar.vue)
23. [`MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ContactsList.vue`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ContactsList.vue)
24. [`MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ContactItem.vue`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ContactItem.vue)
25. [`MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ContactsStats.vue`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ContactsStats.vue)

#### Modais

26. [`MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/modais/ContactFormModal.vue`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/modais/ContactFormModal.vue)
27. [`MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/modais/BulkEditModal.vue`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/modais/BulkEditModal.vue)
28. [`MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/modais/BulkDeleteModal.vue`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/modais/BulkDeleteModal.vue)

---

### 💰 Módulo: Financeiro (Boletos)

#### Rotas

29. [`MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/boletos/boletos.routes.js`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/boletos/boletos.routes.js)

#### Páginas

30. [`MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/boletos/Index.vue`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/boletos/Index.vue)

---

### 🔧 Backend Enterprise (Ruby on Rails)

#### Models

31. [`MenuPdvDmais/enterprise/app/models/kanban_column.rb`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/app/models/kanban_column.rb)
    - Model para colunas do Kanban
32. [`MenuPdvDmais/enterprise/app/models/kanban_card.rb`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/app/models/kanban_card.rb)
    - Model para cards do Kanban

#### Controllers

33. [`MenuPdvDmais/enterprise/app/controllers/enterprise/api/v1/kanban_columns_controller.rb`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/app/controllers/enterprise/api/v1/kanban_columns_controller.rb)
    - API controller para colunas do Kanban
34. [`MenuPdvDmais/enterprise/app/controllers/enterprise/api/v1/kanban_cards_controller.rb`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/app/controllers/enterprise/api/v1/kanban_cards_controller.rb)
    - API controller para cards do Kanban
35. [`MenuPdvDmais/enterprise/app/controllers/enterprise/api/v1/accounts_controller.rb`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/app/controllers/enterprise/api/v1/accounts_controller.rb)
    - Controller para dados de conta

#### Routes

36. [`MenuPdvDmais/enterprise/config/routes.rb`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/config/routes.rb)
    - Rotas enterprise (carregadas pelo patch principal)

#### Helpers

37. [`MenuPdvDmais/enterprise/app/helpers/enterprise_helper.rb`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/enterprise/app/helpers/enterprise_helper.rb)
    - Helpers para funcionalidades enterprise

---

## 💾 Database Migrations (Customizadas)

Migrações de banco de dados adicionadas pelo ErpChatwoot. Durante updates do upstream, **verificar se há conflitos de nome ou coluna**.

### Kanban Migrations

1. [`MenuPdvDmais/db/migrate/20260203100000_create_kanban_columns.rb`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/db/migrate/20260203100000_create_kanban_columns.rb)
   - **Data**: 2026-02-03
   - **Propósito**: Criar tabela `kanban_columns`
   - **Campos**: name, account_id, position, kanban_type, timestamps

2. [`MenuPdvDmais/db/migrate/20260203110000_create_kanban_cards.rb`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/db/migrate/20260203110000_create_kanban_cards.rb)
   - **Data**: 2026-02-03
   - **Propósito**: Criar tabela `kanban_cards`
   - **Campos**: title, description, kanban_column_id, conversation_id, contact_id, position, timestamps

3. [`MenuPdvDmais/db/migrate/20260204022600_add_fields_to_kanban_cards.rb`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/db/migrate/20260204022600_add_fields_to_kanban_cards.rb)
   - **Data**: 2026-02-04
   - **Propósito**: Adicionar campos extras em `kanban_cards`
   - **Campos adicionados**: company_name, contact_name, etc.

4. [`MenuPdvDmais/db/migrate/20260207022000_add_priority_and_due_date_to_kanban_cards.rb`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/db/migrate/20260207022000_add_priority_and_due_date_to_kanban_cards.rb)
   - **Data**: 2026-02-07
   - **Propósito**: Adicionar prioridade e data de vencimento
   - **Campos adicionados**: priority (integer), due_date (date)

5. [`MenuPdvDmais/db/migrate/20260209211000_add_archive_fields_to_kanban_cards.rb`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/db/migrate/20260209211000_add_archive_fields_to_kanban_cards.rb)
   - **Data**: 2026-02-09
   - **Propósito**: Adicionar campos de arquivamento
   - **Campos adicionados**: archived_at (datetime), archived_by_id (bigint)

### Cache/Performance Migrations

6. [`MenuPdvDmais/db/migrate/20231211010807_add_cached_labels_list.rb`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/db/migrate/20231211010807_add_cached_labels_list.rb)
   - **Data**: 2023-12-11
   - **Propósito**: Adicionar cache de labels (possivelmente para performance)

7. [`MenuPdvDmais/db/migrate/20231211010808_fix_cached_labels_list_migration.rb`](file:///home/dev/Projetos/ErpChatwoot/MenuPdvDmais/db/migrate/20231211010808_fix_cached_labels_list_migration.rb)
   - **Data**: 2023-12-11
   - **Propósito**: Correção da migração anterior

---

## 📊 Estatísticas

| Categoria               | Quantidade      |
| ----------------------- | --------------- |
| **Core Patches**        | 3 arquivos      |
| **Enterprise Frontend** | 30 arquivos     |
| **Enterprise Backend**  | 6 arquivos      |
| **Database Migrations** | 7 arquivos      |
| **TOTAL**               | **46 arquivos** |

---

## 🔄 Workflow de Validação em Update do Upstream

Quando executar `./update_upstream.sh`, seguir este checklist:

### 1. ✅ Revisar Core Patches (CRÍTICO)

Para cada arquivo em **Core Patches**:

```bash
# 1. Ver diff do upstream
git diff chatwoot-base/[caminho-original]

# 2. Se houver mudanças significativas, atualizar o patch:
# a) Copiar nova versão
cp chatwoot-base/[caminho-original] MenuPdvDmais/core-patches/[caminho]

# b) Re-aplicar modificações enterprise (consultar este registry)
# c) Testar localmente
```

**Arquivos a revisar:**

- [ ] `Sidebar.vue` - Verificar estrutura de menus
- [ ] `dashboard.routes.js` - Verificar estrutura de rotas
- [ ] `config/routes.rb` - Verificar rotas principais

### 2. ✅ Testar Enterprise Originals

Arquivos enterprise geralmente **não precisam modificação**, mas testar:

```bash
# Rebuild completo
docker-compose down
docker-compose build --no-cache
docker-compose up -d

# Testar cada módulo:
# - Kanban (criar/editar/arquivar cards)
# - Gestão de Contatos (listar/filtrar)
# - Financeiro (abrir iframe)
```

### 3. ✅ Validar Migrações

```bash
# Verificar se migrações customizadas não conflitam
docker-compose exec app bundle exec rails db:migrate:status

# Se houver conflitos de timestamp ou nome de coluna, resolver manualmente
```

### 4. ✅ Commit e Deploy

```bash
git add chatwoot-base MenuPdvDmais
git commit -m "chore: update chatwoot base to v[X.Y.Z] and validate patches"
git push origin main
```

---

## 📝 Notas de Desenvolvimento

### Quando adicionar novo Core Patch:

1. Adicionar entrada neste arquivo na seção **Core Patches**
2. Documentar arquivo original e modificações
3. Criar pull request mencionando este registry

### Quando adicionar novo Enterprise Original:

1. Adicionar entrada neste arquivo na seção **Enterprise Originals**
2. Documentar propósito e módulo relacionado
3. Não há necessidade de validação em updates (mas sempre testar)

### Quando adicionar nova Migration:

1. Adicionar entrada neste arquivo na seção **Database Migrations**
2. Usar timestamp correto (não conflitar com upstream)
3. Documentar propósito e campos criados/modificados

---

## 🔗 Referências

- [Regras de Desenvolvimento](file:///home/dev/Projetos/ErpChatwoot/.ai/rules.md)
- [Workflows](file:///home/dev/Projetos/ErpChatwoot/.ai/workflows.md)
- [Tech Stack](file:///home/dev/Projetos/ErpChatwoot/.ai/tech-stack.md)
- [Dockerfile](file:///home/dev/Projetos/ErpChatwoot/Dockerfile)

---

**Última atualização**: 2026-02-12  
**Versão Chatwoot Base**: [verificar em chatwoot-base]  
**Mantido por**: Equipe ErpChatwoot
