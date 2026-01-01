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
import { Loader2, Slash } from 'lucide-vue-next';
import { computed, ref } from 'vue';
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
const error = ref('');

const isFormValid = computed(() => reason.value.trim().length > 0);

const handleVoid = async () => {
  if (!isFormValid.value) {
    error.value = t('approval.dialogs.void.reasonRequired');
    return;
  }

  try {
    isLoading.value = true;
    error.value = '';

    await approvalsApi.void(props.requestId, {
      reason: reason.value,
    });

    toast.success(t('approval.dialogs.void.success'));

    emit('success');
    isOpen.value = false;
    reason.value = '';
  } catch (err: any) {
    handleApiError(err, t('approval.dialogs.void.error'));
  } finally {
    isLoading.value = false;
  }
};
</script>

<template>
  <Dialog v-model:open="isOpen">
    <DialogContent>
      <DialogHeader>
        <DialogTitle>{{ t('approval.dialogs.void.title') }}</DialogTitle>
        <DialogDescription class="text-red-600">
          {{ t('approval.dialogs.void.warning') }}
        </DialogDescription>
      </DialogHeader>

      <div class="space-y-4">
        <div>
          <Label>{{ t('approval.dialogs.void.reasonLabel') }}</Label>
          <Textarea
            v-model="reason"
            :placeholder="t('approval.dialogs.void.reasonPlaceholder')"
            :disabled="isLoading"
            required
          />
          <p v-if="error" class="text-sm text-red-600 mt-1">{{ error }}</p>
        </div>
      </div>

      <DialogFooter>
        <Button variant="outline" @click="isOpen = false" :disabled="isLoading">{{
          t('common.cancel')
        }}</Button>
        <Button variant="destructive" @click="handleVoid" :disabled="!isFormValid || isLoading">
          <Loader2 v-if="isLoading" class="w-4 h-4 mr-2 animate-spin" />
          <Slash v-else class="w-4 h-4 mr-2" />
          {{ isLoading ? t('approval.dialogs.void.processing') : t('approval.actions.void') }}
        </Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>
