/* global axios */
import ApiClient from './ApiClient';

class KanbanColumnsAPI extends ApiClient {
  constructor() {
    super('kanban_columns', { accountScoped: true, enterprise: true });
  }
}

export default new KanbanColumnsAPI();
