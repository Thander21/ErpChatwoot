<!--
ERP Chatwoot - Kanban Index Component
Projeto: ERP Kanban para Chatwoot Enterprise
Arquivo: Index.vue
Descrição: Componente principal da página de kanban
Autor: Thander21
Data: 2024
Versão: 1.0.0
-->

<template>
  <div class="flex flex-col gap-4">
    <div class="flex items-center gap-3 mb-4">
      <h1 class="text-3xl font-bold text-slate-900 dark:text-white">
        Kanban
      </h1>
    </div>

    <!-- Abas Responsivas -->
    <div class="border-b border-gray-200 dark:border-slate-700 mb-6">
      <nav class="-mb-px flex flex-col sm:flex-row space-y-2 sm:space-y-0 sm:space-x-8">
        <button
          @click="activeTab = 'tarefa'"
          :class="[
            'whitespace-nowrap py-2 px-4 sm:px-1 border-b-2 font-medium text-sm transition-colors duration-200 flex items-center justify-center sm:justify-start gap-2',
            activeTab === 'tarefa'
              ? 'border-blue-500 text-blue-600 dark:text-blue-400 bg-blue-50 dark:bg-blue-900/20'
              : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 dark:text-slate-400 dark:hover:text-slate-300'
          ]"
        >
          <span class="text-lg">📋</span>
          <span>Tarefas</span>
        </button>
        <button
          @click="activeTab = 'comercial'"
          :class="[
            'whitespace-nowrap py-2 px-4 sm:px-1 border-b-2 font-medium text-sm transition-colors duration-200 flex items-center justify-center sm:justify-start gap-2',
            activeTab === 'comercial'
              ? 'border-blue-500 text-blue-600 dark:text-blue-400 bg-blue-50 dark:bg-blue-900/20'
              : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 dark:text-slate-400 dark:hover:text-slate-300'
          ]"
        >
          <span class="text-lg">💼</span>
          <span>Comercial</span>
        </button>
      </nav>
    </div>

    <!-- Conteúdo das Abas -->
    <div v-if="activeTab === 'tarefa'" class="kanban-content">
      <KanbanTarefa />
    </div>

    <div v-if="activeTab === 'comercial'" class="kanban-content">
      <KanbanComercial />
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useI18n } from 'vue-i18n';
import KanbanTarefa from './components/KanbanTarefa.vue';
import KanbanComercial from './components/KanbanComercial.vue';

const { t } = useI18n();

// Estado da aba ativa
const activeTab = ref('tarefa');
</script>
