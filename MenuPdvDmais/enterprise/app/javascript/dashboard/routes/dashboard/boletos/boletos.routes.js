/*
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/boletos/boletos.routes.js
 * Last Modified: 21/03/2026
 * Dependencies: -
 * Calls: -
 * Description: (Adicionar descrição em português)
 */
/**
 * ERP Chatwoot - Boletos Routes
 * =============================================================================
 * Projeto: ERP Boletos para Chatwoot Enterprise
 * Arquivo: boletos.routes.js
 * Descrição: Definição das rotas para o módulo de boletos
 * Autor: Thander21
 * Data: 2024
 * Versão: 1.0.0
 * =============================================================================
 */

import { frontendURL } from "dashboard/helper/URLHelper";
import { ROLES } from "dashboard/constants/permissions.js";
import BoletosIndex from "./Index.vue";

export default {
  routes: [
    {
      path: frontendURL("accounts/:accountId/boletos"),
      name: "boletos_index",
      component: BoletosIndex,
      meta: {
        permissions: [...ROLES],
      },
    },
  ],
};
