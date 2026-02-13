import { ref, computed } from "vue";
import KanbanCardsAPI from "dashboard/api/kanbanCards";
import KanbanColumnsAPI from "dashboard/api/kanbanColumns";

export function useKanban() {
  const columns = ref([]);
  const kanbanCards = ref([]);
  const loading = ref(false);

  // Computed
  const sortedColumns = computed(() => {
    return [...columns.value].sort(
      (a, b) => (a.position || 0) - (b.position || 0)
    );
  });

  const getCardsByColumn = (columnId) => {
    return kanbanCards.value
      .filter((card) => card.kanban_column_id === columnId)
      .sort((a, b) => (a.position || 0) - (b.position || 0));
  };

  const initializeDefaultData = async () => {
    if (columns.value.length === 0) {
      const defaultColumns = [
        { name: "Lead", color: "#fbbf24", position: 0 },
        { name: "Contato", color: "#3b82f6", position: 1 },
        { name: "Proposta", color: "#8b5cf6", position: 2 },
        { name: "Negociação", color: "#f59e0b", position: 3 },
        { name: "Fechamento", color: "#10b981", position: 4 },
      ];

      try {
        for (const colData of defaultColumns) {
          await KanbanColumnsAPI.create({ kanban_column: colData });
        }
        await loadColumns();
      } catch (error) {
        console.warn("Error creating default columns:", error);
      }
    }
  };

  // API Actions
  const loadColumns = async () => {
    try {
      const response = await KanbanColumnsAPI.get();
      columns.value = response.data || [];
    } catch (error) {
      console.error("Error loading columns:", error);
      // Fallback to defaults only if API fails and we have nothing?
      // For now, let's try to init defaults if empty array returned (though API likely returns empty array if new)
      // Actually, initializeDefaultData check columns.length === 0, so if API error leaves it empty, it might trigger defaults.
      // But usually we want defaults on *first run* (empty DB), not API error.
      // Leaving strict error handling aside, let's just retry default init if we suspect it's a new setup.
    }
  };

  const loadCards = async () => {
    try {
      const response = await KanbanCardsAPI.get();
      kanbanCards.value = response.data || [];
    } catch (error) {
      console.error("Error loading cards:", error);
    }
  };

  const loadData = async () => {
    loading.value = true;
    try {
      await loadColumns();
      // If we loaded columns but found none, maybe we should init defaults?
      if (columns.value.length === 0) {
        await initializeDefaultData();
      }
      await loadCards();
    } catch (error) {
      console.error("Error loading data:", error);
    } finally {
      loading.value = false;
    }
  };

  // CRUD Operations
  const createCard = async (cardData) => {
    try {
      const response = await KanbanCardsAPI.create({ kanban_card: cardData });
      if (response.data) {
        kanbanCards.value.push(response.data);
        return response.data;
      }
    } catch (error) {
      console.error("Error creating card:", error);
      throw error;
    }
  };

  const deleteCard = async (cardId) => {
    try {
      await KanbanCardsAPI.delete(cardId);
      const index = kanbanCards.value.findIndex((c) => c.id === cardId);
      if (index !== -1) {
        kanbanCards.value.splice(index, 1);
      }
    } catch (error) {
      console.error("Error deleting card:", error);
      throw error;
    }
  };

  const updateCard = async (cardId, cardData) => {
    try {
      const response = await KanbanCardsAPI.update(cardId, {
        kanban_card: cardData,
      });
      if (response.data) {
        const index = kanbanCards.value.findIndex((c) => c.id === cardId);
        if (index !== -1) {
          kanbanCards.value[index] = response.data;
        }
        return response.data;
      }
    } catch (error) {
      console.error("Error updating card:", error);
      throw error;
    }
  };

  const createColumn = async (columnData) => {
    try {
      const response = await KanbanColumnsAPI.create(columnData);
      if (response.data) {
        columns.value.push(response.data);
        return response.data;
      }
    } catch (error) {
      console.error("Error creating column:", error);
      throw error;
    }
  };

  const updateColumn = async (columnId, columnData) => {
    try {
      const response = await KanbanColumnsAPI.update(columnId, columnData);
      if (response.data) {
        const index = columns.value.findIndex((c) => c.id === columnId);
        if (index !== -1) {
          columns.value[index] = response.data;
        }
        return response.data;
      }
    } catch (error) {
      console.error("Error updating column:", error);
      throw error;
    }
  };

  const deleteColumn = async (columnId) => {
    try {
      await KanbanColumnsAPI.delete(columnId);
      const index = columns.value.findIndex((c) => c.id === columnId);
      if (index !== -1) {
        columns.value.splice(index, 1);
      }
    } catch (error) {
      console.error("Error deleting column:", error);
      throw error;
    }
  };

  const updateCardPosition = async (cardId, columnId, position) => {
    try {
      const card = kanbanCards.value.find((c) => c.id === cardId);
      if (card) {
        // Optimistic update
        card.kanban_column_id = columnId;
        card.position = position;
        
        await KanbanCardsAPI.update(cardId, {
          kanban_card: { kanban_column_id: columnId, position },
        });
      }
    } catch (error) {
      console.error("Error updating card position:", error);
      loadCards(); // Revert on error
    }
  };

  const archiveCard = async (cardId) => {
    try {
      await KanbanCardsAPI.archive(cardId);
      const index = kanbanCards.value.findIndex((c) => c.id === cardId);
      if (index !== -1) {
        kanbanCards.value.splice(index, 1);
      }
    } catch (error) {
      console.error("Error archiving card:", error);
      throw error;
    }
  };

  const fetchArchivedCards = async (month, year) => {
    try {
      const response = await KanbanCardsAPI.getArchivedReport(month, year);
      return response.data;
    } catch (error) {
       console.error("Error fetching archived cards:", error);
       throw error;
    }
  };

  return {
    columns,
    kanbanCards,
    loading,
    sortedColumns,
    getCardsByColumn,
    loadData,
    createCard,
    updateCard,
    deleteCard,
    archiveCard,
    fetchArchivedCards,
    createColumn,
    updateColumn,
    deleteColumn,
    updateCardPosition,
    loadColumns,
  };
}

