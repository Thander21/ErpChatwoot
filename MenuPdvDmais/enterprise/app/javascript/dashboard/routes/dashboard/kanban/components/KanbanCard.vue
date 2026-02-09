<template>
  <div
    class="kanban-card-container bg-white dark:bg-slate-800 rounded-lg p-3 shadow-sm hover:shadow-md transition-all active:cursor-grabbing flex flex-col gap-2 cursor-grab relative overflow-hidden border border-slate-200 dark:border-slate-700"
    :style="{
      borderLeftWidth: showPriorityColor ? '4px' : '1px',
      borderLeftColor: showPriorityColor ? getPriorityColor(card.priority) : '',
    }"
    draggable="true"
    @dragstart="$emit('dragstart', $event)"
    @click="$emit('edit')"
  >
    <!-- Header: Empresa/Contato -->
    <div
      v-if="card.company || card.contact"
      class="border-b border-gray-100 dark:border-slate-700 pb-2 mb-1"
    >
      <router-link
        v-if="card.contact"
        :to="contactUrl"
        class="text-[11px] font-bold text-slate-600 dark:text-white uppercase tracking-wide truncate block hover:text-blue-600 dark:hover:text-blue-400 hover:underline"
        :title="headerTitle"
        @click.stop
      >
        {{ headerText }}
      </router-link>
      <span
        v-else
        class="text-[11px] font-bold text-slate-600 dark:text-white uppercase tracking-wide truncate block"
        :title="headerTitle"
      >
        {{ headerText }}
      </span>
    </div>

    <!-- Linha 1: Título -->
    <div class="flex items-start justify-between gap-2">
      <h4
        class="font-semibold text-slate-900 dark:text-white text-sm leading-snug line-clamp-2"
        :title="card.title"
      >
        {{ card.title }}
      </h4>

      <div class="flex items-center gap-1 shrink-0">
        <span
          v-if="card.conversation_id"
          class="text-[10px] bg-blue-50 dark:bg-blue-900/40 text-blue-700 dark:text-blue-300 px-1.5 py-0.5 rounded-full"
          title="Vinculado a conversa"
        >
          💬
        </span>
      </div>
    </div>

    <!-- Linha 2: Descrição -->
    <p
      v-if="card.description"
      class="text-xs text-slate-600 dark:text-slate-400 line-clamp-2 leading-relaxed"
    >
      {{ card.description }}
    </p>

    <!-- Linha 3: Vendedor e Data -->
    <div
      class="flex items-center justify-between text-xs pt-2 mt-auto border-t border-transparent"
    >
      <div class="flex items-center gap-1.5 max-w-[60%]">
        <div 
          v-if="card.assignee"
          class="flex items-center gap-2 text-slate-700 dark:text-slate-300 truncate font-medium"
          :title="`Vendedor: ${card.assignee.name}`"
        >
          <Avatar 
            :name="card.assignee.name || card.assignee.available_name"
            :src="card.assignee.thumbnail"
            :size="20"
            :rounded-full="true"
          />
          <span class="text-xs">{{ card.assignee.name }}</span>
        </div>
        <span v-else class="text-slate-400 italic text-[10px]"
          >Não atribuído</span
        >
      </div>

      <div
        v-if="card.due_date"
        class="flex items-center gap-1 shrink-0 bg-gray-50 dark:bg-slate-700/50 px-2 py-1 rounded text-xs font-semibold"
        :class="dueDateClass"
      >
        📅 {{ formattedDate }}
      </div>
    </div>

    <!-- Botão de Excluir (Hover) -->
    <button
      @click.stop="$emit('delete')"
      class="absolute top-2 right-2 opacity-0 hover:opacity-100 text-slate-400 hover:text-red-500 p-1 rounded transition-opacity bg-white/80 dark:bg-slate-800/80 backdrop-blur-sm"
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
</template>

<script setup>
import { computed } from "vue";
import { useStore } from "vuex"; 
import Avatar from "dashboard/components-next/avatar/Avatar.vue";

const props = defineProps({
  card: {
    type: Object,
    required: true,
  },
  statusColor: {
    type: String,
    default: null,
  },
  showPriorityColor: {
    type: Boolean,
    default: true,
  },
});

defineEmits(["dragstart", "edit", "delete"]);

const store = useStore();
const accountId = computed(() => store.getters["getCurrentAccountId"]);

const contactUrl = computed(() => {
  if (!props.card.contact) return "#";
  return `/app/accounts/${accountId.value}/contacts/${props.card.contact.id}`;
});

const headerText = computed(() => {
  const companyName = props.card.company
    ? props.card.company.company_name || props.card.company.name
    : "";
  const contactName = props.card.contact ? props.card.contact.name : "";

  if (companyName) {
    return companyName;
  }
  return contactName;
});

const headerTitle = computed(() => headerText.value);

const getPriorityColor = (priority) => {
  if (props.statusColor) return props.statusColor;

  // Retorna diretamente o HEX da cor para garantir que funcione
  switch (priority) {
    case "low":
    case 0:
    case "0":
      return "#60a5fa"; // blue-400
    case "normal":
    case "medium":
    case 1:
    case "1":
      return "#22c55e"; // green-500
    case "high":
    case 2:
    case "2":
      return "#eab308"; // yellow-500
    case "urgent":
    case 3:
    case "3":
      return "#dc2626"; // red-600
    default:
      return "#d1d5db"; // gray-300
  }
};

const processedDueDate = computed(() => {
  if (!props.card.due_date) return null;
  const date = new Date(props.card.due_date);
  // Reset time for comparison
  const dateMidnight = new Date(date);
  dateMidnight.setHours(0, 0, 0, 0);
  return { date, dateMidnight };
});

const dueDateClass = computed(() => {
  if (!processedDueDate.value) return "";

  const today = new Date();
  const todayMidnight = new Date(today.setHours(0, 0, 0, 0));
  const { dateMidnight } = processedDueDate.value;

  if (dateMidnight < todayMidnight) {
    return "text-red-600 dark:text-red-400";
  } else if (dateMidnight.getTime() === todayMidnight.getTime()) {
    return "text-orange-600 dark:text-orange-400";
  }
  return "text-slate-600 dark:text-slate-400";
});

const formattedDate = computed(() => {
  if (!processedDueDate.value) return "";
  // Use browser default locale or fallback to pt-BR if needed, but cleaner to rely on browser
  return processedDueDate.value.date.toLocaleDateString(undefined, {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
  });
});
</script>

<style scoped>
/* Estilo para garantir posicionamento correto do botão excluir */
.kanban-card-container {
  position: relative;
}
</style>
