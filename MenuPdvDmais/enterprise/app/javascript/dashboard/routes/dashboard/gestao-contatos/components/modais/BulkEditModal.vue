<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/modais/BulkEditModal.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: -
 * Description: (Adicionar descrição em português)
-->
<script setup>
import { ref } from "vue";
import WootButton from "dashboard/components-next/button/Button.vue";
import WootInput from "dashboard/components-next/input/Input.vue";

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
    class="fixed inset-0 bg-n-overlay flex items-center justify-center z-50"
    @click="$emit('close')"
  >
    <div
      class="bg-n-solid-1 border border-n-weak rounded-lg p-6 w-full max-w-lg mx-4"
      @click.stop
    >
      <h2 class="text-xl font-bold mb-4 text-n-slate-12">
        Editar Contatos em Lote
      </h2>
      <p class="text-sm text-n-slate-11 mb-4">
        Aplicar alterações a {{ selectedCount }} contato{{
          selectedCount !== 1 ? "s" : ""
        }}
        selecionado{{ selectedCount !== 1 ? "s" : "" }}
      </p>

      <form class="space-y-4" @submit.prevent="handleSubmit">
        <div
          class="bg-n-yellow-3 border border-n-yellow-6 rounded-lg p-4 mb-4"
        >
          <div class="flex items-start gap-3">
            <svg
              class="w-5 h-5 text-n-yellow-11 mt-0.5"
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
                class="text-sm font-medium text-n-yellow-12"
              >
                Atenção: Campos vazios serão ignorados
              </p>
              <p class="text-sm text-n-yellow-11">
                Apenas os campos preenchidos serão atualizados nos contatos
                selecionados.
              </p>
            </div>
          </div>
        </div>

        <div>
          <WootInput
            v-model="form.company_name"
            label="Empresa (opcional)"
            placeholder="Digite o nome da empresa"
            class="w-full"
          />
        </div>

        <div class="flex gap-2 pt-4">
          <WootButton
            type="submit"
            :is-loading="loading"
            color="blue"
            class="flex-1"
          >
            Aplicar Alterações
          </WootButton>
          <WootButton
            variant="outline"
            color="slate"
            @click="$emit('close')"
          >
            Cancelar
          </WootButton>
        </div>
      </form>
    </div>
  </div>
</template>
