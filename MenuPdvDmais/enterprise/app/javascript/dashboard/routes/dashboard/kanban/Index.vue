<!--
ERP Chatwoot - Kanban Index Component
-->

<script setup>
import { ref } from "vue";
import KanbanTarefa from "./components/KanbanTarefa.vue";
import KanbanComercial from "./components/KanbanComercial.vue";
import Tabs from 'dashboard/components/ui/Tabs/Tabs.vue';
import TabsItem from 'dashboard/components/ui/Tabs/TabsItem.vue';

// Estado da aba ativa (0: Tarefa, 1: Comercial)
const activeTab = ref(1);
const tabs = [
  { key: 'tarefa', name: 'Tarefas', icon: 'clipboard-task-list-ltr' },
  { key: 'comercial', name: 'Comercial', icon: 'briefcase' }
];

const onTabChange = (index) => {
  activeTab.value = index;
};
</script>

<template>
  <div class="flex flex-col h-full bg-white dark:bg-slate-900 p-4">
    <!-- Abas -->
    <div class="mb-4">
      <Tabs :index="activeTab" @change="onTabChange">
        <TabsItem 
          v-for="(tab, index) in tabs" 
          :key="tab.key" 
          :index="index" 
          :name="tab.name"
          :show-badge="false"
          :is-compact="true"
        />
      </Tabs>
    </div>

    <!-- Conteúdo das Abas -->
    <div v-if="activeTab === 0" class="flex-1 overflow-hidden">
      <KanbanTarefa />
    </div>

    <div v-if="activeTab === 1" class="flex-1 overflow-hidden">
      <KanbanComercial />
    </div>
  </div>
</template>
