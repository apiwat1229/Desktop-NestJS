<script setup lang="ts">
import { Button } from '@/components/ui/button';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import approvalsApi from '@/services/approvals';
import { handleApiError } from '@/utils/errorHandler';
import { Ban, Loader2 } from 'lucide-vue-next';
import { ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { toast } from 'vue-sonner';

const props = defineProps<{
  requestId: string;
}>();

const emit = defineEmits<{
  success: [];
}>();

const isOpen = defineModel<boolean>('open');
const { t } = useI18n();
const reason = ref('');
const isLoading = ref(false);

const handleCancel = async () => {
  try {
    isLoading.value = true;

    await approvalsApi.cancel(props.requestId, {
      reason: reason.value || undefined,
    });

    toast.success(t('approval.dialogs.cancel.success'));

    emit('success');
    isOpen.value = false;
    reason.value = '';
  } catch (err: any) {
    handleApiError(err, t('approval.dialogs.cancel.error'));
  } finally {
    isLoading.value = false;
  }
};
</script>

<template>
  <Dialog v-model:open="isOpen">
    <DialogContent>
      <DialogHeader>
        <DialogTitle>{{ t('approval.dialogs.cancel.title') }}</DialogTitle>
        <DialogDescription>{{ t('approval.dialogs.cancel.description') }}</DialogDescription>
      </DialogHeader>

      <div class="space-y-4">
        <div>
          <Label>{{ t('approval.dialogs.cancel.reasonLabel') }}</Label>
          <Textarea
            v-model="reason"
            :placeholder="t('approval.dialogs.cancel.reasonPlaceholder')"
            :disabled="isLoading"
          />
        </div>
      </div>

      <DialogFooter>
        <Button variant="outline" @click="isOpen = false" :disabled="isLoading">{{
          t('approval.dialogs.cancel.close')
        }}</Button>
        <Button variant="destructive" @click="handleCancel" :disabled="isLoading">
          <Loader2 v-if="isLoading" class="w-4 h-4 mr-2 animate-spin" />
          <Ban v-else class="w-4 h-4 mr-2" />
          {{ isLoading ? t('approval.dialogs.cancel.processing') : t('approval.actions.cancel') }}
        </Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>
