<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/Index.vue
 * Last Modified: 07/05/2026
 * Dependencies: vue
 * Calls: -
 * Description: Página de gestão de contatos; rolagem unificada no mobile e lista rolável no desktop.
-->
<script setup>
import { ref, computed, onMounted } from "vue";
import { useStore } from "vuex"; // Import Vuex store
import { useContacts } from "./composables/useContacts";
import ContactsHeader from "./components/ContactsHeader.vue";
import ContactsStats from "./components/ContactsStats.vue";
import ContactsFilterBar from "./components/ContactsFilterBar.vue";
import ContactsList from "./components/ContactsList.vue";
import ContactFormModal from "./components/modais/ContactFormModal.vue";
import BulkEditModal from "./components/modais/BulkEditModal.vue";
import BulkDeleteModal from "./components/modais/BulkDeleteModal.vue";
import CompanyProfile from "./components/CompanyProfile.vue";
import CustomContactsAPI from "dashboard/api/customContacts";
import ConfirmModal from "../kanban/components/modais/ConfirmModal.vue";
import WootButton from "dashboard/components-next/button/Button.vue";
import WootInput from "dashboard/components-next/input/Input.vue";
import Spinner from "dashboard/components-next/spinner/Spinner.vue";
import { emitter } from "shared/helpers/mitt";
import { BUS_EVENTS } from "shared/constants/busEvents";

const {
  contacts,
  loading,
  searchQuery,
  companySearchQuery,
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
  getCompanyName,
} = useContacts();

const store = useStore(); // Initialize store

// UI State
const selectedContacts = ref([]);
const editingContact = ref(null);
const isCreating = ref(false); // If we add create functionality
const showBulkEdit = ref(false);
const showBulkDelete = ref(false);
const saving = ref(false);
const bulkSaving = ref(false);
const autoFilling = ref(false);
const isSyncing = ref(false);
const isCleaning = ref(false);
const profileCompany = ref(null); // Empresa selecionada para Ficha do Cliente

// Confirm Modal State
const showConfirmModal = ref(false);
const confirmTitle = ref("");
const confirmMessage = ref("");
const confirmLabel = ref("Confirmar");
const confirmColor = ref("red");
const confirmAction = ref(null);
const confirmTarget = ref(null);

const currentUserName = computed(() => {
  const user = store.getters.getCurrentUser;
  return user?.name || user?.email || "Usuário";
});

// Abre a ficha do cliente para a empresa
const openCompanyProfile = (company) => {
  profileCompany.value = company;
};

const accountId = computed(() => store.getters.getCurrentAccountId);

const syncCompanies = () => {
  confirmTitle.value = "Sincronizar Empresas";
  confirmMessage.value = "Isso irá criar empresas baseadas nos nomes preenchidos nos contatos. Deseja continuar?";
  confirmLabel.value = "Sincronizar";
  confirmColor.value = "blue";
  confirmAction.value = "sync";
  showConfirmModal.value = true;
};

const cleanupCompanies = () => {
  confirmTitle.value = "Limpar Empresas";
  confirmMessage.value = "Isso apagará todas as empresas que não possuem contatos vinculados. Deseja continuar?";
  confirmLabel.value = "Limpar";
  confirmColor.value = "red";
  confirmAction.value = "cleanup";
  showConfirmModal.value = true;
};

const handleConfirm = async () => {
  if (confirmAction.value === "sync") {
    isSyncing.value = true;
    try {
      const response = await CustomContactsAPI.syncCompanies(accountId.value);
      emitter.emit(BUS_EVENTS.SHOW_ALERT, {
        message: response.data.message,
        type: "success",
      });
      refreshContacts();
    } catch (error) {
      emitter.emit(BUS_EVENTS.SHOW_ALERT, {
        message: "Erro ao sincronizar empresas.",
        type: "error",
      });
    } finally {
      isSyncing.value = false;
      showConfirmModal.value = false;
    }
  } else if (confirmAction.value === "cleanup") {
    isCleaning.value = true;
    try {
      const response = await CustomContactsAPI.cleanupCompanies(
        accountId.value,
      );
      emitter.emit(BUS_EVENTS.SHOW_ALERT, {
        message: response.data.message,
        type: "success",
      });
    } catch (error) {
      emitter.emit(BUS_EVENTS.SHOW_ALERT, {
        message: "Erro ao limpar empresas.",
        type: "error",
      });
    } finally {
      isCleaning.value = false;
      showConfirmModal.value = false;
    }
  } else if (confirmAction.value === "delete-contact") {
    try {
      await deleteContact(confirmTarget.value.id);
      emitter.emit(BUS_EVENTS.SHOW_ALERT, {
        message: "Contato deletado com sucesso!",
        type: "success",
      });
    } catch (error) {
      emitter.emit(BUS_EVENTS.SHOW_ALERT, {
        message: "Erro ao deletar contato.",
        type: "error",
      });
    } finally {
      showConfirmModal.value = false;
    }
  }
};

// Sempre agrupado por empresa
const isGrouped = computed(() => true);

