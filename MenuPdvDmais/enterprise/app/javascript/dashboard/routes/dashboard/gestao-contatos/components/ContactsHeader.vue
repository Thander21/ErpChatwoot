<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ContactsHeader.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: -
 * Description: (Adicionar descrição em português)
-->
<script setup>
import WootButton from "dashboard/components-next/button/Button.vue";

defineProps({
  searchQuery: String,
  loading: Boolean,
});

defineEmits(["update:searchQuery", "refresh"]);
</script>

<template>
  <div class="flex items-center justify-between mb-4">
    <h1 class="text-3xl font-bold text-n-slate-12">
      Gestão de Contatos
    </h1>
    <div class="flex gap-2">
      <WootButton
        color="blue"
        icon="refresh-cw"
        :is-loading="loading"
        @click="$emit('refresh')"
      >
        Recarregar
      </WootButton>
    </div>
  </div>
</template>
