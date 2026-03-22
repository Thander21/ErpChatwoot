<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ContactsFilterBar.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: -
 * Description: (Adicionar descrição em português)
-->
<script setup>
defineProps({
  activeFilter: String,
  filteredCount: Number,
});

defineEmits(["clearFilter"]);

const getFilterLabel = (filterType) => {
  switch (filterType) {
    case "all":
      return "Todos os Contatos";
    case "no_company":
      return "Sem Empresa";
    case "no_phone":
      return "Sem Número";
    case "invalid_phone":
      return "Número Inválido";
    default:
      return "Filtro Desconhecido";
  }
};
</script>

<template>
  <div
    v-if="activeFilter !== 'all'"
    class="bg-gray-100 dark:bg-slate-800 border border-gray-200 dark:border-slate-700 rounded-lg p-4 mb-6"
  >
    <div class="flex items-center justify-between">
      <div class="flex items-center gap-3">
        <svg
          class="w-5 h-5 text-gray-600 dark:text-gray-400"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z"
          />
        </svg>
        <span class="text-sm font-medium text-gray-900 dark:text-white">
          Filtro ativo: {{ getFilterLabel(activeFilter) }}
        </span>
        <span class="text-sm text-gray-600 dark:text-gray-400">
          ({{ filteredCount }} contato{{ filteredCount !== 1 ? "s" : "" }})
        </span>
      </div>
      <button
        class="px-3 py-1 text-sm bg-gray-600 text-white rounded hover:bg-gray-700 transition-colors"
        @click="$emit('clearFilter')"
      >
        Limpar Filtro
      </button>
    </div>
  </div>
</template>
