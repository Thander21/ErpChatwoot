<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/kanban/components/KanbanAgenda.vue
 * Last Modified: 17/06/2026
 * Dependencies: vue
 * Calls: -
 * Description: Componente para exibir os cards do Comercial e Tarefas agendadas, organizados por dias da semana e filtrados por agente.
-->
<script setup>
import { ref, computed, onMounted } from "vue";
import { useRoute } from "vue-router";
import { useStore } from "vuex";
import WootSelect from "dashboard/components-next/select/Select.vue";
import WootButton from "dashboard/components-next/button/Button.vue";
import KanbanCard from "./KanbanCard.vue";

const route = useRoute();
const store = useStore();

const loading = ref(false);
const kanbanCardsData = ref([]);
const tarefasData = ref([]);

const selectedAgentId = ref("");
const agents = ref([]);

// Gerenciamento de Semanas (Navegação)
const currentWeekOffset = ref(0); // 0 = esta semana, -1 semana passada, 1 próxima semana

// Helper de Datas
const getStartOfWeek = (date) => {
  const d = new Date(date);
  const day = d.getDay();
  const diff = d.getDate() - day + (day === 0 ? -6 : 1); // Ajuste para que segunda seja o primeiro dia
  return new Date(d.setDate(diff));
};

const weekDays = computed(() => {
  const today = new Date();
  today.setDate(today.getDate() + currentWeekOffset.value * 7);
  const startOfWeek = getStartOfWeek(today);

  const days = [];
  const dayNames = ["Segunda", "Terça", "Quarta", "Quinta", "Sexta", "Sábado", "Domingo"];

  for (let i = 0; i < 7; i++) {
    const d = new Date(startOfWeek);
    d.setDate(startOfWeek.getDate() + i);
    days.push({
      id: i,
      name: dayNames[i],
      dateString: d.toISOString().split("T")[0], // YYYY-MM-DD local timezone roughly, or better use local formatter
      formattedDate: `${String(d.getDate()).padStart(2, "0")}/${String(d.getMonth() + 1).padStart(2, "0")}`,
      dateObj: d,
    });
  }
  return days;
});

const previousWeek = () => {
  currentWeekOffset.value--;
};

const nextWeek = () => {
  currentWeekOffset.value++;
};

const resetWeek = () => {
  currentWeekOffset.value = 0;
};

// Fetch Agents
const fetchAgents = async () => {
  try {
    if (store.getters["agents/getAgents"].length === 0) {
      await store.dispatch("agents/get");
    }
    agents.value = store.getters["agents/getAgents"];
  } catch (e) {
    agents.value = store.getters["agents/getAgents"] || [];
  }
};

const agentOptions = computed(() => {
  const options = [{ value: "", label: "Todos os Agentes" }];
  return options.concat(
    agents.value.map((a) => ({ value: a.id, label: a.name }))
  );
});

// Fetch Data
const fetchData = async () => {
  loading.value = true;
  const accountId = route.params.accountId;

  try {
    // 1. Fetch Comercial Cards
    const cardsResponse = await window.axios.get(
      `/enterprise/api/v1/accounts/${accountId}/kanban_cards`
    );
    kanbanCardsData.value = cardsResponse.data || [];

    // 2. Fetch Tarefas (Conversations)
    const tarefasResponse = await window.axios.get(
      `/enterprise/api/v1/accounts/${accountId}/kanban_cards/tarefas_board`
    );
    tarefasData.value = tarefasResponse.data.payload || [];
  } catch (error) {
    console.error("Erro ao carregar dados da agenda", error);
  } finally {
    loading.value = false;
  }
};

// Data Normalization Helpers
const transformConversationToAgendaCard = (conversation) => {
  // Apenas pendentes ou adiadas
  // Pendente: status == 2 ("pending") ou "pending"
  // Adiada: status == 3 ("snoozed") ou "snoozed"
  const status = conversation.status;
  const isPendingOrSnoozed = status === "pending" || status === 2 || status === "snoozed" || status === 3;
  
  if (!isPendingOrSnoozed) return null;
  if (!conversation.snoozed_until) return null; // Sem data não aparece na agenda

  const contact = conversation.meta?.sender;
  const assignee = conversation.meta?.assignee;
  const company = contact?.company || conversation.meta?.company;

  const dateObj = new Date(conversation.snoozed_until);
  const localDateStr = `${dateObj.getFullYear()}-${String(dateObj.getMonth() + 1).padStart(2, "0")}-${String(dateObj.getDate()).padStart(2, "0")}`;

  return {
    id: `conv_${conversation.id}`,
    original_id: conversation.id,
    type: "tarefa",
    title: `${contact?.name || "Sem Nome"} #${conversation.id}`,
    description: conversation.last_non_activity_message || "Tarefa pendente/adiada",
    contact: contact,
    company: company,
    assignee: assignee,
    implementer: null,
    due_date: localDateStr, // Usando a data formatada
    priority: conversation.priority || "low",
    original_data: conversation,
    agent_id: assignee?.id
  };
};

const transformKanbanCardToAgendaCard = (card) => {
  if (!card.due_date) return null;

  // Usa apenas a parte da data caso seja datetime
  const localDateStr = card.due_date.split("T")[0];

  return {
    id: `card_${card.id}`,
    original_id: card.id,
    type: "comercial",
    title: card.title,
    description: card.description || "Card do Comercial",
    contact: card.contact,
    company: card.company,
    assignee: card.assignee,
    implementer: card.implementer,
    due_date: localDateStr,
    priority: card.priority || "low",
    original_data: card,
    // Prioriza implantador sobre o vendedor
    agent_id: card.implementer?.id || card.assignee?.id
  };
};

