<!--
 * File: MenuPdvDmais/enterprise/app/javascript/dashboard/routes/dashboard/gestao-contatos/components/ficha/ScheduleCard.vue
 * Last Modified: 21/03/2026
 * Dependencies: vue
 * Calls: -
 * Description: (Adicionar descrição em português)
-->
<script setup>
import { computed } from "vue";

const props = defineProps({
  schedule: { type: Object, required: true },
});

function formatDateTime(dateStr) {
  if (!dateStr) return "";
  return new Date(dateStr).toLocaleString("pt-BR", {
    weekday: "short",
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}

const daysUntil = computed(() => {
  const diff = new Date(props.schedule.occurred_at) - new Date();
  return Math.ceil(diff / (1000 * 60 * 60 * 24));
});

const urgencyLabel = computed(() => {
  if (daysUntil.value < 0) return "⚠️ Atrasada";
  if (daysUntil.value === 0) return "🔴 Hoje!";
  if (daysUntil.value === 1) return "🟡 Amanhã";
  if (daysUntil.value <= 7) return `🟢 Em ${daysUntil.value} dias`;
  return `Em ${daysUntil.value} dias`;
});

const urgencyClass = computed(() => {
  if (daysUntil.value < 0) return "text-red-500 font-semibold";
  if (daysUntil.value <= 1) return "text-orange-500 font-semibold";
  return "text-slate-400";
});
</script>

<template>
  <div
    class="bg-white dark:bg-slate-800 border border-amber-200 dark:border-amber-700 rounded-xl p-4"
  >
    <div class="flex items-start gap-3">
      <div
        class="w-10 h-10 bg-amber-100 dark:bg-amber-900/30 rounded-xl flex items-center justify-center text-xl shrink-0"
      >
        📅
      </div>
      <div class="flex-1 min-w-0">
        <p class="text-sm font-semibold text-slate-800 dark:text-slate-200">
          {{ formatDateTime(schedule.occurred_at) }}
        </p>
        <p class="text-sm text-slate-600 dark:text-slate-400 mt-1 line-clamp-3">
          {{ schedule.description }}
        </p>
        <div class="flex items-center gap-3 mt-2 text-xs text-slate-400">
          <span v-if="schedule.user">👤 {{ schedule.user.name }}</span>
          <span v-if="schedule.duration_minutes"
            >⏱️ {{ schedule.duration_minutes }}min</span
          >
          <span :class="urgencyClass">{{ urgencyLabel }}</span>
        </div>
      </div>
    </div>
  </div>
</template>
