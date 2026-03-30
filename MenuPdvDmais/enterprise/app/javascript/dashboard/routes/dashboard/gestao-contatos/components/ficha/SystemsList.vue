<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ficha/SystemsList.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: -
 * Description: (Adicionar descrição em português)
-->
<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ficha/SystemsList.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: BaseTechnicalList.vue
 * Description: Componente de lista e cadastro de Sistemas vinculados ao cliente.
-->
<script setup>
import { ref, reactive } from "vue";
import BaseTechnicalList from "./BaseTechnicalList.vue";
import WootButton from "dashboard/components-next/button/Button.vue";
import WootInput from "dashboard/components-next/input/Input.vue";
import WootTextArea from "dashboard/components-next/textarea/TextArea.vue";

const props = defineProps({
  systems: { type: Array, default: () => [] },
  deploymentId: { type: Number, required: false },
});

const emit = defineEmits(["add", "remove"]);

const showForm = ref(false);
const newSystem = reactive({
  system_name: "",
  version: "",
  installed_at: "",
  notes: "",
});

function formatDate(dateStr) {
  if (!dateStr) return "";
  return new Date(dateStr).toLocaleDateString("pt-BR");
}

function handleAdd() {
  if (!newSystem.system_name.trim()) return;
  emit("add", { ...newSystem });
  Object.assign(newSystem, {
    system_name: "",
    version: "",
    installed_at: "",
    notes: "",
  });
  showForm.value = false;
}
</script>

<template>
  <BaseTechnicalList
    v-model:show-form="showForm"
    title="Sistemas Instalados"
    icon="💻"
    :items="systems"
    empty-text="Nenhum sistema instalado"
    theme="green"
  >
    <template #card="{ item }">
      <div class="flex justify-between items-start mb-2 basis-full">
        <div>
          <h4 class="font-bold text-n-slate-12">
            {{ item.system_name }}
          </h4>
          <span
v-if="item.version" class="text-xs text-n-slate-10"
            >v{{ item.version }}</span
          >
        </div>
        <div class="flex gap-2 items-center">
          <span
            class="text-[10px] font-medium px-2 py-0.5 bg-n-green-3 text-n-green-11 rounded-full"
          >
            {{ formatDate(item.installed_at) }}
          </span>
          <WootButton
            variant="ghost"
            color="ruby"
            size="sm"
            class="p-1"
            icon="trash"
            @click.stop="$emit('remove', item.id)"
          />
        </div>
      </div>
      <p
        v-if="item.notes"
        class="text-sm text-n-slate-11 line-clamp-2 mb-3"
      >
        {{ item.notes }}
      </p>
      <div
        class="flex items-center gap-2 mt-2 pt-2 border-t border-n-weak text-[11px] text-n-slate-10"
      >
        <div
          class="w-5 h-5 rounded-full bg-n-green-3 flex items-center justify-center overflow-hidden border border-n-green-6"
        >
          <img
            v-if="item.installed_by?.avatar_url"
            :src="item.installed_by.avatar_url"
            class="w-full h-full object-cover"
          />
          <span
            v-else
            class="text-[10px] font-bold text-n-green-11 capitalize"
            >{{ item.installed_by?.name?.charAt(0) || "?" }}</span
          >
        </div>
        <span class="text-n-slate-10"
          >Instalado por: {{ item.installed_by?.name || "Sistema" }}</span
        >
      </div>
    </template>

    <template #form>
      <WootInput
        v-model="newSystem.system_name"
        placeholder="Nome do sistema (ex: PDV Dmais)"
        class="w-full"
      />
      <div class="grid grid-cols-2 gap-2">
        <WootInput
          v-model="newSystem.version"
          placeholder="Versão (ex: 3.1.2)"
          class="w-full"
        />
        <WootInput
          v-model="newSystem.installed_at"
          type="date"
          class="w-full"
        />
      </div>
      <WootTextArea
        v-model="newSystem.notes"
        label="Observações"
        placeholder="Observações (opcional)"
        auto-height
      />
      <div class="flex gap-2 pt-2">
        <WootButton
          :disabled="!newSystem.system_name"
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
