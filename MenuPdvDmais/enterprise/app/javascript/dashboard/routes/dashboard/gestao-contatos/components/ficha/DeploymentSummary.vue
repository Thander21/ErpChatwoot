<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ficha/DeploymentSummary.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: -
 * Description: (Adicionar descrição em português)
-->
<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ficha/DeploymentSummary.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: -
 * Description: Resumo da Ficha do Cliente, exibindo o status da implantação e contadores das 5 abas.
-->
<script setup>
import { computed, ref, watch } from "vue";

const props = defineProps({
  deployment: { type: Object, required: true },
  nextSchedule: { type: Object, default: null },
  activities: { type: Array, default: () => [] },
});

defineEmits(["update-status", "add-deployment"]);

const counters = computed(() => [
  {
    id: "trainings",
    icon: "🎓",
    count: props.deployment.trainings_count,
    label: "Treino",
    color: "text-purple-600 dark:text-purple-400",
  },
  {
    id: "installations",
    icon: "🛠️",
    count: props.deployment.installations_count,
    label: "Implan.",
    color: "text-blue-600 dark:text-blue-400",
  },
  {
    id: "systems",
    icon: "💻",
    count: props.deployment.systems_count,
    label: "Sistemas",
    color: "text-green-600 dark:text-green-400",
  },
  {
    id: "hardwares",
    icon: "🔌",
    count: props.deployment.hardwares_count,
    label: "Hard.",
    color: "text-orange-600 dark:text-orange-400",
  },
  {
    id: "networks",
    icon: "🌐",
    count: props.deployment.networks_count,
    label: "Rede",
    color: "text-teal-600 dark:text-teal-400",
  },
]);

const statusClass = computed(() => {
  const map = {
    pending:
      "bg-yellow-100 text-yellow-700 dark:bg-yellow-900/40 dark:text-yellow-300",
    in_progress:
      "bg-blue-100 text-blue-700 dark:bg-blue-900/40 dark:text-blue-300",
    completed:
      "bg-green-100 text-green-700 dark:bg-green-900/40 dark:text-green-300",
    on_hold: "bg-gray-100 text-gray-700 dark:bg-gray-900/40 dark:text-gray-300",
  };
  return map[props.deployment.status] || map.pending;
});

function formatDate(dateStr) {
  if (!dateStr) return "";
  return new Date(dateStr).toLocaleDateString("pt-BR");
}

function formatDateTime(dateStr) {
  if (!dateStr) return "";
  return new Date(dateStr).toLocaleString("pt-BR", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}

// --- PAGINAÇÃO E ORDENAÇÃO DE ATIVIDADES GERAIS ---
const currentPage = ref(1);
const itemsPerPage = 5; // Resumo mostra 5.

watch(
  () => props.activities,
  () => {
    currentPage.value = 1;
  },
  { deep: true },
);

const sortedActivities = computed(() => {
  if (!props.activities) return [];
  return [...props.activities].sort((a, b) => {
    const dateA = new Date(a.occurred_at || a.created_at || 0);
    const dateB = new Date(b.occurred_at || b.created_at || 0);
    return dateB - dateA;
  });
});

const totalPages = computed(
  () => Math.ceil(sortedActivities.value.length / itemsPerPage) || 1,
);

const displayedActivities = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage;
  return sortedActivities.value.slice(start, start + itemsPerPage);
});

function prevPage() {
  if (currentPage.value > 1) currentPage.value--;
}
function nextPage() {
  if (currentPage.value < totalPages.value) currentPage.value++;
}

function getActivityIcon(type) {
  const icons = {
    installation: "🛠️",
    training: "🎓",
    support: "📞",
    maintenance: "🔧",
    system: "💻",
    hardware: "🔌",
    network: "🌐",
  };
  return icons[type] || "📌";
}
</script>

