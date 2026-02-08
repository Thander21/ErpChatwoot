<template>
  <div class="flex-shrink-0 w-72 sm:w-80 h-full max-h-full flex flex-col">
    <div class="bg-gray-100 dark:bg-slate-800 rounded-lg p-4 flex flex-col h-full max-h-full">
      <!-- Column Header -->
      <div class="flex items-center justify-between mb-4 flex-shrink-0">
        <div class="flex items-center gap-2">
          <div
            class="w-3 h-3 rounded-full"
            :style="{ backgroundColor: column.color || '#6b7280' }"
          ></div>
          <h3 class="font-semibold text-slate-900 dark:text-white">
            {{ column.name }}
          </h3>
          <span
            class="text-xs bg-gray-200 dark:bg-slate-700 text-slate-700 dark:text-slate-300 px-2 py-1 rounded-full"
          >
            {{ cards.length }}
          </span>
        </div>

        <!-- Column Actions -->
        <div class="flex gap-1">
          <button
            @click="$emit('edit', column)"
            class="p-1 hover:bg-gray-200 dark:hover:bg-slate-700 rounded text-slate-600 dark:text-slate-400"
            title="Editar coluna"
          >
            <svg
              class="w-4 h-4"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"
              />
            </svg>
          </button>

          <button
            @click="$emit('delete', column)"
            class="p-1 hover:bg-red-100 dark:hover:bg-red-900 rounded text-red-600 dark:text-red-400"
            title="Excluir coluna"
          >
            <svg
              class="w-4 h-4"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
              />
            </svg>
          </button>
        </div>
      </div>

      <!-- Cards Container (Scrollable) -->
      <div
        class="space-y-3 flex-1 overflow-y-auto min-h-[100px] h-full kanban-column pr-1"
        :data-column-id="column.id"
        @drop="$emit('drop', $event, column.id)"
        @dragover.prevent
        @dragenter.prevent
      >
        <!-- Add Card Button -->
        <button
          v-if="canCreateCard"
          @click="$emit('add-card', column.id)"
          class="w-full p-3 border-2 border-dashed border-gray-300 dark:border-slate-600 rounded-lg text-gray-500 dark:text-slate-400 hover:border-gray-400 dark:hover:border-slate-500 hover:text-gray-600 dark:hover:text-slate-300 transition-colors text-sm"
        >
          + Adicionar card
        </button>

        <!-- Cards -->
        <KanbanCard
          v-for="card in cards"
          :key="card.id"
          :card="card"
          :show-priority-color="showPriorityColor"
          @dragstart="$emit('dragstart', $event, card)"
          @edit="$emit('edit-card', card)"
          @delete="$emit('delete-card', card)"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import KanbanCard from './KanbanCard.vue';

const props = defineProps({
  column: {
    type: Object,
    required: true,
  },
  cards: {
    type: Array,
    required: true,
    default: () => [],
  },
  canCreateCard: {
    type: Boolean,
    default: false,
  },
  showPriorityColor: {
    type: Boolean,
    default: true,
  },
});

defineEmits([
  'edit',
  'delete',
  'drop',
  'add-card',
  'dragstart',
  'edit-card',
  'delete-card',
]);
</script>
