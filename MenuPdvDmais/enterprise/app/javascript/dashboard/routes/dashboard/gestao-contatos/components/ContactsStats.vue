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
  <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
    <!-- Total de Contatos -->
    <div
      class="bg-n-solid-1 border border-n-weak rounded-lg p-4 cursor-pointer hover:shadow-lg transition-all duration-200 hover:scale-105"
      :class="{ 'ring-2 ring-n-blue-9': activeFilter === 'all' }"
      @click="$emit('setFilter', 'all')"
    >
      <div class="flex items-center justify-between">
        <div>
          <p class="text-sm font-medium text-n-slate-11">
            Total de Contatos
          </p>
          <p class="text-2xl font-bold text-n-slate-12">
            {{ totalContacts }}
          </p>
        </div>
        <div class="w-12 h-12 bg-n-blue-2 rounded-full flex items-center justify-center">
          <span class="i-lucide-users size-6 text-n-blue-11" />
        </div>
      </div>
    </div>

    <!-- Contatos sem Empresa -->
    <div
      class="bg-n-solid-1 border border-n-weak rounded-lg p-4 cursor-pointer hover:shadow-lg transition-all duration-200 hover:scale-105"
      :class="{ 'ring-2 ring-n-amber-9': activeFilter === 'no_company' }"
      @click="$emit('setFilter', 'no_company')"
    >
      <div class="flex items-center justify-between">
        <div>
          <p class="text-sm font-medium text-n-slate-11">
            Sem Empresa
          </p>
          <p class="text-2xl font-bold text-n-amber-11">
            {{ contactsWithoutCompany }}
          </p>
          <p
            v-if="contactsEligibleForAutoFill > 0"
            class="text-xs text-n-green-11 mt-1"
          >
            {{ contactsEligibleForAutoFill }} podem ser preenchidos
          </p>
        </div>
        <div class="w-12 h-12 bg-n-amber-2 rounded-full flex items-center justify-center">
          <span class="i-lucide-building-2 size-6 text-n-amber-11" />
        </div>
      </div>
    </div>

    <!-- Contatos sem Número -->
    <div
      class="bg-n-solid-1 border border-n-weak rounded-lg p-4 cursor-pointer hover:shadow-lg transition-all duration-200 hover:scale-105"
      :class="{ 'ring-2 ring-n-ruby-9': activeFilter === 'no_phone' }"
      @click="$emit('setFilter', 'no_phone')"
    >
      <div class="flex items-center justify-between">
        <div>
          <p class="text-sm font-medium text-n-slate-11">
            Sem Número
          </p>
          <p class="text-2xl font-bold text-n-ruby-11">
            {{ contactsWithoutPhone }}
          </p>
        </div>
        <div class="w-12 h-12 bg-n-ruby-2 rounded-full flex items-center justify-center">
          <span class="i-lucide-phone size-6 text-n-ruby-11" />
        </div>
      </div>
    </div>

    <!-- Contatos com Número Inválido -->
    <div
      class="bg-n-solid-1 border border-n-weak rounded-lg p-4 cursor-pointer hover:shadow-lg transition-all duration-200 hover:scale-105"
      :class="{ 'ring-2 ring-n-amber-9': activeFilter === 'invalid_phone' }"
      @click="$emit('setFilter', 'invalid_phone')"
    >
      <div class="flex items-center justify-between">
        <div>
          <p class="text-sm font-medium text-n-slate-11">
            Número Inválido
          </p>
          <p class="text-2xl font-bold text-n-amber-11">
            {{ contactsWithInvalidPhone }}
          </p>
        </div>
        <div class="w-12 h-12 bg-n-amber-2 rounded-full flex items-center justify-center">
          <span class="i-lucide-alert-triangle size-6 text-n-amber-11" />
        </div>
      </div>
    </div>
  </div>
</template>
