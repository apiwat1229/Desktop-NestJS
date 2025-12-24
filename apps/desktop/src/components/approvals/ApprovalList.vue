<script setup lang="ts">
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import api from '@/services/api';
import { AlertCircle, CheckCircle2, Clock, XCircle } from 'lucide-vue-next';
import { toast } from 'vue-sonner';

interface ApprovalRequest {
  id: string;
  requestType: string;
  entityType: string;
  entityId: string;
  status: string;
  priority: string;
  submittedAt: string;
  requester: {
    displayName: string;
    email: string;
    role: string;
  };
  currentData: any;
  proposedData: any;
  reason?: string;
}

const props = defineProps<{
  resource?: string; // 'suppliers', 'rubberTypes', etc.
}>();

const emit = defineEmits<{
  refresh: [];
}>();

const approvals = ref<ApprovalRequest[]>([]);
const isLoading = ref(false);

const fetchApprovals = async () => {
  isLoading.value = true;
  try {
    const params: any = { status: 'PENDING' };
    if (props.resource) {
      params.entityType = props.resource;
    }
    const response = await api.get('/approvals', { params });
    approvals.value = response.data;
  } catch (error) {
    console.error('Failed to fetch approvals:', error);
    toast.error('Failed to load approval requests');
  } finally {
    isLoading.value = false;
  }
};

const handleApprove = async (id: string) => {
  try {
    await api.put(`/approvals/${id}/approve`, {
      remark: 'Approved',
    });
    toast.success('Request approved successfully');
    await fetchApprovals();
    emit('refresh');
  } catch (error) {
    console.error('Failed to approve:', error);
    toast.error('Failed to approve request');
  }
};

const handleReject = async (id: string) => {
  try {
    await api.put(`/approvals/${id}/reject`, {
      remark: 'Rejected',
    });
    toast.success('Request rejected');
    await fetchApprovals();
    emit('refresh');
  } catch (error) {
    console.error('Failed to reject:', error);
    toast.error('Failed to reject request');
  }
};

const getStatusBadge = (status: string) => {
  const variants: Record<string, any> = {
    PENDING: { variant: 'secondary', icon: Clock, label: 'Pending' },
    APPROVED: { variant: 'default', icon: CheckCircle2, label: 'Approved' },
    REJECTED: { variant: 'destructive', icon: XCircle, label: 'Rejected' },
  };
  return variants[status] || variants.PENDING;
};

onMounted(() => {
  fetchApprovals();
});
</script>

<template>
  <div class="space-y-4">
    <div v-if="isLoading" class="text-center py-8 text-muted-foreground">Loading approvals...</div>

    <div v-else-if="approvals.length === 0" class="text-center py-8 text-muted-foreground">
      <AlertCircle class="w-12 h-12 mx-auto mb-2 opacity-50" />
      <p>No pending approval requests</p>
    </div>

    <Card v-for="approval in approvals" :key="approval.id" class="overflow-hidden">
      <CardHeader class="pb-3">
        <div class="flex items-start justify-between">
          <div class="space-y-1">
            <CardTitle class="text-base">{{ approval.requestType }}</CardTitle>
            <CardDescription class="text-xs">
              Requested by {{ approval.requester.displayName }} ({{ approval.requester.role }})
            </CardDescription>
          </div>
          <Badge :variant="getStatusBadge(approval.status).variant" class="gap-1">
            <component :is="getStatusBadge(approval.status).icon" class="w-3 h-3" />
            {{ getStatusBadge(approval.status).label }}
          </Badge>
        </div>
      </CardHeader>

      <CardContent class="space-y-4">
        <!-- Changes Preview -->
        <div
          v-if="approval.proposedData"
          class="grid grid-cols-2 gap-4 p-3 bg-muted/30 rounded-md text-sm"
        >
          <div>
            <p class="font-semibold text-xs text-muted-foreground mb-2">Current</p>
            <pre class="text-xs">{{ JSON.stringify(approval.currentData, null, 2) }}</pre>
          </div>
          <div>
            <p class="font-semibold text-xs text-muted-foreground mb-2">Proposed</p>
            <pre class="text-xs">{{ JSON.stringify(approval.proposedData, null, 2) }}</pre>
          </div>
        </div>

        <!-- Reason -->
        <div v-if="approval.reason" class="text-sm">
          <span class="font-semibold">Reason:</span> {{ approval.reason }}
        </div>

        <!-- Actions -->
        <div v-if="approval.status === 'PENDING'" class="flex gap-2 pt-2">
          <Button size="sm" @click="handleApprove(approval.id)" class="flex-1">
            <CheckCircle2 class="w-4 h-4 mr-2" />
            Approve
          </Button>
          <Button size="sm" variant="destructive" @click="handleReject(approval.id)" class="flex-1">
            <XCircle class="w-4 h-4 mr-2" />
            Reject
          </Button>
        </div>
      </CardContent>
    </Card>
  </div>
</template>
