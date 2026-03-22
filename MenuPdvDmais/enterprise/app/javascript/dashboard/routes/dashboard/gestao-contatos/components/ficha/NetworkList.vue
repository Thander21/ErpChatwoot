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
        <h4 class="font-bold text-slate-900 dark:text-white">
          {{ item.network_type }}
        </h4>
        <span
          class="text-[10px] font-medium px-2 py-0.5 bg-green-50 dark:bg-green-900/40 text-green-600 dark:text-green-300 rounded-full"
        >
          {{ formatDate(item.installed_at) }}
        </span>
      </div>
      <p class="text-sm text-slate-600 dark:text-slate-400 line-clamp-2 mb-3">
        {{ item.notes }}
      </p>
      <div
        class="flex items-center gap-2 mt-2 pt-2 border-t border-gray-50 dark:border-slate-700/50 text-[11px] text-slate-400"
      >
        <div
          class="w-5 h-5 rounded-full bg-green-50 dark:bg-green-900/30 flex items-center justify-center overflow-hidden border border-green-100 dark:border-green-800"
        >
          <img
            v-if="item.installed_by?.avatar_url"
            :src="item.installed_by.avatar_url"
            class="w-full h-full object-cover"
          />
          <span
            v-else
            class="text-[10px] font-bold text-green-600 dark:text-green-400 capitalize"
            >{{ item.installed_by?.name?.charAt(0) || "?" }}</span
          >
        </div>
        <span class="text-slate-500 dark:text-slate-400"
          >Agente: {{ item.installed_by?.name || "Sistema" }}</span
        >
      </div>
    </template>

    <template #form>
      <div class="grid grid-cols-2 gap-2">
        <input
          v-model="newNetwork.network_type"
          placeholder="Tipo (ex: Wi-Fi, Cabeada)"
          class="px-3 py-2 text-sm border border-gray-200 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-900 text-slate-800 dark:text-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
        <input
          v-model="newNetwork.installed_at"
          type="date"
          class="px-3 py-2 text-sm border border-gray-200 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-900 text-slate-800 dark:text-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
      </div>
      <input
        v-model="newNetwork.infrastructure_details"
        placeholder="Detalhes da infraestrutura (ex: Roteador principal)"
        class="w-full px-3 py-2 text-sm border border-gray-200 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-900 text-slate-800 dark:text-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500"
      />
      <textarea
        v-model="newNetwork.notes"
        placeholder="Observações adicionais"
        rows="2"
        class="w-full px-3 py-2 text-sm border border-gray-200 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-900 text-slate-800 dark:text-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"
      />
      <div class="flex gap-2">
        <button
          :disabled="!newNetwork.network_type || !newNetwork.installed_at"
          class="flex-1 py-2 bg-blue-600 hover:bg-blue-700 disabled:opacity-50 text-white text-sm font-medium rounded-lg transition-colors"
          @click="handleAdd"
        >
          Registrar
        </button>
        <button
          class="px-4 py-2 text-slate-500 hover:bg-gray-200 dark:hover:bg-slate-700 text-sm rounded-lg transition-colors"
          @click="showForm = false"
        >
          Cancelar
        </button>
      </div>
    </template>
  </BaseTechnicalList>
</template>
