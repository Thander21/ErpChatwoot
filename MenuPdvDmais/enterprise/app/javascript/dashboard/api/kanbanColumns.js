/*
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/api/kanbanColumns.js
 * Last Modified: 21/03/2026
 * Dependencies: -
 * Calls: -
 * Description: (Adicionar descrição em português)
 */
/* global axios */
import ApiClient from "./ApiClient";

class KanbanColumnsAPI extends ApiClient {
  constructor() {
    super("kanban_columns", { accountScoped: true, enterprise: true });
  }
}

export default new KanbanColumnsAPI();
