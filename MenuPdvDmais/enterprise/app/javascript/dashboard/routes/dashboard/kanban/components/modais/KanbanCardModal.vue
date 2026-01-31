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
        {{ isEditing ? "Editar Card" : "Novo Card" }}
      </h2>
      <form @submit.prevent="handleSubmit" class="space-y-4">
        <div>
          <label
            class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1"
          >
            Título *
          </label>
          <input
            v-model="form.title"
            type="text"
            required
            class="w-full px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white"
            placeholder="Digite o título do card"
          />
        </div>

        <div>
          <label
            class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1"
          >
            Descrição
          </label>
          <textarea
            v-model="form.description"
            rows="3"
            class="w-full px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white"
            placeholder="Digite a descrição (opcional)"
          ></textarea>
        </div>

        <div class="grid grid-cols-2 gap-4">
          <div>
            <label
              class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1"
            >
              Coluna
            </label>
            <select
              v-model="form.kanban_column_id"
              required
              class="w-full px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white"
            >
              <option value="">Selecione uma coluna</option>
              <option
                v-for="column in columns"
                :key="column.id"
                :value="column.id"
              >
                {{ column.name }}
              </option>
            </select>
          </div>

          <div>
            <label
              class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1"
            >
              Prioridade
            </label>
            <select
              v-model="form.priority"
              class="w-full px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white"
            >
              <option :value="0">Baixa</option>
              <option :value="1">Normal</option>
              <option :value="2">Alta</option>
              <option :value="3">Urgente</option>
            </select>
          </div>
        </div>

        <div>
          <label
            class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1"
          >
            Data de vencimento
          </label>
          <input
            v-model="form.due_date"
            type="date"
            class="w-full px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white"
          />
        </div>

        <div class="flex gap-2 pt-4">
          <button
            type="submit"
            :disabled="loading"
            class="flex-1 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:opacity-50"
          >
            {{ loading ? "Salvando..." : isEditing ? "Salvar Alterações" : "Criar Card" }}
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
  columns: Array,
  initialData: Object,
  loading: Boolean,
});

const emit = defineEmits(['close', 'submit']);

const form = ref({
  title: '',
  description: '',
  kanban_column_id: '',
  priority: 0,
  due_date: '',
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
        title: '',
        description: '',
        kanban_column_id: '',
        priority: 0,
        due_date: '',
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
