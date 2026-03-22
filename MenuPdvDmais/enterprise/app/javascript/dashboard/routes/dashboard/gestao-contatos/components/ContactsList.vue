<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ContactsList.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: -
 * Description: (Adicionar descrição em português)
-->
<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ContactsList.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue, dashboard/composables
 * Calls: ContactCard.vue
 * Description: Componente orquestrador da visualização agrupada e em lista plana dos contatos.
-->
<script setup>
import { computed, watch } from "vue";
import { useAlert } from "dashboard/composables";
import ContactCard from "./ContactCard.vue";

const props = defineProps({
  contacts: {
    type: [Array, Object],
    required: true,
  },
  isGrouped: {
    type: Boolean,
    default: false,
  },
  title: {
    type: String,
    default: "",
  },
  areAllExpanded: {
    type: Boolean,
    default: false,
  },
  contactsCount: {
    type: Number,
    default: 0,
  },
  selectedIds: {
    type: Array,
    default: () => [],
  },
  showAutoFill: {
    type: Boolean,
    default: false,
  },
  autoFilling: {
    type: Boolean,
    default: false,
  },
  expandedCompanyNames: {
    type: Set,
    default: () => new Set(),
  },
  searchQuery: {
    type: String,
    default: "",
  },
});

const emit = defineEmits([
  "toggleSelection",
  "selectAll",
  "edit",
  "delete",
  "expandAll",
  "collapseAll",
  "toggleGroup",
  "autoFill",
  "bulkEdit",
  "bulkDelete",
  "update-inline",
  "openProfile",
]);

const groupedList = computed(() => {
  if (!props.isGrouped) return [];

  if (
    Array.isArray(props.contacts) &&
    props.contacts.length > 0 &&
    Array.isArray(props.contacts[0].contacts)
  ) {
    return props.contacts;
  }

  if (Array.isArray(props.contacts)) {
    const groups = {};
    props.contacts.forEach((contact) => {
      const company =
        contact.additional_attributes?.company_name ||
        contact.company_name ||
        "" ||
        "Empresa não informada";
      if (!groups[company]) {
        groups[company] = {
          name: company,
          contacts: [],
          company: {
            name: company,
            id: contact.company_id || contact.company?.id || null,
          },
        };
      }
      groups[company].contacts.push(contact);
    });
    return Object.values(groups).sort((a, b) => {
      if (a.name === "Empresa não informada") return 1;
      if (b.name === "Empresa não informada") return -1;
      return a.name.localeCompare(b.name);
    });
  }

  return [];
});

watch(
  () => props.contacts,
  (newGroups) => {
    if (!Array.isArray(newGroups) || !newGroups.length) return;
    if (!Array.isArray(newGroups[0]?.contacts)) return;
    newGroups.forEach((group) => {
      if (group.name && !props.expandedCompanyNames.has(group.name)) {
        emit("toggleGroup", group.name);
      }
    });
  },
  { deep: false },
);

watch(
  () => props.searchQuery,
  (newQuery) => {
    if (!newQuery) {
      emit("collapseAll");
    }
  },
);

const handleOpenProfile = (companyObj) => {
  if (!companyObj || !companyObj.id) {
    useAlert(
      'Esta empresa ainda não está sincronizada! Clique em "Atualizar Empresas" primeiro.',
    );
    return;
  }
  emit("openProfile", companyObj);
};

const handleSaveContact = (id, payload, resolve) => {
  emit("update-inline", { id, payload });
  setTimeout(() => resolve(), 500); // UI visual delay to simulate saving interaction length
};

const handleDeleteContact = (contact) => {
  emit("delete", contact);
};
</script>

<template>
  <div class="flex flex-col gap-2">
    <!-- Grouped Headers -->
    <template v-if="isGrouped">
      <div
        v-for="groupItem in groupedList"
        :key="groupItem.name"
        class="flex flex-col gap-2"
      >
        <!-- Group Header -->
        <div
          class="flex items-center justify-between px-4 py-3 bg-n-solid-1 rounded-lg cursor-pointer hover:bg-n-alpha-1 transition-colors group/header"
          @click="$emit('toggleGroup', groupItem.name)"
        >
          <div class="flex items-center gap-2">
            <span
              class="transform transition-transform duration-200 text-n-slate-11 group-hover/header:text-n-brand"
              :class="{ 'rotate-90': expandedCompanyNames.has(groupItem.name) }"
            >
              <svg
                class="w-4 h-4"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M9 5l7 7-7 7"
                />
              </svg>
            </span>
            <h3
              class="font-medium text-n-slate-12 group-hover/header:text-n-brand"
            >
              {{ groupItem.name }}
            </h3>
            <span
              class="text-xs px-2 py-0.5 rounded-full bg-n-alpha-2 text-n-slate-11"
            >
              {{ groupItem.contacts.length }}
            </span>
          </div>
          <!-- Botão Ficha do Cliente -->
          <button
            v-if="groupItem.name !== 'Empresa não informada'"
            class="ml-auto flex items-center justify-center gap-1.5 px-3 py-1.5 text-xs font-semibold tracking-wide text-n-slate-11 hover:text-n-brand bg-white hover:bg-n-brand/10 border border-n-strong hover:border-n-brand/30 dark:bg-n-solid-2 dark:text-n-slate-11 dark:border-n-weak dark:hover:bg-n-brand/20 dark:hover:text-n-brand rounded-md transition-all duration-300 ease-out shadow-sm hover:shadow-md transform hover:-translate-y-0.5"
            title="Abrir Ficha do Cliente"
            @click.stop="handleOpenProfile(groupItem.company)"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="14"
              height="14"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              stroke-linecap="round"
              stroke-linejoin="round"
            >
              <path
                d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"
              />
            </svg>
            <span>Ficha da Empresa</span>
          </button>
        </div>

        <!-- Contacts in Group -->
        <div
          v-show="expandedCompanyNames.has(groupItem.name)"
          class="flex flex-col gap-2 pl-4 border-l-2 border-slate-200 dark:border-slate-700 ml-2"
        >
          <div
            v-for="contact in groupItem.contacts"
            :key="contact.id"
            class="relative"
          >
            <ContactCard
              :contact="contact"
              @save="handleSaveContact"
              @delete="handleDeleteContact"
            />
          </div>
        </div>
      </div>
    </template>

    <!-- Flat List (Non-Grouped) -->
    <template v-else>
      <div v-for="contact in contacts" :key="contact.id" class="relative">
        <ContactCard
          :contact="contact"
          @save="handleSaveContact"
          @delete="handleDeleteContact"
        />
      </div>
    </template>
  </div>
</template>
