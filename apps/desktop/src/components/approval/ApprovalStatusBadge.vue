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

const props = defineProps<{
  status: string;
}>();

const statusConfig = computed(() => {
  const configs: Record<string, { label: string; variant: string; icon: any }> = {
    PENDING: {
      label: 'รออนุมัติ',
      variant: 'warning',
      icon: Clock,
    },
    APPROVED: {
      label: 'อนุมัติแล้ว',
      variant: 'success',
      icon: CheckCircle2,
    },
    REJECTED: {
      label: 'ปฏิเสธ',
      variant: 'destructive',
      icon: XCircle,
    },
    RETURNED: {
      label: 'ส่งคืนแก้ไข',
      variant: 'info',
      icon: ArrowLeft,
    },
    CANCELLED: {
      label: 'ยกเลิก',
      variant: 'secondary',
      icon: Ban,
    },
    VOID: {
      label: 'โมฆะ',
      variant: 'destructive',
      icon: Slash,
    },
    EXPIRED: {
      label: 'หมดอายุ',
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
