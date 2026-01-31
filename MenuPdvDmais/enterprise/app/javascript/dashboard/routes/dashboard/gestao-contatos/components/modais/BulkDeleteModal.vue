<template>
  <div
    v-if="show"
    class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
    @click="$emit('close')"
  >
    <div
      class="bg-white dark:bg-slate-900 rounded-lg p-6 w-full max-w-lg mx-4"
      @click.stop
    >
      <div class="flex items-center gap-3 mb-4">
        <div
          class="w-12 h-12 bg-red-100 dark:bg-red-900 rounded-full flex items-center justify-center"
        >
          <svg
            class="w-6 h-6 text-red-600 dark:text-red-400"
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
          <h2 class="text-xl font-bold text-slate-900 dark:text-white">
            Confirmar Exclusão
          </h2>
          <p class="text-sm text-slate-600 dark:text-slate-400">
            Esta ação não pode ser desfeita
          </p>
        </div>
      </div>

      <div
        class="bg-red-50 dark:bg-red-900 border border-red-200 dark:border-red-700 rounded-lg p-4 mb-6"
      >
        <div class="flex items-start gap-3">
          <svg
            class="w-5 h-5 text-red-600 dark:text-red-400 mt-0.5"
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
            <p class="text-sm font-medium text-red-800 dark:text-red-200">
              Você está prestes a deletar
              {{ selectedCount }} contato{{
                selectedCount !== 1 ? "s" : ""
              }}
            </p>
            <p class="text-sm text-red-700 dark:text-red-300 mt-1">
              Todos os dados desses contatos, incluindo conversas e histórico,
              serão permanentemente removidos.
            </p>
          </div>
        </div>
      </div>

      <div class="flex gap-2">
        <button
          @click="$emit('close')"
          class="flex-1 px-4 py-2 bg-gray-300 dark:bg-slate-600 text-slate-700 dark:text-slate-300 rounded-lg hover:bg-gray-400 dark:hover:bg-slate-500 transition-colors"
        >
          Cancelar
        </button>
        <button
          @click="$emit('submit')"
          :disabled="loading"
          class="flex-1 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 disabled:opacity-50 transition-colors"
        >
          {{ loading ? "Deletando..." : "Deletar Contatos" }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
defineProps({
  show: Boolean,
  selectedCount: Number,
  loading: Boolean,
});

defineEmits(['close', 'submit']);
</script>
