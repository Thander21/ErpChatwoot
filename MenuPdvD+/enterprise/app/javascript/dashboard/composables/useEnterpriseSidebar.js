/**
 * ERP Chatwoot - Enterprise Sidebar Extensions
 * =============================================================================
 * Projeto: ERP Gestão de Contatos para Chatwoot Enterprise
 * Arquivo: useEnterpriseSidebar.js
 * Descrição: Composable que fornece itens de menu específicos da enterprise
 *            que são automaticamente mesclados com o menu padrão do sidebar
 * Autor: Thander21
 * Data: 2024
 * Versão: 1.0.0
 * =============================================================================
 */

 /**
 * Enterprise Sidebar Extensions
 *
 * This composable provides enterprise-specific sidebar menu items
 * that are automatically merged with the standard sidebar menu
 */

export function getEnterpriseSidebarItems() {
  return [
    {
      name: 'Gestão de Contatos',
      label: 'Gestão de Contatos',
      icon: 'i-lucide-folder-open',
      to: { name: 'gestao_contatos_index' },
      activeOn: ['gestao_contatos_index'],
    },
    {
      name: 'Kanban',
      label: 'Kanban',
      icon: 'i-lucide-trello',
      to: { name: 'kanban_index' },
      activeOn: ['kanban_index'],
    },
    {
      name: 'Boletos',
      label: 'Boletos',
      icon: 'i-lucide-receipt',
      to: { name: 'boletos_index' },
      activeOn: ['boletos_index'],
    },
  ];
}

/**
 * Hook to inject enterprise menu items into the sidebar
 * Usage: Call this in the Sidebar.vue menuItems computed property
 */
export function injectEnterpriseMenuItems(standardMenuItems) {
  const enterpriseItems = getEnterpriseSidebarItems();

  // Insert enterprise items after Conversation section (third position)
  const conversationIndex = standardMenuItems.findIndex(item => item.name === 'Conversation');

  if (conversationIndex !== -1) {
    return [
      ...standardMenuItems.slice(0, conversationIndex + 1),
      {
        name: 'PDv D+',
        label: 'PDv D+',
        icon: 'i-lucide-star',
        children: enterpriseItems,
      },
      ...standardMenuItems.slice(conversationIndex + 1),
    ];
  }

  // Fallback: insert after Reports if Conversation not found
  const reportsIndex = standardMenuItems.findIndex(item => item.name === 'Reports');
  if (reportsIndex !== -1) {
    return [
      ...standardMenuItems.slice(0, reportsIndex + 1),
      {
        name: 'PDv D+',
        label: 'PDv D+',
        icon: 'i-lucide-star',
        children: enterpriseItems,
      },
      ...standardMenuItems.slice(reportsIndex + 1),
    ];
  }

  return [...standardMenuItems, ...enterpriseItems];
}
