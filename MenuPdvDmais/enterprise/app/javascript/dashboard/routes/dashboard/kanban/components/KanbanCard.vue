<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/kanban/components/KanbanCard.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: -
 * Description: (Adicionar descrição em português)
-->
<script setup>
import { computed } from "vue";
import { useStore } from "vuex";
import Avatar from "dashboard/components-next/avatar/Avatar.vue";
import WootButton from "dashboard/components-next/button/Button.vue";

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
  hideActions: {
    type: Boolean,
    default: false,
  },
});

defineEmits(["dragstart", "edit", "delete", "archive"]);

const store = useStore();
const accountId = computed(() => store.getters.getCurrentAccountId);

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
    return "text-n-ruby-9 dark:text-n-ruby-9";
  }
  if (dateMidnight.getTime() === todayMidnight.getTime()) {
    return "text-n-amber-11 dark:text-n-amber-11";
  }
  return "text-n-slate-11 dark:text-n-slate-11";
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

<template>
  <div
    class="kanban-card-container group bg-n-surface-1 rounded-lg p-2 shadow-sm hover:shadow-md transition-all active:cursor-grabbing flex flex-col cursor-grab relative overflow-hidden border border-n-weak"
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
      class="border-b border-n-weak mb-1"
    >
      <router-link
        v-if="card.contact"
        :to="contactUrl"
        target="_blank"
        class="text-[11px] font-bold text-n-slate-11 uppercase tracking-wide truncate block hover:text-n-brand dark:hover:text-n-brand hover:underline"
        :title="headerTitle"
        @click.stop
      >
        {{ headerText }}
      </router-link>
      <span
        v-else
        class="text-[11px] font-bold text-n-slate-11 uppercase tracking-wide truncate block"
        :title="headerTitle"
      >
        {{ headerText }}
      </span>
    </div>

    <!-- Linha 1: Título -->
    <div class="flex items-start justify-between gap-2">
      <h4
        class="font-semibold text-n-slate-12 text-sm leading-snug line-clamp-2"
        :title="card.title"
      >
        {{ card.title }}
      </h4>

      <div class="flex items-center gap-1 shrink-0">
        <span
          v-if="card.conversation_id"
          class="text-[10px] bg-n-brand-alpha text-n-brand px-1.5 py-0.5 rounded-full"
          title="Vinculado a conversa"
        >
          💬
        </span>
      </div>
    </div>

    <!-- Linha 2: Descrição -->
    <p
      v-if="card.description"
      class="text-xs text-n-slate-11 line-clamp-2 leading-relaxed"
    >
      {{ card.description }}
    </p>

    <!-- Linha 3: Vendedor/Implantador e Data -->
    <div
      class="flex items-center justify-between text-xs mt-auto border-t border-transparent"
    >
      <div class="flex items-center gap-1.5 max-w-[60%]">
        <div
          v-if="card.implementer"
          class="flex items-center gap-2 text-n-slate-12 truncate font-medium"
          :title="`Implantador: ${card.implementer.name}`"
        >
          <div class="rounded-full ring-2 ring-n-ruby-9 flex-shrink-0">
            <Avatar
              :name="card.implementer.name || card.implementer.available_name"
              :src="card.implementer.thumbnail"
              :size="20"
              :rounded-full="true"
            />
          </div>
          <div class="flex flex-col items-start leading-tight">
            <span class="text-[9px] text-n-slate-10 uppercase font-semibold">Implantador</span>
            <span class="text-xs">{{ card.implementer.name }}</span>
          </div>
        </div>
        <div
          v-else-if="card.assignee"
          class="flex items-center gap-2 text-n-slate-12 truncate font-medium"
          :title="`Vendedor: ${card.assignee.name}`"
        >
          <div class="rounded-full ring-2 ring-purple-500 flex-shrink-0">
            <Avatar
              :name="card.assignee.name || card.assignee.available_name"
              :src="card.assignee.thumbnail"
              :size="20"
              :rounded-full="true"
            />
          </div>
          <div class="flex flex-col items-start leading-tight">
            <span class="text-[9px] text-n-slate-10 uppercase font-semibold">Vendedor</span>
            <span class="text-xs">{{ card.assignee.name }}</span>
          </div>
        </div>
        <span v-else class="text-n-slate-10 italic text-[10px]">Não atribuído</span>
      </div>

      <div
        v-if="card.due_date"
        class="flex items-center gap-1 shrink-0 bg-n-alpha-black2 px-2 py-1 rounded text-xs font-semibold"
        :class="dueDateClass"
      >
        📅 {{ formattedDate }}
      </div>
    </div>

    <!-- Botões -->
    <div
      v-if="!hideActions"
      class="absolute top-2 right-2 flex gap-1 bg-n-surface-1/90 backdrop-blur-sm rounded p-0.5"
    >
      <WootButton
        v-if="isLastColumn"
        variant="ghost"
        color="teal"
        size="xs"
        icon="i-lucide-inbox"
        title="Arquivar"
        @click.stop="$emit('archive')"
      />

      <WootButton
        v-if="!isLastColumn"
        variant="ghost"
        color="ruby"
        size="xs"
        icon="i-lucide-trash"
        title="Excluir"
        @click.stop="$emit('delete')"
      />
    </div>
  </div>
</template>

<style scoped>
/* Estilo para garantir posicionamento correto do botão excluir */
.kanban-card-container {
  position: relative;
}
</style>
