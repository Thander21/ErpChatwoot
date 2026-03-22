<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/CompanyProfile.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: -
 * Description: (Adicionar descrição em português)
-->
<script setup>
import { ref, computed, watch } from "vue";
import { useDeployment } from "../composables/useDeployment";
import DeploymentSummary from "./ficha/DeploymentSummary.vue";
import ActivityFeed from "./ficha/ActivityFeed.vue";
import ScheduleCard from "./ficha/ScheduleCard.vue";
import SystemsList from "./ficha/SystemsList.vue";
import TrainingList from "./ficha/TrainingList.vue";
import InstallationList from "./ficha/InstallationList.vue";
import HardwareList from "./ficha/HardwareList.vue";
import NetworkList from "./ficha/NetworkList.vue";

const props = defineProps({
  company: { type: Object, required: true },
  isOpen: { type: Boolean, default: false },
});

const emit = defineEmits(["close"]);

const companyId = computed(() => props.company?.id);

const {
  deployments,
  activeDeployment,
  activities,
  systems,
  trainings,
  installations,
  hardwares,
  networks,
  loading,
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
  addHardware,
  addNetwork,
} = useDeployment(companyId);

const activeTab = ref("summary");

const tabs = computed(() => [
  { key: "summary", label: "Resumo", icon: "📊" },
  {
    key: "trainings",
    label: "Treinamento",
    icon: "🎓",
    count: trainings.value.length,
  },
  {
    key: "installations",
    label: "Implantação",
    icon: "🛠️",
    count: installations.value.length,
  },
  { key: "systems", label: "Sistema", icon: "💻", count: systems.value.length },
  {
    key: "hardwares",
    label: "Hardware",
    icon: "🔌",
    count: hardwares.value.length,
  },
  { key: "networks", label: "Rede", icon: "🌐", count: networks.value.length },
]);

// Carrega dados ao abrir
watch(
  () => props.isOpen,
  async (open) => {
    if (open && props.company?.id) {
      await fetchDeployments();
      if (activeDeployment.value) {
        await fetchDeploymentDetails(activeDeployment.value.id);
      }
    }
  },
  { immediate: true },
);

// Função auxiliar para garantir que existe uma implantação antes de registrar algo
async function ensureDeployment() {
  if (activeDeployment.value) return activeDeployment.value.id;

  const res = await createDeployment({
    title: `Ficha Técnica - ${props.company.name}`,
    status: "in_progress",
    started_at: new Date().toISOString().split("T")[0],
  });

  if (res) {
    await fetchDeploymentDetails(res.id);
    return res.id;
  }
  return null;
}

async function handleUpdateStatus(status) {
  if (!activeDeployment.value) return;
  await updateDeployment(activeDeployment.value.id, { status });
}

async function handleAddInstallation(installationData) {
  const depId = await ensureDeployment();
  if (depId) {
    await addInstallation(depId, installationData);
    // Log na timeline
    await addActivity(depId, {
      activity_type: "installation",
      description: `Implantação registrada: ${installationData.installation_name}`,
      occurred_at: installationData.installed_at || new Date().toISOString(),
    });
    await fetchDeploymentDetails(depId);
  }
}

async function handleAddHardware(hardwareData) {
  const depId = await ensureDeployment();
  if (depId) {
    await addHardware(depId, hardwareData);
    const snText = hardwareData.serial_number
      ? ` (S/N: ${hardwareData.serial_number})`
      : "";
    // Log na timeline
    await addActivity(depId, {
      activity_type: "support",
      description: `Hardware registrado: ${hardwareData.hardware_name}${snText}`,
      occurred_at: hardwareData.installed_at || new Date().toISOString(),
    });
    await fetchDeploymentDetails(depId);
  }
}

async function handleAddNetwork(networkData) {
  const depId = await ensureDeployment();
  if (depId) {
    await addNetwork(depId, networkData);
    // Log na timeline
    await addActivity(depId, {
      activity_type: "support",
      description: `Rede registrada: ${networkData.network_type}`,
      occurred_at: networkData.installed_at || new Date().toISOString(),
    });
    await fetchDeploymentDetails(depId);
  }
}

async function handleDeleteActivity(activityId) {
  if (!activeDeployment.value) return;
  await removeActivity(activeDeployment.value.id, activityId);
}

async function handleAddSystem(systemData) {
  const depId = await ensureDeployment();
  if (depId) {
    await addSystem(depId, systemData);
    // Log na timeline
    await addActivity(depId, {
      activity_type: "installation",
      description: `Sistema Instalado: ${systemData.system_name} ${systemData.version || ""}`,
      occurred_at: systemData.installed_at || new Date().toISOString(),
    });
  }
}

async function handleRemoveSystem(systemId) {
  if (!activeDeployment.value) return;
  await removeSystem(activeDeployment.value.id, systemId);
}

async function handleAddTraining(trainingData) {
  const depId = await ensureDeployment();
  if (depId) {
    await addTraining(depId, trainingData);
    // Log na timeline
    await addActivity(depId, {
      activity_type: "training",
      description: `Treinamento realizado: ${trainingData.notes || "Sem descrição"}`,
      occurred_at: trainingData.occurred_at || new Date().toISOString(),
      duration_minutes: trainingData.duration_minutes,
    });
  }
}

async function handleRemoveTraining(trainingId) {
  if (!activeDeployment.value) return;
  await removeTraining(activeDeployment.value.id, trainingId);
}
</script>

