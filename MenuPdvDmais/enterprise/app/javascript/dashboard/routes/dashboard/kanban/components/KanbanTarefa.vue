<!--
ERP Chatwoot - Kanban Tarefa Component
Projeto: ERP Kanban para Chatwoot Enterprise
Arquivo: KanbanTarefa.vue
Descrição: Componente da aba Tarefa - Kanban baseado em conversas
Autor: Thander21
Data: 2024
Versão: 1.0.0
-->

<template>
  <div class="flex flex-col gap-4">
    <!-- Header com filtros e informações -->
    <div class="flex items-center justify-between mb-4">
      <div class="flex items-center gap-4">
        <h2 class="text-xl font-semibold text-slate-900 dark:text-white">
          Kanban de Tarefas
        </h2>
        <div class="flex items-center gap-2 text-sm text-slate-600 dark:text-slate-400">
          <span>Total: {{ totalConversations }}</span>
          <button
            @click="refreshConversations"
            :disabled="loading"
            class="px-3 py-1 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 text-xs flex items-center gap-1"
          >
            <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
            </svg>
            Atualizar
          </button>
        </div>
      </div>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="flex flex-col items-center justify-center py-12">
      <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mb-4"></div>
      <p class="text-slate-600 dark:text-slate-400">Carregando conversas...</p>
    </div>

    <!-- Kanban Board -->
    <div v-else class="flex gap-4 overflow-x-auto pb-4">
      <!-- Coluna 1: Pendentes -->
      <div class="flex-shrink-0 w-80">
        <div class="bg-orange-100 dark:bg-slate-800 rounded-lg p-4 h-full">
          <h3 class="font-semibold text-orange-900 dark:text-white mb-4 flex items-center justify-between">
            <div class="flex items-center gap-2">
              <div class="w-3 h-3 bg-orange-500 rounded-full"></div>
              Pendentes
            </div>
            <span class="text-xs bg-orange-200 dark:bg-slate-700 text-orange-800 dark:text-slate-300 px-2 py-1 rounded-full">
              {{ getConversationsByStatus('pending').length }}
            </span>
          </h3>
          <div class="space-y-3 min-h-[200px]">
            <div
              v-for="conversation in getConversationsByStatus('pending')"
              :key="conversation.id"
              class="bg-white dark:bg-slate-700 rounded-lg p-3 shadow-sm border border-orange-200 dark:border-slate-600 cursor-pointer hover:shadow-md transition-shadow"
              @click="openConversation(conversation)"
            >
              <div class="flex items-start justify-between mb-2">
                <h4 class="font-medium text-slate-900 dark:text-white text-sm line-clamp-2">
                  {{ conversation.contact?.name || 'Contato sem nome' }}
                </h4>
                <span class="text-xs text-slate-500 dark:text-slate-400 flex-shrink-0 ml-2">
                  #{{ conversation.display_id }}
                </span>
              </div>
              <p class="text-xs text-slate-600 dark:text-slate-400 mb-2 line-clamp-2">
                {{ getLastMessage(conversation) }}
              </p>
              <div class="flex items-center justify-between text-xs">
                <span class="text-slate-500 dark:text-slate-400">
                  {{ formatTime(conversation.last_activity_at) }}
                </span>
                <div class="flex items-center gap-1">
                  <div class="w-2 h-2 bg-orange-500 rounded-full"></div>
                  <span class="text-orange-600 dark:text-orange-400">Pendente</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Coluna 2: Abertas não atribuídas -->
      <div class="flex-shrink-0 w-80">
        <div class="bg-red-100 dark:bg-slate-800 rounded-lg p-4 h-full">
          <h3 class="font-semibold text-red-900 dark:text-white mb-4 flex items-center justify-between">
            <div class="flex items-center gap-2">
              <div class="w-3 h-3 bg-red-500 rounded-full"></div>
              Abertas não atribuídas
            </div>
            <span class="text-xs bg-red-200 dark:bg-slate-700 text-red-800 dark:text-slate-300 px-2 py-1 rounded-full">
              {{ getConversationsByStatus('open', false).length }}
            </span>
          </h3>
          <div class="space-y-3 min-h-[200px]">
            <div
              v-for="conversation in getConversationsByStatus('open', false)"
              :key="conversation.id"
              class="bg-white dark:bg-slate-700 rounded-lg p-3 shadow-sm border border-red-200 dark:border-slate-600 cursor-pointer hover:shadow-md transition-shadow"
              @click="openConversation(conversation)"
            >
              <div class="flex items-start justify-between mb-2">
                <h4 class="font-medium text-slate-900 dark:text-white text-sm line-clamp-2">
                  {{ conversation.contact?.name || 'Contato sem nome' }}
                </h4>
                <span class="text-xs text-slate-500 dark:text-slate-400 flex-shrink-0 ml-2">
                  #{{ conversation.display_id }}
                </span>
              </div>
              <p class="text-xs text-slate-600 dark:text-slate-400 mb-2 line-clamp-2">
                {{ getLastMessage(conversation) }}
              </p>
              <div class="flex items-center justify-between text-xs">
                <span class="text-slate-500 dark:text-slate-400">
                  {{ formatTime(conversation.last_activity_at) }}
                </span>
                <div class="flex items-center gap-1">
                  <div class="w-2 h-2 bg-red-500 rounded-full"></div>
                  <span class="text-red-600 dark:text-red-400">Não atribuída</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Coluna 3: Abertas atribuídas -->
      <div class="flex-shrink-0 w-80">
        <div class="bg-blue-100 dark:bg-slate-800 rounded-lg p-4 h-full">
          <h3 class="font-semibold text-blue-900 dark:text-white mb-4 flex items-center justify-between">
            <div class="flex items-center gap-2">
              <div class="w-3 h-3 bg-blue-500 rounded-full"></div>
              Abertas atribuídas
            </div>
            <span class="text-xs bg-blue-200 dark:bg-slate-700 text-blue-800 dark:text-slate-300 px-2 py-1 rounded-full">
              {{ getConversationsByStatus('open', true).length }}
            </span>
          </h3>
          <div class="space-y-3 min-h-[200px]">
            <div
              v-for="conversation in getConversationsByStatus('open', true)"
              :key="conversation.id"
              class="bg-white dark:bg-slate-700 rounded-lg p-3 shadow-sm border border-blue-200 dark:border-slate-600 cursor-pointer hover:shadow-md transition-shadow"
              @click="openConversation(conversation)"
            >
              <div class="flex items-start justify-between mb-2">
                <h4 class="font-medium text-slate-900 dark:text-white text-sm line-clamp-2">
                  {{ conversation.contact?.name || 'Contato sem nome' }}
                </h4>
                <span class="text-xs text-slate-500 dark:text-slate-400 flex-shrink-0 ml-2">
                  #{{ conversation.display_id }}
                </span>
              </div>
              <p class="text-xs text-slate-600 dark:text-slate-400 mb-2 line-clamp-2">
                {{ getLastMessage(conversation) }}
              </p>
              <div class="flex items-center justify-between text-xs">
                <span class="text-slate-500 dark:text-slate-400">
                  {{ formatTime(conversation.last_activity_at) }}
                </span>
                <div class="flex items-center gap-1">
                  <span class="text-blue-600 dark:text-blue-400">
                    {{ conversation.assignee?.name || 'Atribuído' }}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Coluna 4: Adiadas -->
      <div class="flex-shrink-0 w-80">
        <div class="bg-yellow-100 dark:bg-slate-800 rounded-lg p-4 h-full">
          <h3 class="font-semibold text-yellow-900 dark:text-white mb-4 flex items-center justify-between">
            <div class="flex items-center gap-2">
              <div class="w-3 h-3 bg-yellow-500 rounded-full"></div>
              Adiadas
            </div>
            <span class="text-xs bg-yellow-200 dark:bg-slate-700 text-yellow-800 dark:text-slate-300 px-2 py-1 rounded-full">
              {{ getConversationsByStatus('snoozed').length }}
            </span>
          </h3>
          <div class="space-y-3 min-h-[200px]">
            <div
              v-for="conversation in getConversationsByStatus('snoozed')"
              :key="conversation.id"
              class="bg-white dark:bg-slate-700 rounded-lg p-3 shadow-sm border border-yellow-200 dark:border-slate-600 cursor-pointer hover:shadow-md transition-shadow"
              @click="openConversation(conversation)"
            >
              <div class="flex items-start justify-between mb-2">
                <h4 class="font-medium text-slate-900 dark:text-white text-sm line-clamp-2">
                  {{ conversation.contact?.name || 'Contato sem nome' }}
                </h4>
                <span class="text-xs text-slate-500 dark:text-slate-400 flex-shrink-0 ml-2">
                  #{{ conversation.display_id }}
                </span>
              </div>
              <p class="text-xs text-slate-600 dark:text-slate-400 mb-2 line-clamp-2">
                {{ getLastMessage(conversation) }}
              </p>
              <div class="flex items-center justify-between text-xs">
                <span class="text-slate-500 dark:text-slate-400">
                  Até {{ formatDate(conversation.snoozed_until) }}
                </span>
                <div class="flex items-center gap-1">
                  <div class="w-2 h-2 bg-yellow-500 rounded-full"></div>
                  <span class="text-yellow-600 dark:text-yellow-400">Adiada</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Coluna 5: Resolvidas (últimos 7 dias) -->
      <div class="flex-shrink-0 w-80">
        <div class="bg-green-100 dark:bg-slate-800 rounded-lg p-4 h-full">
          <h3 class="font-semibold text-green-900 dark:text-white mb-4 flex items-center justify-between">
            <div class="flex items-center gap-2">
              <div class="w-3 h-3 bg-green-500 rounded-full"></div>
              Resolvidas (7d)
            </div>
            <span class="text-xs bg-green-200 dark:bg-slate-700 text-green-800 dark:text-slate-300 px-2 py-1 rounded-full">
              {{ getConversationsByStatus('resolved').length }}
            </span>
          </h3>
          <div class="space-y-3 min-h-[200px]">
            <div
              v-for="conversation in getConversationsByStatus('resolved')"
              :key="conversation.id"
              class="bg-white dark:bg-slate-700 rounded-lg p-3 shadow-sm border border-green-200 dark:border-slate-600 cursor-pointer hover:shadow-md transition-shadow"
              @click="openConversation(conversation)"
            >
              <div class="flex items-start justify-between mb-2">
                <h4 class="font-medium text-slate-900 dark:text-white text-sm line-clamp-2">
                  {{ conversation.contact?.name || 'Contato sem nome' }}
                </h4>
                <span class="text-xs text-slate-500 dark:text-slate-400 flex-shrink-0 ml-2">
                  #{{ conversation.display_id }}
                </span>
              </div>
              <p class="text-xs text-slate-600 dark:text-slate-400 mb-2 line-clamp-2">
                {{ getLastMessage(conversation) }}
              </p>
              <div class="flex items-center justify-between text-xs">
                <span class="text-slate-500 dark:text-slate-400">
                  {{ formatTime(conversation.last_activity_at) }}
                </span>
                <div class="flex items-center gap-1">
                  <div class="w-2 h-2 bg-green-500 rounded-full"></div>
                  <span class="text-green-600 dark:text-green-400">Resolvida</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import ConversationAPI from 'dashboard/api/conversations';

