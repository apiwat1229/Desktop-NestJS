<script setup lang="ts">
import { Button } from '@/components/ui/button';
import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
} from '@/components/ui/command';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { cn } from '@/lib/utils';
import { bookingsApi } from '@/services/bookings';
import { rubberTypesApi } from '@/services/rubberTypes';
import { suppliersApi } from '@/services/suppliers';
import { useAuthStore } from '@/stores/auth';
import { format } from 'date-fns';
import { Check, ChevronsUpDown } from 'lucide-vue-next';
import { computed, ref, watch } from 'vue';
import { toast } from 'vue-sonner';

// --- Props ---
const props = defineProps<{
  open: boolean;
  selectedDate: Date | null;
  selectedSlot: string;
  nextQueueNo: number | null;
  editingBooking?: any;
}>();

const emit = defineEmits(['update:open', 'success']);

// --- State ---
// const { t } = useI18n(); // Cleaned up unused
const authStore = useAuthStore();
const loading = ref(false);
const suppliers = ref<any[]>([]);
const rubberTypes = ref<any[]>([]);
const openSupplierCombo = ref(false);

const form = ref({
  supplierId: '',
  truckType: '',
  truckRegister: '',
  rubberType: '',
  supplierCode: '', // Helper for display/search
  supplierName: '', // Helper
});

const TRUCK_TYPES = [
  { value: 'กระบะ', label: 'กระบะ' },
  { value: '6 ล้อ', label: '6 ล้อ' },
  { value: '10 ล้อ', label: '10 ล้อ' },
  { value: '10 ล้อ พ่วง', label: '10 ล้อ (พ่วง)' },
  { value: 'เทรลเลอร์', label: 'เทรลเลอร์' },
];

// --- Computeds ---
const isEditMode = computed(() => !!props.editingBooking);
const startTime = computed(() => props.selectedSlot.split('-')[0] || '');
const endTime = computed(() => props.selectedSlot.split('-')[1] || '');

const displayQueueNo = computed(() => {
  if (isEditMode.value && props.editingBooking) {
    return props.editingBooking.queueNo;
  }
  return props.nextQueueNo !== null ? props.nextQueueNo : '-';
});

const displayBookingCode = computed(() => {
  if (isEditMode.value && props.editingBooking) {
    return props.editingBooking.bookingCode;
  }
  if (!props.selectedDate || props.nextQueueNo === null) return '-';
  return genBookingCode(props.selectedDate, props.nextQueueNo);
});

// --- Watchers ---
watch(
  () => props.open,
  (isOpen) => {
    if (isOpen) {
      fetchMasterData();
      if (isEditMode.value && props.editingBooking) {
        // Fill form
        form.value = {
          supplierId: props.editingBooking.supplierId || '',
          truckType: props.editingBooking.truckType || '',
          truckRegister: props.editingBooking.truckRegister || '',
          rubberType: props.editingBooking.rubberType || '',
          supplierCode: props.editingBooking.supplierCode || '',
          supplierName: props.editingBooking.supplierName || '',
        };
      } else {
        // Reset form
        form.value = {
          supplierId: '',
          truckType: '',
          truckRegister: '',
          rubberType: '',
          supplierCode: '',
          supplierName: '',
        };
      }
    }
  }
);

// --- Methods ---
function genBookingCode(date: Date, queueNo: number): string {
  const yy = String(date.getFullYear()).slice(-2);
  const mm = String(date.getMonth() + 1).padStart(2, '0');
  const dd = String(date.getDate()).padStart(2, '0');
  const q = String(queueNo).padStart(2, '0');
  return `${yy}${mm}${dd}${q}`;
}

async function fetchMasterData() {
  if (suppliers.value.length > 0 && rubberTypes.value.length > 0) return;
  try {
    const [suppliersResp, rubberTypesResp] = await Promise.all([
      suppliersApi.getAll(),
      rubberTypesApi.getAll(),
    ]);
    suppliers.value = suppliersResp;
    rubberTypes.value = rubberTypesResp;
  } catch (err) {
    console.error('Failed to fetch master data:', err);
    toast.error('Failed to load initial data');
  }
}

async function handleSubmit() {
  if (!form.value.supplierId || !form.value.rubberType) {
    toast.error('Validation Error', {
      description: 'Please select Supplier and Rubber Type',
    });
    return;
  }

  // Find selected supplier details
  const selectedSupplier = suppliers.value.find((s) => s.id === form.value.supplierId);
  if (!selectedSupplier) return;

  const supplierCode = selectedSupplier.code;
  const supplierName = selectedSupplier.name;

  const payload = {
    date: props.selectedDate ? format(props.selectedDate, 'yyyy-MM-dd') : '',
    startTime: startTime.value,
    endTime: endTime.value,
    supplierId: form.value.supplierId,
    supplierCode,
    supplierName,
    truckType: form.value.truckType,
    truckRegister: form.value.truckRegister,
    rubberType: form.value.rubberType,
    recorder: authStore.user?.username || authStore.user?.email || 'System',
  };

  try {
    loading.value = true;
    if (isEditMode.value && props.editingBooking?.id) {
      const updated = await bookingsApi.update(props.editingBooking.id, payload);
      toast.success('Updated successfully');
      emit('success', updated);
    } else {
      const created = await bookingsApi.create(payload as any);
      toast.success('Created successfully');
      emit('success', created);
    }
    emit('update:open', false);
  } catch (err: any) {
    console.error('Save booking error:', err);
    toast.error('Failed to save booking', {
      description: err.response?.data?.message || err.message,
    });
  } finally {
    loading.value = false;
  }
}
</script>

