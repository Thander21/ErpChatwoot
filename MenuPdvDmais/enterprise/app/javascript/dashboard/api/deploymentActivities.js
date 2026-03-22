/*
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/api/deploymentActivities.js
 * Last Modified: 21/03/2026
 * Dependencies: -
 * Calls: -
 * Description: (Adicionar descrição em português)
 */
/* global axios */

function enterpriseUrl(accountId, deploymentId) {
  return `/enterprise/api/v1/accounts/${accountId}/client_deployments/${deploymentId}/deployment_activities`;
}

function getAccountId() {
  return (
    window.bus?.$store?.getters?.["auth/getCurrentAccount"]?.id ||
    window.chatwootBus?.$store?.getters?.getCurrentAccountId ||
    document.querySelector("[data-account-id]")?.dataset?.accountId
  );
}

const DeploymentActivitiesAPI = {
  getAll(deploymentId) {
    return axios.get(enterpriseUrl(getAccountId(), deploymentId));
  },

  create(deploymentId, data) {
    return axios.post(enterpriseUrl(getAccountId(), deploymentId), {
      deployment_activity: data,
    });
  },

  update(deploymentId, activityId, data) {
    return axios.patch(
      `${enterpriseUrl(getAccountId(), deploymentId)}/${activityId}`,
      { deployment_activity: data },
    );
  },

  delete(deploymentId, activityId) {
    return axios.delete(
      `${enterpriseUrl(getAccountId(), deploymentId)}/${activityId}`,
    );
  },
};

export default DeploymentActivitiesAPI;
