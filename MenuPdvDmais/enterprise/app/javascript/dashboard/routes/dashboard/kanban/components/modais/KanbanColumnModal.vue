<template>
  <div
    v-if="show"
    class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
  >
    <div
      class="bg-white dark:bg-slate-900 rounded-lg p-6 w-full max-w-md mx-4 shadow-xl"
    >
      <h2 class="text-xl font-bold mb-4 text-slate-900 dark:text-white">
        {{ isEditing ? "Editar Coluna" : "Nova Coluna" }}
      </h2>
      <form @submit.prevent="handleSubmit" class="space-y-4">
          <woot-input
            v-model="form.name"
            type="text"
            label="Nome *"
            placeholder="Digite o nome da coluna"
            required
          />

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

          <woot-input
            v-model.number="form.position"
            type="number"
            label="Ordem"
            placeholder="0"
            min="0"
          />

        <div class="flex gap-2 pt-4 justify-end">
          <woot-button
            variant="clear"
            color="slate"
            @click="$emit('close')"
          >
            Cancelar
          </woot-button>
          
          <woot-button
            type="submit"
            :is-loading="loading"
            variant="solid"
            color="blue"
            :class="{ 'opacity-50 cursor-not-allowed': loading }" 
            :disabled="loading"
          >
            {{ isEditing ? "Atualizar" : "Criar Coluna" }}
          </woot-button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue';
import WootButton from 'dashboard/components-next/button/Button.vue';
import WootInput from 'dashboard/components-next/input/Input.vue';

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
