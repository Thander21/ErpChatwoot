<!--
ERP Chatwoot - Kanban Comercial Component
Projeto: ERP Kanban para Chatwoot Enterprise
Arquivo: KanbanComercial.vue
Descrição: Componente da aba Comercial - Kanban customizável
Autor: Thander21
Data: 2024
Versão: 1.0.0
-->

<template>
  <div class="flex flex-col gap-4">
    <!-- Header com controles -->
    <div class="flex items-center justify-between mb-4">
      <div class="flex items-center gap-4">
        <h2 class="text-xl font-semibold text-slate-900 dark:text-white">
          Kanban Comercial
        </h2>
        <div class="flex items-center gap-2 text-sm text-slate-600 dark:text-slate-400">
          <span>{{ kanbanCards.length }} cards</span>
          <span>•</span>
          <span>{{ columns.length }} colunas</span>
        </div>
      </div>

      <div class="flex gap-2">
        <button
          @click="showNewCardModal = true"
          class="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 text-sm flex items-center gap-2"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
          </svg>
          Novo Card
        </button>

        <button
          @click="showNewColumnModal = true"
          class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 text-sm flex items-center gap-2"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
          </svg>
          Nova Coluna
        </button>
      </div>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="flex flex-col items-center justify-center py-12">
      <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mb-4"></div>
      <p class="text-slate-600 dark:text-slate-400">Carregando kanban comercial...</p>
    </div>

    <!-- Kanban Board -->
    <div v-else class="flex gap-4 overflow-x-auto pb-4 min-h-[600px]">
      <div
        v-for="column in sortedColumns"
        :key="column.id"
        class="flex-shrink-0 w-80"
      >
        <div class="bg-gray-100 dark:bg-slate-800 rounded-lg p-4 h-full">
          <!-- Column Header -->
          <div class="flex items-center justify-between mb-4">
            <div class="flex items-center gap-2">
              <div
                class="w-3 h-3 rounded-full"
                :style="{ backgroundColor: column.color || '#6b7280' }"
              ></div>
              <h3 class="font-semibold text-slate-900 dark:text-white">
                {{ column.name }}
              </h3>
              <span class="text-xs bg-gray-200 dark:bg-slate-700 text-slate-700 dark:text-slate-300 px-2 py-1 rounded-full">
                {{ getCardsByColumn(column.id).length }}
              </span>
            </div>

            <!-- Column Actions -->
            <div class="flex gap-1">
              <button
                @click="editColumn(column)"
                class="p-1 hover:bg-gray-200 dark:hover:bg-slate-700 rounded text-slate-600 dark:text-slate-400"
                title="Editar coluna"
              >
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                </svg>
              </button>

              <button
                v-if="columns.length > 1"
                @click="deleteColumn(column)"
                class="p-1 hover:bg-red-100 dark:hover:bg-red-900 rounded text-red-600 dark:text-red-400"
                title="Excluir coluna"
              >
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                </svg>
              </button>
            </div>
          </div>

          <!-- Cards Container -->
          <div
            class="space-y-3 min-h-[200px] kanban-column"
            :data-column-id="column.id"
            @drop="onDrop($event, column.id)"
            @dragover.prevent
            @dragenter.prevent
          >
            <!-- Add Card Button -->
            <button
              @click="addCardToColumn(column.id)"
              class="w-full p-3 border-2 border-dashed border-gray-300 dark:border-slate-600 rounded-lg text-gray-500 dark:text-slate-400 hover:border-gray-400 dark:hover:border-slate-500 hover:text-gray-600 dark:hover:text-slate-300 transition-colors text-sm"
            >
              + Adicionar card
            </button>

            <!-- Cards -->
            <div
              v-for="card in getCardsByColumn(column.id)"
              :key="card.id"
              class="bg-white dark:bg-slate-700 rounded-lg p-3 shadow-sm border border-gray-200 dark:border-slate-600 cursor-move hover:shadow-md transition-shadow"
              :class="{ 'ring-2 ring-blue-500': draggedCard?.id === card.id }"
              draggable="true"
              @dragstart="onDragStart($event, card)"
              @click="editCard(card)"
            >
              <!-- Card Header -->
              <div class="flex items-start justify-between mb-2">
                <h4 class="font-medium text-slate-900 dark:text-white text-sm line-clamp-2 flex-1">
                  {{ card.title }}
                </h4>
                <div class="flex gap-1 ml-2">
                  <span
                    v-if="card.conversation_id"
                    class="text-xs bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200 px-1.5 py-0.5 rounded"
                    title="Vinculado a conversa"
                  >
                    💬
                  </span>
                  <span
                    v-if="card.priority > 0"
                    class="text-xs px-1.5 py-0.5 rounded"
                    :class="getPriorityClass(card.priority)"
                  >
                    {{ getPriorityIcon(card.priority) }}
                  </span>
                </div>
              </div>

              <!-- Card Content -->
              <div v-if="card.description" class="text-xs text-slate-600 dark:text-slate-400 mb-2 line-clamp-2">
                {{ card.description }}
              </div>

              <!-- Card Footer -->
              <div class="flex items-center justify-between text-xs">
                <div class="flex items-center gap-2">
                  <span v-if="card.contact" class="text-slate-500 dark:text-slate-400">
                    👤 {{ card.contact.name }}
                  </span>
                  <span v-if="card.due_date" class="text-slate-500 dark:text-slate-400">
                    📅 {{ formatDate(card.due_date) }}
                  </span>
                </div>
                <button
                  @click.stop="deleteCard(card)"
                  class="text-red-500 hover:text-red-700 dark:text-red-400 dark:hover:text-red-300 p-1"
                  title="Excluir card"
                >
                  <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Novo Card -->
    <div
      v-if="showNewCardModal"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
      @click="closeNewCardModal"
    >
      <div
        class="bg-white dark:bg-slate-900 rounded-lg p-6 w-full max-w-md mx-4"
        @click.stop
      >
        <h2 class="text-xl font-bold mb-4 text-slate-900 dark:text-white">
          Novo Card
        </h2>
        <form @submit.prevent="createCard" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
              Título *
            </label>
            <input
              v-model="newCardForm.title"
              type="text"
              required
              class="w-full px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white"
              placeholder="Digite o título do card"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
              Descrição
            </label>
            <textarea
              v-model="newCardForm.description"
              rows="3"
              class="w-full px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white"
              placeholder="Digite a descrição (opcional)"
            ></textarea>
          </div>

          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
                Coluna
              </label>
              <select
                v-model="newCardForm.kanban_column_id"
                required
                class="w-full px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white"
              >
                <option value="">Selecione uma coluna</option>
                <option
                  v-for="column in columns"
                  :key="column.id"
                  :value="column.id"
                >
                  {{ column.name }}
                </option>
              </select>
            </div>

            <div>
              <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
                Prioridade
              </label>
              <select
                v-model="newCardForm.priority"
                class="w-full px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white"
              >
                <option :value="0">Baixa</option>
                <option :value="1">Normal</option>
                <option :value="2">Alta</option>
                <option :value="3">Urgente</option>
              </select>
            </div>
          </div>

          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
              Data de vencimento
            </label>
            <input
              v-model="newCardForm.due_date"
              type="date"
              class="w-full px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white"
            />
          </div>

          <div class="flex gap-2 pt-4">
            <button
              type="submit"
              :disabled="creatingCard"
              class="flex-1 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:opacity-50"
            >
              {{ creatingCard ? 'Criando...' : 'Criar Card' }}
            </button>
            <button
              type="button"
              @click="closeNewCardModal"
              class="px-4 py-2 bg-gray-300 dark:bg-slate-600 text-slate-700 dark:text-slate-300 rounded-lg hover:bg-gray-400 dark:hover:bg-slate-500"
            >
              Cancelar
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Modal Nova Coluna -->
    <div
      v-if="showNewColumnModal"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
      @click="closeNewColumnModal"
    >
      <div
        class="bg-white dark:bg-slate-900 rounded-lg p-6 w-full max-w-md mx-4"
        @click.stop
      >
        <h2 class="text-xl font-bold mb-4 text-slate-900 dark:text-white">
          {{ editingColumn ? 'Editar Coluna' : 'Nova Coluna' }}
        </h2>
        <form @submit.prevent="editingColumn ? updateColumn() : createColumn()" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
              Nome *
            </label>
            <input
              v-model="newColumnForm.name"
              type="text"
              required
              class="w-full px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white"
              placeholder="Digite o nome da coluna"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
              Cor
            </label>
            <input
              v-model="newColumnForm.color"
              type="color"
              class="w-full h-10 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
              Ordem
            </label>
            <input
              v-model.number="newColumnForm.position"
              type="number"
              min="0"
              class="w-full px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white"
              placeholder="0"
            />
          </div>

          <div class="flex gap-2 pt-4">
            <button
              type="submit"
              :disabled="creatingColumn"
              class="flex-1 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
            >
              {{ creatingColumn ? 'Salvando...' : (editingColumn ? 'Atualizar' : 'Criar Coluna') }}
            </button>
            <button
              type="button"
              @click="editingColumn ? cancelEditColumn() : closeNewColumnModal()"
              class="px-4 py-2 bg-gray-300 dark:bg-slate-600 text-slate-700 dark:text-slate-300 rounded-lg hover:bg-gray-400 dark:hover:bg-slate-500"
            >
              Cancelar
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { useRoute } from 'vue-router';
import KanbanCardsAPI from 'dashboard/api/kanbanCards';

