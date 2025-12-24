<script setup lang="ts">
import ApprovalStatusBadge from '@/components/approval/ApprovalStatusBadge.vue';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import DataTable from '@/components/ui/data-table/DataTable.vue';
import { Label } from '@/components/ui/label';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Switch } from '@/components/ui/switch';
import approvalsApi, { type ApprovalRequest } from '@/services/approvals';
import { handleApiError } from '@/utils/errorHandler';
import { h, onMounted, ref } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();
const approvals = ref<ApprovalRequest[]>([]);
const isLoading = ref(false);

// Filters
const filters = ref({
  status: '',
  showDeleted: false,
});

const columns = [
  {
    accessorKey: 'requestType',
    header: 'ประเภท',
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
    header: 'สถานะ',
    cell: ({ row }: any) => h(ApprovalStatusBadge, { status: row.original.status }),
  },
  {
    accessorKey: 'requester',
    header: 'ผู้ขอ',
    cell: ({ row }: any) =>
      row.original.requester?.displayName || row.original.requester?.email || '-',
  },
  {
    accessorKey: 'submittedAt',
    header: 'วันที่ส่ง',
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
    header: 'จัดการ',
    cell: ({ row }: any) =>
      h(
        Button,
        {
          size: 'sm',
          onClick: () => router.push(`/approvals/${row.original.id}`),
        },
        () => 'ดูรายละเอียด'
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
    handleApiError(error, 'ไม่สามารถโหลดรายการคำขอได้');
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
        <h1 class="text-3xl font-bold">คำขออนุมัติ</h1>
        <p class="text-muted-foreground">จัดการคำขออนุมัติทั้งหมด</p>
      </div>
    </div>

    <!-- Filters -->
    <Card>
      <CardHeader>
        <CardTitle>ตัวกรอง</CardTitle>
        <CardDescription>กรองรายการคำขออนุมัติ</CardDescription>
      </CardHeader>
      <CardContent>
        <div class="flex flex-wrap gap-4">
          <!-- Status Filter -->
          <div class="w-64">
            <Label>สถานะ</Label>
            <Select v-model="filters.status" @update:model-value="fetchApprovals">
              <SelectTrigger>
                <SelectValue placeholder="ทุกสถานะ" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="">ทุกสถานะ</SelectItem>
                <SelectItem value="PENDING">รออนุมัติ</SelectItem>
                <SelectItem value="APPROVED">อนุมัติแล้ว</SelectItem>
                <SelectItem value="REJECTED">ปฏิเสธ</SelectItem>
                <SelectItem value="RETURNED">ส่งคืนแก้ไข</SelectItem>
                <SelectItem value="CANCELLED">ยกเลิก</SelectItem>
                <SelectItem value="VOID">โมฆะ</SelectItem>
                <SelectItem value="EXPIRED">หมดอายุ</SelectItem>
              </SelectContent>
            </Select>
          </div>

          <!-- Show Deleted Toggle -->
          <div class="flex items-end gap-2">
            <div class="flex items-center gap-2">
              <Switch
                :checked="filters.showDeleted"
                @update:checked="
                  (val) => {
                    filters.showDeleted = val;
                    fetchApprovals();
                  }
                "
              />
              <Label>แสดงรายการที่ถูกลบ</Label>
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
