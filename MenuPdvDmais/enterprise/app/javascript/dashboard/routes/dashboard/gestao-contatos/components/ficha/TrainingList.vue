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
import WootButton from "dashboard/components-next/button/Button.vue";
import WootInput from "dashboard/components-next/input/Input.vue";
import WootSelect from "dashboard/components-next/select/Select.vue";
import WootTextArea from "dashboard/components-next/textarea/TextArea.vue";
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
 
const contactOptions = computed(() =>
  companyContacts.value.map((c) => ({
    value: c.id,
    label: `${c.name}${c.phone_number ? ` · ${c.phone_number}` : ""}`,
  })),
);

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
              class="text-sm font-semibold text-n-slate-12"
              >{{ item.contact?.name || "Contato" }}</span
            >
            <span
              class="text-[10px] bg-n-purple-3 text-n-purple-11 px-2 py-0.5 rounded-full font-medium"
            >
              {{ item.system_name }}
            </span>
          </div>
          <p v-if="item.contact?.phone_number" class="text-xs text-n-slate-10">
            📱 {{ item.contact.phone_number }}
          </p>
        </div>
        <div class="flex items-center gap-3 shrink-0">
          <div class="flex flex-col items-end gap-1">
            <span
              v-if="item.trained_at"
              class="text-[10px] font-bold px-2 py-0.5 bg-n-purple-3 text-n-purple-11 rounded-full"
            >
              {{ formatDate(item.trained_at) }}
            </span>
            <span
              v-if="item.duration_minutes"
              class="text-[9px] font-semibold text-n-slate-10 uppercase tracking-wide"
            >
              ⏱️ {{ item.duration_minutes }}min
            </span>
          </div>
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
        class="text-sm text-n-slate-11 line-clamp-2 mt-2 mb-3"
      >
        {{ item.notes }}
      </p>

      <div
        class="flex items-center gap-2 mt-2 pt-2 border-t border-n-weak text-[11px] text-n-slate-10"
      >
        <div
          class="w-5 h-5 rounded-full bg-n-alpha-black2 flex items-center justify-center overflow-hidden border border-n-weak"
        >
          <img
            v-if="item.trained_by?.avatar_url"
            :src="item.trained_by.avatar_url"
            class="full h-full object-cover"
          />
          <span
            v-else
            class="text-[10px] font-bold text-n-slate-12 capitalize"
            >{{ item.trained_by?.name?.charAt(0) || "I" }}</span
          >
        </div>
        <span class="text-n-slate-10"
          >Instrutor: {{ item.trained_by?.name || "Sistema" }}</span
        >
      </div>
    </template>

    <template #form>
      <div class="space-y-3">
        <div>
          <WootSelect
            v-model="newTraining.contact_id"
            label="Quem foi treinado?"
            :options="contactOptions"
            placeholder="Selecionar contato..."
            class="w-full"
          />
        </div>
        <WootInput
          v-model="newTraining.system_name"
          placeholder="Sistema treinado (ex: PDV Dmais)"
          class="w-full"
        />
        <div class="grid grid-cols-2 gap-2">
          <WootInput
            v-model="newTraining.trained_at"
            type="date"
            class="w-full"
          />
          <WootInput
            v-model.number="newTraining.duration_minutes"
            type="number"
            placeholder="Duração (min)"
            class="w-full"
          />
        </div>
        <WootTextArea
          v-model="newTraining.notes"
          label="Observações"
          placeholder="Assuntos abordados, dúvidas levantadas..."
          auto-height
        />
        <div class="flex gap-2 pt-2">
          <WootButton
            :disabled="!newTraining.contact_id || !newTraining.system_name || !newTraining.trained_at"
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
      </div>
    </template>
  </BaseTechnicalList>
</template>
