<script setup lang="ts">
import { Button } from '@/components/ui/button';
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import approvalsApi from '@/services/approvals';
import { handleApiError } from '@/utils/errorHandler';
import { ArrowLeft, Loader2 } from 'lucide-vue-next';
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
const remark = ref('');
const isLoading = ref(false);
const error = ref('');

const isFormValid = computed(() => remark.value.trim().length > 0);

const handleReturn = async () => {
  if (!isFormValid.value) {
    error.value = t('approval.dialogs.return.reasonRequired');
    return;
  }

  try {
    isLoading.value = true;
    error.value = '';

    await approvalsApi.return(props.requestId, {
      remark: remark.value,
    });

    toast.success(t('approval.dialogs.return.success'));

    emit('success');
    isOpen.value = false;
    remark.value = '';
  } catch (err: any) {
    handleApiError(err, t('approval.dialogs.return.error'));
  } finally {
    isLoading.value = false;
  }
};
</script>

<template>
  <Dialog v-model:open="isOpen">
    <DialogContent>
      <DialogHeader>
        <DialogTitle>{{ t('approval.dialogs.return.title') }}</DialogTitle>
      </DialogHeader>

      <div class="space-y-4">
        <div>
          <Label>{{ t('approval.dialogs.return.reasonLabel') }}</Label>
          <Textarea
            v-model="remark"
            :placeholder="t('approval.dialogs.return.reasonPlaceholder')"
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
        <Button
          class="border-blue-500 text-blue-600 hover:bg-blue-50"
          variant="outline"
          @click="handleReturn"
          :disabled="!isFormValid || isLoading"
        >
          <Loader2 v-if="isLoading" class="w-4 h-4 mr-2 animate-spin" />
          <ArrowLeft v-else class="w-4 h-4 mr-2" />
          {{ isLoading ? t('approval.dialogs.return.processing') : t('approval.actions.return') }}
        </Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>
