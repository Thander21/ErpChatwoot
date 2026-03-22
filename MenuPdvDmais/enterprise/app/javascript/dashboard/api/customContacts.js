/*
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/api/customContacts.js
 * Last Modified: 21/03/2026
 * Dependencies: -
 * Calls: -
 * Description: (Adicionar descrição em português)
 */
/* global axios */
import ApiClient from "./ApiClient";

class CustomContactsAPI extends ApiClient {
  constructor() {
    super("kanban_cards", { accountScoped: true });
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

  getContacts(accountId, page = 1) {
    return axios.get(
      `/enterprise/api/v1/accounts/${accountId}/custom_contacts`,
      {
        params: { page },
      },
    );
  }

  updateContact(accountId, contactId, updateData) {
    return axios.patch(
      `/enterprise/api/v1/accounts/${accountId}/custom_contacts/${contactId}`,
      { contact: updateData },
    );
  }

  deleteContact(accountId, contactId) {
    return axios.delete(
      `/enterprise/api/v1/accounts/${accountId}/custom_contacts/${contactId}`,
    );
  }
}

export default new CustomContactsAPI();