const route = useRoute();
const router = useRouter();

const conversations = ref([]);
const loading = ref(false);

// Computed properties
const totalConversations = computed(() => conversations.value.length);

// Cache configuration
const CACHE_KEY = 'kanban_conversations_cache';
const CACHE_EXPIRY_HOURS = 1; // Cache mais curto para dados dinâmicos

// Funções de cache
const saveToCache = (data) => {
  const cacheData = {
    data: data,
    timestamp: Date.now(),
    expiry: Date.now() + (CACHE_EXPIRY_HOURS * 60 * 60 * 1000)
  };
  localStorage.setItem(CACHE_KEY, JSON.stringify(cacheData));
};

const loadFromCache = () => {
  try {
    const cached = localStorage.getItem(CACHE_KEY);
    if (!cached) return null;

    const cacheData = JSON.parse(cached);
    if (Date.now() > cacheData.expiry) {
      localStorage.removeItem(CACHE_KEY);
      return null;
    }

    return cacheData.data;
  } catch (error) {
    console.warn('Erro ao carregar cache:', error);
    return null;
  }
};

const clearCache = () => {
  localStorage.removeItem(CACHE_KEY);
};

// Funções principais
const fetchConversations = async () => {
  loading.value = true;
  try {
    // Tentar carregar do cache primeiro
    const cachedData = loadFromCache();
    if (cachedData) {
      conversations.value = cachedData;
      console.log(`Conversas carregadas do cache: ${cachedData.length} registros`);
      loading.value = false;
      return;
    }

    // Carregar todas as conversas
    console.log('Cache expirado ou inexistente, carregando da API...');
    const allConversations = [];
    let page = 1;
    let hasMorePages = true;

    while (hasMorePages) {
      const response = await ConversationAPI.get(page);
      const pageData = response.data.payload || response.data || [];

      if (pageData.length === 0) {
        hasMorePages = false;
      } else {
        allConversations.push(...pageData);
        page += 1;

        // Limite de segurança
        if (page > 50) {
          console.warn('Limite de 50 páginas atingido');
          hasMorePages = false;
        }
      }
    }

    conversations.value = allConversations;
    saveToCache(allConversations);
    console.log(`Total de conversas carregadas: ${allConversations.length}`);

  } catch (error) {
    console.error('Erro ao buscar conversas:', error);
  } finally {
    loading.value = false;
  }
};

