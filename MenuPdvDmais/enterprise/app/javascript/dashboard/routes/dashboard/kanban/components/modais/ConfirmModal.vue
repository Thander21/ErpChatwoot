<template>
  <div
    v-if="show"
    class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
    @click.self="$emit('cancel')"
  >
    <div
      class="bg-white dark:bg-slate-900 rounded-lg p-6 w-full max-w-md mx-4 shadow-xl"
    >
      <h2 class="text-xl font-bold mb-4 text-slate-900 dark:text-white">
        {{ title }}
      </h2>

      <p class="text-slate-700 dark:text-slate-300 mb-4">
        {{ message }}
      </p>

      <div
        v-if="userName"
        class="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg p-3 mb-4"
      >
        <p class="text-sm text-blue-900 dark:text-blue-200">
          📝 Esta ação será registrada com os dados do usuário:
          <strong class="font-semibold">{{ userName }}</strong>
        </p>
      </div>

      <div class="flex gap-2 justify-end">
        <button
          type="button"
          @click="$emit('cancel')"
          class="inline-flex items-center justify-center px-4 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed transition-colors dark:bg-slate-800 dark:text-gray-200 dark:border-slate-600 dark:hover:bg-slate-700"
          :disabled="loading"
        >
          Cancelar
        </button>

        <button
          @click="$emit('confirm')"
          class="inline-flex items-center justify-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white focus:outline-none focus:ring-2 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          :class="
            confirmColor === 'red'
              ? 'bg-red-600 hover:bg-red-700 focus:ring-red-500'
              : 'bg-green-600 hover:bg-green-700 focus:ring-green-500'
          "
          :disabled="loading"
        >
          <svg
            v-if="loading"
            class="animate-spin -ml-1 mr-2 h-4 w-4 text-white"
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
          >
            <circle
              class="opacity-25"
              cx="12"
              cy="12"
              r="10"
              stroke="currentColor"
              stroke-width="4"
            ></circle>
            <path
              class="opacity-75"
              fill="currentColor"
              d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
            ></path>
          </svg>
          {{ confirmLabel }}
        </button>
      </div>
    </div>
  </div>
</template>

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
