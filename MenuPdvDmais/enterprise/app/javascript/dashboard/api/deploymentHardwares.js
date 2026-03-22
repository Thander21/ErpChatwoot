/*
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/api/deploymentHardwares.js
 * Last Modified: 21/03/2026
 * Dependencies: -
 * Calls: -
 * Description: (Adicionar descrição em português)
 */
/* global axios */

function enterpriseUrl(accountId, deploymentId) {
  return `/enterprise/api/v1/accounts/${accountId}/client_deployments/${deploymentId}/deployment_hardwares`;
}

function getAccountId() {
  return (
    window.bus?.$store?.getters?.["auth/getCurrentAccount"]?.id ||
    window.chatwootBus?.$store?.getters?.getCurrentAccountId ||
    document.querySelector("[data-account-id]")?.dataset?.accountId
  );
}

const DeploymentHardwaresAPI = {
  getAll(deploymentId) {
    return axios.get(enterpriseUrl(getAccountId(), deploymentId));
  },

  create(deploymentId, data) {
    return axios.post(enterpriseUrl(getAccountId(), deploymentId), {
      deployment_hardware: data,
    });
  },

  update(deploymentId, id, data) {
    return axios.patch(`${enterpriseUrl(getAccountId(), deploymentId)}/${id}`, {
      deployment_hardware: data,
    });
  },

  delete(deploymentId, id) {
    return axios.delete(`${enterpriseUrl(getAccountId(), deploymentId)}/${id}`);
  },
};

export default DeploymentHardwaresAPI;
