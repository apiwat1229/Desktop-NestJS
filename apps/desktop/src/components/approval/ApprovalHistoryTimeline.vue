<script setup lang="ts">
import { Badge } from '@/components/ui/badge';
import { Card, CardContent } from '@/components/ui/card';
import {
  AlertTriangle,
  ArrowLeft,
  Ban,
  CheckCircle2,
  Clock,
  Plus,
  Slash,
  XCircle,
} from 'lucide-vue-next';
import { useI18n } from 'vue-i18n';

const props = defineProps<{
  history: any[];
}>();

const { t } = useI18n();

const actionConfig: Record<string, { label: string; icon: any; color: string }> = {
  CREATED: { label: t('approval.history.created'), icon: Plus, color: 'text-blue-600' },
  APPROVED: { label: t('approval.history.approved'), icon: CheckCircle2, color: 'text-green-600' },
  REJECTED: { label: t('approval.history.rejected'), icon: XCircle, color: 'text-red-600' },
  RETURNED: { label: t('approval.history.returned'), icon: ArrowLeft, color: 'text-blue-600' },
  CANCELLED: { label: t('approval.history.cancelled'), icon: Ban, color: 'text-gray-600' },
  VOIDED: { label: t('approval.history.voided'), icon: Slash, color: 'text-red-600' },
  EXPIRED: { label: t('approval.history.expired'), icon: AlertTriangle, color: 'text-orange-600' },
  DELETED: { label: t('approval.history.deleted'), icon: XCircle, color: 'text-gray-600' },
};

const formatDate = (dateString: string) => {
  const date = new Date(dateString);
  return new Intl.DateTimeFormat('th-TH', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  }).format(date);
};

const getConfig = (action: string) => {
  return actionConfig[action] || { label: action, icon: Clock, color: 'text-gray-600' };
};
</script>

<template>
  <div class="space-y-4">
    <div v-if="history.length === 0" class="text-center py-8 text-muted-foreground">
      {{ t('approval.noHistory') }}
    </div>

    <!-- Timeline -->
    <div v-else class="relative space-y-6">
      <!-- Timeline line -->
      <div class="absolute left-4 top-0 bottom-0 w-0.5 bg-border" />

      <!-- Timeline items -->
      <div v-for="(log, index) in history" :key="log.id" class="relative pl-12">
        <!-- Timeline dot -->
        <div
          class="absolute left-0 w-8 h-8 rounded-full bg-background border-2 border-border flex items-center justify-center"
          :class="getConfig(log.action).color"
        >
          <component :is="getConfig(log.action).icon" class="w-4 h-4" />
        </div>

        <!-- Timeline content -->
        <Card>
          <CardContent class="pt-4">
            <div class="flex items-start justify-between mb-2">
              <div>
                <h4 class="font-semibold" :class="getConfig(log.action).color">
                  {{ getConfig(log.action).label }}
                </h4>
                <p class="text-sm text-muted-foreground">
                  {{ formatDate(log.createdAt) }}
                </p>
              </div>
              <Badge variant="outline">
                {{ log.actorRole }}
              </Badge>
            </div>

            <div class="space-y-2">
              <p class="text-sm">
                <span class="font-medium">{{ t('approval.history.performedBy') }}:</span>
                {{ log.actorName }}
              </p>

              <p v-if="log.remark" class="text-sm">
                <span class="font-medium">{{ t('approval.history.note') }}:</span>
                {{ log.remark }}
              </p>

              <!-- Show changes if available -->
              <div v-if="log.oldValue || log.newValue" class="mt-3 pt-3 border-t">
                <p class="text-xs font-medium text-muted-foreground mb-2">
                  {{ t('approval.history.changes') }}:
                </p>
                <div class="grid grid-cols-2 gap-2 text-xs">
                  <div v-if="log.oldValue && Object.keys(log.oldValue).length > 0">
                    <p class="font-medium text-muted-foreground mb-1">
                      {{ t('approval.history.before') }}:
                    </p>
                    <pre class="bg-muted p-2 rounded text-xs overflow-auto">{{
                      JSON.stringify(log.oldValue, null, 2)
                    }}</pre>
                  </div>
                  <div v-if="log.newValue && Object.keys(log.newValue).length > 0">
                    <p class="font-medium text-muted-foreground mb-1">
                      {{ t('approval.history.after') }}:
                    </p>
                    <pre class="bg-muted p-2 rounded text-xs overflow-auto">{{
                      JSON.stringify(log.newValue, null, 2)
                    }}</pre>
                  </div>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  </div>
</template>
