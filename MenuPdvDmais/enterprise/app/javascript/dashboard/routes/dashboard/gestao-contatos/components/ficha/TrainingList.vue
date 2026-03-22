<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ficha/TrainingList.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: -
 * Description: (Adicionar descrição em português)
-->
<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ficha/TrainingList.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: BaseTechnicalList.vue
 * Description: Componente de lista e cadastro de Treinamentos ministrados ao cliente.
-->
<script setup>
import { ref, reactive, computed } from "vue";
import { useStore } from "vuex";
import BaseTechnicalList from "./BaseTechnicalList.vue";
/* global axios */

const props = defineProps({
  trainings: { type: Array, default: () => [] },
  deploymentId: { type: Number, required: false },
  companyId: { type: Number, required: true },
});

const emit = defineEmits(["add", "remove"]);
const store = useStore();
const accountId = computed(() => store.getters.getCurrentAccountId);

const showForm = ref(false);
const companyContacts = ref([]);
const newTraining = reactive({
  contact_id: "",
  system_name: "",
  trained_at: new Date().toISOString().split("T")[0],
  duration_minutes: null,
  notes: "",
});

async function loadContacts() {
  try {
    if (!accountId.value) return;
    const r = await axios.get(
      `/enterprise/api/v1/accounts/${accountId.value}/kanban_cards/contacts_by_company`,
      { params: { company_id: props.companyId } },
    );
    companyContacts.value = r.data || [];
  } catch {
    companyContacts.value = [];
  }
}

function openForm() {
  showForm.value = true;
  if (companyContacts.value.length === 0) loadContacts();
}

function formatDate(dateStr) {
  if (!dateStr) return "";
  return new Date(dateStr).toLocaleDateString("pt-BR");
}

function handleAdd() {
  if (
    !newTraining.contact_id ||
    !newTraining.system_name ||
    !newTraining.trained_at
  )
    return;
  emit("add", { ...newTraining });
  Object.assign(newTraining, {
    contact_id: "",
    system_name: "",
    trained_at: new Date().toISOString().split("T")[0],
    duration_minutes: null,
    notes: "",
  });
  showForm.value = false;
}
</script>

<template>
  <BaseTechnicalList
    title="Treinamentos Realizados"
    icon="🎓"
    :items="trainings"
    empty-text="Nenhum treinamento registrado"
    theme="purple"
    :show-form="showForm"
    @update:show-form="(val) => (val ? openForm() : (showForm = false))"
  >
    <template #card="{ item }">
      <div class="flex justify-between items-start mb-2 basis-full">
        <div class="flex-1 min-w-0 pr-4">
          <div class="flex items-center gap-2 flex-wrap mb-1">
            <span
              class="text-sm font-semibold text-slate-800 dark:text-slate-200"
              >{{ item.contact?.name || "Contato" }}</span
            >
            <span
              class="text-[10px] bg-purple-50 dark:bg-purple-900/40 text-purple-700 dark:text-purple-300 px-2 py-0.5 rounded-full font-medium"
            >
              {{ item.system_name }}
            </span>
          </div>
          <p v-if="item.contact?.phone_number" class="text-xs text-slate-500">
            📱 {{ item.contact.phone_number }}
          </p>
        </div>
        <div class="flex items-center gap-3 shrink-0">
          <div class="flex flex-col items-end gap-1">
            <span
              v-if="item.trained_at"
              class="text-[10px] font-bold px-2 py-0.5 bg-purple-50 dark:bg-purple-900/40 text-purple-600 dark:text-purple-400 rounded-full"
            >
              {{ formatDate(item.trained_at) }}
            </span>
            <span
              v-if="item.duration_minutes"
              class="text-[9px] font-semibold text-slate-400 uppercase tracking-wide"
            >
              ⏱️ {{ item.duration_minutes }}min
            </span>
          </div>
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
        class="text-sm text-slate-600 dark:text-slate-400 line-clamp-2 mt-2 mb-3"
      >
        {{ item.notes }}
      </p>

      <div
        class="flex items-center gap-2 mt-2 pt-2 border-t border-gray-50 dark:border-slate-700/50 text-[11px] text-slate-400"
      >
        <div
          class="w-5 h-5 rounded-full bg-purple-50 dark:bg-purple-900/30 flex items-center justify-center overflow-hidden border border-purple-100 dark:border-purple-800"
        >
          <img
            v-if="item.trained_by?.avatar_url"
            :src="item.trained_by.avatar_url"
            class="full h-full object-cover"
          />
          <span
            v-else
            class="text-[10px] font-bold text-purple-600 dark:text-purple-400 capitalize"
            >{{ item.trained_by?.name?.charAt(0) || "I" }}</span
          >
        </div>
        <span class="text-slate-500 dark:text-slate-400"
          >Instrutor: {{ item.trained_by?.name || "Sistema" }}</span
        >
      </div>
    </template>

    <template #form>
      <div class="space-y-3">
        <div>
          <label class="text-xs text-slate-500 block mb-1"
            >Quem foi treinado?</label
          >
          <select
            v-model="newTraining.contact_id"
            class="w-full px-3 py-2 text-sm border border-gray-200 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-900 text-slate-800 dark:text-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option value="">Selecionar contato...</option>
            <option
              v-for="contact in companyContacts"
              :key="contact.id"
              :value="contact.id"
            >
              {{ contact.name
              }}{{ contact.phone_number ? ` · ${contact.phone_number}` : "" }}
            </option>
          </select>
        </div>
        <input
          v-model="newTraining.system_name"
          placeholder="Sistema treinado (ex: PDV Dmais)"
          class="w-full px-3 py-2 text-sm border border-gray-200 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-900 text-slate-800 dark:text-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
        <div class="grid grid-cols-2 gap-2">
          <input
            v-model="newTraining.trained_at"
            type="date"
            class="px-3 py-2 text-sm border border-gray-200 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-900 text-slate-800 dark:text-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
          <input
            v-model.number="newTraining.duration_minutes"
            type="number"
            placeholder="Duração (min)"
            class="px-3 py-2 text-sm border border-gray-200 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-900 text-slate-800 dark:text-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>
        <textarea
          v-model="newTraining.notes"
          placeholder="Assuntos abordados, dúvidas levantadas..."
          rows="3"
          class="w-full px-3 py-2 text-sm border border-gray-200 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-900 text-slate-800 dark:text-slate-200 focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"
        />
        <div class="flex gap-2">
          <button
            :disabled="
              !newTraining.contact_id ||
              !newTraining.system_name ||
              !newTraining.trained_at
            "
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
      </div>
    </template>
  </BaseTechnicalList>
</template>