// Estado reativo
const columns = ref([]);
const kanbanCards = ref([]);
const loading = ref(false);
const draggedCard = ref(null);

// Modais
const showNewCardModal = ref(false);
const showNewColumnModal = ref(false);
const editingColumn = ref(null);
const creatingCard = ref(false);
const creatingColumn = ref(false);

// Formulários
const newCardForm = ref({
  title: '',
  description: '',
  kanban_column_id: '',
  priority: 0,
  due_date: ''
});

const newColumnForm = ref({
  name: '',
  color: '#6b7280',
  position: 0
});

const route = useRoute();

// Computed properties
const sortedColumns = computed(() => {
  return [...columns.value].sort((a, b) => (a.position || 0) - (b.position || 0));
});

// Cache keys
const COLUMNS_CACHE_KEY = 'kanban_comercial_columns';
const CARDS_CACHE_KEY = 'kanban_comercial_cards';

// Funções de cache
const saveColumnsToCache = (data) => {
  const cacheData = {
    data: data,
    timestamp: Date.now(),
    expiry: Date.now() + (24 * 60 * 60 * 1000) // 24 horas
  };
  localStorage.setItem(COLUMNS_CACHE_KEY, JSON.stringify(cacheData));
};

const loadColumnsFromCache = () => {
  try {
    const cached = localStorage.getItem(COLUMNS_CACHE_KEY);
    if (!cached) return null;

    const cacheData = JSON.parse(cached);
    if (Date.now() > cacheData.expiry) {
      localStorage.removeItem(COLUMNS_CACHE_KEY);
      return null;
    }

    return cacheData.data;
  } catch (error) {
    console.warn('Erro ao carregar cache de colunas:', error);
    return null;
  }
};

