<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ContactsStats.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: -
 * Description: (Adicionar descrição em português)
-->
<script setup>
defineProps({
  totalContacts: Number,
  contactsWithoutCompany: Number,
  contactsEligibleForAutoFill: Number,
  contactsWithoutPhone: Number,
  contactsWithInvalidPhone: Number,
  activeFilter: String,
});

defineEmits(["setFilter"]);
</script>

<template>
  <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-6">
    <!-- Total de Contatos -->
    <div
      class="bg-white dark:bg-slate-800 border border-gray-200 dark:border-slate-700 rounded-lg p-4 cursor-pointer hover:shadow-lg transition-all duration-200 hover:scale-105"
      :class="{ 'ring-2 ring-blue-500': activeFilter === 'all' }"
      @click="$emit('setFilter', 'all')"
    >
      <div class="flex items-center justify-between">
        <div>
          <p class="text-sm font-medium text-gray-600 dark:text-gray-400">
            Total de Contatos
          </p>
          <p class="text-2xl font-bold text-gray-900 dark:text-white">
            {{ totalContacts }}
          </p>
        </div>
        <div
          class="w-12 h-12 bg-blue-100 dark:bg-blue-900 rounded-full flex items-center justify-center"
        >
          <!-- Icon -->
          <svg
            class="w-6 h-6 text-blue-600 dark:text-blue-400"
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
        </div>
      </div>
    </div>

    <!-- Contatos sem Empresa -->
    <div
      class="bg-white dark:bg-slate-800 border border-gray-200 dark:border-slate-700 rounded-lg p-4 cursor-pointer hover:shadow-lg transition-all duration-200 hover:scale-105"
      :class="{ 'ring-2 ring-orange-500': activeFilter === 'no_company' }"
      @click="$emit('setFilter', 'no_company')"
    >
      <div class="flex items-center justify-between">
        <div>
          <p class="text-sm font-medium text-gray-600 dark:text-gray-400">
            Sem Empresa
          </p>
          <p class="text-2xl font-bold text-orange-600 dark:text-orange-400">
            {{ contactsWithoutCompany }}
          </p>
          <p
            v-if="contactsEligibleForAutoFill > 0"
            class="text-xs text-green-600 dark:text-green-400 mt-1"
          >
            {{ contactsEligibleForAutoFill }} podem ser preenchidos
          </p>
        </div>
        <div
          class="w-12 h-12 bg-orange-100 dark:bg-orange-900 rounded-full flex items-center justify-center"
        >
          <svg
            class="w-6 h-6 text-orange-600 dark:text-orange-400"
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
      </div>
    </div>

    <!-- Contatos sem Número -->
    <div
      class="bg-white dark:bg-slate-800 border border-gray-200 dark:border-slate-700 rounded-lg p-4 cursor-pointer hover:shadow-lg transition-all duration-200 hover:scale-105"
      :class="{ 'ring-2 ring-red-500': activeFilter === 'no_phone' }"
      @click="$emit('setFilter', 'no_phone')"
    >
      <div class="flex items-center justify-between">
        <div>
          <p class="text-sm font-medium text-gray-600 dark:text-gray-400">
            Sem Número
          </p>
          <p class="text-2xl font-bold text-red-600 dark:text-red-400">
            {{ contactsWithoutPhone }}
          </p>
        </div>
        <div
          class="w-12 h-12 bg-red-100 dark:bg-red-900 rounded-full flex items-center justify-center"
        >
          <svg
            class="w-6 h-6 text-red-600 dark:text-red-400"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"
            />
          </svg>
        </div>
      </div>
    </div>

    <!-- Contatos com Número Inválido -->
    <div
      class="bg-white dark:bg-slate-800 border border-gray-200 dark:border-slate-700 rounded-lg p-4 cursor-pointer hover:shadow-lg transition-all duration-200 hover:scale-105"
      :class="{ 'ring-2 ring-yellow-500': activeFilter === 'invalid_phone' }"
      @click="$emit('setFilter', 'invalid_phone')"
    >
      <div class="flex items-center justify-between">
        <div>
          <p class="text-sm font-medium text-gray-600 dark:text-gray-400">
            Número Inválido
          </p>
          <p class="text-2xl font-bold text-yellow-600 dark:text-yellow-400">
            {{ contactsWithInvalidPhone }}
          </p>
        </div>
        <div
          class="w-12 h-12 bg-yellow-100 dark:bg-yellow-900 rounded-full flex items-center justify-center"
        >
          <svg
            class="w-6 h-6 text-yellow-600 dark:text-yellow-400"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"
            />
          </svg>
        </div>
      </div>
    </div>
  </div>
</template>
