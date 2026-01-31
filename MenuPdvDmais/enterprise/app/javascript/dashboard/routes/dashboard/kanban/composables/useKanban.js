import { ref, computed } from "vue";
import KanbanCardsAPI from "dashboard/api/kanbanCards";
import KanbanColumnsAPI from "dashboard/api/kanbanColumns";

// Cache keys
const COLUMNS_CACHE_KEY = "kanban_comercial_columns";
const CARDS_CACHE_KEY = "kanban_comercial_cards";

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

  // Cache Logic
  const saveColumnsToCache = (data) => {
    const cacheData = {
      data: data,
      timestamp: Date.now(),
      expiry: Date.now() + 24 * 60 * 60 * 1000, // 24 hours
    };
    localStorage.setItem(COLUMNS_CACHE_KEY, JSON.stringify(cacheData));
  };

  const loadColumnsFromCache = () => {
    try {
      const cached = localStorage.getItem(COLUMNS_CACHE_KEY);
      if (!cached) return null;

      const cacheData = JSON.parse(cached);
      if (Date.now() > cacheData.expiry) {
        localStorage.removeItem(COLUMNS_CACHE_KEY);
        return null;
      }
      return cacheData.data;
    } catch (error) {
      console.warn("Error loading columns cache:", error);
      return null;
    }
  };

  const saveCardsToCache = (data) => {
    const cacheData = {
      data: data,
      timestamp: Date.now(),
      expiry: Date.now() + 60 * 60 * 1000, // 1 hour
    };
    localStorage.setItem(CARDS_CACHE_KEY, JSON.stringify(cacheData));
  };

  const loadCardsFromCache = () => {
    try {
      const cached = localStorage.getItem(CARDS_CACHE_KEY);
      if (!cached) return null;

      const cacheData = JSON.parse(cached);
      if (Date.now() > cacheData.expiry) {
        localStorage.removeItem(CARDS_CACHE_KEY);
        return null;
      }
      return cacheData.data;
    } catch (error) {
      console.warn("Error loading cards cache:", error);
      return null;
    }
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
      saveColumnsToCache(columns.value);
    } catch (error) {
      console.error("Error loading columns:", error);
      const cachedColumns = loadColumnsFromCache();
      if (cachedColumns) {
        columns.value = cachedColumns;
      } else {
        await initializeDefaultData();
      }
    }
  };

  const loadCards = async () => {
    try {
      const response = await KanbanCardsAPI.get();
      kanbanCards.value = response.data || [];
      saveCardsToCache(kanbanCards.value);
    } catch (error) {
      console.error("Error loading cards:", error);
      const cachedCards = loadCardsFromCache();
      if (cachedCards) {
        kanbanCards.value = cachedCards;
      }
    }
  };

  const loadData = async () => {
    loading.value = true;
    try {
      await loadColumns();
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
      const response = await KanbanCardsAPI.create(cardData);
      if (response.data) {
        kanbanCards.value.push(response.data);
        saveCardsToCache(kanbanCards.value);
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
        saveCardsToCache(kanbanCards.value);
      }
    } catch (error) {
      console.error("Error deleting card:", error);
      throw error;
    }
  };

  const updateCard = async (cardId, cardData) => {
    try {
      const response = await KanbanCardsAPI.update(cardId, cardData);
      if (response.data) {
        const index = kanbanCards.value.findIndex((c) => c.id === cardId);
        if (index !== -1) {
          kanbanCards.value[index] = response.data;
          saveCardsToCache(kanbanCards.value);
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
        saveColumnsToCache(columns.value);
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
          saveColumnsToCache(columns.value);
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
        saveColumnsToCache(columns.value);
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
        card.kanban_column_id = columnId;
        card.position = position;
        saveCardsToCache(kanbanCards.value);
        await KanbanCardsAPI.update(cardId, {
          kanban_card: { kanban_column_id: columnId, position },
        });
      }
    } catch (error) {
      console.error("Error updating card position:", error);
      loadCards(); // Revert on error
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
    createColumn,
    updateColumn,
    deleteColumn,
    updateCardPosition,
  };
}
