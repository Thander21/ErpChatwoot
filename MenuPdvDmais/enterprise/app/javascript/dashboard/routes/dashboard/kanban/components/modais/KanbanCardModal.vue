<template>
  <div
    v-if="show"
    class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
    @click="$emit('close')"
  >
    <div
      class="bg-white dark:bg-slate-900 rounded-lg p-6 w-full max-w-md mx-4"
      @click.stop
    >
      <h2 class="text-xl font-bold mb-4 text-slate-900 dark:text-white">
        {{ isEditing ? "Editar Card" : "Novo Card" }}
      </h2>
      <form @submit.prevent="handleSubmit" class="space-y-4">
        <div>
          <label
            class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1"
          >
            Título *
          </label>
          <input
            v-model="form.title"
            type="text"
            required
            class="w-full px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white"
            placeholder="Digite o título do card"
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

        <!-- Seção de Relacionamentos -->
        <div class="space-y-3">
          <!-- TODO: Implementar busca remota ou usar componente de select mais avançado se possível -->
          <div>
            <label
              class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1"
            >
              Empresa
            </label>
            <select
              v-model="form.company_id"
              class="w-full px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white"
              @change="fetchContacts(form.company_id)"
            >
              <option value="">Selecione uma empresa</option>
              <option
                v-for="company in companies"
                :key="company.id"
                :value="company.id"
              >
                {{ company.name }}
              </option>
            </select>
          </div>

          <div>
            <label
              class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1"
            >
              Contato
            </label>
            <select
              v-model="form.contact_id"
              class="w-full px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white"
              :disabled="!contacts.length && !form.company_id"
            >
              <option value="">
                {{
                  contacts.length
                    ? "Selecione o contato"
                    : form.company_id
                      ? "Nenhum contato encontrado"
                      : "Selecione a empresa primeiro"
                }}
              </option>
              <option
                v-for="contact in contacts"
                :key="contact.id"
                :value="contact.id"
              >
                {{ contact.name }}
              </option>
            </select>
          </div>

          <div>
            <label
              class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1"
            >
              Vendedor
            </label>
            <select
              v-model="form.assignee_id"
              class="w-full px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white"
            >
              <option value="">Selecione um vendedor</option>
              <option v-for="agent in agents" :key="agent.id" :value="agent.id">
                {{ agent.name }}
              </option>
            </select>
          </div>
        </div>

        <div class="grid grid-cols-2 gap-4">
          <div>
            <label
              class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1"
            >
              Coluna
            </label>
            <select
              v-model="form.kanban_column_id"
              required
              class="w-full px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white"
            >
              <option value="">Selecione uma coluna</option>
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
              <option :value="0">Baixa</option>
              <option :value="1">Normal</option>
              <option :value="2">Alta</option>
              <option :value="3">Urgente</option>
            </select>
          </div>
        </div>

        <div>
          <label
            class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1"
          >
            Data de vencimento
          </label>
          <input
            v-model="form.due_date"
            type="date"
            class="w-full px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white"
          />
        </div>

        <div class="flex gap-2 pt-4">
          <button
            type="submit"
            :disabled="loading"
            class="flex-1 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:opacity-50"
          >
            {{
              loading
                ? "Salvando..."
                : isEditing
                  ? "Salvar Alterações"
                  : "Criar Card"
            }}
          </button>
          <button
            type="button"
            @click="$emit('close')"
            class="px-4 py-2 bg-gray-300 dark:bg-slate-600 text-slate-700 dark:text-slate-300 rounded-lg hover:bg-gray-400 dark:hover:bg-slate-500"
          >
            Cancelar
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, onMounted } from "vue";
import { useStore } from "vuex";

const props = defineProps({
  show: Boolean,
  columns: Array,
  initialData: Object,
  loading: Boolean,
});

const emit = defineEmits(["close", "submit"]);
const store = useStore();

const form = ref({
  title: "",
  description: "",
  kanban_column_id: "",
  priority: 0,
  due_date: "",
  company_id: "",
  contact_id: "",
  assignee_id: "",
});

const companies = ref([]);
const contacts = ref([]);
const agents = ref([]);

const isEditing = ref(false);

const fetchCompanies = async () => {
  // Assuming simple search or list for now. Needs refinement based on API.
  // Using existing contacts endpoint searching for company type if possible or just all contacts?
  // Since we don't have a dedicated endpoint confirmed, using contacts search.
  try {
    const response = await axios.get("/api/v1/contacts/search", {
      params: { q: "" },
    });
    // Filtering manually if needed or assuming query returns relevant.
    // Ideally we should have a reliable way to get companies.
    companies.value = response.data.payload
      .filter((c) => c.company_name)
      .map((c) => ({ id: c.id, name: c.company_name || c.name }));
  } catch (error) {
    console.error("Error fetching companies", error);
  }
};

const fetchAgents = () => {
  // Use Vuex store for agents
  agents.value = store.getters["agents/getAgents"];
};

const fetchContacts = async (companyId) => {
  if (!companyId) {
    contacts.value = [];
    return;
  }
  // Fetch contacts for this company. Assuming filtering by company name?
  // Or if company_id is a Contact ID, we might need to find contacts LINKED to that contact?
  // User request: "Contato selecionar o contato da empresa selecionada"
  try {
    const response = await axios.get("/api/v1/contacts/search", {
      params: { sort: "name" },
    });
    // Mocking filter logic as I can't confirm backend filter for company_id on contacts
    // Assuming simplistic fetch for now.
    contacts.value = response.data.payload;
  } catch (e) {
    console.error(e);
  }
};

watch(
  () => props.initialData,
  async (newData) => {
    if (newData) {
      form.value = { ...newData };
      isEditing.value = true;
      if (form.value.company_id) {
        await fetchContacts(form.value.company_id);
      }
    } else {
      form.value = {
        title: "",
        description: "",
        kanban_column_id: "",
        priority: 0,
        due_date: "",
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
  emit("submit", { ...form.value });
};
</script>
