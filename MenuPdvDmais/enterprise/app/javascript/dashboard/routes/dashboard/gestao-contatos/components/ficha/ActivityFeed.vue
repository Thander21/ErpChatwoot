<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ficha/ActivityFeed.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: -
 * Description: (Adicionar descrição em português)
-->
<script setup>
defineProps({
  activities: { type: Array, default: () => [] },
  deploymentId: { type: Number, required: true },
});

defineEmits(["delete-activity"]);

const ACTIVITY_CONFIG = {
  visit: {
    icon: "🚗",
    label: "Visita",
    bg: "bg-blue-100 dark:bg-blue-900/30",
    text: "text-blue-600 dark:text-blue-400",
  },
  training: {
    icon: "🎓",
    label: "Treinamento",
    bg: "bg-purple-100 dark:bg-purple-900/30",
    text: "text-purple-600 dark:text-purple-400",
  },
  installation: {
    icon: "💻",
    label: "Instalação",
    bg: "bg-green-100 dark:bg-green-900/30",
    text: "text-green-600 dark:text-green-400",
  },
  support: {
    icon: "🛠️",
    label: "Suporte",
    bg: "bg-orange-100 dark:bg-orange-900/30",
    text: "text-orange-600 dark:text-orange-400",
  },
  call: {
    icon: "📞",
    label: "Ligação",
    bg: "bg-teal-100 dark:bg-teal-900/30",
    text: "text-teal-600 dark:text-teal-400",
  },
  note: {
    icon: "📝",
    label: "Nota",
    bg: "bg-gray-100 dark:bg-gray-700",
    text: "text-gray-600 dark:text-gray-400",
  },
  schedule: {
    icon: "📅",
    label: "Agendamento",
    bg: "bg-amber-100 dark:bg-amber-900/30",
    text: "text-amber-600 dark:text-amber-400",
  },
};

function activityIcon(type) {
  return ACTIVITY_CONFIG[type]?.icon || "•";
}
function activityLabel(type) {
  return ACTIVITY_CONFIG[type]?.label || type;
}
function activityBgColor(type) {
  return ACTIVITY_CONFIG[type]?.bg || "bg-gray-100";
}
function activityTextColor(type) {
  return ACTIVITY_CONFIG[type]?.text || "text-gray-600";
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
      class="text-center py-8 text-slate-400 text-sm"
    >
      Nenhuma atividade registrada ainda
    </div>

    <!-- Feed vertical móbile-first -->
    <div class="relative">
      <!-- Linha vertical da timeline -->
      <div
        class="absolute left-5 top-0 bottom-0 w-0.5 bg-gray-200 dark:bg-slate-700"
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
            class="flex-1 bg-white dark:bg-slate-800 border border-gray-100 dark:border-slate-700 rounded-xl p-3 min-w-0"
          >
            <div class="flex items-start justify-between gap-2 mb-1">
              <span
                class="text-xs font-semibold uppercase tracking-wide"
                :class="activityTextColor(activity.activity_type)"
              >
                {{ activityLabel(activity.activity_type) }}
              </span>
              <button
                class="opacity-0 group-hover:opacity-100 hover:opacity-100 p-1 text-red-400 hover:text-red-600 rounded transition-all shrink-0"
                title="Remover"
                @click="$emit('delete-activity', activity.id)"
              >
                <svg
                  class="w-3.5 h-3.5"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
                  />
                </svg>
              </button>
            </div>

            <p
              class="text-sm text-slate-700 dark:text-slate-300 leading-relaxed"
            >
              {{ activity.description }}
            </p>

            <div
              class="flex items-center justify-between mt-2 text-xs text-slate-400 dark:text-slate-500"
            >
              <span>📅 {{ formatDateTime(activity.occurred_at) }}</span>
              <span v-if="activity.duration_minutes"
                >⏱️ {{ activity.duration_minutes }}min</span
              >
            </div>
            <div class="text-xs text-slate-400 mt-1">
              👤 {{ activity.user?.name }}
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
