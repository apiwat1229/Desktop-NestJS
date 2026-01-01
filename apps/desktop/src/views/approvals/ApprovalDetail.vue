<script setup lang="ts">
import ApprovalActions from '@/components/approval/ApprovalActions.vue';
import ApprovalHistoryTimeline from '@/components/approval/ApprovalHistoryTimeline.vue';
import ApprovalStatusBadge from '@/components/approval/ApprovalStatusBadge.vue';
import VoidedWatermark from '@/components/approval/VoidedWatermark.vue';
import ApproveDialog from '@/components/approval/dialogs/ApproveDialog.vue';
import CancelDialog from '@/components/approval/dialogs/CancelDialog.vue';
import RejectDialog from '@/components/approval/dialogs/RejectDialog.vue';
import ReturnDialog from '@/components/approval/dialogs/ReturnDialog.vue';
import VoidDialog from '@/components/approval/dialogs/VoidDialog.vue';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Label } from '@/components/ui/label';
import approvalsApi, { type ApprovalLog, type ApprovalRequest } from '@/services/approvals';
import { useAuthStore } from '@/stores/auth';
import { handleApiError } from '@/utils/errorHandler';
import { ArrowLeft } from 'lucide-vue-next';
import { computed, onMounted, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRoute, useRouter } from 'vue-router';

const route = useRoute();
const router = useRouter();
const authStore = useAuthStore();

const request = ref<ApprovalRequest | null>(null);
const history = ref<ApprovalLog[]>([]);
const isLoading = ref(false);

// Dialog states
const showApproveDialog = ref(false);
const showRejectDialog = ref(false);
const showVoidDialog = ref(false);
const showCancelDialog = ref(false);
const showReturnDialog = ref(false);

const { t } = useI18n();

const currentUser = computed(() => authStore.user);
const isVoided = computed(() => request.value?.status === 'VOID');

const fetchRequest = async () => {
  try {
    isLoading.value = true;
    const id = route.params.id as string;

    const [requestRes, historyRes] = await Promise.all([
      approvalsApi.getOne(id),
      approvalsApi.getHistory(id),
    ]);

    request.value = requestRes.data;
    history.value = historyRes.data;
  } catch (error: any) {
    handleApiError(error, t('approval.detail.loadError'));
    router.push('/approvals');
  } finally {
    isLoading.value = false;
  }
};

const formatDate = (dateString?: string) => {
  if (!dateString) return '-';
  const date = new Date(dateString);
  return new Intl.DateTimeFormat('th-TH', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  }).format(date);
};

const handleSuccess = () => {
  fetchRequest();
};

onMounted(() => {
  fetchRequest();
});
</script>

