<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/kanban/components/modais/KanbanColumnModal.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: -
 * Description: (Adicionar descrição em português)
-->
<script setup>
import { ref, watch } from "vue";
import WootButton from "dashboard/components-next/button/Button.vue";
import WootInput from "dashboard/components-next/input/Input.vue";
import ColorPicker from "dashboard/components-next/colorpicker/ColorPicker.vue";

const props = defineProps({
  show: Boolean,
  initialData: Object,
  loading: Boolean,
});

const emit = defineEmits(["close", "submit"]);

const form = ref({
  name: "",
  color: "#6b7280",
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
        name: "",
        color: "#6b7280",
        position: 0,
      };
      isEditing.value = false;
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
    class="fixed inset-0 bg-n-overlay flex items-center justify-center z-50"
  >
    <div
      class="bg-n-solid-1 border border-n-weak rounded-lg p-6 w-full max-w-md mx-4 shadow-xl"
    >
      <h2 class="text-xl font-bold mb-4 text-n-slate-12">
        {{ isEditing ? "Editar Coluna" : "Nova Coluna" }}
      </h2>
      <form class="space-y-4" @submit.prevent="handleSubmit">
        <WootInput
          v-model="form.name"
          type="text"
          label="Nome *"
          placeholder="Digite o nome da coluna"
          required
        />

        <div>
          <label
            class="block text-sm font-medium text-n-slate-11 mb-2"
          >
            Cor da Coluna
          </label>
          <ColorPicker
            v-model="form.color"
          />
        </div>

        <WootInput
          v-model.number="form.position"
          type="number"
          label="Ordem"
          placeholder="0"
          min="0"
        />

        <div class="flex gap-2 pt-4 justify-end">
          <WootButton
            variant="outline"
            color="slate"
            @click="$emit('close')"
          >
            Cancelar
          </WootButton>

          <WootButton
            type="submit"
            :is-loading="loading"
            color="blue"
          >
            {{ isEditing ? "Atualizar" : "Criar Coluna" }}
          </WootButton>
        </div>
      </form>
    </div>
  </div>
</template>
