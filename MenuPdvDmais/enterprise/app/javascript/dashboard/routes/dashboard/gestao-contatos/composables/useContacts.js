/*
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/composables/useContacts.js
 * Last Modified: 21/03/2026
 * Dependencies: -
 * Calls: -
 * Description: (Adicionar descrição em português)
 */
import { ref, computed } from "vue";
import { useStore } from "vuex";
import CustomContactsAPI from "dashboard/api/customContacts";

export function useContacts() {
  const store = useStore();
  const contacts = ref([]);
  const loading = ref(false);
  const searchQuery = ref("");
  const companySearchQuery = ref("");
  const activeFilter = ref("all");
  const expandedCompanies = ref(new Set());

  // Cache configuration
  const CACHE_KEY = "erp_contacts_cache";
  const CACHE_EXPIRY_HOURS = 24;

  const saveToCache = (data) => {
    const cacheData = {
      data: data,
      timestamp: Date.now(),
      expiry: Date.now() + CACHE_EXPIRY_HOURS * 60 * 60 * 1000,
    };
    localStorage.setItem(CACHE_KEY, JSON.stringify(cacheData));
  };

  const loadFromCache = () => {
    try {
      const cached = localStorage.getItem(CACHE_KEY);
      if (!cached) return null;

      const cacheData = JSON.parse(cached);
      if (Date.now() > cacheData.expiry) {
        localStorage.removeItem(CACHE_KEY);
        return null;
      }

      return cacheData.data;
    } catch (error) {
      /* debug removed */
      return null;
    }
  };

  const clearCache = () => {
    localStorage.removeItem(CACHE_KEY);
  };

  // Helpers
  const getCompanyName = (contact) => {
    return (
      contact.company?.name || contact.additional_attributes?.company_name || ""
    );
  };

  const formatDate = (dateString) => {
    if (!dateString) return "";
    return new Date(dateString).toLocaleDateString("pt-BR");
  };

  const isInvalidPhone = (phone) => {
    if (!phone || phone.trim() === "") return false;
    const cleanPhone = phone.replace(/\D/g, "");

    // Validar formato internacional ou brasileiro
    const startsWith55 = cleanPhone.startsWith("55") && cleanPhone.length >= 12;
    const isValidFormat = /^\+?55?\d{10,11}$/.test(cleanPhone) || startsWith55;

    // Nota: A lógica original considerava !isValidFormat como true para isInvalidPhone
    return !isValidFormat;
  };

  // API Actions
  const fetchContacts = async (forceRefresh = false) => {
    loading.value = true;
    try {
      if (!forceRefresh) {
        const cachedData = loadFromCache();
        if (cachedData) {
          contacts.value = cachedData;
          loading.value = false;
          return;
        }
      }

      const accountId = store.getters.getCurrentAccountId;
      const response = await CustomContactsAPI.getContacts(accountId, { all: true });

      let pageData = [];
      if (response.data && Array.isArray(response.data)) {
        pageData = response.data;
      } else if (response.data && Array.isArray(response.data.payload)) {
        pageData = response.data.payload;
      } else if (response && Array.isArray(response.payload)) {
        pageData = response.payload;
      }

      contacts.value = pageData;
      saveToCache(pageData);
    } catch (error) {
      /* debug removed */
    } finally {
      loading.value = false;
    }
  };

  const refreshContacts = async () => {
    clearCache();
    await fetchContacts(true);
  };

  const updateContact = async (contactId, updateData) => {
    const accountId = store.getters.getCurrentAccountId;
    await CustomContactsAPI.updateContact(accountId, contactId, updateData);

    const index = contacts.value.findIndex((c) => c.id === contactId);
    if (index !== -1) {
      contacts.value[index] = {
        ...contacts.value[index],
        ...updateData,
        additional_attributes: {
          ...contacts.value[index].additional_attributes,
          ...updateData.additional_attributes,
        },
      };
      saveToCache(contacts.value);
    }
  };

  const deleteContact = async (contactId) => {
    const accountId = store.getters.getCurrentAccountId;
    await CustomContactsAPI.deleteContact(accountId, contactId);

    const index = contacts.value.findIndex((c) => c.id === contactId);
    if (index !== -1) {
      contacts.value.splice(index, 1);
      saveToCache(contacts.value);
    }
  };

  // Computed Logic
  const filteredContacts = computed(() => {
    let filtered = contacts.value;

    if (activeFilter.value !== "all") {
      filtered = filtered.filter((contact) => {
        switch (activeFilter.value) {
          case "no_company":
            return !getCompanyName(contact);
          case "no_phone":
            return !contact.phone_number || contact.phone_number.trim() === "";
          case "invalid_phone":
            return isInvalidPhone(contact.phone_number);
          default:
            return true;
        }
      });
    }

    if (searchQuery.value.trim()) {
      const query = searchQuery.value.toLowerCase().trim();
      filtered = filtered.filter((contact) => {
        const name = (contact.name || "").toLowerCase();
        const email = (contact.email || "").toLowerCase();
        const phone = (contact.phone_number || "").toLowerCase();

        return (
          name.includes(query) ||
          email.includes(query) ||
          phone.includes(query)
        );
      });
    }

    if (companySearchQuery.value.trim()) {
      const companyQuery = companySearchQuery.value.toLowerCase().trim();
      filtered = filtered.filter((contact) => {
        const company = (getCompanyName(contact) || "").toLowerCase();
        return company.includes(companyQuery);
      });
    }

    return filtered;
  });

  const contactsByCompany = computed(() => {
    const grouped = {};

    // Sempre agrupa usando filteredContacts (aplica busca e filtros dentro dos grupos)
    filteredContacts.value.forEach((contact) => {
      const companyName = getCompanyName(contact) || "Empresa não informada";
      if (!grouped[companyName]) {
        grouped[companyName] = {
          name: companyName,
          contacts: [],
          // Constrói o objeto company para abrir a Ficha do Cliente
          company: {
            name: companyName,
            id: contact.company_id || contact.company?.id || null,
          },
        };
      }
      grouped[companyName].contacts.push(contact);
    });

    return Object.values(grouped).sort((a, b) => {
      if (a.name === "Empresa não informada") return 1;
      if (b.name === "Empresa não informada") return -1;
      return a.name.localeCompare(b.name);
    });
  });

  // Stats
  const contactsWithoutCompany = computed(
    () => contacts.value.filter((c) => !getCompanyName(c)).length,
  );

  const contactsWithoutPhone = computed(
    () =>
      contacts.value.filter(
        (c) => !c.phone_number || c.phone_number.trim() === "",
      ).length,
  );

  const contactsWithInvalidPhone = computed(
    () => contacts.value.filter((c) => isInvalidPhone(c.phone_number)).length,
  );

  const contactsEligibleForAutoFill = computed(() => {
    return contacts.value.filter((contact) => {
      if (getCompanyName(contact)) return false;
      if (!contact.name || !contact.name.includes(" - ")) return false;
      const parts = contact.name.split(" - ");
      return parts.length === 2 && parts[1].trim() !== "";
    }).length;
  });

  return {
    contacts,
    loading,
    searchQuery,
    companySearchQuery,
    activeFilter,
    expandedCompanies,
    filteredContacts,
    contactsByCompany,
    // Stats
    totalContacts: computed(() => contacts.value.length),
    contactsWithoutCompany,
    contactsWithoutPhone,
    contactsWithInvalidPhone,
    contactsEligibleForAutoFill,
    // Actions
    fetchContacts,
    refreshContacts,
    updateContact,
    deleteContact,
    getCompanyName,
    formatDate,
    isInvalidPhone,
  };
}
