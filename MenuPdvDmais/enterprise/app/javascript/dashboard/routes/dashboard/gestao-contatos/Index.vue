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
      <div class="flex gap-2 flex-1 max-w-md">
        <div class="relative flex-1">
          <svg class="w-4 h-4 absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
          </svg>
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Pesquisar por nome, telefone ou empresa..."
            class="w-full pl-10 pr-4 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
          <button
            v-if="searchQuery"
            @click="clearSearch"
            class="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300"
          >
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
      </div>
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

    <!-- Dashboard Cards -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-6">
      <!-- Total de Contatos -->
      <div
        @click="setFilter('all')"
        class="bg-white dark:bg-slate-800 border border-gray-200 dark:border-slate-700 rounded-lg p-6 cursor-pointer hover:shadow-lg transition-all duration-200 hover:scale-105"
        :class="{ 'ring-2 ring-blue-500': activeFilter === 'all' }"
      >
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600 dark:text-gray-400">Total de Contatos</p>
            <p class="text-3xl font-bold text-gray-900 dark:text-white">{{ totalContacts }}</p>
          </div>
          <div class="w-12 h-12 bg-blue-100 dark:bg-blue-900 rounded-full flex items-center justify-center">
            <svg class="w-6 h-6 text-blue-600 dark:text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
            </svg>
          </div>
        </div>
      </div>

      <!-- Contatos sem Empresa -->
      <div
        @click="setFilter('no_company')"
        class="bg-white dark:bg-slate-800 border border-gray-200 dark:border-slate-700 rounded-lg p-6 cursor-pointer hover:shadow-lg transition-all duration-200 hover:scale-105"
        :class="{ 'ring-2 ring-orange-500': activeFilter === 'no_company' }"
      >
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600 dark:text-gray-400">Sem Empresa</p>
            <p class="text-3xl font-bold text-orange-600 dark:text-orange-400">{{ contactsWithoutCompany }}</p>
            <p v-if="contactsEligibleForAutoFill > 0" class="text-xs text-green-600 dark:text-green-400 mt-1">
              {{ contactsEligibleForAutoFill }} podem ser preenchidos automaticamente
            </p>
          </div>
          <div class="w-12 h-12 bg-orange-100 dark:bg-orange-900 rounded-full flex items-center justify-center">
            <svg class="w-6 h-6 text-orange-600 dark:text-orange-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
            </svg>
          </div>
        </div>
      </div>

      <!-- Contatos sem Número -->
      <div
        @click="setFilter('no_phone')"
        class="bg-white dark:bg-slate-800 border border-gray-200 dark:border-slate-700 rounded-lg p-6 cursor-pointer hover:shadow-lg transition-all duration-200 hover:scale-105"
        :class="{ 'ring-2 ring-red-500': activeFilter === 'no_phone' }"
      >
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600 dark:text-gray-400">Sem Número</p>
            <p class="text-3xl font-bold text-red-600 dark:text-red-400">{{ contactsWithoutPhone }}</p>
          </div>
          <div class="w-12 h-12 bg-red-100 dark:bg-red-900 rounded-full flex items-center justify-center">
            <svg class="w-6 h-6 text-red-600 dark:text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
            </svg>
          </div>
        </div>
      </div>

      <!-- Contatos com Número Inválido -->
      <div
        @click="setFilter('invalid_phone')"
        class="bg-white dark:bg-slate-800 border border-gray-200 dark:border-slate-700 rounded-lg p-6 cursor-pointer hover:shadow-lg transition-all duration-200 hover:scale-105"
        :class="{ 'ring-2 ring-yellow-500': activeFilter === 'invalid_phone' }"
      >
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600 dark:text-gray-400">Número Inválido</p>
            <p class="text-3xl font-bold text-yellow-600 dark:text-yellow-400">{{ contactsWithInvalidPhone }}</p>
          </div>
          <div class="w-12 h-12 bg-yellow-100 dark:bg-yellow-900 rounded-full flex items-center justify-center">
            <svg class="w-6 h-6 text-yellow-600 dark:text-yellow-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z" />
            </svg>
          </div>
        </div>
      </div>
    </div>

    <!-- Filter Status Bar -->
    <div v-if="activeFilter !== 'all'" class="bg-gray-100 dark:bg-slate-800 border border-gray-200 dark:border-slate-700 rounded-lg p-4 mb-6">
      <div class="flex items-center justify-between">
        <div class="flex items-center gap-3">
          <svg class="w-5 h-5 text-gray-600 dark:text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z" />
          </svg>
          <span class="text-sm font-medium text-gray-900 dark:text-white">
            Filtro ativo: {{ getFilterLabel(activeFilter) }}
          </span>
          <span class="text-sm text-gray-600 dark:text-gray-400">
            ({{ filteredContacts.length }} contato{{ filteredContacts.length !== 1 ? 's' : '' }})
          </span>
        </div>
        <button
          @click="clearFilter"
          class="px-3 py-1 text-sm bg-gray-600 text-white rounded hover:bg-gray-700 transition-colors"
        >
          Limpar Filtro
        </button>
      </div>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="flex flex-col items-center justify-center py-12">
      <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mb-4"></div>
      <p class="text-slate-600 dark:text-slate-400">Carregando contatos...</p>
    </div>

    <!-- Lista Filtrada de Contatos -->
    <div v-else-if="activeFilter !== 'all' && filteredContacts.length > 0" class="space-y-4 max-h-[70vh] overflow-y-auto">
      <div class="flex items-center justify-between mb-6">
        <div class="flex items-center gap-4">
          <h2 class="text-2xl font-bold text-slate-900 dark:text-white">
            Contatos - {{ getFilterLabel(activeFilter) }}
          </h2>
          <span class="px-3 py-1 bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200 rounded-full text-sm font-medium">
            {{ filteredContacts.length }} contato{{ filteredContacts.length !== 1 ? 's' : '' }}
          </span>
        </div>
        <div class="flex gap-2">
          <button
            v-if="activeFilter === 'no_company' && contactsEligibleForAutoFill > 0"
            @click="autoFillCompanies"
            :disabled="autoFilling"
            class="px-4 py-2 bg-emerald-600 text-white rounded-lg hover:bg-emerald-700 disabled:opacity-50 transition-colors flex items-center gap-2"
          >
            <svg v-if="autoFilling" class="w-4 h-4 animate-spin" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
            </svg>
            <svg v-else class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
            </svg>
            {{ autoFilling ? 'Preenchendo...' : `Preencher Automaticamente (${contactsEligibleForAutoFill})` }}
          </button>
          <button
            v-if="filteredContacts.length > 0"
            @click="selectAllContacts"
            class="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
          >
            Selecionar Todos
          </button>
          <button
            v-if="selectedContacts.length > 0"
            @click="showBulkEditModal"
            class="px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors"
          >
            Editar em Lote ({{ selectedContacts.length }})
          </button>
          <button
            v-if="selectedContacts.length > 0"
            @click="showBulkDeleteModal"
            class="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors flex items-center gap-2"
          >
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
            </svg>
            Deletar Selecionados ({{ selectedContacts.length }})
          </button>
        </div>
      </div>

      <div class="bg-white dark:bg-slate-900 border border-gray-200 dark:border-slate-700 rounded-lg overflow-hidden shadow-sm">
        <div class="divide-y divide-gray-200 dark:divide-slate-700">
          <div
            v-for="contact in filteredContacts"
            :key="contact.id"
            class="p-6 hover:bg-gray-50 dark:hover:bg-slate-800 transition-colors"
          >
            <div class="flex justify-between items-start">
              <div class="flex items-start gap-4 flex-1">
                <!-- Checkbox para seleção -->
                <input
                  type="checkbox"
                  :checked="selectedContacts.includes(contact.id)"
                  @change="toggleContactSelection(contact.id)"
                  class="mt-1 w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 rounded focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
                />

                <!-- Avatar -->
                <div class="w-8 h-8 bg-blue-100 dark:bg-blue-900 rounded-full flex items-center justify-center flex-shrink-0">
                  <svg class="w-4 h-4 text-blue-600 dark:text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                  </svg>
                </div>

                <!-- Informações do contato -->
                <div class="flex-1">
                  <div class="flex items-center gap-3 mb-2">
                    <h4 class="text-lg font-semibold text-slate-900 dark:text-white">
                      {{ contact.name || 'Nome não informado' }}
                    </h4>
                    <!-- Indicadores de problema -->
                    <div class="flex gap-1">
                      <span v-if="!getCompanyName(contact)" class="px-2 py-1 bg-orange-100 dark:bg-orange-900 text-orange-800 dark:text-orange-200 rounded-full text-xs">
                        Sem empresa
                      </span>
                      <span v-if="!contact.phone_number || contact.phone_number.trim() === ''" class="px-2 py-1 bg-red-100 dark:bg-red-900 text-red-800 dark:text-red-200 rounded-full text-xs">
                        Sem telefone
                      </span>
                      <span v-else-if="isInvalidPhone(contact.phone_number)" class="px-2 py-1 bg-yellow-100 dark:bg-yellow-900 text-yellow-800 dark:text-yellow-200 rounded-full text-xs">
                        Telefone inválido
                      </span>
                    </div>
                  </div>
                  <div class="grid grid-cols-1 md:grid-cols-3 gap-3 text-sm text-slate-600 dark:text-slate-400">
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
                    <div v-if="getCompanyName(contact)" class="flex items-center gap-2">
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                      </svg>
                      {{ getCompanyName(contact) }}
                    </div>
                    <div v-if="contact.last_activity_at" class="flex items-center gap-2 md:col-span-3">
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                      </svg>
                      Última atividade: {{ formatDate(contact.last_activity_at) }}
                    </div>
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

    <!-- Modal de edição em lote -->
    <div
      v-if="bulkEditing"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
      @click="closeBulkEditModal"
    >
      <div
        class="bg-white dark:bg-slate-900 rounded-lg p-6 w-full max-w-lg mx-4"
        @click.stop
      >
        <h2 class="text-xl font-bold mb-4 text-slate-900 dark:text-white">
          Editar Contatos em Lote
        </h2>
        <p class="text-sm text-slate-600 dark:text-slate-400 mb-4">
          Aplicar alterações a {{ selectedContacts.length }} contato{{ selectedContacts.length !== 1 ? 's' : '' }} selecionado{{ selectedContacts.length !== 1 ? 's' : '' }}
        </p>

        <form @submit.prevent="saveBulkEdit" class="space-y-4">
          <div class="bg-yellow-50 dark:bg-yellow-900 border border-yellow-200 dark:border-yellow-700 rounded-lg p-4 mb-4">
            <div class="flex items-start gap-3">
              <svg class="w-5 h-5 text-yellow-600 dark:text-yellow-400 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z" />
              </svg>
              <div>
                <p class="text-sm font-medium text-yellow-800 dark:text-yellow-200">
                  Atenção: Campos vazios serão ignorados
                </p>
                <p class="text-sm text-yellow-700 dark:text-yellow-300">
                  Apenas os campos preenchidos serão atualizados nos contatos selecionados.
                </p>
              </div>
            </div>
          </div>

          <div>
            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
              Empresa (opcional)
            </label>
            <input
              v-model="bulkEditForm.company_name"
              type="text"
              placeholder="Digite o nome da empresa"
              class="w-full px-3 py-2 border border-gray-300 dark:border-slate-600 rounded-lg bg-white dark:bg-slate-800 text-slate-900 dark:text-white"
            />
          </div>

          <div class="flex gap-2 pt-4">
            <button
              type="submit"
              :disabled="bulkSaving"
              class="flex-1 px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 disabled:opacity-50"
            >
              {{ bulkSaving ? 'Salvando...' : 'Aplicar Alterações' }}
            </button>
            <button
              type="button"
              @click="closeBulkEditModal"
              class="px-4 py-2 bg-gray-300 dark:bg-slate-600 text-slate-700 dark:text-slate-300 rounded-lg hover:bg-gray-400 dark:hover:bg-slate-500"
            >
              Cancelar
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Modal de exclusão em lote -->
    <div
      v-if="bulkDeleting"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
      @click="closeBulkDeleteModal"
    >
      <div
        class="bg-white dark:bg-slate-900 rounded-lg p-6 w-full max-w-lg mx-4"
        @click.stop
      >
        <div class="flex items-center gap-3 mb-4">
          <div class="w-12 h-12 bg-red-100 dark:bg-red-900 rounded-full flex items-center justify-center">
            <svg class="w-6 h-6 text-red-600 dark:text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
            </svg>
          </div>
          <div>
            <h2 class="text-xl font-bold text-slate-900 dark:text-white">
              Confirmar Exclusão
            </h2>
            <p class="text-sm text-slate-600 dark:text-slate-400">
              Esta ação não pode ser desfeita
            </p>
          </div>
        </div>

        <div class="bg-red-50 dark:bg-red-900 border border-red-200 dark:border-red-700 rounded-lg p-4 mb-6">
          <div class="flex items-start gap-3">
            <svg class="w-5 h-5 text-red-600 dark:text-red-400 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z" />
            </svg>
            <div>
              <p class="text-sm font-medium text-red-800 dark:text-red-200">
                Você está prestes a deletar {{ selectedContacts.length }} contato{{ selectedContacts.length !== 1 ? 's' : '' }}
              </p>
              <p class="text-sm text-red-700 dark:text-red-300 mt-1">
                Todos os dados desses contatos, incluindo conversas e histórico, serão permanentemente removidos.
              </p>
            </div>
          </div>
        </div>

        <div class="flex gap-2">
          <button
            @click="closeBulkDeleteModal"
            class="flex-1 px-4 py-2 bg-gray-300 dark:bg-slate-600 text-slate-700 dark:text-slate-300 rounded-lg hover:bg-gray-400 dark:hover:bg-slate-500 transition-colors"
          >
            Cancelar
          </button>
          <button
            @click="deleteBulkContacts"
            :disabled="bulkSaving"
            class="flex-1 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 disabled:opacity-50 transition-colors"
          >
            {{ bulkSaving ? 'Deletando...' : 'Deletar Contatos' }}
          </button>
        </div>
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
const searchQuery = ref('');
const editingContact = ref(null);
const saving = ref(false);
const expandedCompanies = ref(new Set());
const activeFilter = ref('all');
const selectedContacts = ref([]);
const bulkEditing = ref(false);
const bulkDeleting = ref(false);
const autoFilling = ref(false);

