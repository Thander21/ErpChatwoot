<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/boletos/Index.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: -
 * Description: (Adicionar descrição em português)
-->
<!--
ERP Chatwoot - Boletos Index Component
Projeto: ERP Boletos para Chatwoot Enterprise
Arquivo: Index.vue
Descrição: Componente principal da página de boletos com iframe
Autor: Thander21
Data: 2024
Versão: 1.0.0
-->

<script setup>
import { useI18n } from "vue-i18n";

const { t } = useI18n();
</script>

<template>
  <div class="h-full w-full bg-n-surface-1">
    <iframe
      src="https://personal-tggn0jb7.outsystemscloud.com/STICRM/ChatwootBoletos"
      class="w-full h-full border-0"
      title="Sistema de Boletos"
      sandbox="allow-scripts allow-forms allow-same-origin allow-popups allow-presentation allow-top-navigation"
    />
  </div>
</template>
