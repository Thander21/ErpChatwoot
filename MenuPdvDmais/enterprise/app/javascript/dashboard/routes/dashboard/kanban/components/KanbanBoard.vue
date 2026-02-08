<template>
  <div class="flex flex-col gap-4 h-full">
    <!-- Header com controles -->
    <div class="flex items-center justify-between mb-2 flex-shrink-0">
      <div class="flex items-center">
        <h2 class="text-xl font-semibold text-slate-900 dark:text-white">
          {{ title }}
        </h2>
        <div
          class="flex items-center gap-2 text-sm text-slate-600 dark:text-slate-400"
        >
          <span>{{ totalCards }} cards</span>
          <span v-if="columns.length > 0">•</span>
          <span v-if="columns.length > 0">{{ columns.length }} colunas</span>
          <slot name="extra-info"></slot>
        </div>
      </div>

      <div class="flex flex-col sm:flex-row gap-2">
        <woot-button
          v-if="canCreateCard"
          @click="$emit('create-card')"
          color="green"
          icon="plus"
        >
          <span class="hidden sm:inline">Novo Card</span>
          <span class="sm:hidden">Card</span>
        </woot-button>

        <woot-button
          v-if="canCreateColumn"
          @click="$emit('create-column')"
          color="blue"
          icon="plus"
        >
          <span class="hidden sm:inline">Nova Coluna</span>
          <span class="sm:hidden">Coluna</span>
        </woot-button>

        <!-- Slot para botões extras (ex: Refresh na aba Tarefas) -->
        <slot name="actions"></slot>
      </div>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="flex flex-col items-center justify-center py-12">
      <div
        class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mb-4"
      ></div>
      <p class="text-slate-600 dark:text-slate-400">
        {{ loadingText }}
      </p>
    </div>

    <!-- Kanban Board -->
    <div v-else class="flex-1 min-h-0 relative">
      <!-- Mobile Controls (Visible only on small screens) -->
      <div class="sm:hidden flex justify-between items-center mb-2" v-if="sortedColumns.length > 0">
        <button 
          @click="prevColumn" 
          :disabled="activeColumnIndex === 0"
          class="p-2 rounded-full bg-gray-200 dark:bg-slate-700 disabled:opacity-50"
        >
          ←
        </button>
        <span class="text-sm font-medium">
          {{ activeColumnIndex + 1 }} / {{ sortedColumns.length }}
        </span>
        <button 
          @click="nextColumn" 
          :disabled="activeColumnIndex === sortedColumns.length - 1"
          class="p-2 rounded-full bg-gray-200 dark:bg-slate-700 disabled:opacity-50"
        >
          →
        </button>
      </div>

      <!-- Scrollable Container (Desktop) / Slider (Mobile) -->
      <div class="h-full flex gap-4 overflow-x-auto pb-4 snap-x flex-nowrap">
        <template v-for="(column, index) in sortedColumns" :key="column.id">
          <div 
            class="h-full snap-center shrink-0 transition-opacity duration-300"
            :class="{
              'block w-full': isMobile,
              'hidden': isMobile && index !== activeColumnIndex,
              'block': !isMobile,
              'w-80': !isMobile // Fixed width for desktop columns
            }"
          >
            <KanbanColumn
              :column="column"
              :cards="getCardsForColumn(column)"
              :can-create-card="canCreateCard"
              :show-priority-color="showPriorityColor"
              @edit="$emit('edit-column', column)"
              @delete="$emit('delete-column', column)"
              @add-card="$emit('add-card-to-column', column.id)"
              @edit-card="(card) => $emit('edit-card', card)"
              @delete-card="(card) => $emit('delete-card', card)"
              @dragstart="onDragStart"
              @drop="onDrop"
            />
          </div>
        </template>
        
        <div v-if="sortedColumns.length === 0" class="w-full flex items-center justify-center border-2 border-dashed border-gray-300 dark:border-slate-600 rounded-lg">
           <p class="text-slate-500">Nenhuma coluna disponível.</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, computed } from 'vue';
import KanbanColumn from './KanbanColumn.vue';
import WootButton from 'dashboard/components-next/button/Button.vue';

const props = defineProps({
  title: {
    type: String,
    default: 'Kanban Board'
  },
  loading: {
    type: Boolean,
    default: false
  },
  loadingText: {
    type: String,
    default: 'Carregando...'
  },
  columns: {
    type: Array, // Expected: { id, name, color, position? }
    required: true,
    default: () => []
  },
  cards: {
    type: Array, // Expected: { id, kanban_column_id, ... }
    required: true,
    default: () => []
  },
  canCreateColumn: {
    type: Boolean,
    default: false
  },
  canCreateCard: {
    type: Boolean,
    default: false
  },
  // Function to filter cards per column if checking kanban_column_id is not enough
  // or if structure is different
  cardsFilter: {
      type: Function,
      default: null 
  },
  showPriorityColor: {
    type: Boolean,
    default: true
  }
});

const emit = defineEmits([
  'create-card',
  'create-column',
  'edit-column',
  'delete-column',
  'add-card-to-column',
  'edit-card',
  'delete-card',
  'card-moved'
]);

// Computed
const sortedColumns = computed(() => {
  // Sort by position if available, otherwise existing order
  return [...props.columns].sort(
    (a, b) => (a.position || 0) - (b.position || 0)
  );
});

const totalCards = computed(() => props.cards.length);

const getCardsForColumn = (column) => {
  if (props.cardsFilter) {
      return props.cardsFilter(props.cards, column);
  }
  // Default behavior: filter by kanban_column_id matching column.id
  // Note: Ensure types match (string vs int)
  return props.cards
    .filter((card) => card.kanban_column_id == column.id)
    .sort((a, b) => (a.position || 0) - (b.position || 0));
};

// Mobile State
const activeColumnIndex = ref(0);
const isMobile = ref(window.innerWidth < 640);

const handleResize = () => {
  isMobile.value = window.innerWidth < 640;
};

// Drag & Drop
const onDragStart = (event, card) => {
  event.dataTransfer.effectAllowed = 'move';
  event.dataTransfer.setData('text/plain', card.id);
};

const onDrop = (event, columnId) => {
  const cardId = event.dataTransfer.getData('text/plain');
  const card = props.cards.find((c) => c.id == cardId);
  
  if (card && card.kanban_column_id !== columnId) {
    emit('card-moved', { card, targetColumnId: columnId });
  }
};

// Mobile Nav
const nextColumn = () => {
  if (activeColumnIndex.value < sortedColumns.value.length - 1) {
    activeColumnIndex.value++;
  }
};

const prevColumn = () => {
  if (activeColumnIndex.value > 0) {
    activeColumnIndex.value--;
  }
};

onMounted(() => {
  window.addEventListener('resize', handleResize);
});

onUnmounted(() => {
  window.removeEventListener('resize', handleResize);
});
</script>