<template>
  <div v-if="request" class="space-y-6">
    <!-- Back Button -->
    <Button variant="ghost" @click="router.push('/approvals')">
      <ArrowLeft class="w-4 h-4 mr-2" />
      {{ t('approval.detail.backToList') }}
    </Button>

    <!-- Header -->
    <VoidedWatermark :is-voided="isVoided">
      <div class="flex justify-between items-start">
        <div>
          <h1
            class="text-3xl font-bold"
            :class="{ 'line-through text-muted-foreground': isVoided }"
          >
            {{ request.requestType }}
          </h1>
          <p class="text-muted-foreground">ID: {{ request.id }}</p>
          <Badge v-if="isVoided" variant="destructive" class="mt-2">{{
            t('approval.detail.voidBadge')
          }}</Badge>
        </div>
        <ApprovalStatusBadge :status="request.status" />
      </div>
    </VoidedWatermark>

    <!-- Request Details -->
    <VoidedWatermark :is-voided="isVoided">
      <Card>
        <CardHeader>
          <CardTitle>{{ t('approval.detail.requestDetails') }}</CardTitle>
        </CardHeader>
        <CardContent class="space-y-4">
          <div class="grid grid-cols-2 gap-4">
            <div>
              <Label>{{ t('approval.detail.requestType') }}</Label>
              <p>{{ request.requestType }}</p>
            </div>
            <div>
              <Label>{{ t('approval.detail.entityType') }}</Label>
              <p>{{ request.entityType }}</p>
            </div>
            <div>
              <Label>{{ t('approval.detail.requester') }}</Label>
              <p>{{ request.requester?.displayName || request.requester?.email || '-' }}</p>
            </div>
            <div>
              <Label>{{ t('approval.detail.submittedDate') }}</Label>
              <p>{{ formatDate(request.submittedAt) }}</p>
            </div>
            <div v-if="request.approver">
              <Label>{{ t('approval.detail.approver') }}</Label>
              <p>{{ request.approver.displayName || request.approver.email }}</p>
            </div>
            <div v-if="request.actedAt">
              <Label>{{ t('approval.detail.actedDate') }}</Label>
              <p>{{ formatDate(request.actedAt) }}</p>
            </div>
            <div>
              <Label>{{ t('approval.detail.priority') }}</Label>
              <Badge :variant="request.priority === 'URGENT' ? 'destructive' : 'secondary'">
                {{ request.priority }}
              </Badge>
            </div>
            <div v-if="request.expiresAt">
              <Label>{{ t('approval.detail.expiresAt') }}</Label>
              <p>{{ formatDate(request.expiresAt) }}</p>
            </div>
          </div>

          <div v-if="request.reason">
            <Label>{{ t('approval.detail.reason') }}</Label>
            <p class="mt-1">{{ request.reason }}</p>
          </div>

          <div v-if="request.remark">
            <Label>{{ t('approval.detail.remark') }}</Label>
            <p class="mt-1">{{ request.remark }}</p>
          </div>

          <!-- Show Current Data -->
          <div v-if="request.currentData && Object.keys(request.currentData).length > 0">
            <Label>{{ t('approval.detail.currentData') }}</Label>
            <pre class="mt-2 p-4 bg-muted rounded text-sm overflow-auto">{{
              JSON.stringify(request.currentData, null, 2)
            }}</pre>
          </div>

          <!-- Show Proposed Changes -->
          <div v-if="request.proposedData && Object.keys(request.proposedData).length > 0">
            <Label>{{ t('approval.detail.proposedChanges') }}</Label>
            <pre class="mt-2 p-4 bg-muted rounded text-sm overflow-auto">{{
              JSON.stringify(request.proposedData, null, 2)
            }}</pre>
          </div>
        </CardContent>
      </Card>
    </VoidedWatermark>

    <!-- Actions -->
    <Card v-if="currentUser">
      <CardHeader>
        <CardTitle>{{ t('approval.detail.management') }}</CardTitle>
      </CardHeader>
      <CardContent>
        <ApprovalActions
          :request="request"
          :current-user-id="currentUser.id"
          :current-user-role="currentUser.role"
          @approve="showApproveDialog = true"
          @reject="showRejectDialog = true"
          @return="showReturnDialog = true"
          @cancel="showCancelDialog = true"
          @void="showVoidDialog = true"
        />
      </CardContent>
    </Card>

    <!-- History Timeline -->
    <Card>
      <CardHeader>
        <CardTitle>{{ t('approval.detail.history') }}</CardTitle>
      </CardHeader>
      <CardContent>
        <ApprovalHistoryTimeline :history="history" />
      </CardContent>
    </Card>

    <!-- Dialogs -->
    <ApproveDialog
      v-model:open="showApproveDialog"
      :request-id="request.id"
      @success="handleSuccess"
    />
    <RejectDialog
      v-model:open="showRejectDialog"
      :request-id="request.id"
      @success="handleSuccess"
    />
    <VoidDialog v-model:open="showVoidDialog" :request-id="request.id" @success="handleSuccess" />
    <CancelDialog
      v-model:open="showCancelDialog"
      :request-id="request.id"
      @success="handleSuccess"
    />
    <ReturnDialog
      v-model:open="showReturnDialog"
      :request-id="request.id"
      @success="handleSuccess"
    />
  </div>

  <!-- Loading State -->
  <div v-else-if="isLoading" class="flex items-center justify-center min-h-[400px]">
    <p class="text-muted-foreground">{{ t('common.loading') }}</p>
  </div>
</template>
