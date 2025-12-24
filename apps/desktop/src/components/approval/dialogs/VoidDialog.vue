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
import { toast } from 'vue-sonner';

const props = defineProps<{
  requestId: string;
}>();

const emit = defineEmits<{
  success: [];
}>();

const isOpen = defineModel<boolean>('open');
const reason = ref('');
const isLoading = ref(false);
const error = ref('');

const isFormValid = computed(() => reason.value.trim().length > 0);

const handleVoid = async () => {
  if (!isFormValid.value) {
    error.value = 'กรุณาระบุเหตุผลในการทำเป็นโมฆะ';
    return;
  }

  try {
    isLoading.value = true;
    error.value = '';

    await approvalsApi.void(props.requestId, {
      reason: reason.value,
    });

    toast.success('ทำรายการเป็นโมฆะเรียบร้อยแล้ว');

    emit('success');
    isOpen.value = false;
    reason.value = '';
  } catch (err: any) {
    handleApiError(err, 'ไม่สามารถทำรายการเป็นโมฆะได้');
  } finally {
    isLoading.value = false;
  }
};
</script>

<template>
  <Dialog v-model:open="isOpen">
    <DialogContent>
      <DialogHeader>
        <DialogTitle>ทำรายการเป็นโมฆะ</DialogTitle>
        <DialogDescription class="text-red-600">
          ⚠️ การทำรายการเป็นโมฆะจะยกเลิกการอนุมัติที่ผ่านมา
        </DialogDescription>
      </DialogHeader>

      <div class="space-y-4">
        <div>
          <Label>เหตุผลในการทำเป็นโมฆะ *</Label>
          <Textarea
            v-model="reason"
            placeholder="เช่น: ระบุยอดเงินผิด"
            :disabled="isLoading"
            required
          />
          <p v-if="error" class="text-sm text-red-600 mt-1">{{ error }}</p>
        </div>
      </div>

      <DialogFooter>
        <Button variant="outline" @click="isOpen = false" :disabled="isLoading"> ยกเลิก </Button>
        <Button variant="destructive" @click="handleVoid" :disabled="!isFormValid || isLoading">
          <Loader2 v-if="isLoading" class="w-4 h-4 mr-2 animate-spin" />
          <Slash v-else class="w-4 h-4 mr-2" />
          {{ isLoading ? 'กำลังดำเนินการ...' : 'ทำเป็นโมฆะ' }}
        </Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>
