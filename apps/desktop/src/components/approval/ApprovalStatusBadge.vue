<script setup lang="ts">
import { Badge } from '@/components/ui/badge';
import {
  AlertTriangle,
  ArrowLeft,
  Ban,
  CheckCircle2,
  Clock,
  Slash,
  XCircle,
} from 'lucide-vue-next';
import { computed } from 'vue';
import { useI18n } from 'vue-i18n';

const props = defineProps<{
  status: string;
}>();

const { t } = useI18n();

const statusConfig = computed(() => {
  const configs: Record<string, { label: string; variant: string; icon: any }> = {
    PENDING: {
      label: t('approval.status.pending'),
      variant: 'warning',
      icon: Clock,
    },
    APPROVED: {
      label: t('approval.status.approved'),
      variant: 'success',
      icon: CheckCircle2,
    },
    REJECTED: {
      label: t('approval.status.rejected'),
      variant: 'destructive',
      icon: XCircle,
    },
    RETURNED: {
      label: t('approval.status.returned'),
      variant: 'info',
      icon: ArrowLeft,
    },
    CANCELLED: {
      label: t('approval.status.cancelled'),
      variant: 'secondary',
      icon: Ban,
    },
    VOID: {
      label: t('approval.status.void'),
      variant: 'destructive',
      icon: Slash,
    },
    EXPIRED: {
      label: t('approval.status.expired'),
      variant: 'secondary',
      icon: AlertTriangle,
    },
  };

  return configs[props.status] || configs.PENDING;
});
</script>

<template>
  <Badge :variant="statusConfig.variant" class="inline-flex items-center gap-1.5">
    <component :is="statusConfig.icon" class="w-3.5 h-3.5" />
    {{ statusConfig.label }}
  </Badge>
</template>

<style scoped>
/* Custom badge variants */
:deep(.badge) {
  font-weight: 500;
}
</style>
