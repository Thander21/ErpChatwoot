<!--
  ERP Chatwoot - Kanban Tarefa Component
  Uses generic KanbanBoard to display conversations.
-->

<template>
  <KanbanBoard
    title="Kanban de Tarefas"
    :columns="columns"
    :cards="mappedCards"
    :loading="loading"
    loading-text="Carregando conversas..."
    :can-create-column="false"
    :can-create-card="false"
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
  // Check Snoozed first (priority)
  if (conversation.snoozed_until) return "snoozed";
  
  // Status check
  const status = conversation.status;
  
  if (status === 0) return "pending";
  if (status === 1) {
    return conversation.assignee_id ? "open_assigned" : "open_unassigned";
  }
  if (status === 2) {
    // Check 7 days limit? The fetch usually gets all, but we might want to filter display?
    // Original code filtered by 7 days. We can keep it or trust the sort.
    // Let's filter date here to be safe, return null if too old.
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    const resolvedAt = new Date(conversation.updated_at);
    if (resolvedAt < sevenDaysAgo) return null; // Don't show
    return "resolved";
  }
  
  return null;
};

const transformConversationToCard = (conversation) => {
  const columnId = determineColumnId(conversation);
  if (!columnId) return null;

  return {
    id: conversation.id,
    title: `${conversation.contact?.name || "Sem Nome"} #${conversation.display_id}`,
    description: getLastMessage(conversation),
    contact: conversation.contact,
    company: conversation.contact?.company,
    assignee: conversation.assignee,
    due_date: conversation.snoozed_until, // Use snoozed date as due date
    priority: 0,
    kanban_column_id: columnId,
    // Store original object if needed
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

    while (hasMorePages) {
      const response = await ConversationAPI.get(page);
      let pageData = response.data.payload || response.data;

      if (!Array.isArray(pageData)) {
        pageData = [];
      }

      if (pageData.length === 0) {
        hasMorePages = false;
      } else {
        allConversations.push(...pageData);
        page += 1;
        if (page > 50) hasMorePages = false; // Safety limit
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
const getLastMessage = (conversation) => {
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
