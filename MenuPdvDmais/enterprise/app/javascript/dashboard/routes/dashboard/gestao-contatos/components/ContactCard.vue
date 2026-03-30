<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ContactCard.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: -
 * Description: (Adicionar descrição em português)
-->
<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ContactCard.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue, vue-router
 * Calls: -
 * Description: Cartão individual encapsulado para renderizar e editar detalhes de um contato na Ficha ou Grid.
-->
<script setup>
import { ref } from "vue";
import { useRoute } from "vue-router";
import WootButton from "dashboard/components-next/button/Button.vue";
import WootInput from "dashboard/components-next/input/Input.vue";

const props = defineProps({
  contact: { type: Object, required: true },
});

const emit = defineEmits(["save", "delete"]);

const route = useRoute();

const isExpanded = ref(false);
const isDeleteConfirmOpen = ref(false);
const isSaving = ref(false);
const editForm = ref({});

function getContactUrl(id) {
  return `/app/accounts/${route.params.accountId}/contacts/${id}`;
}

function getInitials(name) {
  if (!name) return "";
  const parts = name.split(" ");
  if (parts.length > 1) {
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
  return name.slice(0, 2).toUpperCase();
}

function generateAvatarStyle(name) {
  const colors = [
    "#F87171",
    "#FB923C",
    "#FBBF24",
    "#34D399",
    "#60A5FA",
    "#818CF8",
    "#A78BFA",
    "#F472B6",
  ];
  let hash = 0;
  if (!name) return { backgroundColor: colors[0] };
  for (let i = 0; i < name.length; i++) {
    hash = name.charCodeAt(i) + ((hash << 5) - hash);
  }
  const color = colors[Math.abs(hash) % colors.length];
  return { backgroundColor: color, color: "#fff" };
}

function toggleCard() {
  isExpanded.value = !isExpanded.value;
  if (isExpanded.value) {
    editForm.value = {
      name: props.contact.name,
      email: props.contact.email,
      phone_number: props.contact.phone_number,
      company_name:
        props.contact.additional_attributes?.company_name ||
        props.contact.company_name ||
        "",
      city: props.contact.additional_attributes?.city || "",
      bio: props.contact.additional_attributes?.bio || "",
    };
    isDeleteConfirmOpen.value = false;
  }
}

async function handleSave() {
  if (isSaving.value) return;
  isSaving.value = true;

  const payload = {
    name: editForm.value.name,
    email: editForm.value.email,
    phone_number: editForm.value.phone_number,
    additional_attributes: {
      ...props.contact.additional_attributes,
      company_name: editForm.value.company_name,
      city: editForm.value.city,
      bio: editForm.value.bio,
    },
  };

  try {
    // We emit a promise to let the parent handle the API call, so we can await it here and reset state.
    await new Promise((resolve) =>
      emit("save", props.contact.id, payload, resolve),
    );
    isExpanded.value = false;
  } finally {
    isSaving.value = false;
  }
}
</script>

<template>
  <div
    class="flex flex-col w-full outline-1 outline outline-n-container group/cardLayout rounded-xl bg-n-solid-2 transition-all duration-200 hover:outline-n-brand hover:shadow-sm"
  >
    <!-- Card Header -->
    <div
      class="flex w-full gap-3 py-5 flex-row justify-between items-center px-6"
    >
      <div
        class="flex items-center justify-start flex-1 gap-4 filter hover:brightness-110 transition-all cursor-pointer"
        @click="toggleCard"
      >
        <!-- Avatar -->
        <div class="relative">
          <span
            class="relative inline-flex group/avatar z-0 flex-shrink-0"
            style="width: 48px; height: 48px"
          >
            <img
              v-if="contact.thumbnail"
              :src="contact.thumbnail"
              class="relative inline-flex items-center justify-center object-cover overflow-hidden font-medium rounded-full"
              style="width: 48px; height: 48px"
            />
            <span
              v-else
              role="img"
              class="relative inline-flex items-center justify-center object-cover overflow-hidden font-medium rounded-full"
              :style="generateAvatarStyle(contact.name)"
            >
              <span
                class="select-none text-white font-medium"
                style="font-size: 19.2px"
                >{{ getInitials(contact.name) }}</span
              >
            </span>
          </span>
        </div>

        <!-- Info -->
        <div class="flex flex-col gap-0.5 flex-1 cursor-pointer">
          <div class="flex flex-wrap items-center gap-x-4 gap-y-1">
            <span class="text-base font-medium truncate text-n-slate-12">
              {{ contact.name || "Sem Nome" }}
            </span>
          </div>
          <div
            class="flex flex-wrap items-center justify-start gap-x-3 gap-y-1"
          >
            <span
              v-if="contact.phone_number"
              class="text-sm truncate text-n-slate-11"
            >
              {{ contact.phone_number }}
            </span>
            <!-- View Details Link -->
            <a
              v-if="route.params.accountId"
              :href="getContactUrl(contact.id)"
              class="text-sm font-medium text-n-brand hover:underline ml-2"
              @click.stop
            >
              View details
            </a>
            <span
              v-if="contact.email"
              class="text-sm truncate text-n-slate-11 ml-2 border-l border-n-slate-4 pl-2"
            >
              {{ contact.email }}
            </span>
          </div>
        </div>
      </div>

      <!-- Toggle Button -->
      <div 
        @click.stop
        class="flex items-center"
      >
        <WootButton
          variant="ghost"
          color="slate"
          size="xs"
          @click="toggleCard"
        >
          <span
            class="i-lucide-chevron-down flex-shrink-0 transition-transform duration-200"
            :class="{ 'rotate-180': isExpanded }"
          />
        </WootButton>
      </div>
    </div>

    <!-- Expanded Content (Accordion) -->
    <div
      class="transition-all duration-300 ease-in-out grid overflow-hidden"
      :class="
        isExpanded ? 'grid-rows-[1fr] opacity-100' : 'grid-rows-[0fr] opacity-0'
      "
    >
      <div class="overflow-hidden">
        <div
          v-if="isExpanded"
          class="flex flex-col gap-6 p-6 border-t border-n-strong"
        >
          <!-- Inline Edit Form -->
          <div class="flex flex-col gap-6">
            <div class="flex flex-col items-start gap-2">
              <span class="py-1 text-sm font-medium text-n-slate-12"
                >Editar detalhes</span
              >
              <div class="grid w-full grid-cols-1 gap-4 sm:grid-cols-2">
                <div class="w-full">
                  <WootInput v-model="editForm.name" placeholder="Nome completo" class="w-full" />
                </div>
                <div class="w-full">
                  <WootInput v-model="editForm.email" placeholder="Email" class="w-full" />
                </div>
                <div class="w-full">
                  <WootInput v-model="editForm.phone_number" placeholder="Telefone" class="w-full" />
                </div>
                <div class="w-full">
                  <WootInput v-model="editForm.company_name" placeholder="Empresa" class="w-full" />
                </div>
                <div class="w-full">
                  <WootInput v-model="editForm.city" placeholder="Cidade" class="w-full" />
                </div>
                <div class="w-full">
                  <WootInput v-model="editForm.bio" placeholder="Bio" class="w-full" />
                </div>
              </div>
            </div>

            <!-- Actions -->
            <div>
              <WootButton
                :is-loading="isSaving"
                variant="solid"
                color="blue"
                size="sm"
                @click="handleSave"
              >
                Atualizar contato
              </WootButton>
            </div>
          </div>

          <!-- Delete Section -->
          <div>
            <div
              class="flex flex-col items-start border-t border-n-strong px-0 py-5 mt-4"
            >
              <WootButton
                variant="link"
                color="ruby"
                class="hover:!no-underline"
                @click="isDeleteConfirmOpen = !isDeleteConfirmOpen"
              >
                <div class="flex items-center gap-2">
                  <span class="min-w-0 truncate">Deletar contato</span>
                  <span
                    class="i-lucide-chevron-down flex-shrink-0 transition-transform"
                    :class="{ 'rotate-180': isDeleteConfirmOpen }"
                  />
                </div>
              </WootButton>

              <div
                class="transition-all duration-300 ease-in-out grid w-full overflow-hidden"
                :class="
                  isDeleteConfirmOpen
                    ? 'grid-rows-[1fr] opacity-100 mt-2'
                    : 'grid-rows-[0fr] opacity-0 mt-0'
                "
              >
                <div class="overflow-hidden min-h-0">
                  <span
                    class="inline-flex text-n-slate-11 text-sm items-center gap-1"
                  >
                    Essa ação é permanente.
                    <WootButton
                      variant="link"
                      color="ruby"
                      size="sm"
                      @click="$emit('delete', contact)"
                    >
                      Deletar agora
                    </WootButton>
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
