<script setup lang="ts">
import ApprovalStatusBadge from '@/components/approval/ApprovalStatusBadge.vue';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Checkbox } from '@/components/ui/checkbox';
import DataTable from '@/components/ui/data-table/DataTable.vue';
import { Label } from '@/components/ui/label';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import approvalsApi, { type ApprovalRequest } from '@/services/approvals';
import { handleApiError } from '@/utils/errorHandler';
import { h, onMounted, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';

const router = useRouter();
const approvals = ref<ApprovalRequest[]>([]);
const isLoading = ref(false);

// Filters
const filters = ref({
  status: '',
  showDeleted: false,
});

const { t } = useI18n();

const columns = [
  {
    accessorKey: 'requestType',
    header: t('approval.list.type'),
    cell: ({ row }: any) => {
      const isVoided = row.original.status === 'VOID';
      return h(
        'div',
        {
          class: isVoided ? 'line-through text-muted-foreground' : '',
        },
        row.original.requestType
      );
    },
  },
  {
    accessorKey: 'status',
    header: t('approval.list.status'),
    cell: ({ row }: any) => h(ApprovalStatusBadge, { status: row.original.status }),
  },
  {
    accessorKey: 'requester',
    header: t('approval.list.requester'),
    cell: ({ row }: any) =>
      row.original.requester?.displayName || row.original.requester?.email || '-',
  },
  {
    accessorKey: 'submittedAt',
    header: t('approval.list.submittedDate'),
    cell: ({ row }: any) => {
      const date = new Date(row.original.submittedAt);
      return new Intl.DateTimeFormat('th-TH', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
      }).format(date);
    },
  },
  {
    id: 'actions',
    header: t('approval.list.actions'),
    cell: ({ row }: any) =>
      h(
        Button,
        {
          size: 'sm',
          onClick: () => router.push(`/admin/approvals/${row.original.id}`),
        },
        () => t('approval.list.viewDetails')
      ),
  },
];

const fetchApprovals = async () => {
  try {
    isLoading.value = true;
    const response = await approvalsApi.getAll({
      status: filters.value.status || undefined,
      includeDeleted: filters.value.showDeleted,
    });
    approvals.value = response.data;
  } catch (error: any) {
    handleApiError(error, t('approval.list.loadError'));
  } finally {
    isLoading.value = false;
  }
};

onMounted(() => {
  fetchApprovals();
});
</script>

<template>
  <div class="space-y-6">
    <div class="flex justify-between items-center">
      <div>
        <h1 class="text-3xl font-bold">{{ t('approval.list.title') }}</h1>
        <p class="text-muted-foreground">{{ t('approval.list.description') }}</p>
      </div>
    </div>

    <!-- Filters -->
    <Card>
      <CardHeader>
        <CardTitle>{{ t('approval.list.filters') }}</CardTitle>
        <CardDescription>{{ t('approval.list.filterDescription') }}</CardDescription>
      </CardHeader>
      <CardContent>
        <div class="flex flex-wrap gap-4">
          <!-- Status Filter -->
          <div class="w-64">
            <Label>{{ t('approval.list.status') }}</Label>
            <Select v-model="filters.status" @update:model-value="fetchApprovals">
              <SelectTrigger>
                <SelectValue :placeholder="t('approval.list.allStatuses')" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="">{{ t('approval.list.allStatuses') }}</SelectItem>
                <SelectItem value="PENDING">{{ t('approval.status.pending') }}</SelectItem>
                <SelectItem value="APPROVED">{{ t('approval.status.approved') }}</SelectItem>
                <SelectItem value="REJECTED">{{ t('approval.status.rejected') }}</SelectItem>
                <SelectItem value="RETURNED">{{ t('approval.status.returned') }}</SelectItem>
                <SelectItem value="CANCELLED">{{ t('approval.status.cancelled') }}</SelectItem>
                <SelectItem value="VOID">{{ t('approval.status.void') }}</SelectItem>
                <SelectItem value="EXPIRED">{{ t('approval.status.expired') }}</SelectItem>
              </SelectContent>
            </Select>
          </div>

          <!-- Show Deleted Checkbox -->
          <div class="flex items-end gap-2">
            <div class="flex items-center gap-2">
              <Checkbox
                :checked="filters.showDeleted"
                @update:checked="
                  (val: boolean) => {
                    filters.showDeleted = val;
                    fetchApprovals();
                  }
                "
              />
              <Label>{{ t('approval.list.showDeleted') }}</Label>
            </div>
          </div>
        </div>
      </CardContent>
    </Card>

    <!-- Data Table -->
    <Card>
      <CardContent class="pt-6">
        <DataTable :columns="columns" :data="approvals" :loading="isLoading" />
      </CardContent>
    </Card>
  </div>
</template>
