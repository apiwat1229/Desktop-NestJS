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
import { toast } from 'vue-sonner';

const props = defineProps<{
  requestId: string;
}>();

const emit = defineEmits<{
  success: [];
}>();

const isOpen = defineModel<boolean>('open');
const remark = ref('');
const isLoading = ref(false);
const error = ref('');

const isFormValid = computed(() => remark.value.trim().length > 0);

const handleReturn = async () => {
  if (!isFormValid.value) {
    error.value = 'กรุณาระบุเหตุผลในการส่งคืน';
    return;
  }

  try {
    isLoading.value = true;
    error.value = '';

    await approvalsApi.return(props.requestId, {
      remark: remark.value,
    });

    toast.success('ส่งคืนคำขอเรียบร้อยแล้ว');

    emit('success');
    isOpen.value = false;
    remark.value = '';
  } catch (err: any) {
    handleApiError(err, 'ไม่สามารถส่งคืนคำขอได้');
  } finally {
    isLoading.value = false;
  }
};
</script>

<template>
  <Dialog v-model:open="isOpen">
    <DialogContent>
      <DialogHeader>
        <DialogTitle>ส่งคืนคำขอเพื่อแก้ไข</DialogTitle>
      </DialogHeader>

      <div class="space-y-4">
        <div>
          <Label>เหตุผลในการส่งคืน *</Label>
          <Textarea
            v-model="remark"
            placeholder="กรุณาระบุเหตุผล เช่น: กรุณาเพิ่มรายละเอียด..."
            :disabled="isLoading"
            required
          />
          <p v-if="error" class="text-sm text-red-600 mt-1">{{ error }}</p>
        </div>
      </div>

      <DialogFooter>
        <Button variant="outline" @click="isOpen = false" :disabled="isLoading"> ยกเลิก </Button>
        <Button
          class="border-blue-500 text-blue-600 hover:bg-blue-50"
          variant="outline"
          @click="handleReturn"
          :disabled="!isFormValid || isLoading"
        >
          <Loader2 v-if="isLoading" class="w-4 h-4 mr-2 animate-spin" />
          <ArrowLeft v-else class="w-4 h-4 mr-2" />
          {{ isLoading ? 'กำลังดำเนินการ...' : 'ส่งคืนแก้ไข' }}
        </Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>
