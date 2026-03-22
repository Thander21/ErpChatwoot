/*
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/api/kanbanCards.js
 * Last Modified: 21/03/2026
 * Dependencies: -
 * Calls: -
 * Description: (Adicionar descrição em português)
 */
/* global axios */
import ApiClient from "./ApiClient";

class KanbanCardsAPI extends ApiClient {
  constructor() {
    super("kanban_cards", { accountScoped: true, enterprise: true });
  }

  // Sobrescrever o método get para usar o namespace enterprise
  get(params = {}) {
    let url = this.url;

    // Adicionar parâmetros de query
    const queryParams = new URLSearchParams();
    Object.keys(params).forEach((key) => {
      if (params[key] !== null && params[key] !== undefined) {
        queryParams.append(key, params[key]);
      }
    });

    if (queryParams.toString()) {
      url += `?${queryParams.toString()}`;
    }

    return axios.get(url);
  }

  // Mover card entre colunas
  move(cardId, kanbanColumnId, position = 0) {
    return axios.post(`${this.url}/${cardId}/move`, {
      kanban_column_id: kanbanColumnId,
      position: position,
    });
  }

  archive(cardId) {
    return axios.post(`${this.url}/${cardId}/archive`);
  }

  getArchivedReport(month, year) {
    return axios.get(`${this.url}/archived_report`, {
      params: { month, year },
    });
  }
}

export default new KanbanCardsAPI();