const listTitle = computed(() => {
  if (searchQuery.value) return `Resultados para "${searchQuery.value}"`;
  if (activeFilter.value !== "all") {
    switch (activeFilter.value) {
      case "no_company":
        return "Contatos Sem Empresa";
      case "no_phone":
        return "Contatos Sem Número";
      case "invalid_phone":
        return "Contatos com Número Inválido";
      default:
        return "Contatos Filtrados";
    }
  }
  return "Agrupados por empresa";
});

const areAllExpanded = computed(() => {
  return (
    contactsByCompany.value.length > 0 &&
    expandedCompanies.value.size === contactsByCompany.value.length
  );
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
    selectedContacts.value = filteredContacts.value.map((c) => c.id);
  }
};

const expandAll = () => {
  contactsByCompany.value.forEach((c) => expandedCompanies.value.add(c.name));
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
          company_name: formData.company_name,
        },
      });
      closeEditModal();
      emitter.emit(BUS_EVENTS.SHOW_ALERT, {
        message: "Contato atualizado com sucesso!",
        type: "success",
      });
    }
    // Create logic would go here
  } catch (error) {
    emitter.emit(BUS_EVENTS.SHOW_ALERT, {
      message: "Erro ao salvar contato.",
      type: "error",
    });
  } finally {
    saving.value = false;
  }
};

const handleInlineUpdate = async ({ id, payload }) => {
  try {
    await updateContact(id, payload);
    // Silent success for inline updates
  } catch (error) {
    /* debug removed */
    emitter.emit(BUS_EVENTS.SHOW_ALERT, {
      message: "Erro ao atualizar contato.",
      type: "error",
    });
  }
};

// Delete
const openDeleteModal = (contact) => {
  confirmTitle.value = "Excluir Contato";
  confirmMessage.value = `Tem certeza que deseja deletar ${contact.name}? Toda a história com este contato será removida.`;
  confirmLabel.value = "Deletar";
  confirmColor.value = "red";
  confirmAction.value = "delete-contact";
  confirmTarget.value = contact;
  showConfirmModal.value = true;
};

// Bulk Actions
const openBulkEditModal = () => (showBulkEdit.value = true);
const openBulkDeleteModal = () => (showBulkDelete.value = true);

const handleBulkEdit = async (formData) => {
  if (selectedContacts.value.length === 0) return;
  bulkSaving.value = true;

  try {
    const updateData = {};
    if (formData.company_name && formData.company_name.trim()) {
      updateData.additional_attributes = {
        company_name: formData.company_name.trim(),
      };
    }

    if (Object.keys(updateData).length === 0) {
      emitter.emit(BUS_EVENTS.SHOW_ALERT, {
        message: "Preencha algum campo.",
        type: "warning",
      });
      return;
    }

    // Process sequentially to avoid overflowing API
    for (const id of selectedContacts.value) {
      const contact = contacts.value.find((c) => c.id === id);
      if (contact) {
        // Merge additional attributes carefully
        const existingAttrs = contact.additional_attributes || {};
        const payload = {
          additional_attributes: {
            ...existingAttrs,
            ...updateData.additional_attributes,
          },
        };
        await updateContact(id, payload);
      }
    }

    showBulkEdit.value = false;
    selectedContacts.value = [];
    emitter.emit(BUS_EVENTS.SHOW_ALERT, {
      message: "Edição em lote concluída!",
      type: "success",
    });
  } catch (error) {
    /* debug removed */
    emitter.emit(BUS_EVENTS.SHOW_ALERT, {
      message: "Erro parcial ou total na edição em lote.",
      type: "error",
    });
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
    emitter.emit(BUS_EVENTS.SHOW_ALERT, {
      message: "Contatos deletados com sucesso!",
      type: "success",
    });
  } catch (error) {
    /* debug removed */
    emitter.emit(BUS_EVENTS.SHOW_ALERT, {
      message: "Erro ao deletar alguns contatos.",
      type: "error",
    });
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
          company_name: companyName,
        },
      });
      count++;
    }
    emitter.emit(BUS_EVENTS.SHOW_ALERT, {
      message: `${count} contatos atualizados!`,
      type: "success",
    });
  } catch (error) {
    /* debug removed */
    emitter.emit(BUS_EVENTS.SHOW_ALERT, {
      message: "Erro ao preencher automaticamente.",
      type: "error",
    });
  } finally {
    autoFilling.value = false;
  }
};

onMounted(() => {
  fetchContacts();
});
</script>

