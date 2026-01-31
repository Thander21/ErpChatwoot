<template>
  <div class="flex flex-col gap-4 p-6 bg-white dark:bg-slate-900 rounded-lg shadow max-w-7xl mx-auto">
    <ContactsHeader
      :search-query="searchQuery"
      :loading="loading"
      @update:searchQuery="searchQuery = $event"
      @refresh="refreshContacts"
    />

    <ContactsStats
      :total-contacts="totalContacts"
      :contacts-without-company="contactsWithoutCompany"
      :contacts-eligible-for-auto-fill="contactsEligibleForAutoFill"
      :contacts-without-phone="contactsWithoutPhone"
      :contacts-with-invalid-phone="contactsWithInvalidPhone"
      :active-filter="activeFilter"
      @setFilter="activeFilter = $event"
    />

    <ContactsFilterBar
      :active-filter="activeFilter"
      :filtered-count="filteredContacts.length"
      @clearFilter="activeFilter = 'all'"
    />

    <!-- Loading State -->
    <div v-if="loading" class="flex flex-col items-center justify-center py-12">
      <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mb-4"></div>
      <p class="text-slate-600 dark:text-slate-400">Carregando contatos...</p>
    </div>

    <!-- Empty State -->
    <div v-else-if="filteredContacts.length === 0" class="text-center py-12">
      <svg
        class="w-16 h-16 text-gray-400 mx-auto mb-4"
        fill="none"
        stroke="currentColor"
        viewBox="0 0 24 24"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"
        />
      </svg>
      <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-2">
        Nenhum contato encontrado
      </h3>
      <p class="text-gray-500 dark:text-gray-400">
        {{ searchQuery || activeFilter !== 'all' ? 'Tente alterar os filtros ou a busca.' : 'Os contatos aparecerão aqui assim que forem importados.' }}
      </p>
    </div>

    <!-- Contacts List -->
    <ContactsList
      v-else
      :contacts="isGrouped ? contactsByCompany : filteredContacts"
      :is-grouped="isGrouped"
      :title="listTitle"
      :contacts-count="filteredContacts.length"
      :selected-ids="selectedContacts"
      :show-auto-fill="activeFilter === 'no_company' && contactsEligibleForAutoFill > 0"
      :auto-filling="autoFilling"
      @toggleSelection="toggleSelection"
      @selectAll="selectAll"
      @edit="openEditModal"
      @delete="openDeleteModal"
      @expandAll="expandAll"
      @collapseAll="collapseAll"
      @toggleGroup="toggleGroup"
      @autoFill="handleAutoFill"
      @bulkEdit="openBulkEditModal"
      @bulkDelete="openBulkDeleteModal"
    />

    <!-- Modals -->
    <ContactFormModal
      :show="!!editingContact || isCreating"
      :initial-data="editingContact"
      :loading="saving"
      @close="closeEditModal"
      @submit="handleSaveContact"
    />

    <BulkEditModal
      :show="showBulkEdit"
      :selected-count="selectedContacts.length"
      :loading="bulkSaving"
      @close="showBulkEdit = false"
      @submit="handleBulkEdit"
    />

    <BulkDeleteModal
      :show="showBulkDelete"
      :selected-count="selectedContacts.length"
      :loading="bulkSaving"
      @close="showBulkDelete = false"
      @submit="handleBulkDelete"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useContacts } from './composables/useContacts';
import ContactsHeader from './components/ContactsHeader.vue';
import ContactsStats from './components/ContactsStats.vue';
import ContactsFilterBar from './components/ContactsFilterBar.vue';
import ContactsList from './components/ContactsList.vue';
import ContactFormModal from './components/modais/ContactFormModal.vue';
import BulkEditModal from './components/modais/BulkEditModal.vue';
import BulkDeleteModal from './components/modais/BulkDeleteModal.vue';

const {
  contacts,
  loading,
  searchQuery,
  activeFilter,
  contactsByCompany,
  filteredContacts,
  totalContacts,
  contactsWithoutCompany,
  contactsWithoutPhone,
  contactsWithInvalidPhone,
  contactsEligibleForAutoFill,
  expandedCompanies,
  fetchContacts,
  refreshContacts,
  updateContact,
  deleteContact,
  getCompanyName
} = useContacts();

// UI State
const selectedContacts = ref([]);
const editingContact = ref(null);
const isCreating = ref(false); // If we add create functionality
const showBulkEdit = ref(false);
const showBulkDelete = ref(false);
const saving = ref(false);
const bulkSaving = ref(false);
const autoFilling = ref(false);

// Computed
const isGrouped = computed(() => {
  // Only group if no specific filter is active and no search query
  // Wait, original logic grouped by default unless filtered?
  // Original: v-if="contactsByCompany.length > 0" for grouped list
  // It seems it prefers grouped view if possible.
  return activeFilter.value === 'all' && !searchQuery.value;
});

