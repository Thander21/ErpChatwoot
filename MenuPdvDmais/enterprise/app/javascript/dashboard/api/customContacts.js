/* global axios */
import ApiClient from './ApiClient';

class CustomContactsAPI extends ApiClient {
  constructor() {
    super('kanban_cards', { accountScoped: true });
  }

  // Custom endpoints from Index.vue
  async syncCompanies(accountId) {
    const url = `/enterprise/api/v1/accounts/${accountId}/kanban_cards`;
    return axios.post(`${url}/sync_companies`);
  }

  async cleanupCompanies(accountId) {
    const url = `/enterprise/api/v1/accounts/${accountId}/kanban_cards`;
    return axios.post(`${url}/cleanup_companies`);
  }
}

export default new CustomContactsAPI();
