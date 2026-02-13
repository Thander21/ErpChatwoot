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
      :archived-url="archivedUrl"
      @create-card="openNewCardModal"
      @create-column="openNewColumnModal"
      @edit-column="openEditColumnModal"
      @delete-column="handleDeleteColumn"
      @add-card-to-column="openNewCardModalForColumn"
      @edit-card="openEditCardModal"
      @delete-card="handleDeleteCard"
      @archive-card="handleArchiveCard"
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
      @delete="handleDeleteCard"
      @archive="handleArchiveCard"
    />

    <KanbanColumnModal
      :show="showColumnModal"
      :initial-data="editingColumn"
      :loading="actionLoading"
      @close="closeColumnModal"
      @submit="handleColumnSubmit"
    />

    <!-- Confirm Modal -->
    <ConfirmModal
      :show="showConfirmModal"
      :title="confirmTitle"
      :message="confirmMessage"
      :user-name="currentUserName"
      :confirm-label="confirmLabel"
      :confirm-color="confirmColor"
      :loading="actionLoading"
      @confirm="handleConfirm"
      @cancel="closeConfirmModal"
    />
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from "vue";
import { useRoute } from "vue-router";
import { useStore } from "vuex";
import KanbanBoard from "./KanbanBoard.vue";
import KanbanCardModal from "./modais/KanbanCardModal.vue";
import KanbanColumnModal from "./modais/KanbanColumnModal.vue";
import ConfirmModal from "./modais/ConfirmModal.vue";
import { useKanban } from "../composables/useKanban";
import { emitter } from "shared/helpers/mitt";
import { BUS_EVENTS } from "shared/constants/busEvents";

const store = useStore();

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
  archiveCard,
} = useKanban();

// UI State
const showCardModal = ref(false);
const showColumnModal = ref(false);
const editingCard = ref(null);
const editingColumn = ref(null);
const actionLoading = ref(false);

// Confirm Modal State
const showConfirmModal = ref(false);
const confirmTitle = ref("");
const confirmMessage = ref("");
const confirmLabel = ref("Confirmar");
const confirmColor = ref("red");
const confirmAction = ref(null);
const confirmTarget = ref(null);

// Current User
const currentUserName = computed(() => {
  const user = store.getters.getCurrentUser;
  return user?.name || user?.email || "Usuário";
});

// Archived URL
const archivedUrl = computed(() => {
  const route = useRoute();
  return `/app/accounts/${route.params.accountId}/kanban/archived`;
});

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
        message: "Card atualizado com sucesso",
        type: "success",
      });
    } else {
      await createCard(cardData);
      emitter.emit(BUS_EVENTS.SHOW_ALERT, {
        message: "Card criado com sucesso",
        type: "success",
      });
    }
    closeCardModal();
  } catch (error) {
    emitter.emit(BUS_EVENTS.SHOW_ALERT, {
      message: "Erro ao salvar card",
      type: "error",
    });
  } finally {
    actionLoading.value = false;
  }
};

const handleDeleteCard = (card) => {
  confirmTitle.value = "Excluir Card";
  confirmMessage.value = `Tem certeza que deseja excluir o card "${card.title}"?`;
  confirmLabel.value = "Excluir";
  confirmColor.value = "red";
  confirmAction.value = "delete-card";
  confirmTarget.value = card;
  showConfirmModal.value = true;
};

const handleArchiveCard = (card) => {
  confirmTitle.value = "Arquivar Card";
  confirmMessage.value = `Tem certeza que deseja arquivar o card "${card.title}"?`;
  confirmLabel.value = "Arquivar";
  confirmColor.value = "green";
  confirmAction.value = "archive-card";
  confirmTarget.value = card;
  showConfirmModal.value = true;
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
      message: "Erro ao mover card",
      type: "error",
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
        message: "Coluna atualizada com sucesso",
        type: "success",
      });
    } else {
      await createColumn(columnData);
      emitter.emit(BUS_EVENTS.SHOW_ALERT, {
        message: "Coluna criada com sucesso",
        type: "success",
      });
    }
    closeColumnModal();
  } catch (error) {
    emitter.emit(BUS_EVENTS.SHOW_ALERT, {
      message: "Erro ao salvar coluna",
      type: "error",
    });
  } finally {
    actionLoading.value = false;
  }
};

const handleDeleteColumn = (column) => {
  confirmTitle.value = "Excluir Coluna";
  confirmMessage.value = `Tem certeza que deseja excluir a coluna "${column.name}"?`;
  confirmLabel.value = "Excluir";
  confirmColor.value = "red";
  confirmAction.value = "delete-column";
  confirmTarget.value = column;
  showConfirmModal.value = true;
};

const closeConfirmModal = () => {
  showConfirmModal.value = false;
  confirmAction.value = null;
  confirmTarget.value = null;
};

const handleConfirm = async () => {
  actionLoading.value = true;
  try {
    if (confirmAction.value === "delete-card") {
      await deleteCard(confirmTarget.value.id);
      emitter.emit(BUS_EVENTS.SHOW_ALERT, {
        message: "Card excluído com sucesso",
        type: "success",
      });
      await loadData(); // Reload to update count
    } else if (confirmAction.value === "archive-card") {
      await archiveCard(confirmTarget.value.id);
      emitter.emit(BUS_EVENTS.SHOW_ALERT, {
        message: "Card arquivado com sucesso",
        type: "success",
      });
      await loadData(); // Reload to update count
    } else if (confirmAction.value === "delete-column") {
      await deleteColumn(confirmTarget.value.id);
      emitter.emit(BUS_EVENTS.SHOW_ALERT, {
        message: "Coluna excluída com sucesso",
        type: "success",
      });
      await loadData();
    }
    closeConfirmModal();
  } catch (error) {
    emitter.emit(BUS_EVENTS.SHOW_ALERT, {
      message: "Erro ao executar ação",
      type: "error",
    });
  } finally {
    actionLoading.value = false;
  }
};

onMounted(() => {
  loadData();
});
</script>
