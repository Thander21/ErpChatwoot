<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/kanban/components/modais/ConfirmModal.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: -
 * Description: (Adicionar descrição em português)
-->
<script setup>
import WootButton from "dashboard/components-next/button/Button.vue";

defineProps({
  show: {
    type: Boolean,
    default: false,
  },
  title: {
    type: String,
    default: "Confirmar ação",
  },
  message: {
    type: String,
    required: true,
  },
  userName: {
    type: String,
    default: "",
  },
  confirmLabel: {
    type: String,
    default: "Confirmar",
  },
  confirmColor: {
    type: String,
    default: "red",
  },
  loading: {
    type: Boolean,
    default: false,
  },
});

defineEmits(["confirm", "cancel"]);
</script>

<template>
  <div
    v-if="show"
    class="fixed inset-0 bg-n-overlay flex items-center justify-center z-50"
    @click.self="$emit('cancel')"
  >
    <div
      class="bg-n-surface-1 border border-n-weak rounded-lg p-6 w-full max-w-md mx-4 shadow-xl"
    >
      <h2 class="text-xl font-bold mb-4 text-n-slate-12">
        {{ title }}
      </h2>

      <p class="text-n-slate-11 mb-4">
        {{ message }}
      </p>

      <div
        v-if="userName"
        class="bg-n-alpha-black2 border border-n-weak rounded-lg p-3 mb-4"
      >
        <p class="text-sm text-n-slate-12">
          📝 Esta ação será registrada com os dados do usuário:
          <strong class="font-semibold">{{ userName }}</strong>
        </p>
      </div>

      <div class="flex gap-2 justify-end">
        <WootButton
          variant="outline"
          color="slate"
          :is-loading="loading"
          @click="$emit('cancel')"
        >
          Cancelar
        </WootButton>

        <WootButton
          :color="confirmColor === 'red' ? 'ruby' : 'teal'"
          :is-loading="loading"
          @click="$emit('confirm')"
        >
          {{ confirmLabel }}
        </WootButton>
      </div>
    </div>
  </div>
</template>
