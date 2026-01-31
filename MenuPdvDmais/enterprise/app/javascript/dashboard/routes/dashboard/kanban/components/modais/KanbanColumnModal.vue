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
        {{ isEditing ? "Editar Coluna" : "Nova Coluna" }}
      </h2>
      <form @submit.prevent="handleSubmit" class="space-y-4">
        <div>
          <label
            class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1"
          >
            Nome *
          </label>
          <input
            v-model="form.name"
            type="text"
            required
            class="w-full px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white"
            placeholder="Digite o nome da coluna"
          />
        </div>

        <div>
          <label
            class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1"
          >
            Cor
          </label>
          <input
            v-model="form.color"
            type="color"
            class="w-full h-10 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800"
          />
        </div>

        <div>
          <label
            class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1"
          >
            Ordem
          </label>
          <input
            v-model.number="form.position"
            type="number"
            min="0"
            class="w-full px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white"
            placeholder="0"
          />
        </div>

        <div class="flex gap-2 pt-4">
          <button
            type="submit"
            :disabled="loading"
            class="flex-1 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
          >
            {{ loading ? "Salvando..." : isEditing ? "Atualizar" : "Criar Coluna" }}
          </button>
          <button
            type="button"
            @click="$emit('close')"
            class="px-4 py-2 bg-gray-300 dark:bg-slate-600 text-slate-700 dark:text-slate-300 rounded-lg hover:bg-gray-400 dark:hover:bg-slate-500"
          >
            Cancelar
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue';

const props = defineProps({
  show: Boolean,
  initialData: Object,
  loading: Boolean,
});

const emit = defineEmits(['close', 'submit']);

const form = ref({
  name: '',
  color: '#6b7280',
  position: 0,
});

const isEditing = ref(false);

watch(
  () => props.initialData,
  (newData) => {
    if (newData) {
      form.value = { ...newData };
      isEditing.value = true;
    } else {
      form.value = {
        name: '',
        color: '#6b7280',
        position: 0,
      };
      isEditing.value = false;
    }
  },
  { immediate: true }
);

const handleSubmit = () => {
  emit('submit', { ...form.value });
};
</script>
