/**
 * ERP Chatwoot - Kanban Routes
 * =============================================================================
 * Projeto: ERP Kanban para Chatwoot Enterprise
 * Arquivo: kanban.routes.js
 * Descrição: Definição das rotas para o módulo de kanban
 * Autor: Thander21
 * Data: 2024
 * Versão: 1.0.0
 * =============================================================================
 */

import { frontendURL } from 'dashboard/helper/URLHelper';
import { ROLES } from 'dashboard/constants/permissions.js';
import KanbanIndex from './Index.vue';

export default {
  routes: [
    {
      path: frontendURL('accounts/:accountId/kanban'),
      name: 'kanban_index',
      component: KanbanIndex,
      meta: {
        permissions: [...ROLES],
      },
    },
  ],
};
