<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ContactsFilterBar.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: -
 * Description: (Adicionar descrição em português)
-->
<script setup>
import WootButton from "dashboard/components-next/button/Button.vue";

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
    class="bg-n-alpha-black2 border border-n-weak rounded-lg p-4 mb-6 shadow-sm"
  >
    <div class="flex items-center justify-between">
      <div class="flex items-center gap-3">
        <svg
          class="w-5 h-5 text-n-slate-11"
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
        <span class="text-sm font-medium text-n-slate-12">
          Filtro ativo: {{ getFilterLabel(activeFilter) }}
        </span>
        <span class="text-sm text-n-slate-11">
          ({{ filteredCount }} contato{{ filteredCount !== 1 ? "s" : "" }})
        </span>
      </div>
      <WootButton
        color="slate"
        size="sm"
        @click="$emit('clearFilter')"
      >
        Limpar Filtro
      </WootButton>
    </div>
  </div>
</template>
