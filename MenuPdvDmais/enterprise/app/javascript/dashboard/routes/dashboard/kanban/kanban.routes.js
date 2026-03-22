/*
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/kanban/kanban.routes.js
 * Last Modified: 21/03/2026
 * Dependencies: -
 * Calls: -
 * Description: (Adicionar descrição em português)
 */
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

import { frontendURL } from "dashboard/helper/URLHelper";
import { ROLES } from "dashboard/constants/permissions.js";
import KanbanIndex from "./Index.vue";

export default {
  routes: [
    {
      path: frontendURL("accounts/:accountId/kanban"),
      name: "kanban_index",
      component: KanbanIndex,
      meta: {
        permissions: [...ROLES],
      },
    },
    {
      path: frontendURL("accounts/:accountId/kanban/archived"),
      name: "kanban_archived",
      component: () => import("./components/ArchivedReport.vue"),
      meta: {
        permissions: [...ROLES],
      },
    },
  ],
};
