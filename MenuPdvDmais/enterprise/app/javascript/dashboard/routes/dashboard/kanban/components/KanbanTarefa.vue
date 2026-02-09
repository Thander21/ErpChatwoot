<!--
  ERP Chatwoot - Kanban Tarefa Component
  Uses generic KanbanBoard to display conversations.
-->

<template>
  <div class="h-full">
    <KanbanBoard
      title="Kanban de Tarefas"
      :columns="columns"
      :cards="mappedCards"
      :loading="loading"
      loading-text="Carregando conversas..."
      :can-create-column="false"
      :can-create-card="false"
      :show-priority-color="true"
      @edit-card="openConversation"
    >
      <template #extra-info>
         <span>•</span>
         <button
          @click="refreshConversations"
          :disabled="loading"
          class="px-2 hover:text-blue-600 disabled:opacity-50 text-xs flex items-center gap-1 focus:outline-none"
          title="Atualizar lista"
        >
          <svg
            class="w-3 h-3"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"
            />
          </svg>
        </button>
      </template>
    </KanbanBoard>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from "vue";
import { useRoute } from "vue-router";
import ConversationAPI from "dashboard/api/conversations";
import KanbanBoard from "./KanbanBoard.vue";

const route = useRoute();

const loading = ref(false);
const conversations = ref([]);

// Configuration: Fixed Columns
const columns = [
  { id: "pending", name: "Pendentes", color: "#f97316", position: 0 },
  { id: "open_unassigned", name: "Abertas não atribuídas", color: "#dc2626", position: 1 },
  { id: "open_assigned", name: "Abertas atribuídas", color: "#2563eb", position: 2 },
  { id: "snoozed", name: "Adiadas", color: "#eab308", position: 3 },
  { id: "resolved", name: "Resolvidas (7d)", color: "#16a34a", position: 4 },
];

// Helper to determine column ID for a conversation
const determineColumnId = (conversation) => {
  // Check Snoozed first
  if (conversation.snoozed_until || conversation.status === "snoozed" || conversation.status === 3) return "snoozed";
  
  // Status check
  const status = conversation.status;
  
  // Pending
  if (status === 'pending' || status === 2) return "pending";

  // Open
  if (status === 'open' || status === 0) {
    // Assignee is in meta.assignee
    const assignee = conversation.meta?.assignee;
    return assignee ? "open_assigned" : "open_unassigned";
  }

  // Resolved
  if (status === 'resolved' || status === 1) {
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    const resolvedAt = new Date(conversation.updated_at * 1000); // API returns timestamp in seconds?
    // Wait, API returns floating point: json.updated_at conversation.updated_at.to_f
    // So distinct from Date object constructor? 
    // new Date(seconds * 1000) for JS.
    // Let's assume input is standard timestamp.
    // If to_f returns seconds since epoch.
    if (conversation.updated_at && new Date(conversation.updated_at * 1000) < sevenDaysAgo) return null; 
    return "resolved";
  }
  
  return null;
};

const transformConversationToCard = (conversation) => {
  const columnId = determineColumnId(conversation);
  if (!columnId) return null;

  // Extract data from meta
  const contact = conversation.meta?.sender;
  const assignee = conversation.meta?.assignee;
  // Get correct Company name if available
  const company = contact?.company || conversation.meta?.company;

  return {
    id: conversation.id, // API returns display_id as id
    title: `${contact?.name || "Sem Nome"} #${conversation.id}`,
    // Ensure description is last message content
    description: getLastMessage(conversation),
    contact: contact,
    company: company,
    assignee: assignee,
    // Use conversation due date if available, or snoozed until
    due_date: conversation.snoozed_until, 
    // Priority string is passed directly (low, medium, high, urgent). Default to low if null.
    priority: conversation.priority || "low",
    kanban_column_id: columnId,
    original_conversation: conversation
  };
};

const mappedCards = computed(() => {
  return conversations.value
    .map(transformConversationToCard)
    .filter(card => card !== null);
});

// Fetch Logic (No Cache)
const fetchConversations = async () => {
  loading.value = true;
  try {
    const allConversations = [];
    let page = 1;
    let hasMorePages = true;
    const accountId = route.params.accountId;

    while (hasMorePages) {
      // Use axios directly to ensure params are passed correctly
      // status: 'all' fetches pending, open, snoozed, and resolved
      const response = await window.axios.get(`/api/v1/accounts/${accountId}/conversations`, {
        params: {
          page: page,
          status: 'all'
        }
      });
      
      let pageData = response.data.payload || response.data.data?.payload || [];

      // Handle potential meta structure
      if (response.data.data && Array.isArray(response.data.data)) {
         pageData = response.data.data;
      }
      
      if (!Array.isArray(pageData)) {
        pageData = [];
      }

      if (pageData.length === 0) {
        hasMorePages = false;
      } else {
        allConversations.push(...pageData);
        page += 1;
        // Increase safety limit for production, but kept at 50 for now or until count is reached
        if (page > 50) hasMorePages = false; 
      }
    }
    
    conversations.value = allConversations;
  } catch (error) {
    console.error("Erro ao buscar conversas:", error);
  } finally {
    loading.value = false;
  }
};

const refreshConversations = async () => {
  await fetchConversations();
};

// Utilities
// Utilities
const getLastMessage = (conversation) => {
  if (conversation.last_non_activity_message) {
    return conversation.last_non_activity_message.content || "Mensagem sem conteúdo";
  }
  if (!conversation.messages || conversation.messages.length === 0) {
    return "Sem mensagens";
  }
  const lastMessage = conversation.messages[conversation.messages.length - 1];
  return lastMessage.content || "Mensagem sem conteúdo";
};

const openConversation = (card) => {
  // Use original conversation ID
  const conversationUrl = `/app/accounts/${route.params.accountId}/conversations/${card.id}`;
  window.open(conversationUrl, "_blank");
};

onMounted(() => {
  fetchConversations();
});
</script>
