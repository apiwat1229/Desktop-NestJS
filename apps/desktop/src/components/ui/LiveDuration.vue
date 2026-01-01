<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref } from 'vue';
import { useI18n } from 'vue-i18n';

const props = defineProps<{
  start: string | Date;
  end?: string | Date | null;
}>();

const { t } = useI18n();

const now = ref(new Date());
let timer: any = null;

const updateNow = () => {
  now.value = new Date();
};

onMounted(() => {
  if (!props.end) {
    updateNow();
    timer = setInterval(updateNow, 1000);
  }
});

onUnmounted(() => {
  if (timer) clearInterval(timer);
});

const durationText = computed(() => {
  const startDate = new Date(props.start);
  const endDate = props.end ? new Date(props.end) : now.value;

  if (isNaN(startDate.getTime())) return '-';

  // Calculate difference in milliseconds
  const diff = endDate.getTime() - startDate.getTime();
  if (diff < 0) return '00 ' + t('liveDuration.min');

  // formatting
  const minutes = Math.floor(diff / 60000); // Total minutes

  const h = Math.floor(minutes / 60);
  const m = minutes % 60;

  if (h > 0) {
    return `${h} ${t('liveDuration.hr')} ${m} ${t('liveDuration.min')}`;
  }
  return `${m} ${t('liveDuration.min')}`;
});
</script>

<template>
  <span :class="{ 'text-orange-600 font-medium': !end, 'text-foreground': end }">
    {{ durationText }}
  </span>
</template>
