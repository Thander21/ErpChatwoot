<template>
  <div class="space-y-4 max-h-[70vh] overflow-y-auto">
    <!-- Header / Toolbar -->
    <div class="flex items-center justify-between mb-6">
      <div class="flex items-center gap-4">
        <h2 class="text-2xl font-bold text-slate-900 dark:text-white">
          {{ title }}
        </h2>

      </div>

      <div class="flex gap-2">
        <!-- Group Actions (Expand/Collapse) -->
        <template v-if="isGrouped">
          <button
            @click="areAllExpanded ? $emit('collapseAll') : $emit('expandAll')"
            class="px-3 py-1.5 text-sm rounded transition-colors"
            :class="areAllExpanded 
              ? 'bg-gray-100 text-gray-700 dark:bg-gray-800 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-700'
              : 'bg-blue-100 text-blue-700 dark:bg-blue-900 dark:text-blue-300 hover:bg-blue-200 dark:hover:bg-blue-800'"
          >
            {{ areAllExpanded ? 'Recolher Todas' : 'Expandir Todas' }}
          </button>
        </template>

        <!-- Bulk Actions -->
        <button
          v-if="showAutoFill"
          @click="$emit('autoFill')"
          :disabled="autoFilling"
          class="px-4 py-2 bg-emerald-600 text-white rounded-lg hover:bg-emerald-700 disabled:opacity-50 transition-colors flex items-center gap-2"
        >
          <span v-if="autoFilling" class="animate-spin">↻</span>
          {{ autoFilling ? "Preenchendo..." : "Preencher Auto" }}
        </button>

        <label
          class="flex items-center gap-2 px-4 py-2 bg-gray-100 dark:bg-gray-800 rounded-lg cursor-pointer hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors"
        >
          <input
            type="checkbox"
            :checked="allSelected"
            @change="$emit('selectAll')"
            class="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 rounded focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
          />
          <span class="text-sm font-medium text-slate-700 dark:text-slate-200"
            >Todos</span
          >
        </label>

        <button
          v-if="hasSelection"
          @click="$emit('bulkEdit')"
          class="px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors"
        >
          Editar ({{ selectedCount }})
        </button>
        <button
          v-if="hasSelection"
          @click="$emit('bulkDelete')"
          class="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors flex items-center gap-2"
        >
          Deletar ({{ selectedCount }})
        </button>
      </div>
    </div>

    <!-- List View -->
    <template v-if="!isGrouped">
      <div
        class="bg-white dark:bg-slate-900 border border-gray-200 dark:border-slate-700 rounded-lg overflow-hidden shadow-sm divide-y divide-gray-200 dark:divide-slate-700"
      >
        <ContactItem
          v-for="contact in contacts"
          :key="contact.id"
          :contact="contact"
          :is-selected="selectedIds.includes(contact.id)"
          @toggle-selection="$emit('toggleSelection', contact.id)"
          @edit="$emit('edit', contact)"
          @delete="$emit('delete', contact)"
        />
      </div>
    </template>

    <!-- Grouped View -->
    <template v-else>
      <div
        v-for="company in contacts"
        :key="company.name"
        class="border border-gray-200 dark:border-slate-700 rounded-lg overflow-hidden shadow-sm"
      >
        <!-- Company Header -->
        <div
          class="bg-gradient-to-r from-blue-600 to-blue-700 px-6 py-4 text-white"
        >
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-4">
              <div
                class="w-10 h-10 bg-white bg-opacity-20 rounded-full flex items-center justify-center"
              >
                <!-- Icon -->
                <svg
                  class="w-6 h-6"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"
                  />
                </svg>
              </div>
              <div>
                <h3 class="text-xl font-bold">
                  {{ company.name }}
                </h3>
                <p class="text-blue-100">
                  {{ company.contacts.length }} contato{{
                    company.contacts.length !== 1 ? 's' : ''
                  }}
                </p>
              </div>
            </div>
            <button
              @click="$emit('toggleGroup', company.name)"
              class="p-2 hover:bg-white hover:bg-opacity-10 rounded-lg transition-colors"
            >
              <svg
                class="w-6 h-6 transform transition-transform"
                :class="{ 'rotate-180': !company.expanded }"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M19 9l-7 7-7-7"
                />
              </svg>
            </button>
          </div>
        </div>

        <!-- Group Content -->
        <div
          v-show="company.expanded"
          class="bg-white dark:bg-slate-900 divide-y divide-gray-200 dark:divide-slate-700"
        >
          <ContactItem
            v-for="contact in company.contacts"
            :key="contact.id"
            :contact="contact"
            :is-selected="selectedIds.includes(contact.id)"
            @toggle-selection="$emit('toggleSelection', contact.id)"
            @edit="$emit('edit', contact)"
            @delete="$emit('delete', contact)"
          />
        </div>
      </div>
    </template>
  </div>
</template>

<script setup>
import ContactItem from './ContactItem.vue';

const props = defineProps({
  contacts: Array, // Can be flat array or array of groups
  isGrouped: Boolean,
  isGrouped: Boolean,
  title: String,
  areAllExpanded: Boolean,
  contactsCount: Number,
  selectedIds: Array,
  showAutoFill: Boolean,
  autoFilling: Boolean,
});

const emit = defineEmits([
  'toggleSelection',
  'selectAll',
  'edit',
  'delete',
  'expandAll',
  'collapseAll',
  'toggleGroup',
  'autoFill',
  'bulkEdit',
  'bulkDelete',
]);

const hasSelection = computed(() => props.selectedIds && props.selectedIds.length > 0);
const selectedCount = computed(() => props.selectedIds ? props.selectedIds.length : 0);

// Logic to determine if "All Selected" is checked depends on total visible contacts
import { computed } from 'vue';

const allSelected = computed(() => {
  if (!props.contacts || props.contacts.length === 0) return false;
  
  if (props.isGrouped) {
      // Count total contacts in groups
      let total = 0;
      props.contacts.forEach(g => total += g.contacts.length);
      return total > 0 && props.selectedIds.length === total;
  } else {
      return props.selectedIds.length === props.contacts.length;
  }
});
</script>
