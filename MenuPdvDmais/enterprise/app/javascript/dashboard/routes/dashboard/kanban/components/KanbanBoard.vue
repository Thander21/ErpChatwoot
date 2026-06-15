<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/kanban/components/KanbanBoard.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: -
 * Description: (Adicionar descrição em português)
-->
<script setup>
import { ref, onMounted, onUnmounted, computed } from "vue";
import KanbanColumn from "./KanbanColumn.vue";
import WootButton from "dashboard/components-next/button/Button.vue";
import Spinner from "dashboard/components-next/spinner/Spinner.vue";

const props = defineProps({
  title: {
    type: String,
    default: "Kanban Board",
  },
  loading: {
    type: Boolean,
    default: false,
  },
  loadingText: {
    type: String,
    default: "Carregando...",
  },
  columns: {
    type: Array, // Expected: { id, name, color, position? }
    required: true,
    default: () => [],
  },
  archivedUrl: {
    type: String,
    default: "",
  },
  cards: {
    type: Array, // Expected: { id, kanban_column_id, ... }
    required: true,
    default: () => [],
  },
  canCreateColumn: {
    type: Boolean,
    default: false,
  },
  canCreateCard: {
    type: Boolean,
    default: false,
  },
  // Function to filter cards per column if checking kanban_column_id is not enough
  // or if structure is different
  cardsFilter: {
    type: Function,
    default: null,
  },
  showPriorityColor: {
    type: Boolean,
    default: true,
  },
  canDeleteColumn: {
    type: Boolean,
    default: true,
  },
});

const emit = defineEmits([
  "create-card",
  "create-column",
  "edit-column",
  "delete-column",
  "add-card-to-column",
  "edit-card",
  "delete-card",
  "delete-card",
  "archive-card",
  "card-moved",
]);

// Computed
const sortedColumns = computed(() => {
  // Sort by position if available, otherwise existing order
  return [...props.columns].sort(
    (a, b) => (a.position || 0) - (b.position || 0),
  );
});

const totalCards = computed(() => props.cards.length);

const getDueDateTimestamp = card => {
  if (!card?.due_date) return null;
  const parsed = new Date(card.due_date);
  if (Number.isNaN(parsed.getTime())) return null;
  return parsed.getTime();
};

const getCardsForColumn = (column) => {
  if (props.cardsFilter) {
    return props.cardsFilter(props.cards, column);
  }
  // Default behavior: filter by kanban_column_id matching column.id
  // Note: Ensure types match (string vs int)
  return props.cards
    .filter((card) => card.kanban_column_id == column.id)
    .sort((a, b) => {
      const dueA = getDueDateTimestamp(a);
      const dueB = getDueDateTimestamp(b);

      // Older due dates first. Cards without due date go to the end.
      if (dueA !== null && dueB !== null && dueA !== dueB) return dueA - dueB;
      if (dueA !== null && dueB === null) return -1;
      if (dueA === null && dueB !== null) return 1;

      return (a.position || 0) - (b.position || 0);
    });
};

// Mobile State
// const activeColumnIndex = ref(0);
// const isMobile = ref(window.innerWidth < 640);

// const handleResize = () => {
//   isMobile.value = window.innerWidth < 640;
// };

// Drag & Drop
const onDragStart = (event, card) => {
  event.dataTransfer.effectAllowed = "move";
  event.dataTransfer.setData("text/plain", card.id);
};

const onDrop = (event, columnId) => {
  const cardId = event.dataTransfer.getData("text/plain");
  const card = props.cards.find((c) => c.id == cardId);

  if (card && card.kanban_column_id !== columnId) {
    emit("card-moved", { card, targetColumnId: columnId });
  }
};

// Mobile Nav
// const nextColumn = () => {
//   if (activeColumnIndex.value < sortedColumns.value.length - 1) {
//     activeColumnIndex.value++;
//   }
// };

// const prevColumn = () => {
//   if (activeColumnIndex.value > 0) {
//     activeColumnIndex.value--;
//   }
// };

// onMounted(() => {
//   window.addEventListener("resize", handleResize);
// });

// onUnmounted(() => {
//   window.removeEventListener("resize", handleResize);
// });
</script>

<template>
  <div class="flex flex-col h-full bg-n-surface-1">
    <!-- Header com controles -->
    <div class="flex items-center justify-between mb-1 flex-shrink-0">
      <div class="flex items-center gap-3">
        <h2 class="text-xl font-semibold text-n-slate-12">
          {{ title }}
        </h2>
        <div class="flex items-center gap-2 text-sm text-n-slate-11">
          <span>{{ totalCards }} cards</span>
          <span v-if="columns.length > 0">•</span>
          <span v-if="columns.length > 0">{{ columns.length }} colunas</span>
          <slot name="extra-info" />
          <template v-if="archivedUrl">
            <span class="text-n-slate-9">|</span>
            <router-link
              :to="archivedUrl"
              class="hover:text-n-brand hover:underline flex items-center gap-1.5"
            >
              <span class="i-lucide-box size-3.5 block" />
              Arquivados
            </router-link>
          </template>
        </div>
      </div>

      <div class="flex gap-2">
        <WootButton
          v-if="canCreateCard"
          color="teal"
          icon="plus"
          @click="$emit('create-card')"
        >
          <span class="hidden sm:inline">Novo Card</span>
          <span class="sm:hidden">Card</span>
        </WootButton>

        <WootButton
          v-if="canCreateColumn"
          color="blue"
          icon="plus"
          @click="$emit('create-column')"
        >
          <span class="hidden sm:inline">Nova Coluna</span>
          <span class="sm:hidden">Coluna</span>
        </WootButton>

        <slot name="actions" />
      </div>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="flex flex-col items-center justify-center py-12 flex-1">
      <Spinner :size="48" class="text-n-brand mb-4" />
      <p class="text-n-slate-11">{{ loadingText }}</p>
    </div>

    <!-- Kanban Board Container -->
    <div v-else class="flex-1 min-h-0">
      <div class="flex gap-2 pb-4 min-w-max h-full">
        <template v-for="(column, index) in sortedColumns" :key="column.id">
          <div class="flex-shrink-0 w-72 h-full">
            <KanbanColumn
              :column="column"
              :cards="getCardsForColumn(column)"
              :can-create-card="canCreateCard"
              :can-delete-column="canDeleteColumn"
              :show-priority-color="showPriorityColor"
              :is-last-column="index === sortedColumns.length - 1"
              @edit="$emit('edit-column', column)"
              @delete="$emit('delete-column', column)"
              @add-card="$emit('add-card-to-column', column.id)"
              @edit-card="(card) => $emit('edit-card', card)"
              @delete-card="(card) => $emit('delete-card', card)"
              @archive-card="(card) => $emit('archive-card', card)"
              @dragstart="onDragStart"
              @drop="onDrop"
            />
          </div>
        </template>

        <div
          v-if="sortedColumns.length === 0"
          class="w-full flex items-center justify-center border-2 border-dashed border-n-weak rounded-lg h-64"
        >
          <p class="text-n-slate-11">Nenhuma coluna disponível.</p>
        </div>
      </div>
    </div>
  </div>
</template>
