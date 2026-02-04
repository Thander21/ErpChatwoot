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
            <!-- Card Implementation -->
            <div
              class="flex flex-col w-full outline-1 outline outline-n-container group/cardLayout rounded-xl bg-n-solid-2 transition-all duration-200 hover:outline-n-brand hover:shadow-sm"
            >
              <!-- Card Header -->
              <div
                class="flex w-full gap-3 py-5 flex-row justify-between items-center px-6"
              >
                <div class="flex items-center justify-start flex-1 gap-4">
                  <!-- Avatar -->
                  <div class="relative">
                    <span
                      class="relative inline-flex group/avatar z-0 flex-shrink-0"
                      style="width: 48px; height: 48px"
                    >
                      <img
                        v-if="contact.thumbnail"
                        :src="contact.thumbnail"
                        class="relative inline-flex items-center justify-center object-cover overflow-hidden font-medium rounded-full"
                        style="width: 48px; height: 48px"
                      />
                      <span
                        v-else
                        role="img"
                        class="relative inline-flex items-center justify-center object-cover overflow-hidden font-medium rounded-full"
                        :style="generateAvatarStyle(contact.name)"
                      >
                        <span
                          class="select-none text-white font-medium"
                          style="font-size: 19.2px"
                          >{{ getInitials(contact.name) }}</span
                        >
                      </span>
                    </span>
                  </div>

                  <!-- Info -->
                  <div class="flex flex-col gap-0.5 flex-1">
                    <div class="flex flex-wrap items-center gap-x-4 gap-y-1">
                      <span
                        class="text-base font-medium truncate text-n-slate-12"
                      >
                        {{ contact.name || "Sem Nome" }}
                      </span>
                    </div>
                    <div
                      class="flex flex-wrap items-center justify-start gap-x-3 gap-y-1"
                    >
                      <span
                        v-if="contact.phone_number"
                        class="text-sm truncate text-n-slate-11"
                      >
                        {{ contact.phone_number }}
                      </span>
                      <!-- View Details Link -->
                      <a
                        v-if="route.params.accountId"
                        :href="getContactUrl(contact.id)"
                        class="text-sm font-medium text-n-brand hover:underline ml-2"
                        @click.stop
                      >
                        View details
                      </a>
                      <span
                        v-if="contact.email"
                        class="text-sm truncate text-n-slate-11 ml-2 border-l border-n-slate-4 pl-2"
                      >
                        {{ contact.email }}
                      </span>
                    </div>
                  </div>
                </div>

                <!-- Toggle Button -->
                <button
                  @click="toggleCard(contact.id)"
                  class="inline-flex items-center min-w-0 gap-2 transition-all duration-100 ease-out border-0 rounded-lg outline-1 outline disabled:opacity-50 text-n-slate-12 hover:enabled:bg-n-alpha-2 focus-visible:bg-n-alpha-2 outline-transparent h-6 w-6 p-0 text-xs active:enabled:scale-[0.97] justify-center"
                >
                  <span
                    class="i-lucide-chevron-down flex-shrink-0 transition-transform duration-200"
                    :class="{ 'rotate-180': expandedCards.has(contact.id) }"
                  ></span>
                </button>
              </div>

              <!-- Expanded Content (Accordion) -->
              <div
                class="transition-all duration-300 ease-in-out grid overflow-hidden"
                :class="
                  expandedCards.has(contact.id)
                    ? 'grid-rows-[1fr] opacity-100'
                    : 'grid-rows-[0fr] opacity-0'
                "
              >
                <div class="overflow-hidden">
                  <div
                    class="flex flex-col gap-6 p-6 border-t border-n-strong"
                    v-if="expandedCards.has(contact.id)"
                  >
                    <!-- Inline Edit Form -->
                    <div class="flex flex-col gap-6">
                      <div class="flex flex-col items-start gap-2">
                        <span class="py-1 text-sm font-medium text-n-slate-12"
                          >Editar detalhes</span
                        >
                        <div
                          class="grid w-full grid-cols-1 gap-4 sm:grid-cols-2"
                        >
                          <!-- Name -->
                          <div
                            class="relative flex flex-col min-w-0 gap-1 w-full"
                          >
                            <input
                              v-model="editForms[contact.id].name"
                              class="w-full h-10 px-3 py-2.5 block reset-base text-sm outline outline-1 outline-offset-[-1px] rounded-lg bg-n-alpha-black2 border-none outline-n-weak dark:outline-n-weak focus:outline-n-brand dark:focus:outline-n-brand text-n-slate-12 placeholder:text-n-slate-10 transition-all duration-200"
                              type="text"
                              placeholder="Nome completo"
                            />
                          </div>

                          <!-- Email -->
                          <div
                            class="relative flex flex-col min-w-0 gap-1 w-full"
                          >
                            <input
                              v-model="editForms[contact.id].email"
                              class="w-full h-10 px-3 py-2.5 block reset-base text-sm outline outline-1 outline-offset-[-1px] rounded-lg bg-n-alpha-black2 border-none outline-n-weak dark:outline-n-weak focus:outline-n-brand dark:focus:outline-n-brand text-n-slate-12 placeholder:text-n-slate-10 transition-all duration-200"
                              type="text"
                              placeholder="Email"
                            />
                          </div>

                          <!-- Phone -->
                          <div
                            class="relative flex flex-col min-w-0 gap-1 w-full"
                          >
                            <input
                              v-model="editForms[contact.id].phone_number"
                              class="w-full h-10 px-3 py-2.5 block reset-base text-sm outline outline-1 outline-offset-[-1px] rounded-lg bg-n-alpha-black2 border-none outline-n-weak dark:outline-n-weak focus:outline-n-brand dark:focus:outline-n-brand text-n-slate-12 placeholder:text-n-slate-10 transition-all duration-200"
                              type="text"
                              placeholder="Telefone"
                            />
                          </div>

                          <!-- Company -->
                          <div
                            class="relative flex flex-col min-w-0 gap-1 w-full"
                          >
                            <input
                              v-model="editForms[contact.id].company_name"
                              class="w-full h-10 px-3 py-2.5 block reset-base text-sm outline outline-1 outline-offset-[-1px] rounded-lg bg-n-alpha-black2 border-none outline-n-weak dark:outline-n-weak focus:outline-n-brand dark:focus:outline-n-brand text-n-slate-12 placeholder:text-n-slate-10 transition-all duration-200"
                              type="text"
                              placeholder="Empresa"
                            />
                          </div>

                          <!-- City -->
                          <div
                            class="relative flex flex-col min-w-0 gap-1 w-full"
                          >
                            <input
                              v-model="editForms[contact.id].city"
                              class="w-full h-10 px-3 py-2.5 block reset-base text-sm outline outline-1 outline-offset-[-1px] rounded-lg bg-n-alpha-black2 border-none outline-n-weak dark:outline-n-weak focus:outline-n-brand dark:focus:outline-n-brand text-n-slate-12 placeholder:text-n-slate-10 transition-all duration-200"
                              type="text"
                              placeholder="Cidade"
                            />
                          </div>

                          <!-- Bio -->
                          <div
                            class="relative flex flex-col min-w-0 gap-1 w-full"
                          >
                            <input
                              v-model="editForms[contact.id].bio"
                              class="w-full h-10 px-3 py-2.5 block reset-base text-sm outline outline-1 outline-offset-[-1px] rounded-lg bg-n-alpha-black2 border-none outline-n-weak dark:outline-n-weak focus:outline-n-brand dark:focus:outline-n-brand text-n-slate-12 placeholder:text-n-slate-10 transition-all duration-200"
                              type="text"
                              placeholder="Bio"
                            />
                          </div>
                        </div>
                      </div>

                      <!-- Actions -->
                      <div>
                        <button
                          @click="saveContact(contact.id)"
                          :disabled="savingId === contact.id"
                          class="inline-flex items-center min-w-0 gap-2 transition-all duration-100 ease-out border-0 rounded-lg outline-1 outline disabled:opacity-50 bg-n-brand text-white hover:enabled:brightness-110 focus-visible:brightness-110 outline-transparent h-8 px-3 text-sm active:enabled:scale-[0.97] justify-center"
                        >
                          <span
                            v-if="savingId === contact.id"
                            class="i-lucide-loader-2 animate-spin"
                          ></span>
                          {{
                            savingId === contact.id
                              ? "Salvando..."
                              : "Atualizar contato"
                          }}
                        </button>
                      </div>
                    </div>

                    <!-- Delete Section -->
                    <div>
                      <div
                        class="flex flex-col items-start border-t border-n-strong px-0 py-5 mt-4"
                      >
                        <button
                          @click="toggleDeleteConfirm(contact.id)"
                          class="hover:!no-underline text-n-slate-12 inline-flex items-center min-w-0 gap-2 transition-all duration-100 ease-out border-0 rounded-lg outline-1 outline disabled:opacity-50 text-n-slate-11 hover:enabled:text-n-ruby-9 focus-visible:text-n-ruby-9 hover:enabled:underline focus-visible:underline outline-transparent p-0 font-medium underline-offset-2 text-sm active:enabled:scale-[0.97] justify-center flex-row-reverse"
                        >
                          <span
                            class="i-lucide-chevron-down flex-shrink-0 transition-transform"
                            :class="{
                              'rotate-180': deleteConfirms.has(contact.id),
                            }"
                          ></span>
                          <span class="min-w-0 truncate">Deletar contato</span>
                        </button>

                        <div
                          class="transition-all duration-300 ease-in-out grid w-full overflow-hidden"
                          :class="
                            deleteConfirms.has(contact.id)
                              ? 'grid-rows-[1fr] opacity-100 mt-2'
                              : 'grid-rows-[0fr] opacity-0 mt-0'
                          "
                        >
                          <div class="overflow-hidden min-h-0">
                            <span
                              class="inline-flex text-n-slate-11 text-sm items-center gap-1"
                            >
                              Essa ação é permanente.
                              <button
                                @click="$emit('delete', contact)"
                                class="inline-flex items-center min-w-0 gap-2 transition-all duration-100 ease-out border-0 rounded-lg outline-1 outline disabled:opacity-50 text-n-ruby-9 dark:text-n-ruby-11 hover:enabled:underline focus-visible:underline outline-transparent p-0 font-medium underline-offset-2 text-sm active:enabled:scale-[0.97] justify-center"
                              >
                                <span class="min-w-0 truncate"
                                  >Deletar agora</span
                                >
                              </button>
                            </span>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </template>

    <!-- Flat List (Non-Grouped) -->
    <template v-else>
      <div v-for="contact in contacts" :key="contact.id" class="relative">
        <div
          class="flex flex-col w-full outline-1 outline outline-n-container group/cardLayout rounded-xl bg-n-solid-2 transition-all duration-200 hover:outline-n-brand hover:shadow-sm"
        >
          <!-- Card Header -->
          <div
            class="flex w-full gap-3 py-5 flex-row justify-between items-center px-6"
          >
            <div class="flex items-center justify-start flex-1 gap-4">
              <!-- Avatar -->
              <div class="relative">
                <span
                  class="relative inline-flex group/avatar z-0 flex-shrink-0"
                  style="width: 48px; height: 48px"
                >
                  <img
                    v-if="contact.thumbnail"
                    :src="contact.thumbnail"
                    class="relative inline-flex items-center justify-center object-cover overflow-hidden font-medium rounded-full"
                    style="width: 48px; height: 48px"
                  />
                  <span
                    v-else
                    role="img"
                    class="relative inline-flex items-center justify-center object-cover overflow-hidden font-medium rounded-full"
                    :style="generateAvatarStyle(contact.name)"
                  >
                    <span
                      class="select-none text-white font-medium"
                      style="font-size: 19.2px"
                      >{{ getInitials(contact.name) }}</span
                    >
                  </span>
                </span>
              </div>

              <!-- Info -->
              <div class="flex flex-col gap-0.5 flex-1">
                <div class="flex flex-wrap items-center gap-x-4 gap-y-1">
                  <span class="text-base font-medium truncate text-n-slate-12">
                    {{ contact.name || "Sem Nome" }}
                  </span>
                </div>
                <div
                  class="flex flex-wrap items-center justify-start gap-x-3 gap-y-1"
                >
                  <span
                    v-if="contact.phone_number"
                    class="text-sm truncate text-n-slate-11"
                  >
                    {{ contact.phone_number }}
                  </span>
                  <!-- View Details Link -->
                  <a
                    v-if="route.params.accountId"
                    :href="getContactUrl(contact.id)"
                    class="text-sm font-medium text-n-brand hover:underline ml-2"
                    @click.stop
                  >
                    View details
                  </a>
                  <span
                    v-if="contact.email"
                    class="text-sm truncate text-n-slate-11 ml-2 border-l border-n-slate-4 pl-2"
                  >
                    {{ contact.email }}
                  </span>
                </div>
              </div>
            </div>

            <!-- Toggle Button -->
            <button
              @click="toggleCard(contact.id)"
              class="inline-flex items-center min-w-0 gap-2 transition-all duration-100 ease-out border-0 rounded-lg outline-1 outline disabled:opacity-50 text-n-slate-12 hover:enabled:bg-n-alpha-2 focus-visible:bg-n-alpha-2 outline-transparent h-6 w-6 p-0 text-xs active:enabled:scale-[0.97] justify-center"
            >
              <span
                class="i-lucide-chevron-down flex-shrink-0 transition-transform duration-200"
                :class="{ 'rotate-180': expandedCards.has(contact.id) }"
              ></span>
            </button>
          </div>

          <!-- Expanded Content (Accordion) -->
          <div
            class="transition-all duration-300 ease-in-out grid overflow-hidden"
            :class="
              expandedCards.has(contact.id)
                ? 'grid-rows-[1fr] opacity-100'
                : 'grid-rows-[0fr] opacity-0'
            "
          >
            <div class="overflow-hidden">
              <div
                class="flex flex-col gap-6 p-6 border-t border-n-strong"
                v-if="expandedCards.has(contact.id)"
              >
                <!-- Inline Edit Form -->
                <div class="flex flex-col gap-6">
                  <div class="flex flex-col items-start gap-2">
                    <span class="py-1 text-sm font-medium text-n-slate-12"
                      >Editar detalhes</span
                    >
                    <div class="grid w-full grid-cols-1 gap-4 sm:grid-cols-2">
                      <!-- Name -->
                      <div class="relative flex flex-col min-w-0 gap-1 w-full">
                        <input
                          v-model="editForms[contact.id].name"
                          class="w-full h-10 px-3 py-2.5 block reset-base text-sm outline outline-1 outline-offset-[-1px] rounded-lg bg-n-alpha-black2 border-none outline-n-weak dark:outline-n-weak focus:outline-n-brand dark:focus:outline-n-brand text-n-slate-12 placeholder:text-n-slate-10 transition-all duration-200"
                          type="text"
                          placeholder="Nome completo"
                        />
                      </div>

                      <!-- Email -->
                      <div class="relative flex flex-col min-w-0 gap-1 w-full">
                        <input
                          v-model="editForms[contact.id].email"
                          class="w-full h-10 px-3 py-2.5 block reset-base text-sm outline outline-1 outline-offset-[-1px] rounded-lg bg-n-alpha-black2 border-none outline-n-weak dark:outline-n-weak focus:outline-n-brand dark:focus:outline-n-brand text-n-slate-12 placeholder:text-n-slate-10 transition-all duration-200"
                          type="text"
                          placeholder="Email"
                        />
                      </div>

                      <!-- Phone -->
                      <div class="relative flex flex-col min-w-0 gap-1 w-full">
                        <input
                          v-model="editForms[contact.id].phone_number"
                          class="w-full h-10 px-3 py-2.5 block reset-base text-sm outline outline-1 outline-offset-[-1px] rounded-lg bg-n-alpha-black2 border-none outline-n-weak dark:outline-n-weak focus:outline-n-brand dark:focus:outline-n-brand text-n-slate-12 placeholder:text-n-slate-10 transition-all duration-200"
                          type="text"
                          placeholder="Telefone"
                        />
                      </div>

                      <!-- Company -->
                      <div class="relative flex flex-col min-w-0 gap-1 w-full">
                        <input
                          v-model="editForms[contact.id].company_name"
                          class="w-full h-10 px-3 py-2.5 block reset-base text-sm outline outline-1 outline-offset-[-1px] rounded-lg bg-n-alpha-black2 border-none outline-n-weak dark:outline-n-weak focus:outline-n-brand dark:focus:outline-n-brand text-n-slate-12 placeholder:text-n-slate-10 transition-all duration-200"
                          type="text"
                          placeholder="Empresa"
                        />
                      </div>

                      <!-- City -->
                      <div class="relative flex flex-col min-w-0 gap-1 w-full">
                        <input
                          v-model="editForms[contact.id].city"
                          class="w-full h-10 px-3 py-2.5 block reset-base text-sm outline outline-1 outline-offset-[-1px] rounded-lg bg-n-alpha-black2 border-none outline-n-weak dark:outline-n-weak focus:outline-n-brand dark:focus:outline-n-brand text-n-slate-12 placeholder:text-n-slate-10 transition-all duration-200"
                          type="text"
                          placeholder="Cidade"
                        />
                      </div>

                      <!-- Bio -->
                      <div class="relative flex flex-col min-w-0 gap-1 w-full">
                        <input
                          v-model="editForms[contact.id].bio"
                          class="w-full h-10 px-3 py-2.5 block reset-base text-sm outline outline-1 outline-offset-[-1px] rounded-lg bg-n-alpha-black2 border-none outline-n-weak dark:outline-n-weak focus:outline-n-brand dark:focus:outline-n-brand text-n-slate-12 placeholder:text-n-slate-10 transition-all duration-200"
                          type="text"
                          placeholder="Bio"
                        />
                      </div>
                    </div>
                  </div>

                  <!-- Actions -->
                  <div>
                    <button
                      @click="saveContact(contact.id)"
                      :disabled="savingId === contact.id"
                      class="inline-flex items-center min-w-0 gap-2 transition-all duration-100 ease-out border-0 rounded-lg outline-1 outline disabled:opacity-50 bg-n-brand text-white hover:enabled:brightness-110 focus-visible:brightness-110 outline-transparent h-8 px-3 text-sm active:enabled:scale-[0.97] justify-center"
                    >
                      <span
                        v-if="savingId === contact.id"
                        class="i-lucide-loader-2 animate-spin"
                      ></span>
                      {{
                        savingId === contact.id
                          ? "Salvando..."
                          : "Atualizar contato"
                      }}
                    </button>
                  </div>
                </div>

                <!-- Delete Section -->
                <div>
                  <div
                    class="flex flex-col items-start border-t border-n-strong px-0 py-5 mt-4"
                  >
                    <button
                      @click="toggleDeleteConfirm(contact.id)"
                      class="hover:!no-underline text-n-slate-12 inline-flex items-center min-w-0 gap-2 transition-all duration-100 ease-out border-0 rounded-lg outline-1 outline disabled:opacity-50 text-n-slate-11 hover:enabled:text-n-ruby-9 focus-visible:text-n-ruby-9 hover:enabled:underline focus-visible:underline outline-transparent p-0 font-medium underline-offset-2 text-sm active:enabled:scale-[0.97] justify-center flex-row-reverse"
                    >
                      <span
                        class="i-lucide-chevron-down flex-shrink-0 transition-transform"
                        :class="{
                          'rotate-180': deleteConfirms.has(contact.id),
                        }"
                      ></span>
                      <span class="min-w-0 truncate">Deletar contato</span>
                    </button>

                    <div
                      class="transition-all duration-300 ease-in-out grid w-full overflow-hidden"
                      :class="
                        deleteConfirms.has(contact.id)
                          ? 'grid-rows-[1fr] opacity-100 mt-2'
                          : 'grid-rows-[0fr] opacity-0 mt-0'
                      "
                    >
                      <div class="overflow-hidden min-h-0">
                        <span
                          class="inline-flex text-n-slate-11 text-sm items-center gap-1"
                        >
                          Essa ação é permanente.
                          <button
                            @click="$emit('delete', contact)"
                            class="inline-flex items-center min-w-0 gap-2 transition-all duration-100 ease-out border-0 rounded-lg outline-1 outline disabled:opacity-50 text-n-ruby-9 dark:text-n-ruby-11 hover:enabled:underline focus-visible:underline outline-transparent p-0 font-medium underline-offset-2 text-sm active:enabled:scale-[0.97] justify-center"
                          >
                            <span class="min-w-0 truncate">Deletar agora</span>
                          </button>
                        </span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup>
