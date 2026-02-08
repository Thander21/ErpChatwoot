<template>
  <div
    v-if="show"
    class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
  >
    <div
      class="bg-white dark:bg-slate-900 rounded-lg p-6 w-full max-w-md mx-4 shadow-xl"
    >
      <h2 class="text-xl font-bold mb-4 text-slate-900 dark:text-white">
        {{ isEditing ? "Editar Card" : "Novo Card" }}
      </h2>
      <form @submit.prevent="handleSubmit" class="space-y-4">
        <!-- Seção de Relacionamentos movida para o topo -->
        <div class="space-y-3">
          <div>
            <label
              class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1"
            >
              Empresa *
            </label>
            <ComboBox
              v-model="form.company_id"
              :options="companies"
              label="Empresa *"
              placeholder="Selecione uma empresa"
              search-placeholder="Buscar empresa..."
              :has-error="errors.company_id"
              :message="errors.company_id ? 'Por favor, selecione uma empresa' : ''"
            />
          </div>

          <div>
            <ComboBox
              v-model="form.contact_id"
              :options="contacts"
              label="Contato *"
              placeholder="Selecione o contato"
              search-placeholder="Buscar contato..."
              :disabled="!form.company_id"
              :no-data-text="
                form.company_id
                  ? 'Nenhum contato encontrado'
                  : 'Selecione a empresa primeiro'
              "
              :has-error="errors.contact_id"
              :message="errors.contact_id ? 'Por favor, selecione um contato' : ''"
            />
          </div>

          <div>
            <label
              class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1"
            >
              Vendedor *
            </label>
            <select
              v-model="form.assignee_id"
              required
              class="w-full px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white"
            >
              <option value="" disabled selected>Selecione um vendedor</option>
              <option v-for="agent in agents" :key="agent.id" :value="agent.id">
                {{ agent.name }}
              </option>
            </select>
          </div>
        </div>

        <div>
          <woot-input
            v-model="form.title"
            type="text"
            label="Título *"
            placeholder="Digite o título do card"
            required
          />
        </div>

        <div>
          <label
            class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1"
          >
            Descrição
          </label>
          <textarea
            v-model="form.description"
            rows="3"
            class="w-full px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white"
            placeholder="Digite a descrição (opcional)"
          ></textarea>
        </div>

        <div class="grid grid-cols-2 gap-4">
          <div>
            <label
              class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1"
            >
              Coluna *
            </label>
            <select
              v-model="form.kanban_column_id"
              required
              class="w-full px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white"
            >
              <option value="" disabled selected>Selecione uma coluna</option>
              <option
                v-for="column in columns"
                :key="column.id"
                :value="column.id"
              >
                {{ column.name }}
              </option>
            </select>
          </div>

          <div>
            <label
              class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1"
            >
              Prioridade
            </label>
            <select
              v-model="form.priority"
              class="w-full px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white"
            >
              <option value="low">Baixa</option>
              <option value="normal">Normal</option>
              <option value="high">Alta</option>
              <option value="urgent">Urgente</option>
            </select>
          </div>
        </div>

        <div>
          <woot-input
            v-model="form.due_date"
            type="date"
            label="Data de vencimento"
          />
        </div>

        <div class="flex gap-2 pt-4 justify-end">
          <woot-button variant="ghost" color="slate" @click="$emit('close')">
            Cancelar
          </woot-button>

          <woot-button
            type="submit"
            :is-loading="loading"
            variant="solid"
            color="teal"
            :class="{ 'opacity-50 cursor-not-allowed': loading }"
            :disabled="loading"
          >
            {{ isEditing ? "Salvar Alterações" : "Criar Card" }}
          </woot-button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, onMounted, computed } from "vue";
import { useStore } from "vuex";
import WootButton from "dashboard/components-next/button/Button.vue";
import WootInput from "dashboard/components-next/input/Input.vue";
import ComboBox from "dashboard/components-next/combobox/ComboBox.vue";

const props = defineProps({
  show: Boolean,
  columns: Array,
  initialData: Object,
  loading: Boolean,
});

const emit = defineEmits(["close", "submit"]);
const store = useStore();

// Getter para o ID da conta atual for API paths
const accountId = computed(() => store.getters["getCurrentAccountId"]);