const saveCardsToCache = (data) => {
  const cacheData = {
    data: data,
    timestamp: Date.now(),
    expiry: Date.now() + (60 * 60 * 1000) // 1 hora
  };
  localStorage.setItem(CARDS_CACHE_KEY, JSON.stringify(cacheData));
};

const loadCardsFromCache = () => {
  try {
    const cached = localStorage.getItem(CARDS_CACHE_KEY);
    if (!cached) return null;

    const cacheData = JSON.parse(cached);
    if (Date.now() > cacheData.expiry) {
      localStorage.removeItem(CARDS_CACHE_KEY);
      return null;
    }

    return cacheData.data;
  } catch (error) {
    console.warn('Erro ao carregar cache de cards:', error);
    return null;
  }
};

// Inicializar dados padrão se não existirem
const initializeDefaultData = () => {
  if (columns.value.length === 0) {
    columns.value = [
      { id: 'lead', name: 'Lead', color: '#fbbf24', position: 0 },
      { id: 'contato', name: 'Contato', color: '#3b82f6', position: 1 },
      { id: 'proposta', name: 'Proposta', color: '#8b5cf6', position: 2 },
      { id: 'negociacao', name: 'Negociação', color: '#f59e0b', position: 3 },
      { id: 'fechamento', name: 'Fechamento', color: '#10b981', position: 4 }
    ];
    saveColumnsToCache(columns.value);
  }
};

