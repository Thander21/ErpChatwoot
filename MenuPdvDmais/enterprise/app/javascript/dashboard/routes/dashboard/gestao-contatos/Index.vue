<!--
ERP Chatwoot - Gestão de Contatos Index Component
Projeto: ERP Gestão de Contatos para Chatwoot Enterprise
Arquivo: Index.vue
Descrição: Componente principal da página de gestão de contatos
Autor: Thander21
Data: 2024
Versão: 1.0.0
-->

<template>
  <div class="flex flex-col gap-4 p-6 bg-white dark:bg-slate-900 rounded-lg shadow max-w-7xl mx-auto">
    <div class="flex items-center justify-between mb-4">
      <h1 class="text-3xl font-bold text-slate-900 dark:text-white">
        Gestão de Contatos
      </h1>
      <div class="flex gap-2">
        <button
          @click="refreshContacts"
          :disabled="loading"
          class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 flex items-center gap-2"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
          </svg>
          Recarregar
        </button>
      </div>
    </div>

    <!-- Informações sobre o sistema -->
    <div class="bg-blue-50 dark:bg-slate-800 border border-blue-200 dark:border-slate-700 rounded-lg p-6 mb-6">
      <div class="flex items-start gap-4">
        <div class="flex-shrink-0">
          <svg class="w-8 h-8 text-blue-600 dark:text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        </div>
        <div>
          <h3 class="text-lg font-semibold text-blue-900 dark:text-blue-100 mb-2">
            Sistema de Gestão de Contatos
          </h3>
          <p class="text-blue-800 dark:text-blue-200 mb-3">
            Esta página organiza automaticamente todos os contatos cadastrados no sistema, agrupados por empresa para facilitar a visualização e gestão.
          </p>
          <div class="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
            <div class="bg-white dark:bg-slate-700 rounded p-3">
              <div class="font-semibold text-blue-900 dark:text-blue-100">Total de Contatos</div>
              <div class="text-2xl font-bold text-blue-600 dark:text-blue-400">{{ totalContacts }}</div>
            </div>
            <div class="bg-white dark:bg-slate-700 rounded p-3">
              <div class="font-semibold text-blue-900 dark:text-blue-100">Empresas Cadastradas</div>
              <div class="text-2xl font-bold text-blue-600 dark:text-blue-400">{{ contactsByCompany.length }}</div>
            </div>
            <div class="bg-white dark:bg-slate-700 rounded p-3">
              <div class="font-semibold text-blue-900 dark:text-blue-100">Sem Empresa</div>
              <div class="text-2xl font-bold text-blue-600 dark:text-blue-400">{{ contactsWithoutCompany }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="flex flex-col items-center justify-center py-12">
      <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mb-4"></div>
      <p class="text-slate-600 dark:text-slate-400">Carregando contatos...</p>
    </div>

    <!-- Lista de Empresas (Estrutura Organizacional) -->
    <div v-else-if="contactsByCompany.length > 0" class="space-y-4 max-h-[70vh] overflow-y-auto">
      <div class="flex items-center justify-between mb-6">
        <h2 class="text-2xl font-bold text-slate-900 dark:text-white">
          Empresas e Contatos
        </h2>
        <button
          @click="expandAll"
          class="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
        >
          Expandir Todas
        </button>
      </div>

      <div
        v-for="company in contactsByCompany"
        :key="company.name"
        class="border border-gray-200 dark:border-slate-700 rounded-lg overflow-hidden shadow-sm"
      >
        <!-- Header da Empresa -->
        <div class="bg-gradient-to-r from-blue-600 to-blue-700 px-6 py-4 text-white">
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-4">
              <div class="w-10 h-10 bg-white bg-opacity-20 rounded-full flex items-center justify-center">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                </svg>
              </div>
              <div>
                <h3 class="text-xl font-bold">
                  {{ company.name || 'Empresa não informada' }}
                </h3>
                <p class="text-blue-100">
                  {{ company.contacts.length }} contato{{ company.contacts.length !== 1 ? 's' : '' }}
                </p>
              </div>
            </div>
            <button
              @click="toggleCompany(company.name)"
              class="p-2 hover:bg-white hover:bg-opacity-10 rounded-lg transition-colors"
            >
              <svg
                class="w-6 h-6 transform transition-transform"
                :class="{ 'rotate-180': !company.expanded }"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
              </svg>
            </button>
          </div>
        </div>

        <!-- Lista de Contatos da Empresa -->
        <div v-show="company.expanded" class="bg-white dark:bg-slate-900">
          <div class="divide-y divide-gray-200 dark:divide-slate-700">
            <div
              v-for="contact in company.contacts"
              :key="contact.id"
              class="p-6 hover:bg-gray-50 dark:hover:bg-slate-800 transition-colors"
            >
              <div class="flex justify-between items-start">
                <div class="flex-1">
                  <div class="flex items-center gap-3 mb-2">
                    <div class="w-8 h-8 bg-blue-100 dark:bg-blue-900 rounded-full flex items-center justify-center">
                      <svg class="w-4 h-4 text-blue-600 dark:text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                      </svg>
                    </div>
                    <h4 class="text-lg font-semibold text-slate-900 dark:text-white">
                      {{ contact.name || 'Nome não informado' }}
                    </h4>
                  </div>
                  <div class="ml-11 grid grid-cols-1 md:grid-cols-2 gap-3 text-sm text-slate-600 dark:text-slate-400">
                    <div v-if="contact.email" class="flex items-center gap-2">
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 4.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                      </svg>
                      {{ contact.email }}
                    </div>
                    <div v-if="contact.phone_number" class="flex items-center gap-2">
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
                      </svg>
                      {{ contact.phone_number }}
                    </div>
                    <div v-if="contact.last_activity_at" class="flex items-center gap-2 md:col-span-2">
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                      </svg>
                      Última atividade: {{ formatDate(contact.last_activity_at) }}
                    </div>
                  </div>
                </div>
                <div class="flex gap-2 ml-6">
                  <button
                    @click="editContact(contact)"
                    class="px-4 py-2 text-sm bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                  >
                    Editar
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Estado vazio -->
    <div v-else class="text-center py-12">
      <svg class="w-16 h-16 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
      </svg>
      <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-2">
        Nenhum contato encontrado
      </h3>
      <p class="text-gray-500 dark:text-gray-400">
        Os contatos aparecerão aqui organizados por empresa assim que forem importados.
      </p>
    </div>

    <!-- Modal de edição -->
    <div
      v-if="editingContact"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
      @click="closeEditModal"
    >
      <div
        class="bg-white dark:bg-slate-900 rounded-lg p-6 w-full max-w-md mx-4"
        @click.stop
      >
        <h2 class="text-xl font-bold mb-4 text-slate-900 dark:text-white">
          Editar Contato
        </h2>
        <form @submit.prevent="saveContact" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
              Nome
            </label>
            <input
              v-model="editForm.name"
              type="text"
              class="w-full px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
              Email
            </label>
            <input
              v-model="editForm.email"
              type="email"
              class="w-full px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
              Telefone
            </label>
            <input
              v-model="editForm.phone_number"
              type="text"
              class="w-full px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
              Empresa
            </label>
            <input
              v-model="editForm.company_name"
              type="text"
              class="w-full px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white"
            />
          </div>
          <div class="flex gap-2 pt-4">
            <button
              type="submit"
              :disabled="saving"
              class="flex-1 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
            >
              {{ saving ? 'Salvando...' : 'Salvar' }}
            </button>
            <button
              type="button"
              @click="closeEditModal"
              class="px-4 py-2 bg-gray-300 dark:bg-slate-600 text-slate-700 dark:text-slate-300 rounded-lg hover:bg-gray-400 dark:hover:bg-slate-500"
            >
              Cancelar
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { useRoute } from 'vue-router';
import ContactAPI from 'dashboard/api/contacts';

const route = useRoute();

const contacts = ref([]);
const loading = ref(false);
const companyFilter = ref('');
const editingContact = ref(null);
const saving = ref(false);
const expandedCompanies = ref(new Set());

const editForm = ref({
  name: '',
  email: '',
  phone_number: '',
  company_name: ''
});

// Computed properties
const contactsByCompany = computed(() => {
  const grouped = {};

  contacts.value.forEach(contact => {
    const companyName = getCompanyName(contact) || 'Empresa não informada';
    if (!grouped[companyName]) {
      grouped[companyName] = {
        name: companyName,
        contacts: [],
        expanded: expandedCompanies.value.has(companyName)
      };
    }
    grouped[companyName].contacts.push(contact);
  });

  // Converter para array e ordenar por nome da empresa
  return Object.values(grouped).sort((a, b) => {
    // Colocar "Empresa não informada" por último
    if (a.name === 'Empresa não informada') return 1;
    if (b.name === 'Empresa não informada') return -1;
    return a.name.localeCompare(b.name);
  });
});

const totalContacts = computed(() => contacts.value.length);

const contactsWithoutCompany = computed(() => {
  return contacts.value.filter(contact => !getCompanyName(contact)).length;
});

// Cache configuration
const CACHE_KEY = 'erp_contacts_cache';
const CACHE_EXPIRY_HOURS = 24;

// Funções de cache
const saveToCache = (data) => {
  const cacheData = {
    data: data,
    timestamp: Date.now(),
    expiry: Date.now() + (CACHE_EXPIRY_HOURS * 60 * 60 * 1000)
  };
  localStorage.setItem(CACHE_KEY, JSON.stringify(cacheData));
};

const loadFromCache = () => {
  try {
    const cached = localStorage.getItem(CACHE_KEY);
    if (!cached) return null;

    const cacheData = JSON.parse(cached);
    if (Date.now() > cacheData.expiry) {
      localStorage.removeItem(CACHE_KEY);
      return null;
    }

    return cacheData.data;
  } catch (error) {
    console.warn('Erro ao carregar cache:', error);
    return null;
  }
};

const clearCache = () => {
  localStorage.removeItem(CACHE_KEY);
};

// Funções adicionais
const expandAll = () => {
  contactsByCompany.value.forEach(company => {
    expandedCompanies.value.add(company.name);
  });
};

const refreshContacts = async () => {
  clearCache();
  await fetchContacts();
};

const fetchContacts = async () => {
  loading.value = true;
  try {
    // Tentar carregar do cache primeiro
    const cachedData = loadFromCache();
    if (cachedData) {
      contacts.value = cachedData;
      console.log(`Contatos carregados do cache: ${cachedData.length} registros`);
      loading.value = false;
      return;
    }

    // Se não há cache, buscar da API
    console.log('Cache expirado ou inexistente, carregando da API...');
    const allContacts = [];
    let page = 1;
    let hasMorePages = true;

    // Carregar todas as páginas até não ter mais dados
    while (hasMorePages) {
      const response = await ContactAPI.get(page, 'name', '', companyFilter.value);
      const pageData = response.data.payload || response.data || [];

      if (pageData.length === 0) {
        hasMorePages = false;
      } else {
        allContacts.push(...pageData);
        page += 1;

        // Limite de segurança para evitar loop infinito
        if (page > 100) {
          console.warn('Limite de 100 páginas atingido, interrompendo carregamento');
          hasMorePages = false;
        }
      }
    }

    contacts.value = allContacts;

    // Salvar no cache após carregar
    saveToCache(allContacts);

    console.log(`Total de contatos carregados da API: ${allContacts.length}`);
  } catch (error) {
    console.error('Erro ao buscar contatos:', error);
  } finally {
    loading.value = false;
  }
};

const getCompanyName = (contact) => {
  return contact.additional_attributes?.company_name || '';
};

const formatDate = (dateString) => {
  if (!dateString) return '';
  return new Date(dateString).toLocaleDateString('pt-BR');
};

const editContact = (contact) => {
  editingContact.value = contact;
  editForm.value = {
    name: contact.name || '',
    email: contact.email || '',
    phone_number: contact.phone_number || '',
    company_name: getCompanyName(contact)
  };
};

const saveContact = async () => {
  if (!editingContact.value) return;

  saving.value = true;
  try {
    const updateData = {
      name: editForm.value.name,
      email: editForm.value.email,
      phone_number: editForm.value.phone_number,
      additional_attributes: {
        ...editingContact.value.additional_attributes,
        company_name: editForm.value.company_name
      }
    };

    await ContactAPI.update(editingContact.value.id, updateData);

    // Update local contact
    const index = contacts.value.findIndex(c => c.id === editingContact.value.id);
    if (index !== -1) {
      contacts.value[index] = {
        ...contacts.value[index],
        ...updateData
      };
    }

    closeEditModal();
  } catch (error) {
    console.error('Erro ao salvar contato:', error);
  } finally {
    saving.value = false;
  }
};

const toggleCompany = (companyName) => {
  if (expandedCompanies.value.has(companyName)) {
    expandedCompanies.value.delete(companyName);
  } else {
    expandedCompanies.value.add(companyName);
  }
};

const closeEditModal = () => {
  editingContact.value = null;
  editForm.value = {
    name: '',
    email: '',
    phone_number: '',
    company_name: ''
  };
};

onMounted(() => {
  fetchContacts();
  // Expandir todas as empresas por padrão após carregar
  setTimeout(() => {
    contactsByCompany.value.forEach(company => {
      expandedCompanies.value.add(company.name);
    });
  }, 100);
});
</script>
