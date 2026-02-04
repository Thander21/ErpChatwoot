<template>
  <div
    class="bg-white dark:bg-slate-700 rounded-lg p-3 shadow-sm border border-gray-200 dark:border-slate-600 cursor-grab hover:shadow-md transition-shadow active:cursor-grabbing flex flex-col gap-2"
    draggable="true"
    @dragstart="$emit('dragstart', $event)"
    @click="$emit('edit')"
  >
    <!-- Linha 1: Título e Ações/Priority -->
    <div class="flex items-start justify-between">
      <h4
        class="font-medium text-slate-900 dark:text-white text-sm line-clamp-1 flex-1 mr-2"
        :title="card.title"
      >
        {{ card.title }}
      </h4>
      <div class="flex items-center gap-1 shrink-0">
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
        <button
          @click.stop="$emit('delete')"
          class="text-slate-400 hover:text-red-500 p-0.5"
          title="Excluir"
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
              d="M6 18L18 6M6 6l12 12"
            ></path>
          </svg>
        </button>
      </div>
    </div>

    <!-- Linha 2: Empresa e Contato -->
    <div
      class="flex items-center gap-2 text-xs text-slate-600 dark:text-slate-400 truncate"
    >
      <span
        v-if="card.company"
        class="flex items-center gap-1 truncate"
        title="Empresa"
      >
        🏢 {{ card.company.company_name || card.company.name }}
      </span>
      <span
        v-if="card.company && card.contact"
        class="text-slate-300 dark:text-slate-600"
        >|</span
      >
      <span
        v-if="card.contact"
        class="flex items-center gap-1 truncate"
        title="Contato"
      >
        👤 {{ card.contact.name }}
      </span>
    </div>

    <!-- Linha 3: Vendedor e Data -->
    <div
      class="flex items-center justify-between text-xs text-slate-500 dark:text-slate-500 pt-1 border-t border-gray-100 dark:border-slate-600/50"
    >
      <div class="flex items-center gap-1 truncate">
        <span
          v-if="card.assignee"
          class="flex items-center gap-1"
          title="Vendedor"
        >
          💼 {{ card.assignee.name }}
        </span>
        <span v-else class="text-slate-400 italic">Sem vendedor</span>
      </div>

      <div v-if="card.due_date" class="flex items-center gap-1 shrink-0">
        📅 {{ formatDate(card.due_date) }}
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from "vue";

const props = defineProps({
  card: {
    type: Object,
    required: true,
  },
});

defineEmits(["dragstart", "edit", "delete"]);

const getPriorityClass = (priority) => {
  switch (priority) {
    case 1:
      return "bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200";
    case 2:
      return "bg-orange-100 text-orange-800 dark:bg-orange-900 dark:text-orange-200";
    case 3:
      return "bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200";
    default:
      return "bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300";
  }
};

const getPriorityIcon = (priority) => {
  switch (priority) {
    case 1:
      return "🔵";
    case 2:
      return "🟠";
    case 3:
      return "🔴";
    default:
      return "⚪";
  }
};

const formatDate = (dateString) => {
  if (!dateString) return "";
  const date = new Date(dateString);
  return date.toLocaleDateString("pt-BR");
};
</script>
