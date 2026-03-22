/*
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/api/clientDeployments.js
 * Last Modified: 21/03/2026
 * Dependencies: -
 * Calls: -
 * Description: (Adicionar descrição em português)
 */
/* global axios */

// Utilitário para construir URL base enterprise
function enterpriseUrl(resource) {
  const accountId =
    window.bus?.$store?.getters?.["auth/getCurrentAccount"]?.id ||
    window.chatwootBus?.$store?.getters?.getCurrentAccountId ||
    document.querySelector("[data-account-id]")?.dataset?.accountId;
  return `/enterprise/api/v1/accounts/${accountId}/${resource}`;
}

const ClientDeploymentsAPI = {
  getByCompany(companyId) {
    return axios.get(
      `${enterpriseUrl("client_deployments")}?company_id=${companyId}`,
    );
  },

  getDetails(deploymentId) {
    return axios.get(`${enterpriseUrl("client_deployments")}/${deploymentId}`);
  },

  create(data) {
    return axios.post(enterpriseUrl("client_deployments"), {
      client_deployment: data,
    });
  },

  update(deploymentId, data) {
    return axios.patch(
      `${enterpriseUrl("client_deployments")}/${deploymentId}`,
      { client_deployment: data },
    );
  },

  delete(deploymentId) {
    return axios.delete(
      `${enterpriseUrl("client_deployments")}/${deploymentId}`,
    );
  },
};

export default ClientDeploymentsAPI;
