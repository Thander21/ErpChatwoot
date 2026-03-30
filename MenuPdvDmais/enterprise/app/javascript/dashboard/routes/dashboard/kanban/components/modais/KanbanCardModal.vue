<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/kanban/components/modais/KanbanCardModal.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: -
 * Description: (Adicionar descrição em português)
-->
<script setup>
import { ref, watch, onMounted, computed } from "vue";
import { useStore } from "vuex";
import WootButton from "dashboard/components-next/button/Button.vue";
import WootInput from "dashboard/components-next/input/Input.vue";
import ComboBox from "dashboard/components-next/combobox/ComboBox.vue";
import WootTextArea from "dashboard/components-next/textarea/TextArea.vue";
import WootSelect from "dashboard/components-next/select/Select.vue";

const props = defineProps({
  show: Boolean,
  columns: Array,
  initialData: Object,
  loading: Boolean,
});

const emit = defineEmits(["close", "submit", "delete", "archive"]);
const store = useStore();

// Getter para o ID da conta atual for API paths
const accountId = computed(() => store.getters.getCurrentAccountId);

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
 
const agentOptions = computed(() =>
  agents.value.map((a) => ({ value: a.id, label: a.name })),
);
 
const columnOptions = computed(() =>
  (props.columns || []).map((c) => ({ value: c.id, label: c.name })),
);
 
const priorityOptions = [
  { value: "low", label: "Baixa" },
  { value: "normal", label: "Normal" },
  { value: "high", label: "Alta" },
  { value: "urgent", label: "Urgente" },
];

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
        /* debug removed */
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
    /* debug removed */
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
    /* debug removed */
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
    /* debug removed */
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

<template>
  <div
    v-if="show"
    class="fixed inset-0 bg-n-overlay flex items-center justify-center z-50"
  >
    <div
      class="bg-n-solid-1 border border-n-weak rounded-lg p-6 w-full max-w-md mx-4 shadow-xl"
    >
      <h2 class="text-xl font-bold mb-4 text-n-slate-12">
        {{ isEditing ? "Editar Card" : "Novo Card" }}
      </h2>
      <form class="space-y-4" @submit.prevent="handleSubmit">
        <!-- Seção de Relacionamentos movida para o topo -->
        <div class="space-y-3">
          <div>
            <label
              class="block text-sm font-medium text-n-slate-11 mb-1"
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
            <WootSelect
              v-model="form.assignee_id"
              label="Vendedor *"
              :options="agentOptions"
              placeholder="Selecione um vendedor"
              class="w-full"
            />
          </div>
        </div>

        <div>
          <WootInput
            v-model="form.title"
            type="text"
            label="Título *"
            placeholder="Digite o título do card"
            required
          />
        </div>

        <div>
          <WootTextArea
            v-model="form.description"
            label="Descrição"
            placeholder="Digite a descrição (opcional)"
            auto-height
          />
        </div>

        <div class="grid grid-cols-2 gap-4">
          <div>
            <WootSelect
              v-model="form.kanban_column_id"
              label="Coluna *"
              :options="columnOptions"
              placeholder="Selecione uma coluna"
              class="w-full"
            />
          </div>

          <div>
            <WootSelect
              v-model="form.priority"
              label="Prioridade"
              :options="priorityOptions"
              class="w-full"
            />
          </div>
        </div>

        <div>
          <WootInput
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
            <WootButton
              color="ruby"
              :is-loading="loading"
              @click="handleDelete"
            >
              Excluir
            </WootButton>

            <WootButton
              v-if="isLastColumn"
              color="teal"
              :is-loading="loading"
              @click="handleArchive"
            >
              Arquivar
            </WootButton>
          </div>

          <!-- Regular action buttons -->
          <div class="flex gap-2">
            <WootButton
              variant="outline"
              color="slate"
              @click="$emit('close')"
            >
              Cancelar
            </WootButton>

            <WootButton
              type="submit"
              color="blue"
              :is-loading="loading"
            >
              {{ isEditing ? "Salvar Alterações" : "Criar Card" }}
            </WootButton>
          </div>
        </div>
      </form>
    </div>
  </div>
</template>