const editForm = ref({
  name: '',
  email: '',
  phone_number: '',
  company_name: ''
});

const bulkEditForm = ref({
  company_name: ''
});

const bulkSaving = ref(false);

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

const contactsWithoutPhone = computed(() => {
  return contacts.value.filter(contact => !contact.phone_number || contact.phone_number.trim() === '').length;
});

const contactsWithInvalidPhone = computed(() => {
  return contacts.value.filter(contact => {
    const phone = contact.phone_number;
    if (!phone || phone.trim() === '') return false;
    // Brazilian phone validation: should start with +55 or 55, followed by 10-11 digits
    const cleanPhone = phone.replace(/\D/g, '');
    const isValidLength = cleanPhone.length >= 10 && cleanPhone.length <= 11;
    const startsWith55 = cleanPhone.startsWith('55') && cleanPhone.length >= 12;
    const isValidFormat = /^\+?55?\d{10,11}$/.test(cleanPhone) || startsWith55;
    return !isValidFormat;
  }).length;
});

const filteredContacts = computed(() => {
  let filtered = contacts.value;

  // Apply filter first
  if (activeFilter.value !== 'all') {
    filtered = filtered.filter(contact => {
      switch (activeFilter.value) {
        case 'no_company':
          return !getCompanyName(contact);
        case 'no_phone':
          return !contact.phone_number || contact.phone_number.trim() === '';
        case 'invalid_phone':
          const phone = contact.phone_number;
          if (!phone || phone.trim() === '') return false;
          const cleanPhone = phone.replace(/\D/g, '');
          const isValidFormat = /^\+?55?\d{10,11}$/.test(cleanPhone) || (cleanPhone.startsWith('55') && cleanPhone.length >= 12);
          return !isValidFormat;
        default:
          return true;
      }
    });
  }

  // Apply search filter
  if (searchQuery.value.trim()) {
    const query = searchQuery.value.toLowerCase().trim();
    filtered = filtered.filter(contact => {
      const name = (contact.name || '').toLowerCase();
      const email = (contact.email || '').toLowerCase();
      const phone = (contact.phone_number || '').toLowerCase();
      const company = (getCompanyName(contact) || '').toLowerCase();

      return name.includes(query) ||
             email.includes(query) ||
             phone.includes(query) ||
             company.includes(query);
    });
  }

  return filtered;
});

