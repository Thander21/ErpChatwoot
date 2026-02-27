<template>
  <div class="flex-shrink-0 w-72 sm:w-80 h-full max-h-full flex flex-col">
    <div class="bg-n-solid-1 rounded-lg p-4 flex flex-col h-full max-h-full">
      <!-- Column Header -->
      <div class="flex items-center justify-between mb-4 flex-shrink-0">
        <div class="flex items-center gap-2">
          <div
            class="w-3 h-3 rounded-full"
            :style="{ backgroundColor: column.color || '#6b7280' }"
          ></div>
          <h3 class="font-semibold text-n-slate-12">
            {{ column.name }}
          </h3>
          <span
            class="text-xs bg-n-alpha-black2 text-n-slate-11 px-2 py-1 rounded-full"
          >
            {{ cards.length }}
          </span>
        </div>

        <!-- Column Actions -->
        <div class="flex gap-1">
          <button
            @click="$emit('edit', column)"
            class="p-1 hover:bg-n-alpha-black2 rounded text-n-slate-11"
            title="Editar coluna"
          >
            <span class="i-lucide-pen size-4 block"></span>
          </button>

          <button
            v-if="canDeleteColumn"
            @click="$emit('delete', column)"
            :disabled="cards.length > 0"
            class="p-1 rounded transition-colors"
            :class="
              cards.length > 0
                ? 'text-n-slate-10 cursor-not-allowed'
                : 'hover:bg-n-ruby-2 text-n-ruby-9'
            "
            :title="
              cards.length > 0
                ? 'Remova todos os cards antes de excluir a coluna'
                : 'Excluir coluna'
            "
          >
            <span class="i-lucide-trash-2 size-4 block"></span>
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
          class="w-full p-3 border-2 border-dashed border-n-weak rounded-lg text-n-slate-11 hover:border-n-slate-10 hover:text-n-slate-12 transition-colors text-sm"
        >
          + Adicionar card
        </button>

        <!-- Cards -->
        <KanbanCard
          v-for="card in cards"
          :key="card.id"
          :card="card"
          :show-priority-color="showPriorityColor"
          :is-last-column="isLastColumn"
          @dragstart="$emit('dragstart', $event, card)"
          @edit="$emit('edit-card', card)"
          @delete="$emit('delete-card', card)"
          @archive="$emit('archive-card', card)"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import KanbanCard from "./KanbanCard.vue";

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
  isLastColumn: {
    type: Boolean,
    default: false,
  },
  canDeleteColumn: {
    type: Boolean,
    default: true,
  },
});

defineEmits([
  "edit",
  "delete",
  "drop",
  "add-card",
  "dragstart",
  "edit-card",
  "delete-card",
  "archive-card",
]);
</script>
