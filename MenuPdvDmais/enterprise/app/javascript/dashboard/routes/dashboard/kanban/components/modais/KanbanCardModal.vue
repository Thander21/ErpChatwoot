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
          <div>
            <label
              class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1"
            >
              Empresa *
            </label>
            <select
              v-model="form.company_id"
              required
              class="w-full px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white"
              @change="fetchContacts(form.company_id)"
            >
              <option value="" disabled selected>Selecione uma empresa</option>
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
              Contato *
            </label>
            <select
              v-model="form.contact_id"
              required
              class="w-full px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white"
              :disabled="!form.company_id"
            >
              <option value="" disabled selected>
                {{
                  form.company_id
                    ? contacts.length
                      ? "Selecione o contato"
                      : "Nenhum contato encontrado"
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
import { ref, watch, onMounted, computed } from "vue";
import { useStore } from "vuex";

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
      id: c.id,
      name: c.name,
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
    contacts.value = response.data;
  } catch (e) {
    console.error(e);
  }
};

watch(
  () => props.initialData,
  async (newData) => {
    if (newData) {
      // Garantir que form.priority receba o valor correto mesmo se vier null (embora db force default)
      const safeDate = newData.due_date ? new Date(newData.due_date).toISOString().split('T')[0] : "";
      
      form.value = { 
        ...newData,
        priority: newData.priority || "low",
        due_date: safeDate
      };
      isEditing.value = true;
      if (form.value.company_id) {
        await fetchContacts(form.value.company_id);
      }
    } else {
      // Data de hoje formato YYYY-MM-DD
      const today = new Date().toISOString().split('T')[0];
      
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
  // Valida campos obrigatórios manualmente se necessário, mas HTML5 'required' deve cuidar disso
  // Nota: browser validation handles 'required' only if triggered by submit button inside form.
  emit("submit", { ...form.value });
};
</script>