import { defineProps, defineEmits, computed, ref } from "vue";
import { useRoute } from "vue-router";

const props = defineProps({
  contacts: {
    type: [Array, Object], // Can be Object if using contactsByCompany directly
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
]);

// State
const route = useRoute();
const expandedCards = ref(new Set());
const deleteConfirms = ref(new Set());
const editForms = ref({});
const savingId = ref(null);

const getContactUrl = (id) => {
  return `/app/accounts/${route.params.accountId}/contacts/${id}`;
};

const groupedList = computed(() => {
  if (!props.isGrouped) return [];

  // If we already received an array of Group Objects (from contactsByCompany)
  // Check if the first item has 'contacts' array property to distinguish from flat contact list
  if (
    Array.isArray(props.contacts) &&
    props.contacts.length > 0 &&
    Array.isArray(props.contacts[0].contacts)
  ) {
    return props.contacts;
  }

  // Also handle empty array but if `isGrouped` is true, we might expect groups.
  // But if empty, it returns empty array.

  // Fallback: Group locally if it's a flat array of contacts
  if (Array.isArray(props.contacts)) {
    const groups = {};
    props.contacts.forEach((contact) => {
      const company = getCompanyName(contact) || "Sem Empresa";
      if (!groups[company]) groups[company] = [];
      groups[company].push(contact);
    });

    // Convert map to Array of objects to match the structure we want in template
    return Object.keys(groups)
      .sort((a, b) => {
        if (a === "Sem Empresa") return -1;
        if (b === "Sem Empresa") return 1;
        return a.localeCompare(b);
      })
      .map((name) => ({
        name,
        contacts: groups[name],
      }));
  }

  // Fallback for Object (shouldn't happen with current useContacts, but safe refactor)
  if (typeof props.contacts === "object") {
    return Object.keys(props.contacts)
      .sort((a, b) => {
        if (a === "Sem Empresa") return -1;
        if (b === "Sem Empresa") return 1;
        return a.localeCompare(b);
      })
      .map((key) => ({
        name: key,
        contacts: props.contacts[key],
      }));
  }

  return [];
});

// Helper for group fallback
const getCompanyName = (contact) => {
  return (
    contact.additional_attributes?.company_name || contact.company_name || ""
  );
};

// Initials helper
const getInitials = (name) => {
  if (!name) return "";
  const parts = name.split(" ");
  if (parts.length > 1) {
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
  return name.slice(0, 2).toUpperCase();
};

const generateAvatarStyle = (name) => {
  const colors = [
    "#F87171",
    "#FB923C",
    "#FBBF24",
    "#34D399",
    "#60A5FA",
    "#818CF8",
    "#A78BFA",
    "#F472B6",
  ];
  let hash = 0;
  if (!name) return { backgroundColor: colors[0] };
  for (let i = 0; i < name.length; i++) {
    hash = name.charCodeAt(i) + ((hash << 5) - hash);
  }
  const color = colors[Math.abs(hash) % colors.length];
  return { backgroundColor: color, color: "#fff" };
};

const toggleCard = (id) => {
  if (expandedCards.value.has(id)) {
    expandedCards.value.delete(id);
    delete editForms.value[id]; // Cleanup specific form
  } else {
    expandedCards.value.add(id);
    // Find contact. Use the normalized groupedList if grouping is active, or flat list.
    let contact = null;

    if (props.isGrouped) {
      for (const group of groupedList.value) {
        const found = group.contacts.find((c) => c.id === id);
        if (found) {
          contact = found;
          break;
        }
      }
    } else {
      // Flat list
      if (Array.isArray(props.contacts)) {
        contact = props.contacts.find((c) => c.id === id);
      }
    }

    if (contact) {
      editForms.value[id] = {
        name: contact.name,
        email: contact.email,
        phone_number: contact.phone_number,
        company_name: getCompanyName(contact),
        city: contact.additional_attributes?.city || "",
        bio: contact.additional_attributes?.bio || "",
      };
    }
  }
};

const toggleDeleteConfirm = (id) => {
  if (deleteConfirms.value.has(id)) {
    deleteConfirms.value.delete(id);
  } else {
    deleteConfirms.value.add(id);
  }
};

const saveContact = async (id) => {
  if (savingId.value) return;
  savingId.value = id;
  const formData = editForms.value[id];

  // Construct payload matching the API expectation loosely
  const payload = {
    name: formData.name,
    email: formData.email,
    phone_number: formData.phone_number,
    additional_attributes: {
      company_name: formData.company_name,
      city: formData.city,
      bio: formData.bio,
    },
  };

  try {
    emit("update-inline", { id, payload });
    // We can't await emit directly for completion unless parent returns promise?
    // Vue emit is synchronous but doesn't return the handler result usually unless mapped.
    // However, we can simulate delay or just unset.
    // For better UX, let's keep it spinning for 500ms or until prop changes?
    // Since we are changing local state 'editForms' won't update until we re-init.
    // But if we save, we probably want to keep the form open?
    setTimeout(() => {
      savingId.value = null;
    }, 500);
  } catch (e) {
    savingId.value = null;
  }
};
</script>