// Carregar dados
const loadData = async () => {
  loading.value = true;
  try {
    // Carregar colunas do cache primeiro
    const cachedColumns = loadColumnsFromCache();
    if (cachedColumns) {
      columns.value = cachedColumns;
    } else {
      initializeDefaultData();
    }

    // Carregar cards da API
    const response = await KanbanCardsAPI.get();
    kanbanCards.value = response.data || [];
    saveCardsToCache(kanbanCards.value);

  } catch (error) {
    console.error('Erro ao carregar dados:', error);
    // Fallback para cache se API falhar
    const cachedCards = loadCardsFromCache();
    if (cachedCards) {
      kanbanCards.value = cachedCards;
    }
  } finally {
    loading.value = false;
  }
};

// Funções de cards
const getCardsByColumn = (columnId) => {
  return kanbanCards.value
    .filter(card => card.kanban_column_id === columnId)
    .sort((a, b) => (a.position || 0) - (b.position || 0));
};

const createCard = async () => {
  if (!newCardForm.value.title || !newCardForm.value.kanban_column_id) return;

  creatingCard.value = true;
  try {
    const cardData = {
      ...newCardForm.value,
      position: getCardsByColumn(newCardForm.value.kanban_column_id).length
    };

    const response = await KanbanCardsAPI.create(cardData);
    kanbanCards.value.push(response.data);
    saveCardsToCache(kanbanCards.value);

    closeNewCardModal();
  } catch (error) {
    console.error('Erro ao criar card:', error);
  } finally {
    creatingCard.value = false;
  }
};

const editCard = (card) => {
  // TODO: Implementar edição de card
  console.log('Editar card:', card);
};

const deleteCard = async (card) => {
  if (confirm('Tem certeza que deseja excluir este card?')) {
    try {
      await KanbanCardsAPI.delete(card.id);
      const index = kanbanCards.value.findIndex(c => c.id === card.id);
      if (index !== -1) {
        kanbanCards.value.splice(index, 1);
        saveCardsToCache(kanbanCards.value);
      }
    } catch (error) {
      console.error('Erro ao excluir card:', error);
    }
  }
};

const addCardToColumn = (columnId) => {
  newCardForm.value.kanban_column_id = columnId;
  showNewCardModal.value = true;
};

// Funções de colunas
const createColumn = async () => {
  if (!newColumnForm.value.name) return;

  creatingColumn.value = true;
  try {
    const newColumn = {
      id: Date.now().toString(),
      ...newColumnForm.value,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };

    columns.value.push(newColumn);
    saveColumnsToCache(columns.value);

    closeNewColumnModal();
  } catch (error) {
    console.error('Erro ao criar coluna:', error);
  } finally {
    creatingColumn.value = false;
  }
};

const editColumn = (column) => {
  editingColumn.value = column;
  newColumnForm.value = {
    name: column.name,
    color: column.color || '#6b7280',
    position: column.position || 0
  };
  showNewColumnModal.value = true;
};