const listTitle = computed(() => {
  if (activeFilter.value !== 'all') {
    switch (activeFilter.value) {
      case "no_company": return "Contatos Sem Empresa";
      case "no_phone": return "Contatos Sem Número";
      case "invalid_phone": return "Contatos com Número Inválido";
      default: return "Contatos Filtrados";
    }
  }
  return isGrouped.value ? "Empresas e Contatos" : "Todos os Contatos";
});

// Handlers
const toggleSelection = (id) => {
  const index = selectedContacts.value.indexOf(id);
  if (index > -1) {
    selectedContacts.value.splice(index, 1);
  } else {
    selectedContacts.value.push(id);
  }
};

const selectAll = () => {
  if (selectedContacts.value.length === filteredContacts.value.length) {
    selectedContacts.value = [];
  } else {
    selectedContacts.value = filteredContacts.value.map(c => c.id);
  }
};

const expandAll = () => {
  contactsByCompany.value.forEach(c => expandedCompanies.value.add(c.name));
};

const collapseAll = () => {
  expandedCompanies.value.clear();
};

const toggleGroup = (companyName) => {
  if (expandedCompanies.value.has(companyName)) {
    expandedCompanies.value.delete(companyName);
  } else {
    expandedCompanies.value.add(companyName);
  }
};

// Edit / Create
const openEditModal = (contact) => {
  editingContact.value = contact;
};

const closeEditModal = () => {
  editingContact.value = null;
  isCreating.value = false;
};

const handleSaveContact = async (formData) => {
  saving.value = true;
  try {
    if (editingContact.value) {
      await updateContact(editingContact.value.id, {
        name: formData.name,
        email: formData.email,
        phone_number: formData.phone_number,
        additional_attributes: {
          company_name: formData.company_name
        }
      });
      closeEditModal();
    }
    // Create logic would go here
  } catch (error) {
    alert("Erro ao salvar contato.");
  } finally {
    saving.value = false;
  }
};

// Delete
const openDeleteModal = async (contact) => {
  if (confirm(`Tem certeza que deseja deletar ${contact.name}?`)) {
    try {
      await deleteContact(contact.id);
    } catch (error) {
      alert("Erro ao deletar contato.");
    }
  }
};

// Bulk Actions
const openBulkEditModal = () => showBulkEdit.value = true;
const openBulkDeleteModal = () => showBulkDelete.value = true;

const handleBulkEdit = async (formData) => {
  if (selectedContacts.value.length === 0) return;
  bulkSaving.value = true;
  
  try {
    const updateData = {};
    if (formData.company_name && formData.company_name.trim()) {
      updateData.additional_attributes = {
          company_name: formData.company_name.trim()
      };
    }

    if (Object.keys(updateData).length === 0) {
      alert("Preencha algum campo.");
      return;
    }

    // Process sequentially to avoid overflowing API
    for (const id of selectedContacts.value) {
      const contact = contacts.value.find(c => c.id === id);
      if (contact) {
         // Merge additional attributes carefully
         const existingAttrs = contact.additional_attributes || {};
         const payload = {
             additional_attributes: {
                 ...existingAttrs,
                 ...updateData.additional_attributes
             }
         };
         await updateContact(id, payload);
      }
    }
    
    showBulkEdit.value = false;
    selectedContacts.value = [];
    alert("Edição em lote concluída!");
  } catch (error) {
    console.error(error);
    alert("Erro parcial ou total na edição em lote.");
  } finally {
    bulkSaving.value = false;
  }
};

const handleBulkDelete = async () => {
  if (selectedContacts.value.length === 0) return;
  bulkSaving.value = true;

  try {
    for (const id of selectedContacts.value) {
      await deleteContact(id);
    }
    showBulkDelete.value = false;
    selectedContacts.value = [];
    alert("Contatos deletados com sucesso!");
  } catch (error) {
    console.error(error);
    alert("Erro ao deletar alguns contatos.");
  } finally {
    bulkSaving.value = false;
  }
};

const handleAutoFill = async () => {
  autoFilling.value = true;
  try {
    const eligible = contacts.value.filter((contact) => {
      if (getCompanyName(contact)) return false;
      if (!contact.name || !contact.name.includes(" - ")) return false;
      const parts = contact.name.split(" - ");
      return parts.length === 2 && parts[1].trim() !== "";
    });

    let count = 0;
    for (const contact of eligible) {
       const parts = contact.name.split(" - ");
       const companyName = parts[1].trim();
       
       await updateContact(contact.id, {
           additional_attributes: {
               company_name: companyName
           }
       });
       count++;
    }
    alert(`${count} contatos atualizados!`);
  } catch (error) {
    console.error(error);
    alert("Erro ao preencher automaticamente.");
  } finally {
    autoFilling.value = false;
  }
};

onMounted(() => {
  fetchContacts();
});
</script>
