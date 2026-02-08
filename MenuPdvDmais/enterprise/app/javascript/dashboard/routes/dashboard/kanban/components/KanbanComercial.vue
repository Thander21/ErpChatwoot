<!--
  ERP Chatwoot - Kanban Comercial View
  Controls business logic for Commercial Kanban and passes data to generic KanbanBoard.
-->
<template>
  <div class="h-full">
    <KanbanBoard
      title="Kanban Comercial"
      :columns="columns"
      :cards="kanbanCards"
      :loading="loading"
      :can-create-column="true"
      :can-create-card="true"
      :show-priority-color="true"
      @create-card="openNewCardModal"
      @create-column="openNewColumnModal"
      @edit-column="openEditColumnModal"
      @delete-column="handleDeleteColumn"
      @add-card-to-column="openNewCardModalForColumn"
      @edit-card="openEditCardModal"
      @delete-card="handleDeleteCard"
      @card-moved="handleCardMoved"
    />

    <!-- Modals -->
    <KanbanCardModal
      :show="showCardModal"
      :columns="sortedColumns"
      :initial-data="editingCard"
      :loading="actionLoading"
      @close="closeCardModal"
      @submit="handleCardSubmit"
    />

    <KanbanColumnModal
      :show="showColumnModal"
      :initial-data="editingColumn"
      :loading="actionLoading"
      @close="closeColumnModal"
      @submit="handleColumnSubmit"
    />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import KanbanBoard from './KanbanBoard.vue';
import KanbanCardModal from './modais/KanbanCardModal.vue';
import KanbanColumnModal from './modais/KanbanColumnModal.vue';
import { useKanban } from '../composables/useKanban';
import { emitter } from 'shared/helpers/mitt';
import { BUS_EVENTS } from 'shared/constants/busEvents';

const {
  columns,
  kanbanCards,
  loading,
  sortedColumns,
  getCardsByColumn, // Not used directly in template but available
  loadData,
  createCard,
  updateCard,
  updateCardPosition,
  deleteCard,
  createColumn,
  updateColumn,
  deleteColumn,
} = useKanban();

// UI State
const showCardModal = ref(false);
const showColumnModal = ref(false);
const editingCard = ref(null);
const editingColumn = ref(null);
const actionLoading = ref(false);

// Actions
const openNewCardModal = () => {
  editingCard.value = null;
  showCardModal.value = true;
};

const openNewCardModalForColumn = (columnId) => {
  editingCard.value = { kanban_column_id: columnId };
  showCardModal.value = true;
};

const openEditCardModal = (card) => {
  editingCard.value = { ...card };
  showCardModal.value = true;
};

const closeCardModal = () => {
  showCardModal.value = false;
  editingCard.value = null;
};

const handleCardSubmit = async (cardData) => {
  actionLoading.value = true;
  try {
    if (editingCard.value && editingCard.value.id) {
       await updateCard(editingCard.value.id, cardData);
       emitter.emit(BUS_EVENTS.SHOW_ALERT, {
         message: 'Card atualizado com sucesso',
         type: 'success',
       });
    } else {
       await createCard(cardData);
       emitter.emit(BUS_EVENTS.SHOW_ALERT, {
         message: 'Card criado com sucesso',
         type: 'success',
       });
    }
    closeCardModal();
  } catch (error) {
    emitter.emit(BUS_EVENTS.SHOW_ALERT, {
      message: 'Erro ao salvar card',
      type: 'error',
    });
  } finally {
    actionLoading.value = false;
  }
};

const handleDeleteCard = async (card) => {
  if (confirm('Tem certeza que deseja excluir este card?')) {
    try {
      await deleteCard(card.id);
      emitter.emit(BUS_EVENTS.SHOW_ALERT, {
        message: 'Card excluído com sucesso',
        type: 'success',
      });
    } catch (error) {
      emitter.emit(BUS_EVENTS.SHOW_ALERT, {
        message: 'Erro ao excluir card',
        type: 'error',
      });
    }
  }
};

const handleCardMoved = async ({ card, targetColumnId }) => {
  // Calculate new position
  // We need to know cards in target column to determine position
  // useKanban has getCardsByColumn helper
  const cardsInTarget = kanbanCards.value
    .filter((c) => c.kanban_column_id === targetColumnId)
    .sort((a, b) => (a.position || 0) - (b.position || 0));
    
  const newPosition = cardsInTarget.length;

  try {
    await updateCardPosition(card.id, targetColumnId, newPosition);
  } catch (error) {
    emitter.emit(BUS_EVENTS.SHOW_ALERT, {
      message: 'Erro ao mover card',
      type: 'error',
    });
  }
};

// Column Actions
const openNewColumnModal = () => {
  editingColumn.value = null;
  showColumnModal.value = true;
};

const openEditColumnModal = (column) => {
  editingColumn.value = { ...column };
  showColumnModal.value = true;
};

const closeColumnModal = () => {
  showColumnModal.value = false;
  editingColumn.value = null;
};

const handleColumnSubmit = async (columnData) => {
  actionLoading.value = true;
  try {
    if (editingColumn.value && editingColumn.value.id) {
      await updateColumn(editingColumn.value.id, columnData);
      emitter.emit(BUS_EVENTS.SHOW_ALERT, {
        message: 'Coluna atualizada com sucesso',
        type: 'success',
      });
    } else {
      await createColumn(columnData);
      emitter.emit(BUS_EVENTS.SHOW_ALERT, {
        message: 'Coluna criada com sucesso',
        type: 'success',
      });
    }
    closeColumnModal();
  } catch (error) {
    emitter.emit(BUS_EVENTS.SHOW_ALERT, {
      message: 'Erro ao salvar coluna',
      type: 'error',
    });
  } finally {
    actionLoading.value = false;
  }
};

const handleDeleteColumn = async (column) => {
  if (confirm(`Tem certeza que deseja excluir a coluna "${column.name}"?`)) {
    try {
      await deleteColumn(column.id);
      emitter.emit(BUS_EVENTS.SHOW_ALERT, {
        message: 'Coluna excluída com sucesso',
        type: 'success',
      });
    } catch (error) {
      emitter.emit(BUS_EVENTS.SHOW_ALERT, {
        message: 'Erro ao excluir coluna',
        type: 'error',
      });
    }
  }
};

onMounted(() => {
  loadData();
});
</script>
