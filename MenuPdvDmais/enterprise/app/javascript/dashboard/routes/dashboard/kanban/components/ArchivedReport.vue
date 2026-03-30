<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/kanban/components/ArchivedReport.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: -
 * Description: (Adicionar descrição em português)
-->
<script setup>
import { ref, onMounted, computed } from "vue";
import { useKanban } from "../composables/useKanban";
import { useStore } from "vuex";
import { frontendURL } from "dashboard/helper/URLHelper";
import KanbanCardModal from "./modais/KanbanCardModal.vue";
import WootButton from "dashboard/components-next/button/Button.vue";
import WootSelect from "dashboard/components-next/select/Select.vue";
import Spinner from "dashboard/components-next/spinner/Spinner.vue";

const store = useStore();
const { fetchArchivedCards, loadColumns, columns } = useKanban();

const cards = ref([]);
const loading = ref(false);
const accountId = computed(() => store.getters.getCurrentAccountId);
const kanbanUrl = computed(() =>
  frontendURL(`accounts/${accountId.value}/kanban`),
);

// Modal state
const showCardModal = ref(false);
const selectedCard = ref(null);

// Dates
const currentDate = new Date();
const selectedMonth = ref(currentDate.getMonth() + 1);
const selectedYear = ref(currentDate.getFullYear());
const selectedStatus = ref("archived"); // Default to archived
const selectedAgent = ref("");
const agents = ref([]);

const fetchAgents = async () => {
  try {
    if (store.getters["agents/getAgents"].length === 0) {
      await store.dispatch("agents/get");
    }
    agents.value = store.getters["agents/getAgents"];
  } catch (e) {
    /* debug removed */
  }
};

// Filtered cards based on status
const filteredCards = computed(() => {
  if (selectedStatus.value === "all") {
    return cards.value;
  }
  if (selectedStatus.value === "archived") {
    return cards.value.filter((card) => card.archived_at && !card.deleted_at);
  }
  if (selectedStatus.value === "deleted") {
    return cards.value.filter((card) => card.deleted_at);
  }
  return cards.value;
});

// Apply Agent Filter on top of status filter
const finalFilteredCards = computed(() => {
  let result = filteredCards.value;

  if (selectedAgent.value) {
    result = result.filter((card) => {
      return card.assignee && card.assignee.id === selectedAgent.value;
    });
  }

  return result;
});

const months = [
  "Janeiro",
  "Fevereiro",
  "Março",
  "Abril",
  "Maio",
  "Junho",
  "Julho",
  "Agosto",
  "Setembro",
  "Outubro",
  "Novembro",
  "Dezembro",
];

const years = computed(() => {
  const current = new Date().getFullYear();
  const list = [];
  for (let i = current; i >= current - 5; i--) {
    list.push({ value: i, label: i.toString() });
  }
  return list;
});
 
const statusOptions = [
  { value: "all", label: "Todos os Status" },
  { value: "archived", label: "Apenas Arquivados" },
  { value: "deleted", label: "Apenas Excluídos" },
];
 
const monthOptions = months.map((m, i) => ({ value: i + 1, label: m }));
 
const agentOptions = computed(() => [
  { value: "", label: "Todos os Vendedores" },
  ...agents.value.map((a) => ({ value: a.id, label: a.name })),
]);

const fetchData = async () => {
  loading.value = true;
  try {
    cards.value = await fetchArchivedCards(
      selectedMonth.value,
      selectedYear.value,
    );
  } catch (error) {
    /* debug removed */
  } finally {
    loading.value = false;
  }
};

const formatDate = (dateString) => {
  if (!dateString) return "-";
  return new Date(dateString).toLocaleString("pt-BR");
};

// Modal Actions
const openCardModal = (card) => {
  selectedCard.value = { ...card };
  showCardModal.value = true;
};

const closeCardModal = () => {
  showCardModal.value = false;
  selectedCard.value = null;
};

// Stub handlers for modal actions (visual only for now in report)
const handleCardUpdate = () => {
  closeCardModal();
  fetchData(); // Refresh data
};

const handleCardDelete = () => {
  closeCardModal();
  fetchData();
};

const handleCardArchive = () => {
  closeCardModal();
  fetchData();
};

onMounted(() => {
  fetchData();
  loadColumns();
  fetchAgents();
});
</script>