<template>
  <!-- Modal de perfil/ficha do cliente - overlay lateral estilo sheet mobile -->
  <div
    v-if="isOpen"
    class="fixed inset-0 z-[9999] flex items-center justify-center p-4 sm:p-0"
    @click.self="$emit('close')"
  >
    <!-- Backdrop -->
    <div class="absolute inset-0 bg-black/50 backdrop-blur-sm" />

    <!-- Painel principal -->
    <div
      class="relative w-[95vw] sm:max-w-6xl bg-white dark:bg-slate-900 rounded-2xl shadow-2xl flex flex-col h-[95vh] overflow-hidden transition-all duration-300 transform"
    >
      <!-- Header fixo -->
      <div
        class="flex items-center justify-between px-4 py-3 border-b border-gray-200 dark:border-slate-700 shrink-0"
      >
        <div class="flex items-center gap-3">
          <div
            class="w-10 h-10 bg-blue-100 dark:bg-blue-900 rounded-xl flex items-center justify-center"
          >
            <svg
              class="w-5 h-5 text-blue-600 dark:text-blue-400"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"
              />
            </svg>
          </div>
          <div>
            <h2
              class="text-lg font-bold text-slate-900 dark:text-white leading-tight"
            >
              {{ company.name }}
            </h2>
            <p class="text-xs text-slate-500 dark:text-slate-400">
              Ficha do Cliente
            </p>
          </div>
        </div>
        <button
          class="p-2 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-gray-100 dark:hover:bg-slate-800 transition-colors"
          @click="$emit('close')"
        >
          <svg
            class="w-5 h-5"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M6 18L18 6M6 6l12 12"
            />
          </svg>
        </button>
      </div>

      <!-- Estado de loading -->
      <div v-if="loading" class="flex-1 flex items-center justify-center py-12">
        <div class="flex flex-col items-center gap-3 text-slate-400">
          <svg class="w-8 h-8 animate-spin" fill="none" viewBox="0 0 24 24">
            <circle
              class="opacity-25"
              cx="12"
              cy="12"
              r="10"
              stroke="currentColor"
              stroke-width="4"
            />
            <path
              class="opacity-75"
              fill="currentColor"
              d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"
            />
          </svg>
          <span class="text-sm">Carregando ficha...</span>
        </div>
      </div>

      <!-- Conteúdo principal -->
      <template v-else>
        <!-- Abas de navegação -->
        <div
          class="flex border-b border-gray-200 dark:border-slate-700 px-4 shrink-0 overflow-x-auto"
        >
          <button
            v-for="tab in tabs"
            :key="tab.key"
            class="flex items-center gap-1.5 px-3 py-2.5 text-sm font-medium whitespace-nowrap border-b-2 transition-colors mr-1"
            :class="
              activeTab === tab.key
                ? 'border-blue-600 text-blue-600 dark:text-blue-400'
                : 'border-transparent text-slate-500 hover:text-slate-700 dark:hover:text-slate-300'
            "
            @click="activeTab = tab.key"
          >
            <span>{{ tab.icon }}</span>
            {{ tab.label }}
            <span
              v-if="tab.count !== undefined && tab.count > 0"
              class="bg-blue-100 dark:bg-blue-900 text-blue-700 dark:text-blue-300 text-xs px-1.5 py-0.5 rounded-full"
            >
              {{ tab.count }}
            </span>
          </button>
        </div>

        <!-- Conteúdo das abas -->
        <div class="flex-1 flex flex-col min-h-0 w-full">
          <!-- Aba: Resumo -->
          <div
            v-if="activeTab === 'summary'"
            class="flex-1 overflow-y-auto w-full p-4 pb-8"
          >
            <DeploymentSummary
              v-if="activeDeployment"
              :deployment="activeDeployment"
              :activities="activities"
              :next-schedule="nextSchedules[0]"
              @update-status="handleUpdateStatus"
            />
            <div
              v-else
              class="flex flex-col items-center justify-center py-12 px-6 text-center"
            >
              <div
                class="w-16 h-16 bg-blue-50 dark:bg-blue-900/30 rounded-2xl flex items-center justify-center mb-4 text-3xl"
              >
                📊
              </div>
              <h3
                class="text-base font-semibold text-slate-700 dark:text-slate-300"
              >
                Nenhuma implantação iniciada
              </h3>
              <p
                class="text-sm text-slate-500 dark:text-slate-400 max-w-xs mt-1"
              >
                Escolha qualquer uma das abas de registro acima para começar a
                documentar os dados técnicos desta empresa.
              </p>
            </div>
          </div>

          <!-- Aba: Treinamento -->
          <TrainingList
            v-if="activeTab === 'trainings'"
            :trainings="trainings"
            :deployment-id="activeDeployment?.id"
            :company-id="company.id"
            @add="handleAddTraining"
            @remove="handleRemoveTraining"
          />

          <!-- Aba: Implantação -->
          <InstallationList
            v-if="activeTab === 'installations'"
            :installations="installations"
            @add="handleAddInstallation"
          />

          <!-- Aba: Sistema -->
          <SystemsList
            v-if="activeTab === 'systems'"
            :systems="systems"
            :deployment-id="activeDeployment?.id"
            @add="handleAddSystem"
            @remove="handleRemoveSystem"
          />

          <!-- Aba: Hardware -->
          <HardwareList
            v-if="activeTab === 'hardwares'"
            :hardwares="hardwares"
            @add="handleAddHardware"
          />

          <!-- Aba: Rede -->
          <NetworkList
            v-if="activeTab === 'networks'"
            :networks="networks"
            @add="handleAddNetwork"
          />
        </div>
      </template>
    </div>
  </div>
</template>
