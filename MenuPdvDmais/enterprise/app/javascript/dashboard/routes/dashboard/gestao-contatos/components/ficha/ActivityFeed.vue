<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ficha/ActivityFeed.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: -
 * Description: (Adicionar descrição em português)
-->
<script setup>
import WootButton from "dashboard/components-next/button/Button.vue";

defineProps({
  activities: { type: Array, default: () => [] },
  deploymentId: { type: Number, required: true },
});

defineEmits(["delete-activity"]);

const ACTIVITY_CONFIG = {
  visit: {
    icon: "🚗",
    label: "Visita",
    bg: "bg-n-blue-3",
    text: "text-n-blue-11",
  },
  training: {
    icon: "🎓",
    label: "Treinamento",
    bg: "bg-n-alpha-black2",
    text: "text-n-slate-12",
  },
  installation: {
    icon: "💻",
    label: "Instalação",
    bg: "bg-n-green-3",
    text: "text-n-green-11",
  },
  support: {
    icon: "🛠️",
    label: "Suporte",
    bg: "bg-n-orange-3",
    text: "text-n-orange-11",
  },
  call: {
    icon: "📞",
    label: "Ligação",
    bg: "bg-n-teal-3",
    text: "text-n-teal-11",
  },
  note: {
    icon: "📝",
    label: "Nota",
    bg: "bg-n-slate-3",
    text: "text-n-slate-11",
  },
  schedule: {
    icon: "📅",
    label: "Agendamento",
    bg: "bg-n-amber-3",
    text: "text-n-amber-11",
  },
};

function activityIcon(type) {
  return ACTIVITY_CONFIG[type]?.icon || "•";
}
function activityLabel(type) {
  return ACTIVITY_CONFIG[type]?.label || type;
}
function activityBgColor(type) {
  return ACTIVITY_CONFIG[type]?.bg || "bg-n-slate-3";
}
function activityTextColor(type) {
  return ACTIVITY_CONFIG[type]?.text || "text-n-slate-11";
}

function formatDateTime(dateStr) {
  if (!dateStr) return "";
  return new Date(dateStr).toLocaleString("pt-BR", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}
</script>

<template>
  <div class="p-4">
    <div
      v-if="activities.length === 0"
      class="text-center py-8 text-n-slate-11 text-sm"
    >
      Nenhuma atividade registrada ainda
    </div>

    <!-- Feed vertical móbile-first -->
    <div class="relative">
      <!-- Linha vertical da timeline -->
      <div
        class="absolute left-5 top-0 bottom-0 w-0.5 bg-n-weak"
      />

      <div class="space-y-1">
        <div
          v-for="activity in activities"
          :key="activity.id"
          class="relative flex gap-4 pb-4"
        >
          <!-- Ícone do tipo -->
          <div
            class="relative z-10 w-10 h-10 rounded-full flex items-center justify-center text-lg shrink-0"
            :class="activityBgColor(activity.activity_type)"
          >
            {{ activityIcon(activity.activity_type) }}
          </div>

          <!-- Conteúdo -->
          <div
            class="flex-1 bg-n-surface-1 border border-n-weak rounded-xl p-3 min-w-0"
          >
            <div class="flex items-start justify-between gap-2 mb-1">
              <span
                class="text-xs font-semibold uppercase tracking-wide"
                :class="activityTextColor(activity.activity_type)"
              >
                {{ activityLabel(activity.activity_type) }}
              </span>
              <WootButton
                variant="ghost"
                color="ruby"
                size="sm"
                class="opacity-0 group-hover:opacity-100 p-1 shrink-0"
                icon="trash"
                title="Remover"
                @click="$emit('delete-activity', activity.id)"
              />
            </div>

            <p
              class="text-sm text-n-slate-12 leading-relaxed"
            >
              {{ activity.description }}
            </p>

            <div
              class="flex items-center justify-between mt-2 text-xs text-n-slate-10"
            >
              <span>📅 {{ formatDateTime(activity.occurred_at) }}</span>
              <span v-if="activity.duration_minutes"
                >⏱️ {{ activity.duration_minutes }}min</span
              >
            </div>
            <div class="text-xs text-n-slate-11 mt-1">
              👤 {{ activity.user?.name }}
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
