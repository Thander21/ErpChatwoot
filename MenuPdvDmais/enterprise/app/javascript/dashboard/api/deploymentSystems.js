/*
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/api/deploymentSystems.js
 * Last Modified: 21/03/2026
 * Dependencies: -
 * Calls: -
 * Description: (Adicionar descrição em português)
 */
/* global axios */

function enterpriseUrl(accountId, deploymentId) {
  return `/enterprise/api/v1/accounts/${accountId}/client_deployments/${deploymentId}/deployment_systems`;
}

function getAccountId() {
  return (
    window.bus?.$store?.getters?.["auth/getCurrentAccount"]?.id ||
    window.chatwootBus?.$store?.getters?.getCurrentAccountId ||
    document.querySelector("[data-account-id]")?.dataset?.accountId
  );
}

const DeploymentSystemsAPI = {
  getAll(deploymentId) {
    return axios.get(enterpriseUrl(getAccountId(), deploymentId));
  },

  create(deploymentId, data) {
    return axios.post(enterpriseUrl(getAccountId(), deploymentId), {
      deployment_system: data,
    });
  },

  update(deploymentId, systemId, data) {
    return axios.patch(
      `${enterpriseUrl(getAccountId(), deploymentId)}/${systemId}`,
      { deployment_system: data },
    );
  },

  delete(deploymentId, systemId) {
    return axios.delete(
      `${enterpriseUrl(getAccountId(), deploymentId)}/${systemId}`,
    );
  },
};

export default DeploymentSystemsAPI;
