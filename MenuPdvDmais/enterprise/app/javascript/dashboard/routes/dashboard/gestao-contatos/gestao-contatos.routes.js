/*
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/gestao-contatos.routes.js
 * Last Modified: 21/03/2026
 * Dependencies: -
 * Calls: -
 * Description: (Adicionar descrição em português)
 */
/**
 * ERP Chatwoot - Gestão de Contatos Routes
 * =============================================================================
 * Projeto: ERP Gestão de Contatos para Chatwoot Enterprise
 * Arquivo: gestao-contatos.routes.js
 * Descrição: Definição das rotas para o módulo de gestão de contatos
 * Autor: Thander21
 * Data: 2024
 * Versão: 1.0.0
 * =============================================================================
 */

import { frontendURL } from "dashboard/helper/URLHelper";
import { ROLES } from "dashboard/constants/permissions.js";
import GestaoContatosIndex from "./Index.vue";

export default {
  routes: [
    {
      path: frontendURL("accounts/:accountId/gestao-contatos"),
      name: "gestao_contatos_index",
      component: GestaoContatosIndex,
      meta: {
        permissions: [...ROLES],
      },
    },
  ],
};
