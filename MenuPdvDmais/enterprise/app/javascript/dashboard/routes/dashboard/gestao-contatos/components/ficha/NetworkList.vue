<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ficha/NetworkList.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: -
 * Description: (Adicionar descrição em português)
-->
<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ficha/NetworkList.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: BaseTechnicalList.vue
 * Description: Componente de lista e cadastro de ativos e configurações de Rede.
-->
<script setup>
import { ref, reactive } from "vue";
import BaseTechnicalList from "./BaseTechnicalList.vue";
import WootButton from "dashboard/components-next/button/Button.vue";
import WootInput from "dashboard/components-next/input/Input.vue";
import WootTextArea from "dashboard/components-next/textarea/TextArea.vue";

const props = defineProps({
  networks: { type: Array, default: () => [] },
});

const emit = defineEmits(["add"]);

const showForm = ref(false);
const newNetwork = reactive({
  network_type: "",
  infrastructure_details: "",
  installed_at: new Date().toISOString().split("T")[0],
  notes: "",
});

function formatDate(date) {
  if (!date) return "-";
  return new Date(date).toLocaleDateString("pt-BR");
}

function handleAdd() {
  if (!newNetwork.network_type || !newNetwork.installed_at) return;
  emit("add", { ...newNetwork });
  Object.assign(newNetwork, {
    network_type: "",
    infrastructure_details: "",
    installed_at: new Date().toISOString().split("T")[0],
    notes: "",
  });
  showForm.value = false;
}
</script>

<template>
  <BaseTechnicalList
    v-model:show-form="showForm"
    title="Registros de Rede"
    icon="🌐"
    :items="networks"
    empty-text="Nenhum registro de rede"
    theme="green"
  >
    <template #card="{ item }">
      <div class="flex justify-between items-start mb-2">
        <h4 class="font-bold text-n-slate-12">
          {{ item.network_type }}
        </h4>
        <span
          class="text-[10px] font-medium px-2 py-0.5 bg-n-green-3 text-n-green-11 rounded-full"
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
          >Agente: {{ item.installed_by?.name || "Sistema" }}</span
        >
      </div>
    </template>

    <template #form>
      <div class="grid grid-cols-2 gap-2">
        <WootInput
          v-model="newNetwork.network_type"
          placeholder="Tipo (ex: Wi-Fi, Cabeada)"
          class="w-full"
        />
        <WootInput
          v-model="newNetwork.installed_at"
          type="date"
          class="w-full"
        />
      </div>
      <WootInput
        v-model="newNetwork.infrastructure_details"
        placeholder="Detalhes da infraestrutura (ex: Roteador principal)"
        class="w-full"
      />
      <WootTextArea
        v-model="newNetwork.notes"
        label="Observações"
        placeholder="Observações adicionais"
        auto-height
      />
      <div class="flex gap-2 pt-2">
        <WootButton
          :disabled="!newNetwork.network_type || !newNetwork.installed_at"
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
