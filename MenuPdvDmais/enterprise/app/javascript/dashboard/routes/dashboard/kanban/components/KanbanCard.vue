<template>
  <div
    class="kanban-card-container group bg-white dark:bg-slate-800 rounded-lg p-3 shadow-sm hover:shadow-md transition-all active:cursor-grabbing flex flex-col gap-2 cursor-grab relative overflow-hidden border border-slate-200 dark:border-slate-700"
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
        target="_blank"
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

    <!-- Botões (Hover) -->
    <div
      class="absolute top-2 right-2 flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity bg-white/90 dark:bg-slate-800/90 backdrop-blur-sm rounded p-0.5"
    >
      <!-- Botão de Arquivar (Apenas última coluna) -->
      <button
        v-if="isLastColumn"
        @click.stop="$emit('archive')"
        class="text-slate-400 hover:text-green-600 p-1 rounded transition-colors"
        title="Arquivar"
      >
        <!-- Folder Icon -->
        <svg
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 20 20"
          fill="currentColor"
          class="w-4 h-4"
        >
          <path
            d="M2 6a2 2 0 012-2h5l2 2h5a2 2 0 012 2v6a2 2 0 01-2 2H4a2 2 0 01-2-2V6z"
          />
        </svg>
      </button>

      <!-- Botão de Excluir (NÃO mostrar na última coluna) -->
      <button
        v-if="!isLastColumn"
        @click.stop="$emit('delete')"
        class="text-slate-400 hover:text-red-600 p-1 rounded transition-colors"
        title="Excluir"
      >
        <!-- Trash Icon -->
        <svg
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 20 20"
          fill="currentColor"
          class="w-4 h-4"
        >
          <path
            fill-rule="evenodd"
            d="M9 2a1 1 0 00-.894.553L7.382 4H4a1 1 0 000 2v10a2 2 0 002 2h8a2 2 0 002-2V6a1 1 0 100-2h-3.382l-.724-1.447A1 1 0 0011 2H9zM7 8a1 1 0 012 0v6a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v6a1 1 0 102 0V8a1 1 0 00-1-1z"
            clip-rule="evenodd"
          />
        </svg>
      </button>
    </div>
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
  isLastColumn: {
    type: Boolean,
    default: false,
  },
});

defineEmits(["dragstart", "edit", "delete", "archive"]);

const store = useStore();
const accountId = computed(() => store.getters["getCurrentAccountId"]);

const contactUrl = computed(() => {
  if (!props.card.contact) return "#";
  return `/app/accounts/${accountId.value}/contacts/${props.card.contact.id}`;
});

const headerText = computed(() => {
  // 1. Tenta pegar o nome da empresa nos atributos adicionais do contato
  const additionalAttributesName =
    props.card.contact &&
    props.card.contact.additional_attributes &&
    props.card.contact.additional_attributes.company_name;

  if (additionalAttributesName) {
    return additionalAttributesName;
  }

  // 2. Fallback para o objeto company (Kanban Comercial)
  const companyName = props.card.company ? props.card.company.name : "";
  if (companyName) {
    return companyName;
  }

  // 3. Padrão se não encontrar nada
  return "Falta Empresa";
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
