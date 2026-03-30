<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ficha/InstallationList.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: -
 * Description: (Adicionar descrição em português)
-->
<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ficha/InstallationList.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: BaseTechnicalList.vue
 * Description: Componente de lista e cadastro de atividades de Implantação.
-->
<script setup>
import { ref, reactive } from "vue";
import BaseTechnicalList from "./BaseTechnicalList.vue";
import WootButton from "dashboard/components-next/button/Button.vue";
import WootInput from "dashboard/components-next/input/Input.vue";
import WootTextArea from "dashboard/components-next/textarea/TextArea.vue";

const props = defineProps({
  installations: { type: Array, default: () => [] },
});

const emit = defineEmits(["add"]);

const showForm = ref(false);
const newInstallation = reactive({
  installation_name: "",
  installed_at: new Date().toISOString().split("T")[0],
  notes: "",
});

function formatDate(date) {
  if (!date) return "-";
  return new Date(date).toLocaleDateString("pt-BR");
}

function handleAdd() {
  if (!newInstallation.installation_name || !newInstallation.installed_at)
    return;
  emit("add", { ...newInstallation });
  Object.assign(newInstallation, {
    installation_name: "",
    installed_at: new Date().toISOString().split("T")[0],
    notes: "",
  });
  showForm.value = false;
}
</script>

<template>
  <BaseTechnicalList
    v-model:show-form="showForm"
    title="Registros de Implantação"
    icon="🛠️"
    :items="installations"
    empty-text="Nenhuma instalação registrada"
    theme="blue"
  >
    <template #card="{ item }">
      <div class="flex justify-between items-start mb-2">
        <h4 class="font-bold text-n-slate-12">
          {{ item.installation_name }}
        </h4>
        <span
          class="text-[10px] font-medium px-2 py-0.5 bg-n-blue-3 text-n-blue-11 rounded-full"
        >
          {{ formatDate(item.installed_at) }}
        </span>
      </div>
      <p class="text-sm text-n-slate-11 line-clamp-2 mb-3">
        {{ item.notes }}
      </p>
      <div
        class="flex items-center gap-2 mt-2 pt-2 border-t border-n-weak text-[11px] text-n-slate-10"
      >
        <div
          class="w-5 h-5 rounded-full bg-n-blue-3 flex items-center justify-center overflow-hidden border border-n-blue-6"
        >
          <img
            v-if="item.installed_by?.avatar_url"
            :src="item.installed_by.avatar_url"
            class="w-full h-full object-cover"
          />
          <span
            v-else
            class="text-[10px] font-bold text-n-blue-11 capitalize"
            >{{ item.installed_by?.name?.charAt(0) || "A" }}</span
          >
        </div>
        <span class="text-n-slate-10"
          >Agente: {{ item.installed_by?.name || "Sistema" }}</span
        >
      </div>
    </template>

    <template #form>
      <WootInput
        v-model="newInstallation.installation_name"
        placeholder="Nome da implantação (ex: Troca de Servidor)"
        class="w-full"
      />
      <WootInput
        v-model="newInstallation.installed_at"
        type="date"
        class="w-full"
      />
      <WootTextArea
        v-model="newInstallation.notes"
        label="Observações"
        placeholder="Detalhes e observações"
        auto-height
      />
      <div class="flex gap-2 pt-2">
        <WootButton
          :disabled="!newInstallation.installation_name || !newInstallation.installed_at"
          color="blue"
          class="flex-1"
          @click="handleAdd"
        >
          Registrar
        </WootButton>
        <WootButton
          variant="outline"
          color="slate"
          @click="showForm = false"
        >
          Cancelar
        </WootButton>
      </div>
    </template>
  </BaseTechnicalList>
</template>
