<template>
  <div
    class="flex flex-col h-full overflow-hidden w-full max-w-6xl mx-auto gap-4 p-4"
  >
    <!-- Header Section -->
    <div class="flex flex-col gap-4 flex-shrink-0">
      <div class="flex items-center justify-between">
        <h1 class="text-2xl font-bold text-slate-900 dark:text-white">
          Relatório de Arquivados e Excluídos
        </h1>
        <router-link
          :to="kanbanUrl"
          class="text-sm text-blue-600 dark:text-blue-400 hover:underline"
        >
          Voltar para Kanban
        </router-link>
      </div>

      <!-- Filters Bar -->
      <div
        class="flex flex-wrap items-center gap-2 bg-white dark:bg-slate-800 p-3 rounded-lg border border-slate-200 dark:border-slate-700 shadow-sm"
      >
        <div class="flex items-center gap-2">
          <span class="text-sm font-medium text-slate-700 dark:text-slate-300"
            >Filtros:</span
          >
          <!-- Status Filter -->
          <select
            v-model="selectedStatus"
            class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block p-2 dark:bg-slate-700 dark:border-slate-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
          >
            <option value="all">Todos os Status</option>
            <option value="archived">Apenas Arquivados</option>
            <option value="deleted">Apenas Excluídos</option>
          </select>

          <select
            v-model="selectedMonth"
            class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block p-2 dark:bg-slate-700 dark:border-slate-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
          >
            <option
              v-for="(month, index) in months"
              :key="index"
              :value="index + 1"
            >
              {{ month }}
            </option>
          </select>

          <select
            v-model="selectedYear"
            class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block p-2 dark:bg-slate-700 dark:border-slate-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
          >
            <option v-for="year in years" :key="year" :value="year">
              {{ year }}
            </option>
          </select>

          <!-- Agent Filter -->
          <select
            v-model="selectedAgent"
            class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block p-2 dark:bg-slate-700 dark:border-slate-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
          >
            <option value="">Todos os Vendedores</option>
            <option v-for="agent in agents" :key="agent.id" :value="agent.id">
              {{ agent.name }}
            </option>
          </select>

          <button
            @click="fetchData"
            class="text-white bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 font-medium rounded-lg text-sm px-4 py-2 dark:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none dark:focus:ring-blue-800 ml-2"
          >
            Filtrar
          </button>
        </div>
      </div>
    </div>

    <!-- Content -->
    <div
      class="flex-1 overflow-hidden bg-white dark:bg-slate-900 rounded-lg border border-slate-200 dark:border-slate-700 shadow flex flex-col"
    >
      <div v-if="loading" class="flex items-center justify-center p-12 flex-1">
        <div
          class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"
        ></div>
      </div>

      <div
        v-else-if="finalFilteredCards.length === 0"
        class="flex flex-col items-center justify-center p-12 text-slate-500 flex-1"
      >
        <p class="text-lg">
          Nenhum card encontrado com os filtros selecionados.
        </p>
      </div>

      <div v-else class="overflow-auto flex-1 custom-scroll">
        <table
          class="w-full text-sm text-left text-gray-500 dark:text-gray-400"
        >
          <thead
            class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-slate-900 dark:text-white sticky top-0 border-b border-gray-200 dark:border-gray-700"
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
              class="bg-white border-b dark:bg-slate-900 dark:border-gray-800 hover:bg-gray-50 dark:hover:bg-slate-800 cursor-pointer"
              @click="openCardModal(card)"
            >
              <td class="py-4 px-6">
                <span
                  v-if="card.deleted_at"
                  class="bg-red-100 text-red-800 text-xs font-medium px-2.5 py-0.5 rounded dark:bg-red-900 dark:text-red-300"
                >
                  Excluído
                </span>
                <span
                  v-else
                  class="bg-green-100 text-green-800 text-xs font-medium px-2.5 py-0.5 rounded dark:bg-green-900 dark:text-green-300"
                >
                  Arquivado
                </span>
              </td>
              <td
                class="py-4 px-6 font-medium text-gray-900 whitespace-nowrap dark:text-white"
              >
                {{ card.title }}
              </td>
              <td class="py-4 px-6 dark:text-white">
                <div v-if="card.company">{{ card.company.name }}</div>
                <div v-else-if="card.contact">{{ card.contact.name }}</div>
                <span v-else>-</span>
              </td>
              <td class="py-4 px-6 dark:text-white">
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
              <td class="py-4 px-6 dark:text-white">
                {{ formatDate(card.deleted_at || card.archived_at) }}
              </td>
              <td class="py-4 px-6 dark:text-white">
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

<script setup>
import { ref, onMounted, computed } from "vue";
import { useKanban } from "../composables/useKanban";
import { useStore } from "vuex";
import { frontendURL } from "dashboard/helper/URLHelper";
import KanbanCardModal from "./modais/KanbanCardModal.vue";

const store = useStore();
const { fetchArchivedCards, loadColumns, columns } = useKanban();

const cards = ref([]);
const loading = ref(false);
const accountId = computed(() => store.getters["getCurrentAccountId"]);
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
    console.error("Error fetching agents", e);
  }
};

// Filtered cards based on status
const filteredCards = computed(() => {
  if (selectedStatus.value === "all") {
    return cards.value;
  } else if (selectedStatus.value === "archived") {
    return cards.value.filter((card) => card.archived_at && !card.deleted_at);
  } else if (selectedStatus.value === "deleted") {
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
    list.push(i);
  }
  return list;
});

const fetchData = async () => {
  loading.value = true;
  try {
    cards.value = await fetchArchivedCards(
      selectedMonth.value,
      selectedYear.value,
    );
  } catch (error) {
    console.error(error);
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