const refreshConversations = async () => {
  clearCache();
  await fetchConversations();
};

// Filtrar conversas por status
const getConversationsByStatus = (status, assigned = null) => {
  const sevenDaysAgo = new Date();
  sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

  return conversations.value.filter(conversation => {
    // Filtro de status
    if (status === 'pending' && conversation.status !== 0) return false;
    if (status === 'open' && conversation.status !== 1) return false;
    if (status === 'resolved' && conversation.status !== 2) return false;
    if (status === 'snoozed' && !conversation.snoozed_until) return false;

    // Filtro específico para abertas atribuídas/não atribuídas
    if (status === 'open') {
      if (assigned === true && !conversation.assignee_id) return false;
      if (assigned === false && conversation.assignee_id) return false;
    }

    // Filtro de 7 dias para resolvidas
    if (status === 'resolved') {
      const resolvedAt = new Date(conversation.updated_at);
      if (resolvedAt < sevenDaysAgo) return false;
    }

    return true;
  }).sort((a, b) => new Date(b.last_activity_at) - new Date(a.last_activity_at));
};

// Utilitários
const getLastMessage = (conversation) => {
  if (!conversation.messages || conversation.messages.length === 0) {
    return 'Sem mensagens';
  }
  const lastMessage = conversation.messages[conversation.messages.length - 1];
  return lastMessage.content || 'Mensagem sem conteúdo';
};

const formatTime = (dateString) => {
  if (!dateString) return '';
  const date = new Date(dateString);
  const now = new Date();
  const diffInHours = (now - date) / (1000 * 60 * 60);

  if (diffInHours < 1) {
    return `${Math.floor(diffInHours * 60)}min atrás`;
  } else if (diffInHours < 24) {
    return `${Math.floor(diffInHours)}h atrás`;
  } else {
    return `${Math.floor(diffInHours / 24)}d atrás`;
  }
};

const formatDate = (dateString) => {
  if (!dateString) return '';
  return new Date(dateString).toLocaleDateString('pt-BR');
};

const openConversation = (conversation) => {
  // Abrir conversa no Chatwoot
  const conversationUrl = `/app/accounts/${route.params.accountId}/conversations/${conversation.id}`;
  window.open(conversationUrl, '_blank');
};

onMounted(() => {
  fetchConversations();
});
</script>

<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
