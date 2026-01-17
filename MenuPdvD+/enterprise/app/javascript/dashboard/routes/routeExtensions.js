/**
 * ERP Chatwoot - Enterprise Route Extensions
 * =============================================================================
 * Projeto: ERP Gestão de Contatos para Chatwoot Enterprise
 * Arquivo: routeExtensions.js
 * Descrição: Extensões para injeção de rotas customizadas no dashboard
 *            sem modificar os arquivos principais do Chatwoot
 * Autor: Thander21
 * Data: 2024
 * Versão: 1.0.0
 * =============================================================================
 */

/**
 * Enterprise Extension for Dashboard Routes
 *
 * This file provides a hook to inject custom routes into the dashboard
 * without modifying the core Chatwoot files, maintaining upstream compatibility
 *
 * Usage: Import this file in the main dashboard.routes.js initialization
 */

let enterpriseRoutes = [];

/**
 * Register enterprise routes to be injected into the dashboard
 * @param {Array} routes - Array of route objects to add
 */
export function registerEnterpriseRoutes(routes) {
  enterpriseRoutes = [...enterpriseRoutes, ...routes];
}

/**
 * Get all registered enterprise routes
 * @returns {Array} Array of enterprise routes
 */
export function getEnterpriseRoutes() {
  return enterpriseRoutes;
}

/**
 * Merge enterprise routes with dashboard routes
 * @param {Array} dashboardRoutes - Main dashboard routes
 * @returns {Array} Combined routes
 */
export function mergeEnterpriseRoutes(dashboardRoutes) {
  if (enterpriseRoutes.length === 0) {
    return dashboardRoutes;
  }

  // Find the main dashboard container route and inject enterprise routes into its children
  return dashboardRoutes.map(route => {
    if (route.path && route.path.includes('accounts/:accountId') && route.children) {
      return {
        ...route,
        children: [...route.children, ...enterpriseRoutes],
      };
    }
    return route;
  });
}
