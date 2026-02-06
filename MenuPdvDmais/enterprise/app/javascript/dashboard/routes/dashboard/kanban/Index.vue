<!--
ERP Chatwoot - Kanban Index Component
-->

<template>
  <div class="flex flex-col h-full bg-white dark:bg-slate-900 p-4">
    <!-- Abas -->
    <div class="flex border-b border-slate-200 dark:border-slate-700 mb-6">
      <button
        @click="activeTab = 'tarefa'"
        class="pb-2 px-4 text-sm font-medium border-b-2 transition-colors duration-200 flex items-center gap-2"
        :class="[
          activeTab === 'tarefa'
            ? 'border-blue-600 text-blue-600 dark:text-blue-400'
            : 'border-transparent text-slate-500 hover:text-slate-700 dark:text-slate-400 dark:hover:text-slate-300',
        ]"
      >
        <span class="text-lg">📋</span>
        <span>Tarefas</span>
      </button>
      <button
        @click="activeTab = 'comercial'"
        class="pb-2 px-4 text-sm font-medium border-b-2 transition-colors duration-200 flex items-center gap-2"
        :class="[
          activeTab === 'comercial'
            ? 'border-blue-600 text-blue-600 dark:text-blue-400'
            : 'border-transparent text-slate-500 hover:text-slate-700 dark:text-slate-400 dark:hover:text-slate-300',
        ]"
      >
        <span class="text-lg">💼</span>
        <span>Comercial</span>
      </button>
    </div>

    <!-- Conteúdo das Abas -->
    <div v-if="activeTab === 'tarefa'" class="flex-1 overflow-hidden">
      <KanbanTarefa />
    </div>

    <div v-if="activeTab === 'comercial'" class="flex-1 overflow-hidden">
      <KanbanComercial />
    </div>
  </div>
</template>

<script setup>
import { ref } from "vue";
import KanbanTarefa from "./components/KanbanTarefa.vue";
import KanbanComercial from "./components/KanbanComercial.vue";

// Estado da aba ativa
const activeTab = ref("comercial");
</script>