// Computed Agrupado
const cardsByDay = computed(() => {
  // Normalize e filtre por agente
  const normalizedTarefas = tarefasData.value
    .map(transformConversationToAgendaCard)
    .filter(Boolean);

  const normalizedCards = kanbanCardsData.value
    .map(transformKanbanCardToAgendaCard)
    .filter(Boolean);

  let allCards = [...normalizedTarefas, ...normalizedCards];

  // Aplicar Filtro de Agente
  if (selectedAgentId.value) {
    allCards = allCards.filter(card => card.agent_id === selectedAgentId.value);
  }

  // Agrupar nos dias da semana
  const result = {};
  weekDays.value.forEach(day => {
    result[day.dateString] = allCards.filter(card => card.due_date === day.dateString);
  });

  return result;
});

const openCard = (card) => {
  if (card.type === "tarefa") {
    const conversationUrl = `/app/accounts/${route.params.accountId}/conversations/${card.original_id}`;
    window.open(conversationUrl, "_blank");
  } else {
    // Para comercial, seria ideal abrir o modal de edição, mas a aba Agenda é focada em leitura.
    // Vamos emitir ou permitir que se veja as infos. Como KanbanCard aceita cliques...
    // Se precisarmos editar, teríamos que incorporar o modal. Por hora, apenas alerta ou redireciona.
  }
};

onMounted(() => {
  fetchAgents();
  fetchData();
});
</script>

<template>
  <div class="flex flex-col h-full bg-n-surface-1">
    <!-- Header / Filtros -->
    <div class="flex flex-wrap items-center justify-between p-1 bg-n-surface-1 gap-4">
      <div class="flex items-center gap-4">
        <h2 class="text-lg font-bold text-n-slate-12 m-0 flex items-center gap-2">
          <span class="i-lucide-calendar text-n-slate-11"></span>
          Agenda da Semana
        </h2>
        
        <!-- Navegação de Semanas -->
        <div class="flex items-center gap-2 ml-4 bg-n-alpha-1 rounded-lg p-1">
          <button
            class="p-1 hover:bg-n-alpha-2 rounded text-n-slate-11 hover:text-n-slate-12 transition-colors flex items-center justify-center"
            @click="previousWeek"
            title="Semana Anterior"
          >
            <span class="i-lucide-chevron-left text-xl block"></span>
          </button>
          <span class="text-sm font-medium text-n-slate-12 min-w-[140px] text-center">
            {{ weekDays[0]?.formattedDate }} - {{ weekDays[6]?.formattedDate }}
          </span>
          <button
            class="p-1 hover:bg-n-alpha-2 rounded text-n-slate-11 hover:text-n-slate-12 transition-colors flex items-center justify-center"
            @click="nextWeek"
            title="Próxima Semana"
          >
            <span class="i-lucide-chevron-right text-xl block"></span>
          </button>
          <button
            v-if="currentWeekOffset !== 0"
            class="px-2 py-1 text-xs font-medium bg-n-surface-1 border border-n-weak hover:bg-n-alpha-1 rounded text-n-slate-11 transition-colors"
            @click="resetWeek"
          >
            Hoje
          </button>
        </div>
      </div>

      <div class="flex items-center gap-3">
        <WootSelect
          v-model="selectedAgentId"
          :options="agentOptions"
          class="w-64 mb-0"
        />
        <WootButton
          variant="ghost"
          color="slate"
          icon="refresh"
          :is-loading="loading"
          @click="fetchData"
        />
      </div>
    </div>

    <!-- Agenda Grid -->
    <div class="flex-1 min-h-0 overflow-x-auto p-1">
      <div v-if="loading" class="flex h-full items-center justify-center text-n-slate-11">
        Carregando agenda...
      </div>
      <div v-else class="flex h-full min-w-max gap-2">
        <!-- Coluna de cada dia -->
        <div
          v-for="day in weekDays"
          :key="day.id"
          class="flex-shrink-0 w-72 sm:w-80 h-full max-h-full flex flex-col"
        >
          <div class="bg-n-solid-1 rounded-lg p-2 flex flex-col h-full max-h-full">
            <!-- Cabeçalho da Coluna -->
            <div class="flex items-center justify-between mb-2 flex-shrink-0">
              <div class="flex items-center gap-2">
                <h3 class="font-semibold text-n-slate-12">
                  {{ day.name }}
                </h3>
                <span class="text-xs bg-n-alpha-black2 text-n-slate-11 px-2 py-1 rounded-full">
                  {{ cardsByDay[day.dateString]?.length || 0 }}
                </span>
              </div>
              <div class="text-xs text-n-slate-11">{{ day.formattedDate }}</div>
            </div>

            <!-- Cards do Dia -->
            <div class="space-y-3 flex-1 overflow-y-auto min-h-[100px] h-full kanban-column pr-1">
              <template v-if="cardsByDay[day.dateString]?.length > 0">
              <div
                v-for="card in cardsByDay[day.dateString]"
                :key="card.id"
                class="relative"
              >
                <!-- Badge indicador da origem -->
                <div 
                  class="absolute top-2 right-2 text-[10px] font-bold px-1.5 py-0.5 rounded shadow-sm z-10"
                  :class="card.type === 'tarefa' ? 'bg-orange-100 text-orange-800 border border-orange-200' : 'bg-blue-100 text-blue-800 border border-blue-200'"
                >
                  {{ card.type === 'tarefa' ? 'Tarefa' : 'Comercial' }}
                </div>
                
                <KanbanCard
                  :card="card"
                  :show-priority-color="true"
                  :hide-actions="true"
                  @click="openCard(card)"
                  class="cursor-pointer hover:border-n-brand transition-colors"
                />
              </div>
            </template>
            <div v-else class="flex h-32 items-center justify-center text-xs text-n-slate-11 italic">
              Nenhum agendamento
            </div>
          </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
