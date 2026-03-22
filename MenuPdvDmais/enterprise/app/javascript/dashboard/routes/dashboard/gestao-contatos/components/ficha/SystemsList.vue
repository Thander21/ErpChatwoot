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
          <h4 class="font-bold text-slate-900 dark:text-white">
            {{ item.system_name }}
          </h4>
          <span
v-if="item.version" class="text-xs text-slate-500"
            >v{{ item.version }}</span
          >
        </div>
        <div class="flex gap-2 items-center">
          <span
            class="text-[10px] font-medium px-2 py-0.5 bg-green-50 dark:bg-green-900/40 text-green-600 dark:text-green-300 rounded-full"
          >
            {{ formatDate(item.installed_at) }}
          </span>
          <button
            class="p-1.5 text-red-400 hover:text-red-600 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-lg transition-colors"
            @click.stop="$emit('remove', item.id)"
          >
            <svg
              class="w-4 h-4"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
              />
            </svg>
          </button>
        </div>
      </div>
      <p
        v-if="item.notes"
        class="text-sm text-slate-600 dark:text-slate-400 line-clamp-2 mb-3"
      >
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
          >Instalado por: {{ item.installed_by?.name || "Sistema" }}</span
        >
      </div>
    </template>

    <template #form>
      <input
        v-model="newSystem.system_name"
        placeholder="Nome do sistema (ex: PDV Dmais)"
        class="w-full px-3 py-2 text-sm border border-gray-200 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-900 text-slate-800 dark:text-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500"
      />
      <div class="grid grid-cols-2 gap-2">
        <input
          v-model="newSystem.version"
          placeholder="Versão (ex: 3.1.2)"
          class="px-3 py-2 text-sm border border-gray-200 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-900 text-slate-800 dark:text-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
        <input
          v-model="newSystem.installed_at"
          type="date"
          class="px-3 py-2 text-sm border border-gray-200 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-900 text-slate-800 dark:text-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
      </div>
      <input
        v-model="newSystem.notes"
        placeholder="Observações (opcional)"
        class="w-full px-3 py-2 text-sm border border-gray-200 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-900 text-slate-800 dark:text-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500"
      />
      <div class="flex gap-2">
        <button
          :disabled="!newSystem.system_name"
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
