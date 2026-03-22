<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ficha/HardwareList.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: -
 * Description: (Adicionar descrição em português)
-->
<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ficha/HardwareList.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: BaseTechnicalList.vue
 * Description: Componente de lista e cadastro de atividades e manutenções de Hardware.
-->
<script setup>
import { ref, reactive } from "vue";
import BaseTechnicalList from "./BaseTechnicalList.vue";

const props = defineProps({
  hardwares: { type: Array, default: () => [] },
});

const emit = defineEmits(["add"]);

const showForm = ref(false);
const newHardware = reactive({
  hardware_name: "",
  serial_number: "",
  installed_at: new Date().toISOString().split("T")[0],
  notes: "",
});

function formatDate(date) {
  if (!date) return "-";
  return new Date(date).toLocaleDateString("pt-BR");
}

function handleAdd() {
  if (!newHardware.hardware_name || !newHardware.installed_at) return;
  emit("add", { ...newHardware });
  Object.assign(newHardware, {
    hardware_name: "",
    serial_number: "",
    installed_at: new Date().toISOString().split("T")[0],
    notes: "",
  });
  showForm.value = false;
}
</script>

<template>
  <BaseTechnicalList
    v-model:show-form="showForm"
    title="Hardwares Registrados"
    icon="🔌"
    :items="hardwares"
    empty-text="Nenhum hardware registrado"
    theme="orange"
  >
    <template #card="{ item }">
      <div class="flex justify-between items-start mb-2">
        <h4 class="font-bold text-slate-900 dark:text-white">
          {{ item.hardware_name }}
        </h4>
        <span
          class="text-[10px] font-medium px-2 py-0.5 bg-orange-50 dark:bg-orange-900/40 text-orange-600 dark:text-orange-300 rounded-full"
        >
          {{ formatDate(item.installed_at) }}
        </span>
      </div>
      <div v-if="item.serial_number" class="text-xs text-slate-500 mb-2">
        S/N: {{ item.serial_number }}
      </div>
      <p class="text-sm text-slate-600 dark:text-slate-400 line-clamp-2 mb-3">
        {{ item.notes }}
      </p>
      <div
        class="flex items-center gap-2 mt-2 pt-2 border-t border-gray-50 dark:border-slate-700/50 text-[11px] text-slate-400"
      >
        <div
          class="w-5 h-5 rounded-full bg-orange-50 dark:bg-orange-900/30 flex items-center justify-center overflow-hidden border border-orange-100 dark:border-orange-800"
        >
          <img
            v-if="item.installed_by?.avatar_url"
            :src="item.installed_by.avatar_url"
            class="w-full h-full object-cover"
          />
          <span
            v-else
            class="text-[10px] font-bold text-orange-600 dark:text-orange-400 capitalize"
            >{{ item.installed_by?.name?.charAt(0) || "?" }}</span
          >
        </div>
        <span class="text-slate-500 dark:text-slate-400"
          >Agente: {{ item.installed_by?.name || "Sistema" }}</span
        >
      </div>
    </template>

    <template #form>
      <input
        v-model="newHardware.hardware_name"
        placeholder="Nome do Hardware (ex: Impressora Epson)"
        class="w-full px-3 py-2 text-sm border border-gray-200 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-900 text-slate-800 dark:text-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500"
      />
      <div class="grid grid-cols-2 gap-2">
        <input
          v-model="newHardware.serial_number"
          placeholder="Número de Série"
          class="px-3 py-2 text-sm border border-gray-200 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-900 text-slate-800 dark:text-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
        <input
          v-model="newHardware.installed_at"
          type="date"
          class="px-3 py-2 text-sm border border-gray-200 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-900 text-slate-800 dark:text-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
      </div>
      <textarea
        v-model="newHardware.notes"
        placeholder="Observações adicionais"
        rows="2"
        class="w-full px-3 py-2 text-sm border border-gray-200 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-900 text-slate-800 dark:text-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"
      />
      <div class="flex gap-2">
        <button
          :disabled="!newHardware.hardware_name || !newHardware.installed_at"
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