<template>
  <div
    class="flex h-full min-h-0 flex-1 flex-col bg-n-surface-1 w-full max-w-7xl mx-auto"
  >
    <!-- Mobile: scroll inclui stats + filtros + lista. md+: só a lista rola. -->
    <div
      class="flex min-h-0 max-h-[100dvh] flex-1 flex-col overflow-y-auto overscroll-y-contain pb-20 md:max-h-none md:overflow-hidden md:pb-4"
    >
    <!-- Header Section -->
    <div class="flex flex-col gap-4 flex-shrink-0 p-4 pb-0 md:pb-4">
      <ContactsHeader
        :search-query="searchQuery"
        :loading="loading"
        @update:search-query="searchQuery = $event"
        @refresh="refreshContacts"
      />

      <ContactsStats
        :total-contacts="totalContacts"
        :contacts-without-company="contactsWithoutCompany"
        :contacts-eligible-for-auto-fill="contactsEligibleForAutoFill"
        :contacts-without-phone="contactsWithoutPhone"
        :contacts-with-invalid-phone="contactsWithInvalidPhone"
        :active-filter="activeFilter"
        @set-filter="activeFilter = $event"
      />

      <!-- Search Bar -->
      <div class="flex flex-col sm:flex-row gap-4 w-full">
        <div class="relative flex-1">
          <WootInput
            v-model="companySearchQuery"
            placeholder="Pesquisar por empresa..."
            class="w-full"
            custom-input-class="pl-4 pr-12"
          />
          <WootButton
            v-if="companySearchQuery"
            variant="ghost"
            color="ruby"
            icon="x"
            size="sm"
            class="absolute inset-y-0 right-1 my-auto"
            @click="companySearchQuery = ''"
          />
        </div>

        <div class="relative flex-1">
          <WootInput
            v-model="searchQuery"
            placeholder="Pesquisar por nome ou telefone..."
            class="w-full"
            custom-input-class="pl-4 pr-12"
          />
          <WootButton
            v-if="searchQuery"
            variant="ghost"
            color="ruby"
            icon="x"
            size="sm"
            class="absolute inset-y-0 right-1 my-auto"
            @click="searchQuery = ''"
          />
        </div>
      </div>

      <div class="flex gap-2 w-full">
        <WootButton
          color="blue"
          icon="refresh-cw"
          :is-loading="isSyncing"
          class="flex-1"
          @click="syncCompanies"
        >
          Atualizar Empresas
        </WootButton>
        <WootButton
          color="ruby"
          icon="trash-2"
          :is-loading="isCleaning"
          class="flex-1"
          @click="cleanupCompanies"
        >
          Limpar Vazias
        </WootButton>
      </div>

      <ContactsFilterBar
        :active-filter="activeFilter"
        :filtered-count="filteredContacts.length"
        @clear-filter="activeFilter = 'all'"
      />
    </div>

    <!-- Lista: no desktop rola sozinha; no mobile segue o fluxo do scroll do pai -->
    <div
      class="px-4 pb-4 min-h-0 md:flex-1 md:overflow-y-auto"
    >
      <!-- Loading State -->
      <div
        v-if="loading"
        class="flex flex-col items-center justify-center py-12"
      >
        <Spinner :size="48" class="text-n-brand mb-4" />
        <p class="text-n-slate-11">Carregando contatos...</p>
      </div>

      <!-- Empty State -->
      <div v-else-if="filteredContacts.length === 0" class="text-center py-12">
        <span class="i-lucide-users size-16 text-n-slate-9 block mx-auto mb-4" />
        <h3 class="text-lg font-medium text-n-slate-12 mb-2">
          Nenhum contato encontrado
        </h3>
        <p class="text-n-slate-11">
          {{
            searchQuery || companySearchQuery || activeFilter !== "all"
              ? "Tente alterar os filtros ou a busca."
              : "Os contatos aparecerão aqui assim que forem importados."
          }}
        </p>
      </div>

      <!-- Contacts List -->
      <ContactsList
        v-else
        :contacts="contactsByCompany"
        :search-query="searchQuery"
        :is-grouped="true"
        :title="listTitle"
        :expanded-company-names="expandedCompanies"
        :are-all-expanded="areAllExpanded"
        :contacts-count="filteredContacts.length"
        :selected-ids="selectedContacts"
        :show-auto-fill="
          activeFilter === 'no_company' && contactsEligibleForAutoFill > 0
        "
        :auto-filling="autoFilling"
        @toggle-selection="toggleSelection"
        @select-all="selectAll"
        @edit="openEditModal"
        @delete="openDeleteModal"
        @expand-all="expandAll"
        @collapse-all="collapseAll"
        @toggle-group="toggleGroup"
        @auto-fill="handleAutoFill"
        @bulk-edit="openBulkEditModal"
        @bulk-delete="openBulkDeleteModal"
        @update-inline="handleInlineUpdate"
        @open-profile="openCompanyProfile"
      />
    </div>
    </div>

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

    <!-- Ficha do Cliente -->
    <CompanyProfile
      v-if="profileCompany"
      :company="profileCompany"
      :is-open="!!profileCompany"
      @close="profileCompany = null"
    />
    <ConfirmModal
      :show="showConfirmModal"
      :title="confirmTitle"
      :message="confirmMessage"
      :user-name="currentUserName"
      :confirm-label="confirmLabel"
      :confirm-color="confirmColor"
      @confirm="handleConfirm"
      @cancel="showConfirmModal = false"
    />
  </div>
</template>