<template>
  <div class="p-4 space-y-4">
    <!-- Card de implantação ativa -->
    <div
      class="bg-gradient-to-br from-blue-50 to-indigo-50 dark:from-blue-900/20 dark:to-indigo-900/20 border border-blue-100 dark:border-blue-800 rounded-xl p-4"
    >
      <div class="flex items-start justify-between mb-3">
        <div class="flex-1">
          <h3
            class="font-semibold text-slate-800 dark:text-slate-200 text-sm leading-tight"
          >
            {{ deployment.title }}
          </h3>
          <p
            v-if="deployment.started_at"
            class="text-xs text-slate-500 dark:text-slate-400 mt-0.5"
          >
            Início: {{ formatDate(deployment.started_at) }}
          </p>
        </div>
        <!-- Badge de status -->
        <select
          :value="deployment.status"
          :class="statusClass"
          class="text-xs font-semibold px-2 py-1 rounded-full border-0 cursor-pointer ml-2"
          @change="$emit('update-status', $event.target.value)"
        >
          <option value="pending">⏳ Pendente</option>
          <option value="in_progress">🔄 Em andamento</option>
          <option value="completed">✅ Concluído</option>
          <option value="on_hold">⏸️ Pausado</option>
        </select>
      </div>

      <!-- Técnico responsável -->
      <div
        v-if="deployment.assignee"
        class="flex items-center gap-2 text-xs text-slate-600 dark:text-slate-400"
      >
        <div
          class="w-6 h-6 bg-blue-200 dark:bg-blue-700 rounded-full flex items-center justify-center text-blue-700 dark:text-blue-200 font-bold text-xs"
        >
          {{ deployment.assignee.name?.[0]?.toUpperCase() }}
        </div>
        <span>{{ deployment.assignee.name }}</span>
      </div>
    </div>

    <!-- Próxima visita em destaque -->
    <div
      v-if="nextSchedule"
      class="bg-amber-50 dark:bg-amber-900/20 border border-amber-200 dark:border-amber-700 rounded-xl p-4"
    >
      <div class="flex items-center gap-2 mb-2">
        <span class="text-lg">📅</span>
        <span
          class="text-xs font-semibold text-amber-700 dark:text-amber-300 uppercase tracking-wide"
          >Próxima Visita</span
        >
      </div>
      <p class="text-sm font-semibold text-slate-800 dark:text-slate-200">
        {{ formatDateTime(nextSchedule.occurred_at) }}
      </p>
      <p class="text-sm text-slate-600 dark:text-slate-400 mt-1 line-clamp-2">
        {{ nextSchedule.description }}
      </p>
      <p v-if="nextSchedule.user" class="text-xs text-slate-500 mt-1">
        👤 {{ nextSchedule.user.name }}
      </p>
    </div>

    <!-- Contadores rápidos — LOOP OTIMIZADO -->
    <div class="grid grid-cols-2 sm:grid-cols-5 gap-2">
      <div
        v-for="counter in counters"
        :key="counter.id"
        class="bg-white dark:bg-slate-800 border border-gray-100 dark:border-slate-700 rounded-xl p-2.5 text-center shadow-sm"
      >
        <div class="text-xl mb-0.5">{{ counter.icon }}</div>
        <div class="text-lg font-bold leading-tight" :class="counter.color">
          {{ counter.count || 0 }}
        </div>
        <div
          class="text-[10px] uppercase font-bold text-slate-400 tracking-tight"
        >
          {{ counter.label }}
        </div>
      </div>
    </div>

    <!-- Notas gerais -->
    <div
      v-if="deployment.notes"
      class="bg-gray-50 dark:bg-slate-800 rounded-xl p-4"
    >
      <p
        class="text-xs font-semibold text-slate-500 dark:text-slate-400 uppercase tracking-wide mb-2"
      >
        Observações
      </p>
      <p class="text-sm text-slate-700 dark:text-slate-300 whitespace-pre-wrap">
        {{ deployment.notes }}
      </p>
    </div>

    <!-- Feed de Últimas Atividades (Paginado para 5) -->
    <div class="mt-6 border-t border-gray-100 dark:border-slate-700/50 pt-6">
      <h4
        class="text-sm font-bold text-slate-800 dark:text-slate-200 mb-4 flex items-center justify-between"
      >
        Registro Global Atividades
        <span
          class="text-[10px] bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-400 px-2 py-0.5 rounded-full font-semibold uppercase tracking-wide border border-gray-200 dark:border-slate-700"
        >
          {{ sortedActivities.length }} Total
        </span>
      </h4>

      <div class="space-y-3">
        <div
          v-if="displayedActivities.length === 0"
          class="text-center py-6 text-slate-400 text-[13px] italic border border-dashed border-gray-200 dark:border-slate-700 rounded-xl"
        >
          Nenhuma atividade registrada na timeline
        </div>

        <div
          v-for="activity in displayedActivities"
          :key="activity.id"
          class="p-3 bg-white dark:bg-slate-800 border border-gray-100 dark:border-slate-700 rounded-xl shadow-sm flex flex-col gap-2"
        >
          <div class="flex justify-between items-start">
            <div class="flex items-start gap-2.5">
              <span class="text-base mt-0.5 opacity-80">{{
                getActivityIcon(activity.activity_type)
              }}</span>
              <p
                class="text-sm font-semibold text-slate-700 dark:text-slate-300 leading-snug"
              >
                {{ activity.description }}
              </p>
            </div>
            <span
              class="text-[10px] font-bold px-2 py-0.5 bg-gray-50 dark:bg-slate-900/60 text-slate-500 dark:text-slate-400 rounded border border-gray-100 dark:border-slate-700 shrink-0"
            >
              {{ formatDateTime(activity.occurred_at || activity.created_at) }}
            </span>
          </div>
        </div>
      </div>

      <!-- Paginação -->
      <div
        v-if="totalPages > 1"
        class="flex items-center justify-between pt-4 mt-2"
      >
        <button
          :disabled="currentPage === 1"
          class="px-3 py-1.5 text-xs font-semibold rounded-lg border border-gray-200 dark:border-slate-700 text-slate-600 dark:text-slate-300 hover:bg-gray-50 dark:hover:bg-slate-800 disabled:opacity-30 transition-colors"
          @click="prevPage"
        >
          Anterior
        </button>
        <span class="text-[11px] text-slate-400 font-medium tracking-wide">Pág. {{ currentPage }} de {{ totalPages }}</span>
        <button
          :disabled="currentPage === totalPages"
          class="px-3 py-1.5 text-xs font-semibold rounded-lg border border-gray-200 dark:border-slate-700 text-slate-600 dark:text-slate-300 hover:bg-gray-50 dark:hover:bg-slate-800 disabled:opacity-30 transition-colors"
          @click="nextPage"
        >
          Próximo
        </button>
      </div>
    </div>
  </div>
</template>