const contactsEligibleForAutoFill = computed(() => {
  return contacts.value.filter(contact => {
    // Deve não ter empresa definida
    if (getCompanyName(contact)) return false;

    // Deve ter nome no formato "Nome - Empresa"
    if (!contact.name || !contact.name.includes(' - ')) return false;

    const parts = contact.name.split(' - ');
    return parts.length === 2 && parts[1].trim() !== '';
  }).length;
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

const setFilter = (filterType) => {
  activeFilter.value = filterType;
};

const clearFilter = () => {
  activeFilter.value = 'all';
};

const getFilterLabel = (filterType) => {
  switch (filterType) {
    case 'all':
      return 'Todos os Contatos';
    case 'no_company':
      return 'Sem Empresa';
    case 'no_phone':
      return 'Sem Número';
    case 'invalid_phone':
      return 'Número Inválido';
    default:
      return 'Filtro Desconhecido';
  }
};

const isInvalidPhone = (phone) => {
  if (!phone || phone.trim() === '') return false;
  const cleanPhone = phone.replace(/\D/g, '');
  const isValidFormat = /^\+?55?\d{10,11}$/.test(cleanPhone) || (cleanPhone.startsWith('55') && cleanPhone.length >= 12);
  return !isValidFormat;
};

const selectAllContacts = () => {
  if (selectedContacts.value.length === filteredContacts.value.length) {
    selectedContacts.value = [];
  } else {
    selectedContacts.value = filteredContacts.value.map(contact => contact.id);
  }
};

const toggleContactSelection = (contactId) => {
  const index = selectedContacts.value.indexOf(contactId);
  if (index > -1) {
    selectedContacts.value.splice(index, 1);
  } else {
    selectedContacts.value.push(contactId);
  }
};

const showBulkEditModal = () => {
  bulkEditing.value = true;
};

const saveBulkEdit = async () => {
  if (selectedContacts.value.length === 0) return;

  bulkSaving.value = true;
  try {
    const updates = [];

    // Prepare updates only for filled fields
    const updateData = {};
    if (bulkEditForm.value.company_name && bulkEditForm.value.company_name.trim() !== '') {
      updateData.additional_attributes = {
        company_name: bulkEditForm.value.company_name.trim()
      };
    }

    // If no fields to update, show warning
    if (Object.keys(updateData).length === 0) {
      alert('Preencha pelo menos um campo para atualizar.');
      return;
    }

    // Update each selected contact
    for (const contactId of selectedContacts.value) {
      const contact = contacts.value.find(c => c.id === contactId);
      if (contact) {
        try {
          await ContactAPI.update(contactId, updateData);

          // Update local contact data
          const index = contacts.value.findIndex(c => c.id === contactId);
          if (index !== -1) {
            contacts.value[index] = {
              ...contacts.value[index],
              ...updateData,
              additional_attributes: {
                ...contacts.value[index].additional_attributes,
                ...updateData.additional_attributes
              }
            };
          }

          updates.push(contactId);
        } catch (error) {
          console.error(`Erro ao atualizar contato ${contactId}:`, error);
        }
      }
    }

    console.log(`Contatos atualizados: ${updates.length}`);
    closeBulkEditModal();

    // Clear selections
    selectedContacts.value = [];

  } catch (error) {
    console.error('Erro ao salvar edições em lote:', error);
  } finally {
    bulkSaving.value = false;
  }
};

const closeBulkEditModal = () => {
  bulkEditing.value = false;
  bulkEditForm.value = {
    company_name: ''
  };
};

const showBulkDeleteModal = () => {
  bulkDeleting.value = true;
};

const deleteBulkContacts = async () => {
  if (selectedContacts.value.length === 0) return;

  bulkSaving.value = true;
  try {
    let deletedCount = 0;

    // Delete each selected contact
    for (const contactId of selectedContacts.value) {
      try {
        await ContactAPI.delete(contactId);

        // Remove from local contacts array
        const index = contacts.value.findIndex(c => c.id === contactId);
        if (index !== -1) {
          contacts.value.splice(index, 1);
        }

        deletedCount++;
      } catch (error) {
        console.error(`Erro ao deletar contato ${contactId}:`, error);
      }
    }

    console.log(`Contatos deletados: ${deletedCount}`);

    // Clear cache to force refresh on next load
    clearCache();

    // Clear selections
    selectedContacts.value = [];

    // Close modal
    bulkDeleting.value = false;

    // Show success message
    alert(`✅ ${deletedCount} contato${deletedCount !== 1 ? 's' : ''} foi${deletedCount === 1 ? '' : 'ram'} deletado${deletedCount === 1 ? '' : 's'} com sucesso!`);

  } catch (error) {
    console.error('Erro ao deletar contatos:', error);
    alert('❌ Erro ao deletar contatos. Tente novamente.');
  } finally {
    bulkSaving.value = false;
  }
};

const closeBulkDeleteModal = () => {
  bulkDeleting.value = false;
};

const clearSearch = () => {
  searchQuery.value = '';
};

const autoFillCompanies = async () => {
  if (contactsEligibleForAutoFill.value === 0) return;

  autoFilling.value = true;
  try {
    let updatedCount = 0;

    // Process each eligible contact
    for (const contact of contacts.value) {
      // Skip if already has company or doesn't match format
      if (getCompanyName(contact)) continue;
      if (!contact.name || !contact.name.includes(' - ')) continue;

      const parts = contact.name.split(' - ');
      if (parts.length !== 2 || parts[1].trim() === '') continue;

      const rawCompanyName = parts[1].trim();

      // Format the company name
      let formattedCompanyName = formatCompanyName(rawCompanyName);

      if (formattedCompanyName) {
        const updateData = {
          additional_attributes: {
            ...contact.additional_attributes,
            company_name: formattedCompanyName
          }
        };

        try {
          await ContactAPI.update(contact.id, updateData);

          // Update local contact data
          const index = contacts.value.findIndex(c => c.id === contact.id);
          if (index !== -1) {
            contacts.value[index] = {
              ...contacts.value[index],
              ...updateData,
              additional_attributes: updateData.additional_attributes
            };
          }

          updatedCount++;
        } catch (error) {
          console.error(`Erro ao atualizar contato ${contact.id}:`, error);
        }
      }
    }

    console.log(`Empresas preenchidas automaticamente: ${updatedCount}`);

    // Clear cache to force refresh on next load
    clearCache();

    // Show success message
    alert(`✅ ${updatedCount} contato${updatedCount !== 1 ? 's' : ''} teve${updatedCount === 1 ? '' : 'ram'} a empresa preenchida automaticamente!`);

  } catch (error) {
    console.error('Erro ao preencher empresas automaticamente:', error);
    alert('❌ Erro ao preencher empresas automaticamente. Tente novamente.');
  } finally {
    autoFilling.value = false;
  }
};

const formatCompanyName = (companyName) => {
  if (!companyName) return '';

  try {
    // Remove accents and normalize
    const normalized = companyName.normalize('NFD').replace(/[\u0300-\u036f]/g, '');
    // Remove emojis and special characters except spaces and basic punctuation
    const cleaned = normalized.replace(/[^\w\s\-&.()]/g, '').trim();
    // Title case each word
    const titleized = cleaned.split(/\s+/).map(word =>
      word.charAt(0).toUpperCase() + word.slice(1).toLowerCase()
    ).join(' ');
    // Remove extra spaces
    return titleized.replace(/\s+/g, ' ').trim();
  } catch (error) {
    console.warn('Erro ao formatar nome da empresa:', error);
    return companyName.trim();
  }
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
