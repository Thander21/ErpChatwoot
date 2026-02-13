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
              :message="
                errors.company_id ? 'Por favor, selecione uma empresa' : ''
              "
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
              :message="
                errors.contact_id ? 'Por favor, selecione um contato' : ''
              "
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

        <div
          class="flex gap-2 pt-4"
          :class="isEditing ? 'justify-between' : 'justify-end'"
        >
          <!-- Delete and Archive buttons (only when editing) -->
          <div v-if="isEditing" class="flex gap-2">
            <button
              type="button"
              class="inline-flex items-center justify-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-red-700 bg-red-100 hover:bg-red-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              @click="handleDelete"
              :disabled="loading"
            >
              Excluir
            </button>

            <button
              v-if="isLastColumn"
              type="button"
              class="inline-flex items-center justify-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-green-700 bg-green-100 hover:bg-green-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              @click="handleArchive"
              :disabled="loading"
            >
              Arquivar
            </button>
          </div>

          <!-- Regular action buttons -->
          <div class="flex gap-2">
            <button
              type="button"
              class="inline-flex items-center justify-center px-4 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed transition-colors dark:bg-slate-800 dark:text-gray-200 dark:border-slate-600 dark:hover:bg-slate-700"
              @click="$emit('close')"
            >
              Cancelar
            </button>

            <button
              type="submit"
              class="inline-flex items-center justify-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              :class="{ 'opacity-50 cursor-not-allowed': loading }"
              :disabled="loading"
            >
              <svg
                v-if="loading"
                class="animate-spin -ml-1 mr-2 h-4 w-4 text-white"
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
              >
                <circle
                  class="opacity-25"
                  cx="12"
                  cy="12"
                  r="10"
                  stroke="currentColor"
                  stroke-width="4"
                ></circle>
                <path
                  class="opacity-75"
                  fill="currentColor"
                  d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                ></path>
              </svg>
              {{ isEditing ? "Salvar Alterações" : "Criar Card" }}
            </button>
          </div>
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

const emit = defineEmits(["close", "submit", "delete", "archive"]);
const store = useStore();

// Getter para o ID da conta atual for API paths
const accountId = computed(() => store.getters["getCurrentAccountId"]);

// Check if card is in last column
const isLastColumn = computed(() => {
  if (
    !props.columns ||
    props.columns.length === 0 ||
    !form.value.kanban_column_id
  ) {
    return false;
  }
  const sortedColumns = [...props.columns].sort(
    (a, b) => (a.position || 0) - (b.position || 0),
  );
  const lastColumn = sortedColumns[sortedColumns.length - 1];
  return form.value.kanban_column_id === lastColumn.id;
});

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
const selectedCompany = ref(null);

const fetchCompanies = async () => {
  try {
    let allCompanies = [];
    let currentPage = 1;
    let hasMore = true;

    // Paginate through all companies to load the complete list
    while (hasMore) {
      const response = await axios.get(
        `/api/v1/accounts/${accountId.value}/companies`,
        {
          params: {
            sort: "name",
            page: currentPage,
          },
        },
      );

      const pageCompanies = response.data.payload || [];
      allCompanies = allCompanies.concat(pageCompanies);

      // Check if there are more pages (RESULTS_PER_PAGE = 25 in controller)
      if (pageCompanies.length < 25) {
        hasMore = false;
      } else {
        currentPage++;
      }

      // Safety limit to prevent infinite loops (adjust if needed)
      if (currentPage > 100) {
        console.warn("Reached pagination limit of 100 pages (2500 companies)");
        hasMore = false;
      }
    }

    // Convert to ComboBox format
    let results = allCompanies.map((c) => ({
      value: c.id,
      label: c.name,
    }));

    // If a company is selected, ensure it's in the list
    if (form.value.company_id && selectedCompany.value) {
      const exists = results.find((c) => c.value === form.value.company_id);
      if (!exists) {
        results.push(selectedCompany.value);
      }
    }

    companies.value = results;
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
    if (newId) {
      errors.value.company_id = false;
      // Update selected company object for persistence
      const selected = companies.value.find((c) => c.value === newId);
      if (selected) {
        selectedCompany.value = selected;
      }
    }
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

      // Set selected company from initial data if available for select label
      if (newData.company && newData.company.id && newData.company.name) {
        selectedCompany.value = {
          value: newData.company.id,
          label: newData.company.name,
        };
      } else {
        selectedCompany.value = null;
      }

      isEditing.value = true;
      if (form.value.company_id) {
        // If we have selectedCompany, ensure it's in the list after fetch
        // Or fetch first to see if it's there
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
      // Reset selected company
      selectedCompany.value = null;
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

const handleDelete = () => {
  if (props.initialData && props.initialData.id) {
    emit("delete", props.initialData);
  }
};

const handleArchive = () => {
  if (props.initialData && props.initialData.id) {
    emit("archive", props.initialData);
  }
};
</script>