const updateColumn = async () => {
  if (!editingColumn.value || !newColumnForm.value.name) return;

  creatingColumn.value = true;
  try {
    const index = columns.value.findIndex(c => c.id === editingColumn.value.id);
    if (index !== -1) {
      columns.value[index] = {
        ...columns.value[index],
        ...newColumnForm.value,
        updated_at: new Date().toISOString()
      };
      saveColumnsToCache(columns.value);
    }

    cancelEditColumn();
  } catch (error) {
    console.error('Erro ao atualizar coluna:', error);
  } finally {
    creatingColumn.value = false;
  }
};

const deleteColumn = (column) => {
  if (columns.value.length <= 1) {
    alert('Não é possível excluir a última coluna.');
    return;
  }

  if (confirm(`Tem certeza que deseja excluir a coluna "${column.name}"? Todos os cards serão movidos para a primeira coluna.`)) {
    // Mover cards para primeira coluna
    const firstColumn = columns.value.find(c => c.id !== column.id);
    if (firstColumn) {
      kanbanCards.value.forEach(card => {
        if (card.kanban_column_id === column.id) {
          card.kanban_column_id = firstColumn.id;
        }
      });
    }

    // Remover coluna
    const index = columns.value.findIndex(c => c.id === column.id);
    if (index !== -1) {
      columns.value.splice(index, 1);
      saveColumnsToCache(columns.value);
      saveCardsToCache(kanbanCards.value);
    }
  }
};

const cancelEditColumn = () => {
  editingColumn.value = null;
  newColumnForm.value = {
    name: '',
    color: '#6b7280',
    position: 0
  };
  showNewColumnModal.value = false;
};

// Drag & Drop
const onDragStart = (event, card) => {
  draggedCard.value = card;
  event.dataTransfer.effectAllowed = 'move';
  event.dataTransfer.setData('text/html', event.target.outerHTML);
};

const onDrop = async (event, columnId) => {
  event.preventDefault();

  if (!draggedCard.value) return;

  const cardId = draggedCard.value.id;
  const sourceColumnId = draggedCard.value.kanban_column_id;

  // Se movendo para a mesma coluna, apenas reordenar
  if (sourceColumnId === columnId) {
    // TODO: Implementar reordenamento na mesma coluna
    draggedCard.value = null;
    return;
  }

  try {
    // Mover para coluna diferente usando API
    const position = getCardsByColumn(columnId).length;
    const response = await KanbanCardsAPI.move(cardId, columnId, position);

    // Atualizar localmente
    const cardIndex = kanbanCards.value.findIndex(c => c.id === cardId);
    if (cardIndex !== -1) {
      kanbanCards.value[cardIndex] = response.data;
      saveCardsToCache(kanbanCards.value);
    }
  } catch (error) {
    console.error('Erro ao mover card:', error);
  } finally {
    draggedCard.value = null;
  }
};

// Modais
const closeNewCardModal = () => {
  showNewCardModal.value = false;
  newCardForm.value = {
    title: '',
    description: '',
    kanban_column_id: '',
    priority: 0,
    due_date: ''
  };
};

const closeNewColumnModal = () => {
  showNewColumnModal.value = false;
  newColumnForm.value = {
    name: '',
    color: '#6b7280',
    position: 0
  };
};

// Utilitários
const getPriorityClass = (priority) => {
  const classes = {
    1: 'bg-yellow-100 dark:bg-yellow-900 text-yellow-800 dark:text-yellow-200',
    2: 'bg-orange-100 dark:bg-orange-900 text-orange-800 dark:text-orange-200',
    3: 'bg-red-100 dark:bg-red-900 text-red-800 dark:text-red-200'
  };
  return classes[priority] || 'bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-200';
};

const getPriorityIcon = (priority) => {
  const icons = {
    1: '!',
    2: '!!',
    3: '!!!'
  };
  return icons[priority] || '';
};

const formatDate = (dateString) => {
  if (!dateString) return '';
  return new Date(dateString).toLocaleDateString('pt-BR');
};

onMounted(() => {
  loadData();
});
</script>

<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.kanban-column {
  transition: background-color 0.2s ease;
}

.kanban-column:hover {
  background-color: rgba(59, 130, 246, 0.05);
}
</style>