<template>
  <Dialog :open="open" @update:open="$emit('update:open', $event)">
    <DialogContent class="max-w-3xl max-h-[90vh] overflow-y-auto">
      <DialogHeader>
        <DialogTitle>{{ isEditMode ? 'Edit Booking' : 'Add Booking' }}</DialogTitle>
        <DialogDescription>
          {{ selectedDate ? format(selectedDate, 'dd MMM yyyy') : '-' }} • {{ selectedSlot }}
        </DialogDescription>
      </DialogHeader>

      <form @submit.prevent="handleSubmit" class="space-y-4 mt-6">
        <!-- Time Slots -->
        <div class="grid grid-cols-2 gap-4">
          <div class="space-y-2">
            <Label>Start Time</Label>
            <Input :model-value="startTime" readonly disabled />
          </div>
          <div class="space-y-2">
            <Label>End Time</Label>
            <Input :model-value="endTime" readonly disabled />
          </div>
        </div>

        <!-- Queue Info -->
        <div class="grid grid-cols-2 gap-4">
          <div class="space-y-2">
            <Label>Queue Number</Label>
            <Input :model-value="displayQueueNo" readonly disabled />
          </div>
          <div class="space-y-2">
            <Label>Booking Code</Label>
            <Input :model-value="displayBookingCode" readonly disabled />
          </div>
        </div>

        <!-- Supplier -->
        <div class="space-y-2">
          <Label>Supplier</Label>
          <Popover v-model:open="openSupplierCombo">
            <PopoverTrigger as-child>
              <Button
                variant="outline"
                role="combobox"
                :aria-expanded="openSupplierCombo"
                class="w-full justify-between"
              >
                {{
                  form.supplierId
                    ? suppliers.find((framework) => framework.id === form.supplierId)?.code +
                      ' - ' +
                      suppliers.find((framework) => framework.id === form.supplierId)?.name
                    : 'Select Supplier'
                }}
                <ChevronsUpDown class="ml-2 h-4 w-4 shrink-0 opacity-50" />
              </Button>
            </PopoverTrigger>
            <PopoverContent class="w-[400px] p-0">
              <Command
                :filter-function="
                  (list: any[], term: string) =>
                    list.filter((i) => (i.code + i.name).toLowerCase().includes(term.toLowerCase()))
                "
              >
                <CommandInput placeholder="Search supplier..." />
                <CommandEmpty>No supplier found.</CommandEmpty>
                <CommandList>
                  <CommandGroup>
                    <CommandItem
                      v-for="framework in suppliers"
                      :key="framework.id"
                      :value="framework"
                      @select="
                        () => {
                          form.supplierId = framework.id;
                          openSupplierCombo = false;
                        }
                      "
                    >
                      <Check
                        :class="
                          cn(
                            'mr-2 h-4 w-4',
                            form.supplierId === framework.id ? 'opacity-100' : 'opacity-0'
                          )
                        "
                      />
                      {{ framework.code }} - {{ framework.name }}
                    </CommandItem>
                  </CommandGroup>
                </CommandList>
              </Command>
            </PopoverContent>
          </Popover>
        </div>

        <!-- Truck Info -->
        <div class="grid grid-cols-2 gap-4">
          <div class="space-y-2">
            <Label>Truck Type</Label>
            <Select v-model="form.truckType">
              <SelectTrigger>
                <SelectValue placeholder="Select Type" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem v-for="type in TRUCK_TYPES" :key="type.value" :value="type.value">
                  {{ type.label }}
                </SelectItem>
              </SelectContent>
            </Select>
          </div>
          <div class="space-y-2">
            <Label>Truck Register</Label>
            <Input v-model="form.truckRegister" placeholder="e.g. 70-1234" />
          </div>
        </div>

        <!-- Rubber Type -->
        <div class="space-y-2">
          <Label>Rubber Type <span class="text-red-500">*</span></Label>
          <Select v-model="form.rubberType">
            <SelectTrigger>
              <SelectValue placeholder="Select Rubber Type" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem v-for="type in rubberTypes" :key="type.id" :value="type.code">
                {{ type.name }}
              </SelectItem>
            </SelectContent>
          </Select>
        </div>

        <DialogFooter class="mt-6">
          <Button type="button" variant="outline" @click="$emit('update:open', false)">
            Cancel
          </Button>
          <Button type="submit" :disabled="loading">
            {{ loading ? 'Saving...' : isEditMode ? 'Update' : 'Save' }}
          </Button>
        </DialogFooter>
      </form>
    </DialogContent>
  </Dialog>
</template>
