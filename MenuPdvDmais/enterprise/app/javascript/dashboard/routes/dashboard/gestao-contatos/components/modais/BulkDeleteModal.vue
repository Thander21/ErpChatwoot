<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/modais/BulkDeleteModal.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: -
 * Description: (Adicionar descrição em português)
-->
<script setup>
import WootButton from "dashboard/components-next/button/Button.vue";

defineProps({
  show: Boolean,
  selectedCount: Number,
  loading: Boolean,
});

defineEmits(["close", "submit"]);
</script>

<template>
  <div
    v-if="show"
    class="fixed inset-0 bg-n-overlay flex items-center justify-center z-50"
    @click="$emit('close')"
  >
    <div
      class="bg-n-solid-1 border border-n-weak rounded-lg p-6 w-full max-w-lg mx-4"
      @click.stop
    >
      <div class="flex items-center gap-3 mb-4">
        <div
          class="w-12 h-12 bg-n-red-3 rounded-full flex items-center justify-center"
        >
          <svg
            class="w-6 h-6 text-n-red-11"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
            />
          </svg>
        </div>
        <div>
          <h2 class="text-xl font-bold text-n-slate-12">
            Confirmar Exclusão
          </h2>
          <p class="text-sm text-n-slate-11">
            Esta ação não pode ser desfeita
          </p>
        </div>
      </div>

      <div
        class="bg-n-red-3 border border-n-red-6 rounded-lg p-4 mb-6"
      >
        <div class="flex items-start gap-3">
          <svg
            class="w-5 h-5 text-n-red-11 mt-0.5"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"
            />
          </svg>
          <div>
            <p class="text-sm font-medium text-n-red-12">
              Você está prestes a deletar
              {{ selectedCount }} contato{{ selectedCount !== 1 ? "s" : "" }}
            </p>
            <p class="text-sm text-n-red-11 mt-1">
              Todos os dados desses contatos, incluindo conversas e histórico,
              serão permanentemente removidos.
            </p>
          </div>
        </div>
      </div>

      <div class="flex gap-2">
        <WootButton
          variant="outline"
          color="slate"
          class="flex-1"
          @click="$emit('close')"
        >
          Cancelar
        </WootButton>
        <WootButton
          :is-loading="loading"
          color="ruby"
          class="flex-1"
          @click="$emit('submit')"
        >
          {{ loading ? "Deletando..." : "Deletar Contatos" }}
        </WootButton>
      </div>
    </div>
  </div>
</template>
