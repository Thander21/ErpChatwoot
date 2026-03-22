/*
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/composables/useDeployment.js
 * Last Modified: 21/03/2026
 * Dependencies: -
 * Calls: -
 * Description: (Adicionar descrição em português)
 */
import { ref, computed } from "vue";
import clientDeploymentsAPI from "../../../../api/clientDeployments";
import deploymentActivitiesAPI from "../../../../api/deploymentActivities";
import deploymentSystemsAPI from "../../../../api/deploymentSystems";
import deploymentTrainingsAPI from "../../../../api/deploymentTrainings";
import deploymentInstallationsAPI from "../../../../api/deploymentInstallations";
import deploymentHardwaresAPI from "../../../../api/deploymentHardwares";
import deploymentNetworksAPI from "../../../../api/deploymentNetworks";

export function useDeployment(companyId) {
  const deployments = ref([]);
  const activeDeployment = ref(null);
  const activities = ref([]);
  const systems = ref([]);
  const trainings = ref([]);
  const installations = ref([]);
  const hardwares = ref([]);
  const networks = ref([]);
  const loading = ref(false);
  const error = ref(null);

  // Agendamentos futuros (atividades do tipo 'schedule' com data futura)
  const nextSchedules = computed(() =>
    activities.value
      .filter(
        (a) =>
          a.activity_type === "schedule" &&
          new Date(a.occurred_at) >= new Date(),
      )
      .sort((a, b) => new Date(a.occurred_at) - new Date(b.occurred_at)),
  );

  const recentActivities = computed(() =>
    activities.value
      .filter((a) => a.activity_type !== "schedule")
      .sort((a, b) => new Date(b.occurred_at) - new Date(a.occurred_at)),
  );

  async function fetchDeployments() {
    loading.value = true;
    error.value = null;
    try {
      const response = await clientDeploymentsAPI.getByCompany(companyId.value);
      deployments.value = response.data;
      // Auto-seleciona a primeira implantação ativa, ou a mais recente
      if (deployments.value.length > 0) {
        const active = deployments.value.find((d) =>
          ["pending", "in_progress"].includes(d.status),
        );
        activeDeployment.value = active || deployments.value[0];
      }
    } catch (e) {
      error.value = "Erro ao carregar implantações.";
    } finally {
      loading.value = false;
    }
  }

  async function fetchDeploymentDetails(deploymentId) {
    loading.value = true;
    try {
      const response = await clientDeploymentsAPI.getDetails(deploymentId);
      activeDeployment.value = response.data;
      activities.value = response.data.activities || [];
      systems.value = response.data.systems || [];
      trainings.value = response.data.trainings || [];
      installations.value = response.data.installations || [];
      hardwares.value = response.data.hardwares || [];
      networks.value = response.data.networks || [];
    } catch (e) {
      error.value = "Erro ao carregar detalhes.";
    } finally {
      loading.value = false;
    }
  }

  async function createDeployment(data) {
    const response = await clientDeploymentsAPI.create({
      ...data,
      company_id: companyId.value,
    });
    deployments.value.unshift(response.data);
    activeDeployment.value = response.data;
    return response.data;
  }

  async function updateDeployment(deploymentId, data) {
    const response = await clientDeploymentsAPI.update(deploymentId, data);
    const index = deployments.value.findIndex((d) => d.id === deploymentId);
    if (index !== -1) deployments.value[index] = response.data;
    activeDeployment.value = response.data;
    return response.data;
  }

  async function addActivity(deploymentId, data) {
    const response = await deploymentActivitiesAPI.create(deploymentId, data);
    activities.value.unshift(response.data);
    return response.data;
  }

  async function removeActivity(deploymentId, activityId) {
    await deploymentActivitiesAPI.delete(deploymentId, activityId);
    activities.value = activities.value.filter((a) => a.id !== activityId);
  }

  async function addSystem(deploymentId, data) {
    const response = await deploymentSystemsAPI.create(deploymentId, data);
    systems.value.unshift(response.data);
    return response.data;
  }

  async function removeSystem(deploymentId, systemId) {
    await deploymentSystemsAPI.delete(deploymentId, systemId);
    systems.value = systems.value.filter((s) => s.id !== systemId);
  }

  async function addTraining(deploymentId, data) {
    const response = await deploymentTrainingsAPI.create(deploymentId, data);
    trainings.value.unshift(response.data);
    return response.data;
  }

  async function removeTraining(deploymentId, trainingId) {
    await deploymentTrainingsAPI.delete(deploymentId, trainingId);
    trainings.value = trainings.value.filter((t) => t.id !== trainingId);
  }

  async function addInstallation(deploymentId, data) {
    const response = await deploymentInstallationsAPI.create(
      deploymentId,
      data,
    );
    installations.value.unshift(response.data);
    return response.data;
  }

  async function removeInstallation(deploymentId, id) {
    await deploymentInstallationsAPI.delete(deploymentId, id);
    installations.value = installations.value.filter((i) => i.id !== id);
  }

  async function addHardware(deploymentId, data) {
    const response = await deploymentHardwaresAPI.create(deploymentId, data);
    hardwares.value.unshift(response.data);
    return response.data;
  }

  async function removeHardware(deploymentId, id) {
    await deploymentHardwaresAPI.delete(deploymentId, id);
    hardwares.value = hardwares.value.filter((h) => h.id !== id);
  }

  async function addNetwork(deploymentId, data) {
    const response = await deploymentNetworksAPI.create(deploymentId, data);
    networks.value.unshift(response.data);
    return response.data;
  }

  async function removeNetwork(deploymentId, id) {
    await deploymentNetworksAPI.delete(deploymentId, id);
    networks.value = networks.value.filter((n) => n.id !== id);
  }

  return {
    deployments,
    activeDeployment,
    activities,
    systems,
    trainings,
    installations,
    hardwares,
    networks,
    loading,
    error,
    nextSchedules,
    recentActivities,
    fetchDeployments,
    fetchDeploymentDetails,
    createDeployment,
    updateDeployment,
    addActivity,
    removeActivity,
    addSystem,
    removeSystem,
    addTraining,
    removeTraining,
    addInstallation,
    removeInstallation,
    addHardware,
    removeHardware,
    addNetwork,
    removeNetwork,
  };
}