<template>
  <div
    class="flex flex-col h-full overflow-hidden w-full max-w-6xl mx-auto gap-4 p-4"
  >
    <!-- Header Section -->
    <div class="flex flex-col gap-4 flex-shrink-0">
      <div class="flex items-center justify-between">
        <h1 class="text-2xl font-semibold text-n-slate-12">
          Relatório de Arquivados e Excluídos
        </h1>
        <WootButton
          variant="link"
          color="slate"
          size="sm"
          icon="arrow-left"
          @click="$router.push(kanbanUrl)"
        >
          Voltar para Kanban
        </WootButton>
      </div>
 
      <div
        class="flex flex-wrap items-center gap-3 bg-n-surface-1 p-3 rounded-lg border border-n-weak dark:border-n-weak shadow-sm"
      >
        <div class="flex items-center gap-2">
          <span class="text-sm font-medium text-n-slate-11">Filtros:</span>
          <WootSelect
            v-model="selectedStatus"
            :options="statusOptions"
            class="min-w-[170px]"
          />
 
          <WootSelect
            v-model="selectedMonth"
            :options="monthOptions"
            class="min-w-[130px]"
          />
 
          <WootSelect
            v-model="selectedYear"
            :options="years"
            class="min-w-[100px]"
          />
 
          <WootSelect
            v-model="selectedAgent"
            :options="agentOptions"
            class="min-w-[180px]"
          />
 
          <WootButton
            icon="filter"
            color="blue"
            @click="fetchData"
          >
            Filtrar
          </WootButton>
        </div>
      </div>
    </div>

    <!-- Content -->
    <div
      class="flex-1 overflow-hidden bg-n-surface-1 rounded-lg border border-n-weak dark:border-n-weak shadow flex flex-col"
    >
      <div v-if="loading" class="flex flex-col items-center justify-center p-12 flex-1">
        <Spinner :size="48" class="text-n-brand mb-4" />
        <p class="text-n-slate-11">Carregando relatório...</p>
      </div>

      <div
        v-else-if="finalFilteredCards.length === 0"
        class="flex flex-col items-center justify-center p-12 text-n-slate-11 flex-1"
      >
        <p class="text-lg">
          Nenhum card encontrado com os filtros selecionados.
        </p>
      </div>

      <div v-else class="overflow-auto flex-1 custom-scroll">
        <table class="w-full text-sm text-left text-n-slate-11">
          <thead
            class="text-xs text-n-slate-12 uppercase bg-n-alpha-black2 sticky top-0 border-b border-n-weak"
          >
            <tr>
              <th scope="col" class="py-3 px-6">Status</th>
              <th scope="col" class="py-3 px-6">Título</th>
              <th scope="col" class="py-3 px-6">Empresa/Contato</th>
              <th scope="col" class="py-3 px-6">Ação Por</th>
              <th scope="col" class="py-3 px-6">Data Ação</th>
              <th scope="col" class="py-3 px-6">Vendedor</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="card in finalFilteredCards"
              :key="card.id"
              class="bg-n-surface-1 border-b border-n-weak hover:bg-n-alpha-black2 cursor-pointer"
              @click="openCardModal(card)"
            >
              <td class="py-4 px-6">
                <span
                  v-if="card.deleted_at"
                  class="bg-n-ruby-3 text-n-ruby-11 text-xs font-medium px-2.5 py-0.5 rounded"
                >
                  Excluído
                </span>
                <span
                  v-else
                  class="bg-n-teal-3 text-n-teal-11 text-xs font-medium px-2.5 py-0.5 rounded"
                >
                  Arquivado
                </span>
              </td>
              <td
                class="py-4 px-6 font-medium text-n-slate-12 whitespace-nowrap"
              >
                {{ card.title }}
              </td>
              <td class="py-4 px-6 text-n-slate-12">
                <div v-if="card.company">{{ card.company.name }}</div>
                <div v-else-if="card.contact">{{ card.contact.name }}</div>
                <span v-else>-</span>
              </td>
              <td class="py-4 px-6 text-n-slate-12">
                <div v-if="card.deleted_by" class="flex items-center gap-2">
                  <img
                    v-if="card.deleted_by.thumbnail"
                    :src="card.deleted_by.thumbnail"
                    class="w-6 h-6 rounded-full"
                  />
                  <span>{{ card.deleted_by.name }}</span>
                </div>
                <div
                  v-else-if="card.archived_by"
                  class="flex items-center gap-2"
                >
                  <img
                    v-if="card.archived_by.thumbnail"
                    :src="card.archived_by.thumbnail"
                    class="w-6 h-6 rounded-full"
                  />
                  <span>{{ card.archived_by.name }}</span>
                </div>
                <span v-else>-</span>
              </td>
              <td class="py-4 px-6 text-n-slate-12">
                {{ formatDate(card.deleted_at || card.archived_at) }}
              </td>
              <td class="py-4 px-6 text-n-slate-12">
                <span v-if="card.assignee">{{ card.assignee.name }}</span>
                <span v-else>-</span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Card Modal -->
    <KanbanCardModal
      v-if="showCardModal"
      :show="showCardModal"
      :initial-data="selectedCard"
      :columns="columns"
      :loading="false"
      @close="closeCardModal"
      @submit="handleCardUpdate"
      @delete="handleCardDelete"
      @archive="handleCardArchive"
    />
  </div>
</template>
