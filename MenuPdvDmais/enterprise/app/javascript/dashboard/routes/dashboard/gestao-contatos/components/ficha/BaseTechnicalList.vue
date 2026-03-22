<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ficha/BaseTechnicalList.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: -
 * Description: (Adicionar descrição em português)
-->
<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ficha/BaseTechnicalList.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: -
 * Description: Wrapper genérico das abas da Ficha, contendo UI padronizada.
-->
<script setup>
import { computed, ref, watch } from "vue";

const props = defineProps({
  title: { type: String, required: true },
  icon: { type: String, default: "" },
  items: { type: Array, default: () => [] },
  emptyText: { type: String, default: "Nenhum registro encontrado" },
  theme: { type: String, default: "blue" }, // blue, purple, green, orange
  showForm: { type: Boolean, default: false },
});

defineEmits(["update:showForm"]);

const themes = {
  blue: { btn: "bg-blue-600 hover:bg-blue-700" },
  purple: { btn: "bg-purple-600 hover:bg-purple-700" },
  green: { btn: "bg-green-600 hover:bg-green-700" },
  orange: { btn: "bg-orange-600 hover:bg-orange-700" },
};

const themeClasses = computed(() => {
  return themes[props.theme] || themes.blue;
});

// --- PAGINAÇÃO E ORDENAÇÃO ---
const currentPage = ref(1);
const itemsPerPage = 3;

// Monitora mudanças nos itens para resetar a página para 1 se adicionarem algo novo
watch(
  () => props.items,
  () => {
    currentPage.value = 1;
  },
  { deep: true },
);

// Ordena os itens do mais recente para o mais antigo (baseado nos campos de data comuns)
const sortedItems = computed(() => {
  if (!props.items) return [];
  return [...props.items].sort((a, b) => {
    const dateA = new Date(
      a.trained_at ||
        a.installed_at ||
        a.occurred_at ||
        a.created_at ||
        a.updated_at ||
        0,
    );
    const dateB = new Date(
      b.trained_at ||
        b.installed_at ||
        b.occurred_at ||
        b.created_at ||
        b.updated_at ||
        0,
    );
    return dateB - dateA;
  });
});

const totalPages = computed(
  () => Math.ceil(sortedItems.value.length / itemsPerPage) || 1,
);

const displayedItems = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage;
  return sortedItems.value.slice(start, start + itemsPerPage);
});

function prevPage() {
  if (currentPage.value > 1) currentPage.value--;
}

function nextPage() {
  if (currentPage.value < totalPages.value) currentPage.value++;
}
</script>

<template>
  <div class="flex-1 flex flex-col min-h-0 p-4 pt-2">
    <!-- Header Padronizado -->
    <div class="flex items-center justify-between mb-4 shrink-0">
      <h3 class="text-sm font-semibold text-slate-700 dark:text-slate-300">
        {{ title }}
      </h3>
      <button
        v-if="!showForm"
        :class="themeClasses.btn"
        class="flex items-center gap-1.5 px-3 py-1.5 text-white text-xs font-semibold rounded-lg transition-colors shadow-sm"
        @click="$emit('update:showForm', true)"
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
            d="M12 6v6m0 0v6m0-6h6m-6 0H6"
          />
        </svg>
        Adicionar
      </button>
    </div>

    <!-- Formulário no Topo -->
    <div
      v-if="showForm"
      class="bg-gray-50 dark:bg-slate-800 border border-gray-200 dark:border-slate-700 rounded-xl p-4 space-y-3 mb-4 shrink-0"
    >
      <slot name="form" />
    </div>

    <!-- Área da Lista (Gerenciada via Paginação JS) -->
    <div class="flex-1 pr-1 space-y-3 pb-2 pt-2">
      <!-- Lista Vazia -->
      <div
        v-if="items.length === 0 && !showForm"
        class="text-center py-6 text-slate-400 text-sm italic"
      >
        <div v-if="icon" class="mb-2 text-3xl opacity-50">{{ icon }}</div>
        {{ emptyText }}
      </div>

      <!-- Lista de Itens Paginados -->
      <div
        v-for="item in displayedItems"
        :key="item.id"
        class="p-4 bg-white dark:bg-slate-800 border border-gray-100 dark:border-slate-700 rounded-xl shadow-sm"
      >
        <slot name="card" :item="item" />
      </div>

      <!-- Controles de Paginação -->
      <div
        v-if="totalPages > 1"
        class="flex items-center justify-between pt-3 mt-4 border-t border-gray-100 dark:border-slate-700"
      >
        <button
          :disabled="currentPage === 1"
          class="px-3 py-1.5 text-xs font-semibold rounded-lg border border-gray-200 dark:border-slate-700 text-slate-600 dark:text-slate-300 hover:bg-gray-50 dark:hover:bg-slate-800 disabled:opacity-30 transition-colors"
          @click="prevPage"
        >
          Anterior
        </button>
        <span class="text-xs text-slate-500 font-medium">Página {{ currentPage }} de {{ totalPages }}</span>
        <button
          :disabled="currentPage === totalPages"
          class="px-3 py-1.5 text-xs font-semibold rounded-lg border border-gray-200 dark:border-slate-700 text-slate-600 dark:text-slate-300 hover:bg-gray-50 dark:hover:bg-slate-800 disabled:opacity-30 transition-colors"
          @click="nextPage"
        >
          Próximo
        </button>
      </div>
    </div>
  </div>
</template>
