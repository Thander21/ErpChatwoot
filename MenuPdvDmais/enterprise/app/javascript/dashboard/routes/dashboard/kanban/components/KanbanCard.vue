<template>
  <div
    class="bg-white dark:bg-slate-700 rounded-lg p-3 shadow-sm border border-gray-200 dark:border-slate-600 cursor-grab hover:shadow-md transition-shadow active:cursor-grabbing"
    draggable="true"
    @dragstart="$emit('dragstart', $event)"
    @click="$emit('edit')"
  >
    <!-- Card Header -->
    <div class="flex items-start justify-between mb-2">
      <h4
        class="font-medium text-slate-900 dark:text-white text-sm line-clamp-2 flex-1"
      >
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
    <div
      v-if="card.description"
      class="text-xs text-slate-600 dark:text-slate-400 mb-2 line-clamp-2"
    >
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
        @click.stop="$emit('delete')"
        class="text-red-500 hover:text-red-700 dark:text-red-400 dark:hover:text-red-300 p-1 rounded-full hover:bg-red-50 dark:hover:bg-red-900/30"
        title="Excluir card"
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
            d="M6 18L18 6M6 6l12 12"
          />
        </svg>
      </button>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue';

const props = defineProps({
  card: {
    type: Object,
    required: true,
  },
});

defineEmits(['dragstart', 'edit', 'delete']);

const getPriorityClass = (priority) => {
  switch (priority) {
    case 1:
      return 'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200';
    case 2:
      return 'bg-orange-100 text-orange-800 dark:bg-orange-900 dark:text-orange-200';
    case 3:
      return 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200';
    default:
      return 'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300';
  }
};

const getPriorityIcon = (priority) => {
  switch (priority) {
    case 1:
      return '🔵';
    case 2:
      return '🟠';
    case 3:
      return '🔴';
    default:
      return '⚪';
  }
};

const formatDate = (dateString) => {
  if (!dateString) return '';
  const date = new Date(dateString);
  return date.toLocaleDateString('pt-BR');
};
</script>
