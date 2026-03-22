/*
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/api/deploymentTrainings.js
 * Last Modified: 21/03/2026
 * Dependencies: -
 * Calls: -
 * Description: (Adicionar descrição em português)
 */
/* global axios */

function enterpriseUrl(accountId, deploymentId) {
  return `/enterprise/api/v1/accounts/${accountId}/client_deployments/${deploymentId}/deployment_trainings`;
}

function getAccountId() {
  return (
    window.bus?.$store?.getters?.["auth/getCurrentAccount"]?.id ||
    window.chatwootBus?.$store?.getters?.getCurrentAccountId ||
    document.querySelector("[data-account-id]")?.dataset?.accountId
  );
}

const DeploymentTrainingsAPI = {
  getAll(deploymentId) {
    return axios.get(enterpriseUrl(getAccountId(), deploymentId));
  },

  create(deploymentId, data) {
    return axios.post(enterpriseUrl(getAccountId(), deploymentId), {
      deployment_training: data,
    });
  },

  update(deploymentId, trainingId, data) {
    return axios.patch(
      `${enterpriseUrl(getAccountId(), deploymentId)}/${trainingId}`,
      { deployment_training: data },
    );
  },

  delete(deploymentId, trainingId) {
    return axios.delete(
      `${enterpriseUrl(getAccountId(), deploymentId)}/${trainingId}`,
    );
  },
};

export default DeploymentTrainingsAPI;
