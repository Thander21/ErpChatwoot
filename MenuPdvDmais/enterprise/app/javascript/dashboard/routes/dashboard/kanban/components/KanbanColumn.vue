<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/kanban/components/KanbanColumn.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: -
 * Description: (Adicionar descrição em português)
-->
<script setup>
import KanbanCard from "./KanbanCard.vue";
import WootButton from "dashboard/components-next/button/Button.vue";

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

<template>
  <div class="flex-shrink-0 w-72 sm:w-80 h-full max-h-full flex flex-col">
    <div class="bg-n-solid-1 rounded-lg p-3 flex flex-col h-full max-h-full">
      <!-- Column Header -->
      <div class="flex items-center justify-between mb-2 flex-shrink-0">
        <div class="flex items-center gap-2">
          <div
            class="w-3 h-3 rounded-full"
            :style="{ backgroundColor: column.color || '#6b7280' }"
          />
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
          <WootButton
            variant="ghost"
            color="slate"
            size="xs"
            icon="pen"
            title="Editar coluna"
            @click="$emit('edit', column)"
          />

          <WootButton
            v-if="canDeleteColumn"
            :disabled="cards.length > 0"
            variant="ghost"
            color="ruby"
            size="xs"
            icon="trash"
            :title="
              cards.length > 0
                ? 'Remova todos os cards antes de excluir a coluna'
                : 'Excluir coluna'
            "
            @click="$emit('delete', column)"
          />
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
        <WootButton
          v-if="canCreateCard"
          variant="outline"
          color="slate"
          icon="plus"
          class="w-full border-dashed"
          @click="$emit('add-card', column.id)"
        >
          Adicionar card
        </WootButton>

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
