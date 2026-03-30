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
import WootButton from "dashboard/components-next/button/Button.vue";
import WootSelect from "dashboard/components-next/select/Select.vue";

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
    color: "text-n-slate-11",
  },
  {
    id: "installations",
    icon: "🛠️",
    count: props.deployment.installations_count,
    label: "Implan.",
    color: "text-n-blue-11",
  },
  {
    id: "systems",
    icon: "💻",
    count: props.deployment.systems_count,
    label: "Sistemas",
    color: "text-n-green-11",
  },
  {
    id: "hardwares",
    icon: "🔌",
    count: props.deployment.hardwares_count,
    label: "Hard.",
    color: "text-n-orange-11",
  },
  {
    id: "networks",
    icon: "🌐",
    count: props.deployment.networks_count,
    label: "Rede",
    color: "text-n-teal-11",
  },
]);

const statusClass = computed(() => {
  const map = {
    pending:
      "bg-n-yellow-3 text-n-yellow-11",
    in_progress:
      "bg-n-blue-3 text-n-blue-11",
    completed:
      "bg-n-green-3 text-n-green-11",
    on_hold: "bg-n-slate-3 text-n-slate-11",
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
 
const statusOptions = [
  { value: "pending", label: "⏳ Pendente" },
  { value: "in_progress", label: "🔄 Em andamento" },
  { value: "completed", label: "✅ Concluído" },
  { value: "on_hold", label: "⏸️ Pausado" },
];

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
      class="bg-n-brand/5 border border-n-brand/10 rounded-xl p-4"
    >
      <div class="flex items-start justify-between mb-3">
        <div class="flex-1">
          <h3
            class="font-semibold text-n-slate-12 text-sm leading-tight"
          >
            {{ deployment.title }}
          </h3>
          <p
            v-if="deployment.started_at"
            class="text-xs text-n-slate-11 mt-0.5"
          >
            Início: {{ formatDate(deployment.started_at) }}
          </p>
        </div>
        <!-- Badge de status -->
        <WootSelect
          :model-value="deployment.status"
          :options="statusOptions"
          class="min-w-[140px]"
          @update:model-value="$emit('update-status', $event)"
        />
      </div>

      <!-- Técnico responsável -->
      <div
        v-if="deployment.assignee"
        class="flex items-center gap-2 text-xs text-n-slate-11"
      >
        <div
          class="w-6 h-6 bg-n-brand/10 rounded-full flex items-center justify-center text-n-brand font-bold text-xs"
        >
          {{ deployment.assignee.name?.[0]?.toUpperCase() }}
        </div>
        <span>{{ deployment.assignee.name }}</span>
      </div>
    </div>

    <!-- Próxima visita em destaque -->
    <div
      v-if="nextSchedule"
      class="bg-n-alpha-black2 border border-n-weak rounded-xl p-4"
    >
      <div class="flex items-center gap-2 mb-2">
        <span class="text-lg">📅</span>
        <span
          class="text-xs font-semibold text-n-slate-12 uppercase tracking-wide"
          >Próxima Visita</span
        >
      </div>
      <p class="text-sm font-semibold text-n-slate-12">
        {{ formatDateTime(nextSchedule.occurred_at) }}
      </p>
      <p class="text-sm text-n-slate-11 mt-1 line-clamp-2">
        {{ nextSchedule.description }}
      </p>
      <p v-if="nextSchedule.user" class="text-xs text-n-slate-11 mt-1">
        👤 {{ nextSchedule.user.name }}
      </p>
    </div>

    <!-- Contadores rápidos — LOOP OTIMIZADO -->
    <div class="grid grid-cols-2 sm:grid-cols-5 gap-2">
      <div
        v-for="counter in counters"
        :key="counter.id"
        class="bg-n-surface-1 border border-n-weak rounded-xl p-2.5 text-center shadow-sm"
      >
        <div class="text-xl mb-0.5">{{ counter.icon }}</div>
        <div class="text-lg font-bold leading-tight" :class="counter.color">
          {{ counter.count || 0 }}
        </div>
        <div
          class="text-[10px] uppercase font-bold text-n-slate-11 tracking-tight"
        >
          {{ counter.label }}
        </div>
      </div>
    </div>

    <!-- Notas gerais -->
    <div
      v-if="deployment.notes"
      class="bg-n-alpha-black2 rounded-xl p-4"
    >
      <p
        class="text-xs font-semibold text-n-slate-11 uppercase tracking-wide mb-2"
      >
        Observações
      </p>
      <p class="text-sm text-n-slate-12 whitespace-pre-wrap">
        {{ deployment.notes }}
      </p>
    </div>

    <!-- Feed de Últimas Atividades (Paginado para 5) -->
    <div class="mt-6 border-t border-n-weak pt-6">
      <h4
        class="text-sm font-bold text-n-slate-12 mb-4 flex items-center justify-between"
      >
        Registro Global Atividades
        <span
          class="text-[10px] bg-n-alpha-black2 text-n-slate-11 px-2 py-0.5 rounded-full font-semibold uppercase tracking-wide border border-n-weak"
        >
          {{ sortedActivities.length }} Total
        </span>
      </h4>

      <div class="space-y-3">
        <div
          v-if="displayedActivities.length === 0"
          class="text-center py-6 text-n-slate-11 text-[13px] italic border border-dashed border-n-weak rounded-xl"
        >
          Nenhuma atividade registrada na timeline
        </div>

        <div
          v-for="activity in displayedActivities"
          :key="activity.id"
          class="p-3 bg-n-surface-1 border border-n-weak rounded-xl shadow-sm flex flex-col gap-2"
        >
          <div class="flex justify-between items-start">
            <div class="flex items-start gap-2.5">
              <span class="text-base mt-0.5 opacity-80">{{
                getActivityIcon(activity.activity_type)
              }}</span>
              <p
                class="text-sm font-semibold text-n-slate-12 leading-snug"
              >
                {{ activity.description }}
              </p>
            </div>
            <span
              class="text-[10px] font-bold px-2 py-0.5 bg-n-alpha-black2 text-n-slate-11 rounded border border-n-weak shrink-0"
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
        <WootButton
          :disabled="currentPage === 1"
          variant="outline"
          color="slate"
          size="sm"
          @click="prevPage"
        >
          Anterior
        </WootButton>
        <span class="text-[11px] text-n-slate-11 font-medium tracking-wide">Pág. {{ currentPage }} de {{ totalPages }}</span>
        <WootButton
          :disabled="currentPage === totalPages"
          variant="outline"
          color="slate"
          size="sm"
          @click="nextPage"
        >
          Próximo
        </WootButton>
      </div>
    </div>
  </div>
</template>
