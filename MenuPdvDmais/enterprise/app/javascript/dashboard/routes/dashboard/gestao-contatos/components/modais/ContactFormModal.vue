<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/modais/ContactFormModal.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: -
 * Description: (Adicionar descrição em português)
-->
<script setup>
import { ref, watch, computed } from "vue";

const props = defineProps({
  show: Boolean,
  initialData: Object,
  loading: Boolean,
});

const emit = defineEmits(["close", "submit"]);

const form = ref({
  name: "",
  email: "",
  phone_number: "",
  company_name: "",
});

const isEditing = computed(() => !!props.initialData);

watch(
  () => props.initialData,
  (newData) => {
    if (newData) {
      form.value = {
        name: newData.name || "",
        email: newData.email || "",
        phone_number: newData.phone_number || "",
        company_name:
          newData.company_name ||
          newData.additional_attributes?.company_name ||
          "",
      };
    } else {
      form.value = {
        name: "",
        email: "",
        phone_number: "",
        company_name: "",
      };
    }
  },
  { immediate: true },
);

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
      class="bg-white dark:bg-slate-900 rounded-lg p-6 w-full max-w-md mx-4"
      @click.stop
    >
      <h2 class="text-xl font-bold mb-4 text-slate-900 dark:text-white">
        {{ isEditing ? "Editar Contato" : "Novo Contato" }}
      </h2>
      <form class="space-y-4" @submit.prevent="handleSubmit">
        <div>
          <label
            class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1"
          >
            Nome
          </label>
          <input
            v-model="form.name"
            type="text"
            class="w-full px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white"
          />
        </div>
        <div>
          <label
            class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1"
          >
            Email
          </label>
          <input
            v-model="form.email"
            type="email"
            class="w-full px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white"
          />
        </div>
        <div>
          <label
            class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1"
          >
            Telefone
          </label>
          <input
            v-model="form.phone_number"
            type="text"
            class="w-full px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white"
          />
        </div>
        <div>
          <label
            class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1"
          >
            Empresa
          </label>
          <input
            v-model="form.company_name"
            type="text"
            class="w-full px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white"
          />
        </div>
        <div class="flex gap-2 pt-4">
          <button
            type="submit"
            :disabled="loading"
            class="flex-1 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
          >
            {{ loading ? "Salvando..." : isEditing ? "Salvar" : "Criar" }}
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
