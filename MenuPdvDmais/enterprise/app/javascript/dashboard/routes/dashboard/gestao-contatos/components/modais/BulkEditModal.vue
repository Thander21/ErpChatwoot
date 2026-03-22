<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/modais/BulkEditModal.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: -
 * Description: (Adicionar descrição em português)
-->
<script setup>
import { ref } from "vue";

defineProps({
  show: Boolean,
  selectedCount: Number,
  loading: Boolean,
});

const emit = defineEmits(["close", "submit"]);

const form = ref({
  company_name: "",
});

const handleSubmit = () => {
  emit("submit", { ...form.value });
};
</script>

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
      <h2 class="text-xl font-bold mb-4 text-slate-900 dark:text-white">
        Editar Contatos em Lote
      </h2>
      <p class="text-sm text-slate-600 dark:text-slate-400 mb-4">
        Aplicar alterações a {{ selectedCount }} contato{{
          selectedCount !== 1 ? "s" : ""
        }}
        selecionado{{ selectedCount !== 1 ? "s" : "" }}
      </p>

      <form class="space-y-4" @submit.prevent="handleSubmit">
        <div
          class="bg-yellow-50 dark:bg-yellow-900 border border-yellow-200 dark:border-yellow-700 rounded-lg p-4 mb-4"
        >
          <div class="flex items-start gap-3">
            <svg
              class="w-5 h-5 text-yellow-600 dark:text-yellow-400 mt-0.5"
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
              <p
                class="text-sm font-medium text-yellow-800 dark:text-yellow-200"
              >
                Atenção: Campos vazios serão ignorados
              </p>
              <p class="text-sm text-yellow-700 dark:text-yellow-300">
                Apenas os campos preenchidos serão atualizados nos contatos
                selecionados.
              </p>
            </div>
          </div>
        </div>

        <div>
          <label
            class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1"
          >
            Empresa (opcional)
          </label>
          <input
            v-model="form.company_name"
            type="text"
            placeholder="Digite o nome da empresa"
            class="w-full px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white"
          />
        </div>

        <div class="flex gap-2 pt-4">
          <button
            type="submit"
            :disabled="loading"
            class="flex-1 px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 disabled:opacity-50"
          >
            {{ loading ? "Salvando..." : "Aplicar Alterações" }}
          </button>
          <button
            type="button"
            class="px-4 py-2 bg-gray-300 dark:bg-slate-600 text-slate-700 dark:text-slate-300 rounded-lg hover:bg-gray-400 dark:hover:bg-slate-500"
            @click="$emit('close')"
          >
            Cancelar
          </button>
        </div>
      </form>
    </div>
  </div>
</template>
