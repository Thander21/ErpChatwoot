/*
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/initializeRoutes.js
 * Last Modified: 21/03/2026
 * Dependencies: -
 * Calls: -
 * Description: (Adicionar descrição em português)
 */
/**
 * ERP Chatwoot - Enterprise Routes Initialization
 * =============================================================================
 * Projeto: ERP Gestão de Contatos para Chatwoot Enterprise
 * Arquivo: initializeRoutes.js
 * Descrição: Inicialização de todas as rotas customizadas da Enterprise
 *            Executar durante inicialização do app para registrar módulos
 * Autor: Thander21
 * Data: 2024
 * Versão: 1.0.0
 * =============================================================================
 */

/**
 * Enterprise Routes Initialization
 *
 * This file initializes all Enterprise custom routes
 * Run this during app initialization to register enterprise modules
 */

import { registerEnterpriseRoutes } from "./routeExtensions.js";
import gestaoContatosRoutes from "./dashboard/gestao-contatos/gestao-contatos.routes.js";
import kanbanRoutes from "./dashboard/kanban/kanban.routes.js";
import boletosRoutes from "./dashboard/boletos/boletos.routes.js";

/**
 * Initialize enterprise routes
 * Call this function during app startup to register all enterprise features
 */
export function initializeEnterpriseRoutes() {
  // Register enterprise routes
  registerEnterpriseRoutes(gestaoContatosRoutes.routes);
  registerEnterpriseRoutes(kanbanRoutes.routes);
  registerEnterpriseRoutes(boletosRoutes.routes);

  /* debug removed */
}

export default {
  initializeEnterpriseRoutes,
};