const form = ref({
  title: "",
  description: "",
  kanban_column_id: "",
  priority: "low",
  due_date: "",
  company_id: "",
  contact_id: "",
  assignee_id: "",
});

const companies = ref([]);
const contacts = ref([]);
const agents = ref([]);

const errors = ref({
  company_id: false,
  contact_id: false,
  assignee_id: false,
});

const isEditing = ref(false);

const fetchCompanies = async () => {
  try {
    // Busca a lista de empresas oficial
    // Limitando a 100 para exemplo, ideal seria um select remoto com busca
    const response = await axios.get(
      `/api/v1/accounts/${accountId.value}/companies`,
      {
        params: {
          sort: "name",
          per_page: 100,
        },
      },
    );
    // O endpoint de companies retorna payload com a lista
    companies.value = response.data.payload.map((c) => ({
      value: c.id,
      label: c.name,
    }));
  } catch (error) {
    console.error("Error fetching companies", error);
  }
};

const fetchAgents = async () => {
  try {
    // Garante que o store de agentes esteja carregado
    if (store.getters["agents/getAgents"].length === 0) {
      await store.dispatch("agents/get");
    }
    agents.value = store.getters["agents/getAgents"];
  } catch (e) {
    console.error("Error fetching agents", e);
    // Ultimate fallback
    agents.value = store.getters["agents/getAgents"];
  }
};

const fetchContacts = async (companyId) => {
  if (!companyId) {
    contacts.value = [];
    return;
  }

  try {
    // Precisamos buscar contatos vinculados a esta empresa
    // Usamos a action customizada que deixamos no controller para facilitar a query por ID
    const response = await axios.get(
      `/enterprise/api/v1/accounts/${accountId.value}/kanban_cards/contacts_by_company`,
      {
        params: { company_id: companyId },
      },
    );
    contacts.value = response.data.map((c) => ({
      value: c.id,
      label: c.name,
    }));
  } catch (e) {
    console.error(e);
  }
};

watch(
  () => form.value.company_id,
  (newId) => {
    if (newId) errors.value.company_id = false;
    fetchContacts(newId);
  },
);

watch(
  () => form.value.contact_id,
  (newId) => {
    if (newId) errors.value.contact_id = false;
  },
);

watch(
  () => props.initialData,
  async (newData) => {
    // Check if newData exists and has an ID (indicating an edit)
    // Sometimes initialData might be an empty object {}, so we check keys or specific property
    if (newData && newData.id) {
      // Garantir que form.priority receba o valor correto mesmo se vier null (embora db force default)
      const safeDate = newData.due_date
        ? new Date(newData.due_date).toISOString().split("T")[0]
        : "";

      form.value = {
        ...newData,
        priority: newData.priority || "low",
        due_date: safeDate,
      };
      isEditing.value = true;
      if (form.value.company_id) {
        await fetchContacts(form.value.company_id);
      }
    } else {
      // Data de hoje formato YYYY-MM-DD (Local Time)
      const date = new Date();
      const year = date.getFullYear();
      const month = String(date.getMonth() + 1).padStart(2, "0");
      const day = String(date.getDate()).padStart(2, "0");
      const today = `${year}-${month}-${day}`;

      form.value = {
        title: "",
        description: "",
        kanban_column_id: "",
        priority: "low",
        due_date: today, // Preenche com hoje
        company_id: "",
        contact_id: "",
        assignee_id: "",
      };
      isEditing.value = false;
      contacts.value = [];
    }
  },
  { immediate: true },
);

onMounted(() => {
  fetchAgents();
  fetchCompanies();
});

const handleSubmit = () => {
  // Reset errors
  errors.value = {
    company_id: false,
    contact_id: false,
  };

  let hasError = false;

  // Manual validation for mandatory fields
  if (!form.value.company_id) {
    errors.value.company_id = true;
    hasError = true;
  }
  if (!form.value.contact_id) {
    errors.value.contact_id = true;
    hasError = true;
  }
  // Assignee is handled by 'required' attribute on select, but we can double check
  if (!form.value.assignee_id) {
     // Native validation usually catches this, but just in case
  }

  if (hasError) {
    return;
  }

  // Valida campos obrigatórios manualmente se necessário, mas HTML5 'required' deve cuidar disso
  // Nota: browser validation handles 'required' only if triggered by submit button inside form.
  emit("submit", { ...form.value });
};
</script>
