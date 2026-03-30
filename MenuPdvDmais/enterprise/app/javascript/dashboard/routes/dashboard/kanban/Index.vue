<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/kanban/Index.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: -
 * Description: (Adicionar descrição em português)
-->
<!--
ERP Chatwoot - Kanban Index Component
-->

<script setup>
import { ref } from "vue";
import KanbanTarefa from "./components/KanbanTarefa.vue";
import KanbanComercial from "./components/KanbanComercial.vue";
import Tabs from "dashboard/components/ui/Tabs/Tabs.vue";
import TabsItem from "dashboard/components/ui/Tabs/TabsItem.vue";

// Estado da aba ativa (0: Tarefa, 1: Comercial)
const activeTab = ref(1);
const tabs = [
  { key: "tarefa", name: "Tarefas", icon: "clipboard-task-list-ltr" },
  { key: "comercial", name: "Comercial", icon: "briefcase" },
];

const onTabChange = (index) => {
  activeTab.value = index;
};
</script>

<template>
  <div class="flex flex-col h-full bg-n-surface-1 p-4 overflow-x-auto">
    <!-- Abas -->
    <div class="mb-4 flex-shrink-0">
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
    <div v-if="activeTab === 0" class="flex-1 min-h-0">
      <KanbanTarefa />
    </div>

    <div v-if="activeTab === 1" class="flex-1 min-h-0">
      <KanbanComercial />
    </div>
  </div>
</template>
