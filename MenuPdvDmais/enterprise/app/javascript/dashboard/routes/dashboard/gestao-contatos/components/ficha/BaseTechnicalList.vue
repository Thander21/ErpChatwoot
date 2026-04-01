<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ficha/BaseTechnicalList.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: -
 * Description: (Adicionar descrição em português)
-->
<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ficha/BaseTechnicalList.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: -
 * Description: Wrapper genérico das abas da Ficha, contendo UI padronizada.
-->
<script setup>
import { computed, ref, watch } from "vue";
import WootButton from "dashboard/components-next/button/Button.vue";

const props = defineProps({
  title: { type: String, required: true },
  icon: { type: String, default: "" },
  items: { type: Array, default: () => [] },
  emptyText: { type: String, default: "Nenhum registro encontrado" },
  theme: { type: String, default: "blue" }, // blue, purple, green, orange
  showForm: { type: Boolean, default: false },
});

defineEmits(["update:showForm"]);

const themes = {
  blue: "blue",
  purple: "blue", // Woot doesn't have purple, mapping to primary
  green: "teal",
  orange: "amber",
};

const themeColor = computed(() => {
  return themes[props.theme] || "blue";
});

// --- PAGINAÇÃO E ORDENAÇÃO ---
const currentPage = ref(1);
const itemsPerPage = 3;

// Monitora mudanças nos itens para resetar a página para 1 se adicionarem algo novo
watch(
  () => props.items,
  () => {
    currentPage.value = 1;
  },
  { deep: true },
);

// Ordena os itens do mais recente para o mais antigo (baseado nos campos de data comuns)
const sortedItems = computed(() => {
  if (!props.items) return [];
  return [...props.items].sort((a, b) => {
    const dateA = new Date(
      a.trained_at ||
        a.installed_at ||
        a.occurred_at ||
        a.created_at ||
        a.updated_at ||
        0,
    );
    const dateB = new Date(
      b.trained_at ||
        b.installed_at ||
        b.occurred_at ||
        b.created_at ||
        b.updated_at ||
        0,
    );
    return dateB - dateA;
  });
});

const totalPages = computed(
  () => Math.ceil(sortedItems.value.length / itemsPerPage) || 1,
);

const displayedItems = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage;
  return sortedItems.value.slice(start, start + itemsPerPage);
});

function prevPage() {
  if (currentPage.value > 1) currentPage.value--;
}

function nextPage() {
  if (currentPage.value < totalPages.value) currentPage.value++;
}
</script>

<template>
  <div class="flex-1 flex flex-col min-h-0 p-4 pt-2">
    <!-- Header Padronizado -->
    <div class="flex items-center justify-between mb-4 shrink-0">
      <h3 class="text-sm font-semibold text-n-slate-12">
        {{ title }}
      </h3>
      <WootButton
        v-if="!showForm"
        :color="themeColor"
        icon="plus"
        size="sm"
        @click="$emit('update:showForm', true)"
      >
        Adicionar
      </WootButton>
    </div>

    <!-- Formulário no Topo -->
    <div
      v-if="showForm"
      class="bg-n-alpha-black2 border border-n-weak rounded-xl p-4 space-y-3 mb-4 shrink-0"
    >
      <slot name="form" />
    </div>

    <!-- Área da Lista (Gerenciada via Paginação JS) -->
    <div class="flex-1 pr-1 space-y-3 pb-2 pt-2">
      <!-- Lista Vazia -->
      <div
        v-if="items.length === 0 && !showForm"
        class="text-center py-6 text-n-slate-11 text-sm italic"
      >
        <div v-if="icon" class="mb-2 text-3xl opacity-50">{{ icon }}</div>
        {{ emptyText }}
      </div>

      <!-- Lista de Itens Paginados -->
      <div
        v-for="item in displayedItems"
        :key="item.id"
        class="p-4 bg-n-surface-1 border border-n-weak rounded-xl shadow-sm"
      >
        <slot name="card" :item="item" />
      </div>

      <!-- Controles de Paginação -->
      <div
        v-if="totalPages > 1"
        class="flex items-center justify-between pt-3 mt-4 border-t border-n-weak"
      >
        <WootButton
          :disabled="currentPage === 1"
          variant="outline"
          color="slate"
          size="sm"
          @click="prevPage"
        >
          Anterior
        </WootButton>
        <span class="text-xs text-n-slate-11 font-medium">Página {{ currentPage }} de {{ totalPages }}</span>
        <WootButton
          :disabled="currentPage === totalPages"
          variant="outline"
          color="slate"
          size="sm"
          @click="nextPage"
        >
          Próximo
        </WootButton>
      </div>
    </div>
  </div>
</template>
