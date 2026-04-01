<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/modais/ContactFormModal.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: -
 * Description: (Adicionar descrição em português)
-->
<script setup>
import { ref, watch, computed } from "vue";
import WootButton from "dashboard/components-next/button/Button.vue";
import WootInput from "dashboard/components-next/input/Input.vue";

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
    class="fixed inset-0 bg-n-overlay flex items-center justify-center z-50"
    @click="$emit('close')"
  >
    <div
      class="bg-n-solid-1 border border-n-weak rounded-lg p-6 w-full max-w-md mx-4"
      @click.stop
    >
      <h2 class="text-xl font-bold mb-4 text-n-slate-12">
        {{ isEditing ? "Editar Contato" : "Novo Contato" }}
      </h2>
      <form class="space-y-4" @submit.prevent="handleSubmit">
        <div>
          <WootInput
            v-model="form.name"
            label="Nome"
            placeholder="Nome completo"
            class="w-full"
          />
        </div>
        <div>
          <WootInput
            v-model="form.email"
            type="email"
            label="Email"
            placeholder="Email"
            class="w-full"
          />
        </div>
        <div>
          <WootInput
            v-model="form.phone_number"
            label="Telefone"
            placeholder="Telefone"
            class="w-full"
          />
        </div>
        <div>
          <WootInput
            v-model="form.company_name"
            label="Empresa"
            placeholder="Empresa"
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
            {{ isEditing ? "Salvar" : "Criar" }}
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
