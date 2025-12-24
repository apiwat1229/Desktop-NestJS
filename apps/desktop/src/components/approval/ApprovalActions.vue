<script setup lang="ts">
import { Button } from '@/components/ui/button';
import { ArrowLeft, Ban, CheckCircle2, Edit, Slash, XCircle } from 'lucide-vue-next';
import { computed } from 'vue';

const props = defineProps<{
  request: any;
  currentUserId: string;
  currentUserRole: string;
}>();

const emit = defineEmits<{
  approve: [];
  reject: [];
  return: [];
  cancel: [];
  void: [];
  edit: [];
}>();

// Check if user is the requester
const isRequester = computed(() => props.request.requesterId === props.currentUserId);

// Check if user is admin/manager
const isApprover = computed(() => {
  return ['ADMIN', 'admin', 'MANAGER', 'manager'].includes(props.currentUserRole);
});

// Show approve/reject/return buttons (for approvers on pending requests)
const canApprove = computed(() => {
  return props.request.status === 'PENDING' && isApprover.value;
});

// Show cancel button (for requesters on pending requests)
const canCancel = computed(() => {
  return props.request.status === 'PENDING' && isRequester.value;
});

// Show void button (for admins on approved requests)
const canVoid = computed(() => {
  return props.request.status === 'APPROVED' && ['ADMIN', 'admin'].includes(props.currentUserRole);
});

// Show edit button (for requesters on returned requests)
const canEdit = computed(() => {
  return props.request.status === 'RETURNED' && isRequester.value;
});
</script>

<template>
  <div class="flex flex-wrap gap-2">
    <!-- Approve Button -->
    <Button v-if="canApprove" @click="emit('approve')" class="bg-green-600 hover:bg-green-700">
      <CheckCircle2 class="w-4 h-4 mr-2" />
      อนุมัติ
    </Button>

    <!-- Reject Button -->
    <Button v-if="canApprove" @click="emit('reject')" variant="destructive">
      <XCircle class="w-4 h-4 mr-2" />
      ปฏิเสธ
    </Button>

    <!-- Return Button -->
    <Button
      v-if="canApprove"
      @click="emit('return')"
      variant="outline"
      class="border-blue-500 text-blue-600 hover:bg-blue-50"
    >
      <ArrowLeft class="w-4 h-4 mr-2" />
      ส่งคืนแก้ไข
    </Button>

    <!-- Cancel Button -->
    <Button v-if="canCancel" @click="emit('cancel')" variant="outline">
      <Ban class="w-4 h-4 mr-2" />
      ยกเลิกคำขอ
    </Button>

    <!-- Void Button -->
    <Button v-if="canVoid" @click="emit('void')" variant="destructive">
      <Slash class="w-4 h-4 mr-2" />
      ทำเป็นโมฆะ
    </Button>

    <!-- Edit Button -->
    <Button v-if="canEdit" @click="emit('edit')" variant="default">
      <Edit class="w-4 h-4 mr-2" />
      แก้ไขคำขอ
    </Button>

    <!-- No actions available -->
    <p
      v-if="!canApprove && !canCancel && !canVoid && !canEdit"
      class="text-sm text-muted-foreground"
    >
      ไม่มีการดำเนินการที่สามารถทำได้
    </p>
  </div>
</template>
