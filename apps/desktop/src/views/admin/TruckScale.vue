<script setup lang="ts">
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Calendar } from '@/components/ui/calendar';
import { Card, CardContent } from '@/components/ui/card';
import { Checkbox } from '@/components/ui/checkbox';
import Combobox from '@/components/ui/combobox/Combobox.vue';
import DataTable from '@/components/ui/data-table/DataTable.vue';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import LiveDuration from '@/components/ui/LiveDuration.vue';
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Textarea } from '@/components/ui/textarea';
import { cn } from '@/lib/utils';
import { approvalsApi } from '@/services/approvals';
import { bookingsApi } from '@/services/bookings';
import { masterApi } from '@/services/master';
import { rubberTypesApi } from '@/services/rubberTypes';
import { socketService } from '@/services/socket';
import { useAuthStore } from '@/stores/auth';
import { getLocalTimeZone, today } from '@internationalized/date';
import type { ColumnDef } from '@tanstack/vue-table';
import { format } from 'date-fns';
import {
  Calendar as CalendarIcon,
  CheckCircle,
  Clock,
  Search,
  Settings,
  Truck,
} from 'lucide-vue-next';
import { computed, h, onMounted, onUnmounted, ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { toast } from 'vue-sonner';

// State
const activeTab = ref('checkin');
const bookings = ref<any[]>([]);
const isLoading = ref(false);
const searchQuery = ref('');
const settingsOpen = ref(false);
const settings = ref({
  autoRefresh: true,
  sound: false,
});

const { t } = useI18n();

const provinces = ref<any[]>([]);
const rubberTypes = ref<any[]>([]);

const provinceOptions = computed(() => {
  return provinces.value.map((p) => ({
    value: p.name_th,
    label: p.name_th,
  }));
});

const getRubberTypeName = (code: string | undefined) => {
  if (!code) return '-';
  const found = rubberTypes.value.find((r) => r.code === code);
  return found ? found.name : code;
};

const fetchMasterData = async () => {
  try {
    const [provs, rubbers] = await Promise.all([masterApi.getProvinces(), rubberTypesApi.getAll()]);
    provinces.value = provs;
    rubberTypes.value = rubbers;
  } catch (e) {
    console.error('Failed to load master data', e);
  }
};

// Load Settings
const STORAGE_KEY_SETTINGS = 'truck_scale_settings';
const loadSettings = () => {
  const saved = localStorage.getItem(STORAGE_KEY_SETTINGS);
  if (saved) {
    try {
      settings.value = JSON.parse(saved);
    } catch (e) {
      console.error('Error loading settings', e);
    }
  }
};
watch(
  settings,
  (newVal) => {
    localStorage.setItem(STORAGE_KEY_SETTINGS, JSON.stringify(newVal));
  },
  { deep: true }
);

// Date Handling
const selectedDateObject = ref<any>(today(getLocalTimeZone()));
const isDatePopoverOpen = ref(false);
const selectedDate = computed(() => {
  return selectedDateObject.value ? selectedDateObject.value.toString() : '';
});

// Watch for date changes to refetch
watch(selectedDate, (newVal) => {
  if (newVal) fetchBookings();
});

const handleDateSelect = (newDate: any) => {
  selectedDateObject.value = newDate;
  isDatePopoverOpen.value = false;
};

// Confirmation Dialog
// Check-in Logic
const authStore = useAuthStore();
const checkInDialogOpen = ref(false);
const checkInStep = ref(1); // 1 = Form, 2 = Confirmation
const selectedBooking = ref<any>(null);
const checkInTime = ref<Date | null>(null);

const recorderName = computed(() => {
  const user = authStore.user as any;
  if (!user) return 'Unknown';
  if (user.firstName && user.lastName) {
    return `${user.firstName} ${user.lastName}`;
  }
  return user.name || user.displayName || user.email || 'Unknown';
});

const checkInData = ref({
  truckType: '',
  truckRegister: '',
  note: '',
});

const openCheckInDialog = (booking: any) => {
  selectedBooking.value = booking;
  checkInStep.value = 1;
  // Set current time for check-in
  checkInTime.value = new Date();

  // Pre-fill data if available (optional)
  checkInData.value = {
    truckType: booking.truckType || '',
    truckRegister: booking.truckRegister || '',
    note: '',
  };
  checkInDialogOpen.value = true;
};

const handleNextStep = () => {
  // Basic validation
  if (!checkInData.value.truckType) {
    toast.error(t('truckScale.toast.selectTruckType'));
    return;
  }
  if (!checkInData.value.truckRegister || !checkInData.value.truckRegister.trim()) {
    toast.error(t('truckScale.toast.truckRegisterRequired'));
    return;
  }
  checkInStep.value = 2;
};

const confirmCheckIn = async () => {
  if (!selectedBooking.value) return;
  try {
    await bookingsApi.checkIn(selectedBooking.value.id, checkInData.value);
    toast.success(t('truckScale.toast.checkInSuccess'));
    checkInDialogOpen.value = false;
    fetchBookings();
  } catch (error) {
    console.error('Check-in failed:', error);
    toast.error(t('truckScale.toast.errorCheckIn'));
  }
};

// Fetch Data
const fetchBookings = async () => {
  isLoading.value = true;
  try {
    const response = await bookingsApi.getAll({ date: selectedDate.value });
    // Assuming backend returns array directly as per previous fix
    bookings.value = Array.isArray(response) ? response : (response as any).data || [];
    if (bookings.value.length > 0) console.log('[TruckScale] Booking Data:', bookings.value[0]);
  } catch (error) {
    console.error('Failed to fetch bookings:', error);
    toast.error(t('truckScale.toast.loadBookingsFailed'));
    bookings.value = [];
  } finally {
    isLoading.value = false;
  }
};

// Actions

// Stats
const stats = computed(() => {
  const total = bookings.value.length;
  const checkedIn = bookings.value.filter((b) => b.checkinAt).length;
  const pending = total - checkedIn;
  return { total, checkedIn, pending };
});

// Filtered Data
const filteredBookings = computed(() => {
  let data = bookings.value;

  // Filter by Tab
  if (activeTab.value === 'checkin') {
    // Show all or pending? Keep strict.
  } else if (activeTab.value === 'scale-in') {
    data = data.filter((b) => b.checkinAt);
  } else if (activeTab.value === 'scale-out') {
    // Show items that have Weight In but NO Weight Out yet
    data = data.filter((b) => b.weightIn && !b.weightOut);
  } else if (activeTab.value === 'dashboard') {
    // Show completed items (have Weight Out)
    data = data.filter((b) => b.weightOut);
  }

  if (!searchQuery.value) return data;
  const lowerQuery = searchQuery.value.toLowerCase();
  return data.filter(
    (b) =>
      b.bookingCode.toLowerCase().includes(lowerQuery) ||
      b.supplierName.toLowerCase().includes(lowerQuery) ||
      b.truckRegister?.toLowerCase().includes(lowerQuery)
  );
});

// Scale Out & Dashboard Logic
const weightOutDialogOpen = ref(false);
const confirmCheckoutDialogOpen = ref(false);
const weightOutData = ref<{ weightOut: number | null }>({ weightOut: 0 });

const openWeightOut = (booking: any) => {
  selectedDrainBooking.value = booking;
  weightOutData.value = { weightOut: 0 };
  weightOutDialogOpen.value = true;
};

const handleWeightOutNext = () => {
  // Validate
  if (!weightOutData.value.weightOut || weightOutData.value.weightOut <= 0) {
    toast.error(t('truckScale.toast.weightOutRequired'));
    return;
  }
  weightOutDialogOpen.value = false;
  confirmCheckoutDialogOpen.value = true;
};

// Detail & Time Log Logic
const detailDialogOpen = ref(false);
const timeLogDialogOpen = ref(false);
const selectedDetailBooking = ref<any>(null);

const openBookingDetail = (booking: any) => {
  selectedDetailBooking.value = booking;
  detailDialogOpen.value = true;
};

const openTimeLog = (booking: any) => {
  selectedDetailBooking.value = booking;
  timeLogDialogOpen.value = true;
};

const confirmWeightOut = async () => {
  if (!selectedDrainBooking.value) return;
  try {
    await bookingsApi.saveWeightOut(selectedDrainBooking.value.id, weightOutData.value);
    toast.success(t('truckScale.toast.weightOutSuccess'));
    confirmCheckoutDialogOpen.value = false;
    fetchBookings();
  } catch (e) {
    toast.error(t('truckScale.toast.errorWeightOut'));
  }
};

const dashboardStats = computed(() => {
  const completed = bookings.value.filter((b) => b.weightOut);
  const totalCount = completed.length;
  const totalWeightIn = completed.reduce((sum, b) => sum + (b.weightIn || 0), 0);
  const totalWeightOut = completed.reduce((sum, b) => sum + (b.weightOut || 0), 0);
  const totalNet = Math.abs(totalWeightIn - totalWeightOut);

  return {
    count: totalCount,
    net: totalNet,
    gross: totalWeightIn, // Or calculate differently? Assuming Gross = In
    weightIn: totalWeightIn,
    weightOut: totalWeightOut,
  };
});

// Scale In Logic
const startDrainDialogOpen = ref(false);
const requestEditDialogOpen = ref(false);
const selectedRequestEditBooking = ref<any>(null);
const requestEditReason = ref('');

const openRequestEdit = (booking: any) => {
  selectedRequestEditBooking.value = booking;
  requestEditReason.value = '';
  requestEditDialogOpen.value = true;
};

const confirmRequestEdit = async () => {
  if (!selectedRequestEditBooking.value) return;
  if (!requestEditReason.value) {
    toast.error(t('truckScale.toast.reasonRequired'));
    return;
  }
  try {
    await approvalsApi.create({
      requestType: 'EDIT',
      entityType: 'BOOKING',
      entityId: selectedRequestEditBooking.value.id,
      sourceApp: 'DESKTOP',
      actionType: 'EDIT_WEIGHT_IN',
      reason: requestEditReason.value,
      currentData: { weightIn: selectedRequestEditBooking.value.weightIn },
    });
    toast.success(t('truckScale.toast.editRequestSent'));
    requestEditDialogOpen.value = false;
    fetchBookings();
  } catch (error) {
    console.error('Request edit failed:', error);
    toast.error(t('truckScale.toast.editRequestFailed'));
  }
};
const stopDrainDialogOpen = ref(false);
const stopDrainReason = ref('');
const weightInDialogOpen = ref(false);
const selectedDrainBooking = ref<any>(null);
const weightInData = ref({
  rubberSource: '',
  rubberType: '',
  weightIn: 0,
  trailerRubberSource: '',
  trailerRubberType: '',
  trailerWeightIn: 0,
});

const formattedWeightIn = computed({
  get: () => {
    if (!weightInData.value.weightIn) return '';
    return weightInData.value.weightIn.toLocaleString();
  },
  set: (val) => {
    const num = Number(val.replace(/,/g, ''));
    if (!isNaN(num)) {
      weightInData.value.weightIn = num;
    }
  },
});

const formattedTrailerWeightIn = computed({
  get: () => {
    if (!weightInData.value.trailerWeightIn) return '';
    return weightInData.value.trailerWeightIn.toLocaleString();
  },
  set: (val) => {
    const num = Number(val.replace(/,/g, ''));
    if (!isNaN(num)) {
      weightInData.value.trailerWeightIn = num;
    }
  },
});

const rubberTypeOptions = computed(() => {
  return rubberTypes.value.map((t) => ({
    value: t.name,
    label: t.name,
  }));
});

const openStartDrain = (booking: any) => {
  selectedDrainBooking.value = booking;
  startDrainDialogOpen.value = true;
};

const openStopDrain = (booking: any) => {
  selectedDrainBooking.value = booking;
  stopDrainReason.value = '';
  stopDrainDialogOpen.value = true;
};

const openWeightIn = (booking: any) => {
  selectedDrainBooking.value = booking;

  const rawType = (booking.rubberType || '').trim();
  const isValidType = rubberTypes.value.some((t) => t.name === rawType);

  const rawTrailerType = (booking.trailerRubberType || '').trim();
  const isValidTrailerType = rubberTypes.value.some((t) => t.name === rawTrailerType);

  weightInData.value = {
    rubberSource: booking.rubberSource || '',
    rubberType: isValidType ? rawType : '',
    weightIn: booking.weightIn || 0,
    trailerRubberSource: booking.trailerRubberSource || '',
    trailerRubberType: isValidTrailerType ? rawTrailerType : '',
    trailerWeightIn: booking.trailerWeightIn || 0,
  };
  weightInDialogOpen.value = true;
};

const confirmStartDrain = async () => {
  console.log('Confirm Start Drain clicked:', selectedDrainBooking.value);
  if (!selectedDrainBooking.value) {
    console.error('No booking selected for drain start');
    return;
  }
  try {
    await bookingsApi.startDrain(selectedDrainBooking.value.id);
    toast.success(t('truckScale.toast.drainTimerStarted'));
    startDrainDialogOpen.value = false;
    fetchBookings();
  } catch (e: any) {
    console.error('Start drain error:', e);
    toast.error(
      t('truckScale.toast.startDrainFailed') + ': ' + (e.response?.data?.message || e.message)
    );
  }
};

const confirmStopDrain = async () => {
  if (!selectedDrainBooking.value) return;

  const start = new Date(selectedDrainBooking.value.startDrainAt).getTime();
  const end = new Date().getTime();
  const durationMins = Math.floor((end - start) / 60000);

  if (durationMins < 40 && !stopDrainReason.value.trim()) {
    toast.error(t('truckScale.toast.reasonRequiredDuration'));
    return;
  }

  try {
    await bookingsApi.stopDrain(selectedDrainBooking.value.id, {
      note: stopDrainReason.value,
    });
    toast.success(t('truckScale.toast.drainTimerStopped'));
    stopDrainDialogOpen.value = false;
    fetchBookings();
  } catch (e) {
    toast.error(t('truckScale.toast.stopDrainFailed'));
  }
};

const saveWeightIn = async () => {
  if (!selectedDrainBooking.value) return;
  try {
    await bookingsApi.saveWeightIn(selectedDrainBooking.value.id, weightInData.value);
    toast.success('Weight In Saved');
    weightInDialogOpen.value = false;
    fetchBookings();
  } catch (e) {
    toast.error('Failed to save weight');
  }
};

const calculateDuration = (start: string | Date, end: string | Date) => {
  if (!start || !end) return '00 ' + t('liveDuration.min');
  const s = new Date(start).getTime();
  const e = new Date(end).getTime();
  const diff = Math.floor((e - s) / 60000); // minutes
  return `${diff} ${t('liveDuration.min')}`;
};

// Columns
const columns: ColumnDef<any>[] = [
  {
    accessorKey: 'queueNo',
    header: () => t('truckScale.queue') || 'Queue',
    cell: ({ row }) => h('div', { class: 'font-bold text-center w-12' }, row.original.queueNo),
  },
  {
    accessorKey: 'date',
    header: () => t('truckScale.date'),
    cell: ({ row }) => format(new Date(row.original.date), 'dd-MMM-yyyy'),
  },
  {
    accessorKey: 'time',
    header: () => t('truckScale.time') || 'Time',
    cell: ({ row }) => `${row.original.startTime} - ${row.original.endTime}`,
  },
  {
    accessorKey: 'bookingCode',
    header: () => t('booking.bookingCode'),
    cell: ({ row }) => row.original.bookingCode,
  },
  {
    accessorKey: 'supplierName',
    header: () => t('truckScale.supplier') || 'Supplier',
    cell: ({ row }) => `${row.original.supplierCode} - ${row.original.supplierName}`,
  },
  {
    accessorKey: 'truckRegister',
    header: () => t('truckScale.truck') || 'Truck',
    cell: ({ row }) => {
      const type = row.original.truckType;
      const register = row.original.truckRegister;
      const text = [type, register].filter(Boolean).join(' - ') || '-';
      return h('div', { class: 'flex items-center gap-2' }, [
        h(Truck, { class: 'w-4 h-4 text-muted-foreground' }),
        h('span', text),
      ]);
    },
  },
  {
    id: 'status',
    header: () => t('truckScale.status'),
    cell: ({ row }) => {
      const isCheckedIn = !!row.original.checkinAt;
      if (isCheckedIn) {
        return h(Badge, { class: 'bg-green-500 hover:bg-green-600 gap-1' }, () => [
          h(CheckCircle, { class: 'w-3 h-3' }),
          'Checked In ' + format(new Date(row.original.checkinAt), 'HH:mm'),
        ]);
      }
      return h(
        Button,
        {
          size: 'sm',
          variant: 'outline',
          class: 'gap-1 text-orange-600 border-orange-200 hover:bg-orange-50',
          onClick: () => openCheckInDialog(row.original),
        },
        () => [h(Clock, { class: 'w-3 h-3' }), 'Check In']
      );
    },
  },
];

// Scale In Columns
const scaleInColumns: ColumnDef<any>[] = [
  {
    accessorKey: 'supplierName',
    header: () => t('truckScale.supplier') || 'Supplier',
    cell: ({ row }) =>
      h('div', { class: 'flex flex-col' }, [
        h('span', { class: 'font-medium' }, row.original.supplierCode),
        h('span', { class: 'text-sm text-muted-foreground' }, row.original.supplierName),
      ]),
  },
  {
    accessorKey: 'queueNo',
    header: () => t('truckScale.queue') || 'Queue',
    cell: ({ row }) =>
      h('div', {}, `${row.original.startTime} - ${row.original.endTime} (${row.original.queueNo})`),
  },
  {
    accessorKey: 'truckRegister',
    header: () => t('truckScale.licensePlate') || 'License Plate',
    cell: ({ row }) => row.original.truckRegister || '-',
  },
  {
    accessorKey: 'truckType',
    header: () => t('truckScale.type') || 'Type',
    cell: ({ row }) => row.original.truckType || '-',
  },
  {
    accessorKey: 'startDrainAt',
    header: () => t('truckScale.startDrain') || 'Start Drain',
    cell: ({ row }) => {
      if (row.original.startDrainAt) {
        return h(
          'span',
          { class: 'text-green-600 font-medium' },
          format(new Date(row.original.startDrainAt), 'HH:mm')
        );
      }
      return h(
        Button,
        {
          size: 'sm',
          class: 'bg-green-100 text-green-700 hover:bg-green-200 border-none shadow-none',
          onClick: () => openStartDrain(row.original),
        },
        () => t('truckScale.startDrain')
      );
    },
  },
  {
    accessorKey: 'stopDrainAt',
    header: () => t('truckScale.stopDrain') || 'Stop Drain',
    cell: ({ row }) => {
      if (!row.original.startDrainAt)
        return h(Button, { size: 'sm', disabled: true, variant: 'secondary' }, () => 'Stop'); // Disabled if not started
      if (row.original.stopDrainAt) {
        return h(
          'span',
          { class: 'text-red-600 font-medium' },
          format(new Date(row.original.stopDrainAt), 'HH:mm')
        );
      }
      return h(
        Button,
        {
          size: 'sm',
          class: 'bg-red-100 text-red-700 hover:bg-red-200 border-none shadow-none',
          onClick: () => openStopDrain(row.original),
        },
        () => t('truckScale.stopDrain')
      );
    },
  },
  {
    id: 'totalDrain',
    header: () => t('truckScale.totalDrain') || 'Total Drain',
    cell: ({ row }) => {
      if (row.original.startDrainAt) {
        return h(LiveDuration, {
          start: row.original.startDrainAt,
          end: row.original.stopDrainAt,
        });
      }
      return '00 ' + t('liveDuration.min');
    },
  },
  {
    accessorKey: 'weightIn',
    header: () => t('truckScale.weightIn') || 'Weight In',
    cell: ({ row }) =>
      row.original.weightIn ? `${row.original.weightIn.toLocaleString()} kg` : '-',
  },
  {
    id: 'action',
    header: () => t('common.actions'),
    cell: ({ row }) => {
      const hasWeight = !!row.original.weightIn;
      const canEdit = row.original.canEditWeightIn; // Assuming backend provides this flag

      if (hasWeight) {
        if (canEdit) {
          return h(
            Button,
            {
              size: 'sm',
              variant: 'outline',
              class: 'text-blue-600 border-blue-200 bg-blue-50',
              onClick: () => openWeightIn(row.original),
            },
            () => t('common.edit')
          );
        }
        return h(
          Button,
          {
            size: 'sm',
            variant: 'outline',
            class: 'text-orange-600 border-orange-200 bg-orange-50',
            onClick: () => openRequestEdit(row.original),
          },
          () => t('truckScale.requestEdit')
        );
      }
      return h(
        Button,
        {
          size: 'sm',
          class: 'bg-gray-200 text-gray-700 hover:bg-gray-300',
          onClick: () => openWeightIn(row.original),
        },
        () => t('common.save')
      );
    },
  },
];

const scaleOutColumns: ColumnDef<any>[] = [
  ...scaleInColumns.slice(0, 3), // Supplier, Queue, Truck
  {
    accessorKey: 'truckType',
    header: () => t('truckScale.type'),
    cell: ({ row }) => row.original.truckType || '-',
  },
  {
    accessorKey: 'startDrainAt',
    header: () => t('truckScale.startDrain') || 'Start Drain',
    cell: ({ row }) =>
      row.original.startDrainAt ? format(new Date(row.original.startDrainAt), 'HH:mm') : '-',
  },
  {
    accessorKey: 'stopDrainAt',
    header: () => t('truckScale.stopDrain') || 'Stop Drain',
    cell: ({ row }) =>
      row.original.stopDrainAt ? format(new Date(row.original.stopDrainAt), 'HH:mm') : '-',
  },
  {
    id: 'totalDrain',
    header: () => t('truckScale.totalDrain'),
    cell: ({ row }) => {
      if (row.original.startDrainAt) {
        return h(LiveDuration, {
          start: row.original.startDrainAt,
          end: row.original.stopDrainAt,
        });
      }
      return '00 ' + t('liveDuration.min');
    },
  },
  {
    accessorKey: 'weightIn',
    header: () => t('truckScale.weightIn'),
    cell: ({ row }) =>
      row.original.weightIn ? `${row.original.weightIn.toLocaleString()} kg` : '-',
  },
  {
    id: 'action',
    header: () => t('common.actions'),
    cell: ({ row }) => {
      return h(
        Button,
        {
          size: 'sm',
          class: 'bg-blue-100 text-blue-600 hover:bg-blue-200 border-none shadow-none',
          onClick: () => openWeightOut(row.original),
        },
        () => t('common.save')
      );
    },
  },
];

const dashboardColumns: ColumnDef<any>[] = [
  {
    accessorKey: 'date',
    header: () => t('truckScale.date'),
    cell: ({ row }) => format(new Date(row.original.date), 'dd-MMM-yyyy'),
  },
  {
    accessorKey: 'supplierName',
    header: () => t('truckScale.supplier'),
    cell: ({ row }) => `${row.original.supplierCode} : ${row.original.supplierName}`,
  },
  {
    accessorKey: 'truckRegister',
    header: () => t('truckScale.licensePlate') || 'License Plate',
    cell: ({ row }) => row.original.truckRegister || '-',
  },
  {
    accessorKey: 'truckType',
    header: () => t('truckScale.type') || 'Type',
    cell: ({ row }) => row.original.truckType || '-',
  },
  {
    id: 'rubberTypeProvince',
    header: () =>
      `${t('truckScale.rubberType')} / ${t('admin.suppliers.dialog.labels.province') || 'Province'}`,
    cell: ({ row }) =>
      h('div', { class: 'flex flex-col' }, [
        h('span', { class: 'font-medium' }, row.original.rubberType || '-'),
        h(
          'span',
          { class: 'text-xs text-muted-foreground' },
          row.original.rubberSource || 'Province not specified'
        ),
      ]),
  },
  {
    accessorKey: 'weightIn',
    header: () => t('truckScale.weightIn') || 'Weight In',
    cell: ({ row }) =>
      row.original.weightIn ? `${row.original.weightIn.toLocaleString()} Kg.` : '-',
  },
  {
    accessorKey: 'weightOut',
    header: () => t('truckScale.weightOut'),
    cell: ({ row }) =>
      row.original.weightOut ? `${row.original.weightOut.toLocaleString()} Kg.` : '-',
  },
  {
    id: 'netWeight',
    header: () => t('truckScale.netWeight') || 'Net',
    cell: ({ row }) => {
      const net = Math.abs((row.original.weightIn || 0) - (row.original.weightOut || 0));
      return h('span', { class: 'font-bold' }, `${net.toLocaleString()} Kg.`);
    },
  },
  {
    id: 'actions',
    header: () => t('common.actions'),
    cell: ({ row }) =>
      h('div', { class: 'flex gap-2' }, [
        h(
          Button,
          {
            size: 'icon',
            variant: 'ghost',
            class: 'h-8 w-8 bg-green-50 text-green-600 hover:bg-green-100',
            onClick: () => openBookingDetail(row.original),
          },
          () => h(CheckCircle, { class: 'w-4 h-4' })
        ),
        h(
          Button,
          {
            size: 'icon',
            variant: 'ghost',
            class: 'h-8 w-8 bg-blue-50 text-blue-600 hover:bg-blue-100',
            onClick: () => openTimeLog(row.original),
          },
          () => h(Clock, { class: 'w-4 h-4' })
        ),
      ]),
  },
];

onMounted(async () => {
  loadSettings();
  fetchMasterData();
  await authStore.fetchUser();
  fetchBookings();

  // Socket Listener
  socketService.on('notification', () => {
    // Only refresh if autoRefresh is on
    if (settings.value.autoRefresh) {
      // Debounce slightly or just fetch
      console.log('[TruckScale] Notification received, refreshing data...');
      fetchBookings();
    }

    // Play Sound
    if (settings.value.sound) {
      // Simple beep using browser API if possible, or create an Audio context
      // Since we don't have assets, we can try a simple audio object if a URL existed,
      // or just log it for now. Users often demand a real sound, so we can try a data URI beep suitable for notification.
      try {
        const audioCtx = new (window.AudioContext || (window as any).webkitAudioContext)();
        const oscillator = audioCtx.createOscillator();
        const gainNode = audioCtx.createGain();
        oscillator.connect(gainNode);
        gainNode.connect(audioCtx.destination);
        oscillator.type = 'sine';
        oscillator.frequency.setValueAtTime(500, audioCtx.currentTime);
        gainNode.gain.setValueAtTime(0.1, audioCtx.currentTime);
        oscillator.start();
        oscillator.stop(audioCtx.currentTime + 0.1);
      } catch (e) {
        console.error('Audio play failed', e);
      }
    }
  });
});

onUnmounted(() => {
  socketService.off('notification');
});
</script>

<template>
  <div class="h-full flex flex-col p-6 space-y-6 max-w-[1600px] mx-auto w-full">
    <!-- Tabs -->
    <Tabs v-model="activeTab" class="w-full flex flex-col space-y-6">
      <!-- Header & Tabs List Row -->
      <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <!-- Title -->
        <div class="flex flex-col gap-1">
          <h1 class="text-3xl font-bold tracking-tight">{{ t('truckScale.title') }}</h1>
          <p class="text-muted-foreground">{{ t('truckScale.formDescription') }}</p>
        </div>

        <!-- Tabs List (Right Aligned) -->
        <TabsList class="h-10 bg-muted/50 p-1 rounded-lg self-start md:self-center">
          <TabsTrigger
            value="checkin"
            class="px-4 text-sm font-medium transition-all data-[state=active]:bg-blue-600 data-[state=active]:text-white data-[state=active]:shadow-sm rounded-md"
          >
            {{ t('truckScale.checkIn') }}
          </TabsTrigger>
          <TabsTrigger
            value="scale-in"
            class="px-4 text-sm font-medium transition-all data-[state=active]:bg-blue-600 data-[state=active]:text-white data-[state=active]:shadow-sm rounded-md"
          >
            {{ t('truckScale.weightIn') }}
          </TabsTrigger>
          <TabsTrigger
            value="scale-out"
            class="px-4 text-sm font-medium transition-all data-[state=active]:bg-blue-600 data-[state=active]:text-white data-[state=active]:shadow-sm rounded-md"
          >
            {{ t('truckScale.weightOut') }}
          </TabsTrigger>
          <TabsTrigger
            value="dashboard"
            class="px-4 text-sm font-medium transition-all data-[state=active]:bg-blue-600 data-[state=active]:text-white data-[state=active]:shadow-sm rounded-md"
          >
            {{ t('truckScale.dashboard') }}
          </TabsTrigger>
        </TabsList>

        <!-- Settings Button -->
        <Dialog v-model:open="settingsOpen">
          <DialogTrigger as-child>
            <Button variant="outline" size="icon" class="ml-2">
              <Settings class="w-4 h-4" />
            </Button>
          </DialogTrigger>
          <DialogContent class="sm:max-w-[425px]">
            <DialogHeader>
              <DialogTitle>{{ t('common.settings') }}</DialogTitle>
              <DialogDescription>
                Configure notification and auto-refresh settings.
              </DialogDescription>
            </DialogHeader>
            <div class="grid gap-4 py-4">
              <div class="flex items-center justify-between space-x-2">
                <Label htmlFor="auto-refresh" class="flex flex-col space-y-1">
                  <span>{{ t('truckScale.settings.autoRefresh') }}</span>
                  <span class="font-normal leading-snug text-muted-foreground">
                    {{ t('truckScale.settings.autoRefreshDesc') }}
                  </span>
                </Label>
                <Checkbox
                  id="auto-refresh"
                  :checked="settings.autoRefresh"
                  @update:checked="(v) => (settings.autoRefresh = v)"
                />
              </div>
              <div class="flex items-center justify-between space-x-2">
                <Label htmlFor="sound" class="flex flex-col space-y-1">
                  <span>{{ t('truckScale.settings.sound') }}</span>
                  <span class="font-normal leading-snug text-muted-foreground">
                    {{ t('truckScale.settings.soundDesc') }}
                  </span>
                </Label>
                <Checkbox
                  id="sound"
                  :checked="settings.sound"
                  @update:checked="(v) => (settings.sound = v)"
                />
              </div>
            </div>
          </DialogContent>
        </Dialog>
      </div>

      <TabsContent value="checkin" class="space-y-6 mt-0">
        <!-- Controls & Stats -->
        <Card class="border-none shadow-sm bg-card/50 backdrop-blur-sm">
          <CardContent class="p-6 space-y-6">
            <!-- Filters & Stats Combined Row -->
            <div class="flex flex-col xl:flex-row gap-6 items-end justify-between">
              <!-- Filters Group -->
              <div class="flex flex-col md:flex-row gap-4 items-end w-full xl:w-auto">
                <div class="grid gap-2 w-full md:w-auto">
                  <Label>{{ t('truckScale.date') }}</Label>
                  <Popover v-model:open="isDatePopoverOpen">
                    <PopoverTrigger as-child>
                      <Button
                        variant="outline"
                        :class="
                          cn(
                            'w-full md:w-[200px] justify-start text-left font-normal',
                            !selectedDate && 'text-muted-foreground'
                          )
                        "
                      >
                        <CalendarIcon class="mr-2 h-4 w-4" />
                        <span>{{
                          selectedDate
                            ? format(new Date(selectedDate), 'dd-MMM-yyyy')
                            : t('truckScale.pickDate')
                        }}</span>
                      </Button>
                    </PopoverTrigger>
                    <PopoverContent class="w-auto p-0">
                      <Calendar
                        :model-value="selectedDateObject"
                        @update:model-value="handleDateSelect"
                        mode="single"
                        initial-focus
                      />
                    </PopoverContent>
                  </Popover>
                </div>
                <div class="grid gap-2 w-full md:w-[320px]">
                  <Label>{{ t('common.search') }}</Label>
                  <div class="relative">
                    <Search class="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
                    <Input
                      v-model="searchQuery"
                      :placeholder="t('truckScale.searchPlaceholder')"
                      class="pl-9"
                    />
                  </div>
                </div>
                <Button
                  class="bg-blue-600 hover:bg-blue-700 w-full md:w-auto"
                  @click="fetchBookings"
                >
                  <Search class="w-4 h-4 mr-2" />
                  {{ t('common.search') }}
                </Button>
              </div>

              <!-- Stats Cards Group (Right Aligned) -->
              <div class="grid grid-cols-1 md:grid-cols-3 gap-4 w-full xl:w-auto mt-4 xl:mt-0">
                <div
                  class="rounded-lg border bg-background px-4 py-2 flex items-center gap-4 border-l-4 border-l-blue-500 shadow-sm min-w-[200px]"
                >
                  <div class="p-2 bg-blue-50 rounded-lg text-blue-600">
                    <Truck class="w-4 h-4" />
                  </div>
                  <div class="flex flex-col">
                    <span class="text-xs text-muted-foreground font-medium">{{
                      t('truckScale.totalExpected') || 'Total Expected'
                    }}</span>
                    <span class="text-xl font-bold leading-none">{{ stats.total }}</span>
                  </div>
                </div>

                <div
                  class="rounded-lg border bg-background px-4 py-2 flex items-center gap-4 border-l-4 border-l-green-500 shadow-sm min-w-[200px]"
                >
                  <div class="p-2 bg-green-50 rounded-lg text-green-600">
                    <CheckCircle class="w-4 h-4" />
                  </div>
                  <div class="flex flex-col">
                    <span class="text-xs text-muted-foreground font-medium">{{
                      t('truckScale.stats.checkedIn')
                    }}</span>
                    <span class="text-xl font-bold leading-none text-green-600">{{
                      stats.checkedIn
                    }}</span>
                  </div>
                </div>

                <div
                  class="rounded-lg border bg-background px-4 py-2 flex items-center gap-4 border-l-4 border-l-orange-500 shadow-sm min-w-[200px]"
                >
                  <div class="p-2 bg-orange-50 rounded-lg text-orange-600">
                    <Clock class="w-4 h-4" />
                  </div>
                  <div class="flex flex-col">
                    <span class="text-xs text-muted-foreground font-medium">{{
                      t('truckScale.stats.pending')
                    }}</span>
                    <span class="text-xl font-bold leading-none text-orange-600">{{
                      stats.pending
                    }}</span>
                  </div>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>

        <!-- DataTable -->
        <DataTable :columns="columns" :data="filteredBookings" :loading="isLoading" />
      </TabsContent>

      <TabsContent value="scale-in" class="space-y-6 mt-0">
        <!-- Controls & Stats (Scale In) -->
        <Card class="border-none shadow-sm bg-card/50 backdrop-blur-sm">
          <CardContent class="p-6 space-y-6">
            <div class="flex flex-col xl:flex-row gap-6 items-end justify-between">
              <!-- Filters Group -->
              <div class="flex flex-col md:flex-row gap-4 items-end w-full xl:w-auto">
                <div class="grid gap-2 w-full md:w-auto">
                  <Label>{{ t('booking.selectDate') }}</Label>
                  <Popover v-model:open="isDatePopoverOpen">
                    <PopoverTrigger as-child>
                      <Button
                        variant="outline"
                        :class="
                          cn(
                            'w-full md:w-[200px] justify-start text-left font-normal',
                            !selectedDate && 'text-muted-foreground'
                          )
                        "
                      >
                        <CalendarIcon class="mr-2 h-4 w-4" />
                        <span>{{
                          selectedDate
                            ? format(new Date(selectedDate), 'dd-MMM-yyyy')
                            : 'Pick a date'
                        }}</span>
                      </Button>
                    </PopoverTrigger>
                    <PopoverContent class="w-auto p-0">
                      <Calendar
                        :model-value="selectedDateObject"
                        @update:model-value="handleDateSelect"
                        mode="single"
                        initial-focus
                      />
                    </PopoverContent>
                  </Popover>
                </div>
                <div class="grid gap-2 w-full md:w-[320px]">
                  <Label>{{ t('truckScale.searchBooking') }}</Label>
                  <div class="relative">
                    <Search class="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
                    <Input
                      v-model="searchQuery"
                      :placeholder="t('truckScale.searchPlaceholder')"
                      class="pl-9"
                    />
                  </div>
                </div>
                <Button
                  class="bg-blue-600 hover:bg-blue-700 w-full md:w-auto"
                  @click="fetchBookings"
                >
                  <Search class="w-4 h-4 mr-2" />
                  {{ t('common.search') }}
                </Button>
              </div>

              <!-- Stats Cards Group -->
              <div class="grid grid-cols-1 md:grid-cols-3 gap-4 w-full xl:w-auto mt-4 xl:mt-0">
                <div
                  class="rounded-lg border bg-background px-4 py-2 flex items-center gap-4 border-l-4 border-l-blue-500 shadow-sm min-w-[200px]"
                >
                  <div class="p-2 bg-blue-50 rounded-lg text-blue-600">
                    <Truck class="w-4 h-4" />
                  </div>
                  <div class="flex flex-col">
                    <span class="text-xs text-muted-foreground font-medium">{{
                      t('truckScale.totalExpected')
                    }}</span>
                    <span class="text-xl font-bold leading-none">{{ stats.total }}</span>
                  </div>
                </div>

                <div
                  class="rounded-lg border bg-background px-4 py-2 flex items-center gap-4 border-l-4 border-l-green-500 shadow-sm min-w-[200px]"
                >
                  <div class="p-2 bg-green-50 rounded-lg text-green-600">
                    <CheckCircle class="w-4 h-4" />
                  </div>
                  <div class="flex flex-col">
                    <span class="text-xs text-muted-foreground font-medium">{{
                      t('truckScale.stats.checkedIn')
                    }}</span>
                    <span class="text-xl font-bold leading-none text-green-600">{{
                      stats.checkedIn
                    }}</span>
                  </div>
                </div>

                <div
                  class="rounded-lg border bg-background px-4 py-2 flex items-center gap-4 border-l-4 border-l-orange-500 shadow-sm min-w-[200px]"
                >
                  <div class="p-2 bg-orange-50 rounded-lg text-orange-600">
                    <Clock class="w-4 h-4" />
                  </div>
                  <div class="flex flex-col">
                    <span class="text-xs text-muted-foreground font-medium">{{
                      t('truckScale.stats.pending')
                    }}</span>
                    <span class="text-xl font-bold leading-none text-orange-600">{{
                      stats.pending
                    }}</span>
                  </div>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>

        <DataTable :columns="scaleInColumns" :data="filteredBookings" :loading="isLoading" />
      </TabsContent>

      <TabsContent value="scale-out" class="space-y-6 mt-0">
        <!-- Controls & Stats (Scale Out) -->
        <Card class="border-none shadow-sm bg-card/50 backdrop-blur-sm">
          <CardContent class="p-6 space-y-6">
            <div class="flex flex-col xl:flex-row gap-6 items-end justify-between">
              <!-- Filters Group -->
              <div class="flex flex-col md:flex-row gap-4 items-end w-full xl:w-auto">
                <div class="grid gap-2 w-full md:w-auto">
                  <Label>{{ t('booking.selectDate') }}</Label>
                  <Popover v-model:open="isDatePopoverOpen">
                    <PopoverTrigger as-child>
                      <Button
                        variant="outline"
                        :class="
                          cn(
                            'w-full md:w-[200px] justify-start text-left font-normal',
                            !selectedDate && 'text-muted-foreground'
                          )
                        "
                      >
                        <CalendarIcon class="mr-2 h-4 w-4" />
                        <span>{{
                          selectedDate
                            ? format(new Date(selectedDate), 'dd-MMM-yyyy')
                            : t('truckScale.pickDate')
                        }}</span>
                      </Button>
                    </PopoverTrigger>
                    <PopoverContent class="w-auto p-0">
                      <Calendar
                        :model-value="selectedDateObject"
                        @update:model-value="handleDateSelect"
                        mode="single"
                        initial-focus
                      />
                    </PopoverContent>
                  </Popover>
                </div>
                <div class="grid gap-2 w-full md:w-[320px]">
                  <Label>{{ t('truckScale.searchBooking') }}</Label>
                  <div class="relative">
                    <Search class="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
                    <Input
                      v-model="searchQuery"
                      :placeholder="t('truckScale.searchPlaceholder')"
                      class="pl-9"
                    />
                  </div>
                </div>
                <Button
                  class="bg-blue-600 hover:bg-blue-700 w-full md:w-auto"
                  @click="fetchBookings"
                >
                  <Search class="w-4 h-4 mr-2" />
                  {{ t('common.search') }}
                </Button>
              </div>

              <!-- Stats Cards Group -->
              <div class="grid grid-cols-1 md:grid-cols-3 gap-4 w-full xl:w-auto mt-4 xl:mt-0">
                <div
                  class="rounded-lg border bg-background px-4 py-2 flex items-center gap-4 border-l-4 border-l-blue-500 shadow-sm min-w-[200px]"
                >
                  <div class="p-2 bg-blue-50 rounded-lg text-blue-600">
                    <Truck class="w-4 h-4" />
                  </div>
                  <div class="flex flex-col">
                    <span class="text-xs text-muted-foreground font-medium">{{
                      t('truckScale.totalExpected')
                    }}</span>
                    <span class="text-xl font-bold leading-none">{{ stats.total }}</span>
                  </div>
                </div>

                <div
                  class="rounded-lg border bg-background px-4 py-2 flex items-center gap-4 border-l-4 border-l-green-500 shadow-sm min-w-[200px]"
                >
                  <div class="p-2 bg-green-50 rounded-lg text-green-600">
                    <CheckCircle class="w-4 h-4" />
                  </div>
                  <div class="flex flex-col">
                    <span class="text-xs text-muted-foreground font-medium">{{
                      t('truckScale.stats.checkedIn')
                    }}</span>
                    <span class="text-xl font-bold leading-none text-green-600">{{
                      stats.checkedIn
                    }}</span>
                  </div>
                </div>

                <div
                  class="rounded-lg border bg-background px-4 py-2 flex items-center gap-4 border-l-4 border-l-orange-500 shadow-sm min-w-[200px]"
                >
                  <div class="p-2 bg-orange-50 rounded-lg text-orange-600">
                    <Clock class="w-4 h-4" />
                  </div>
                  <div class="flex flex-col">
                    <span class="text-xs text-muted-foreground font-medium">{{
                      t('truckScale.stats.pending')
                    }}</span>
                    <span class="text-xl font-bold leading-none text-orange-600">{{
                      stats.pending
                    }}</span>
                  </div>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
        <DataTable :columns="scaleOutColumns" :data="filteredBookings" :loading="isLoading" />
      </TabsContent>

      <TabsContent value="dashboard" class="space-y-6 mt-0">
        <!-- Controls & Stats (Dashboard) -->
        <Card class="border-none shadow-sm bg-card/50 backdrop-blur-sm">
          <CardContent class="p-6 space-y-6">
            <div class="flex flex-col xl:flex-row gap-6 items-end justify-between">
              <!-- Filters Group -->
              <div class="flex flex-col md:flex-row gap-4 items-end w-full xl:w-auto">
                <div class="grid gap-2 w-full md:w-auto">
                  <Label>{{ t('booking.selectDate') }}</Label>
                  <Popover v-model:open="isDatePopoverOpen">
                    <PopoverTrigger as-child>
                      <Button
                        variant="outline"
                        :class="
                          cn(
                            'w-full md:w-[200px] justify-start text-left font-normal',
                            !selectedDate && 'text-muted-foreground'
                          )
                        "
                      >
                        <CalendarIcon class="mr-2 h-4 w-4" />
                        <span>{{
                          selectedDate
                            ? format(new Date(selectedDate), 'dd-MMM-yyyy')
                            : t('truckScale.pickDate')
                        }}</span>
                      </Button>
                    </PopoverTrigger>
                    <PopoverContent class="w-auto p-0">
                      <Calendar
                        :model-value="selectedDateObject"
                        @update:model-value="handleDateSelect"
                        mode="single"
                        initial-focus
                      />
                    </PopoverContent>
                  </Popover>
                </div>
                <div class="grid gap-2 w-full md:w-[320px]">
                  <Label>{{ t('truckScale.searchBooking') }}</Label>
                  <div class="relative">
                    <Search class="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
                    <Input
                      v-model="searchQuery"
                      :placeholder="t('truckScale.searchPlaceholder')"
                      class="pl-9"
                    />
                  </div>
                </div>
                <Button
                  class="bg-blue-600 hover:bg-blue-700 w-full md:w-auto"
                  @click="fetchBookings"
                >
                  <Search class="w-4 h-4 mr-2" />
                  {{ t('common.search') }}
                </Button>
              </div>

              <!-- Stats Cards Group (Dashboard Specific) -->
              <div class="grid grid-cols-1 md:grid-cols-4 gap-4 w-full xl:w-auto mt-4 xl:mt-0">
                <div
                  class="rounded-lg border bg-background px-4 py-2 flex flex-col justify-center gap-1 border-l-4 border-l-blue-500 shadow-sm min-w-[150px]"
                >
                  <span class="text-xs text-muted-foreground font-medium">{{
                    t('truckScale.stats.totalTrips')
                  }}</span>
                  <span class="text-xl font-bold leading-none">{{ dashboardStats.count }}</span>
                </div>

                <div
                  class="rounded-lg border bg-background px-4 py-2 flex flex-col justify-center gap-1 border-l-4 border-l-green-500 shadow-sm min-w-[150px]"
                >
                  <span class="text-xs text-muted-foreground font-medium">{{
                    t('truckScale.stats.totalNetWeight')
                  }}</span>
                  <span class="text-xl font-bold leading-none text-green-600"
                    >{{ dashboardStats.net.toLocaleString() }} Kg.</span
                  >
                </div>

                <div
                  class="rounded-lg border bg-background px-4 py-2 flex flex-col justify-center gap-1 border-l-4 border-l-blue-400 shadow-sm min-w-[150px]"
                >
                  <span class="text-xs text-muted-foreground font-medium">{{
                    t('truckScale.stats.totalGross')
                  }}</span>
                  <span class="text-xl font-bold leading-none text-blue-500"
                    >{{ dashboardStats.gross.toLocaleString() }} Kg.</span
                  >
                </div>

                <div
                  class="rounded-lg border bg-background px-4 py-2 flex flex-col justify-center gap-1 border-l-4 border-l-orange-500 shadow-sm min-w-[150px]"
                >
                  <span class="text-xs text-muted-foreground font-medium">{{
                    t('truckScale.stats.inOut')
                  }}</span>
                  <div class="flex items-baseline gap-1">
                    <span class="text-lg font-bold text-blue-600">{{
                      dashboardStats.weightIn.toLocaleString()
                    }}</span>
                    <span class="text-muted-foreground">/</span>
                    <span class="text-lg font-bold text-orange-600">{{
                      dashboardStats.weightOut.toLocaleString()
                    }}</span>
                    <span class="text-sm text-muted-foreground ml-1">Kg.</span>
                  </div>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>

        <DataTable :columns="dashboardColumns" :data="filteredBookings" :loading="isLoading" />
      </TabsContent>
    </Tabs>

    <!-- Check-in Confirmation Dialog -->
    <!-- Check-in Dialog -->
    <Dialog v-model:open="checkInDialogOpen">
      <DialogContent class="sm:max-w-[700px]">
        <!-- STEP 1: FORM -->
        <div v-if="checkInStep === 1">
          <DialogHeader class="mb-4">
            <DialogTitle class="text-xl">{{ t('truckScale.checkInRecord') }}</DialogTitle>
            <DialogDescription class="sr-only">{{
              t('truckScale.formDescription')
            }}</DialogDescription>
          </DialogHeader>

          <!-- Booking Details Card -->
          <div class="bg-muted/30 rounded-lg p-4 mb-6 border">
            <div class="flex items-center gap-2 mb-4">
              <div class="w-1 h-6 bg-blue-600 rounded-full"></div>
              <span class="font-semibold text-base">{{ t('approval.requestDetails') }}</span>
              <Badge
                variant="secondary"
                class="ml-auto bg-blue-100 text-blue-700 hover:bg-blue-100 text-lg px-3 py-1"
              >
                Q{{ selectedBooking?.queueNo }}
              </Badge>
            </div>

            <div class="space-y-2 text-sm">
              <div class="grid grid-cols-[100px_1fr] items-center">
                <span class="text-muted-foreground">{{ t('truckScale.date') }}</span>
                <span class="font-medium">
                  {{
                    selectedBooking?.date
                      ? format(new Date(selectedBooking.date), 'dd-MMM-yyyy')
                      : '-'
                  }}
                </span>
              </div>
              <div class="grid grid-cols-[100px_1fr] items-center">
                <span class="text-muted-foreground">{{ t('booking.timeSlot') }}</span>
                <span class="font-medium">
                  {{ selectedBooking?.startTime }} - {{ selectedBooking?.endTime }}
                </span>
              </div>
              <div class="grid grid-cols-[100px_1fr] items-center">
                <span class="text-muted-foreground">{{ t('booking.bookingCode') }}</span>
                <span class="font-medium">{{ selectedBooking?.bookingCode }}</span>
              </div>
              <div class="grid grid-cols-[100px_1fr] items-center">
                <span class="text-muted-foreground">{{ t('truckScale.supplier') }}</span>
                <span class="font-medium">
                  {{ selectedBooking?.supplierCode }} — {{ selectedBooking?.supplierName }}
                </span>
              </div>
            </div>
          </div>

          <!-- Check-in Form -->
          <div class="grid gap-4 py-4">
            <!-- Row 1: Time & Recorder -->
            <div class="grid grid-cols-2 gap-4">
              <div class="grid gap-2">
                <Label>{{ t('truckScale.checkInTime') }}</Label>
                <Input
                  :model-value="checkInTime ? format(checkInTime, 'HH:mm') : '-'"
                  readonly
                  class="bg-muted font-mono"
                />
              </div>
              <div class="grid gap-2">
                <Label>{{ t('booking.recorder') }}</Label>
                <Input :model-value="recorderName" readonly class="bg-muted" />
              </div>
            </div>

            <!-- Row 2: Truck Info -->
            <div class="grid grid-cols-2 gap-4">
              <div class="grid gap-2">
                <Label
                  >{{ t('truckScale.truckType') }} <span class="text-destructive">*</span></Label
                >
                <Select v-model="checkInData.truckType">
                  <SelectTrigger>
                    <SelectValue :placeholder="t('truckScale.selectTruckType')" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="กระบะ">{{ t('truckScale.truckTypes.pickup') }}</SelectItem>
                    <SelectItem value="6 ล้อ">{{ t('truckScale.truckTypes.6wheeler') }}</SelectItem>
                    <SelectItem value="10 ล้อ">{{
                      t('truckScale.truckTypes.10wheeler')
                    }}</SelectItem>
                    <SelectItem value="10 ล้อ พ่วง">{{
                      t('truckScale.truckTypes.10wheelerTrailer')
                    }}</SelectItem>
                    <SelectItem value="เทรลเลอร์">{{
                      t('truckScale.truckTypes.trailer')
                    }}</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div class="grid grid-cols-2 gap-4">
                <div class="grid gap-2 col-span-2">
                  <Label
                    >{{ t('truckScale.licensePlate') }}
                    <span class="text-destructive">*</span></Label
                  >
                  <Input v-model="checkInData.truckRegister" placeholder="Ex. 1กข 1234" />
                </div>
              </div>
            </div>

            <!-- Note -->
            <div class="grid gap-2">
              <Label>{{ t('approval.note') }}</Label>
              <Textarea
                v-model="checkInData.note"
                placeholder="Additional details (if any)"
                class="min-h-[100px]"
              />
            </div>
          </div>

          <DialogFooter>
            <Button variant="outline" @click="checkInDialogOpen = false">
              {{ t('common.close') }}
            </Button>
            <Button class="bg-blue-600 hover:bg-blue-700" @click="handleNextStep">
              {{ t('common.confirm') }}
            </Button>
          </DialogFooter>
        </div>

        <!-- STEP 2: CONFIRMATION -->
        <div v-else class="flex flex-col items-center justify-center py-6 text-center space-y-6">
          <DialogHeader class="mb-2">
            <DialogTitle class="text-2xl font-bold">{{
              t('truckScale.confirmCheckIn')
            }}</DialogTitle>
            <DialogDescription class="sr-only">{{
              t('truckScale.confirmCheckIn')
            }}</DialogDescription>
          </DialogHeader>

          <div class="space-y-2">
            <p class="text-muted-foreground text-sm">{{ t('truckScale.verifyBeforeConfirm') }}</p>
          </div>

          <div class="bg-muted/30 border rounded-xl p-6 w-full max-w-sm mx-auto space-y-6">
            <!-- Primary Info: Supplier & Time -->
            <div class="space-y-2">
              <div class="text-sm text-muted-foreground font-medium">
                {{ t('truckScale.supplier') }}
              </div>
              <div class="text-2xl font-bold text-foreground leading-tight">
                {{ selectedBooking?.supplierCode }} — {{ selectedBooking?.supplierName }}
              </div>
            </div>

            <div class="space-y-2">
              <div class="text-sm text-muted-foreground font-medium">
                {{ t('truckScale.checkInTime') }}
              </div>
              <div
                class="text-3xl font-extrabold text-blue-600 bg-blue-50 py-3 rounded-lg border border-blue-100"
              >
                {{ checkInTime ? format(checkInTime, 'HH:mm') : '-' }}
              </div>
            </div>

            <div class="border-t pt-4 space-y-3">
              <div class="grid grid-cols-2 gap-2 text-sm">
                <div class="text-muted-foreground">{{ t('booking.bookingCode') }}</div>
                <div class="font-medium text-right">{{ selectedBooking?.bookingCode }}</div>

                <div class="text-muted-foreground">{{ t('truckScale.truck') }}</div>
                <div class="font-medium text-right">
                  {{ checkInData.truckType || '-' }} • {{ checkInData.truckRegister || '-' }}
                </div>
              </div>
            </div>
          </div>

          <div class="flex gap-4 w-full max-w-sm justify-center pt-4">
            <Button variant="outline" class="w-full h-11" @click="checkInStep = 1">
              {{ t('common.cancel') }}
            </Button>
            <Button class="w-full h-11 bg-blue-600 hover:bg-blue-700" @click="confirmCheckIn">
              {{ t('common.confirm') }}
            </Button>
          </div>
        </div>
      </DialogContent>
    </Dialog>

    <!-- Start Drain Dialog -->
    <Dialog v-model:open="startDrainDialogOpen">
      <DialogContent class="sm:max-w-[425px]">
        <DialogHeader>
          <DialogTitle>{{ t('truckScale.confirmStartDrainTimer') }}</DialogTitle>
          <DialogDescription class="sr-only">{{
            t('truckScale.confirmStartDrainDescription') || 'Confirm to start drain timer.'
          }}</DialogDescription>
        </DialogHeader>

        <div class="space-y-4 py-2">
          <!-- Truck Card -->
          <div class="bg-muted/50 p-4 rounded-xl flex items-center justify-between border">
            <div class="flex items-center gap-3">
              <div class="bg-background p-2.5 rounded-lg border shadow-sm">
                <Truck class="w-6 h-6 text-blue-600" />
              </div>
              <div>
                <div class="font-bold text-lg leading-none mb-1">
                  {{ selectedDrainBooking?.truckRegister }}
                </div>
                <div
                  class="text-xs text-muted-foreground bg-white px-2 py-0.5 rounded border inline-block"
                >
                  {{ selectedDrainBooking?.truckType }}
                </div>
              </div>
            </div>
            <Badge class="bg-blue-600 hover:bg-blue-700 text-base px-3 py-0.5 shadow-sm">
              Q {{ selectedDrainBooking?.queueNo }}
            </Badge>
          </div>

          <!-- Details List -->
          <div class="space-y-3 px-1">
            <div class="grid grid-cols-[100px_1fr] text-sm">
              <span class="text-muted-foreground">{{ t('truckScale.supplier') }} :</span>
              <span class="font-medium text-foreground truncate">{{
                selectedDrainBooking?.supplierName
              }}</span>
            </div>
            <div class="grid grid-cols-[100px_1fr] text-sm">
              <span class="text-muted-foreground">{{ t('booking.bookingCode') }} :</span>
              <span class="font-medium font-mono text-foreground">{{
                selectedDrainBooking?.bookingCode
              }}</span>
            </div>
            <div class="grid grid-cols-[100px_1fr] text-sm">
              <span class="text-muted-foreground">{{ t('truckScale.rubberType') }} :</span>
              <span class="font-medium text-foreground">{{
                getRubberTypeName(selectedDrainBooking?.rubberType)
              }}</span>
            </div>
          </div>

          <div class="border-t my-2"></div>

          <!-- Time Action -->
          <div
            class="flex justify-between items-center bg-green-50 p-4 rounded-xl border border-green-100"
          >
            <span class="text-green-700 font-medium text-sm">{{ t('truckScale.startTime') }}:</span>
            <span
              class="text-green-700 font-mono text-xl font-bold bg-white px-3 py-1 rounded-lg border border-green-200 shadow-sm"
            >
              {{ format(new Date(), 'HH:mm') }}
            </span>
          </div>
        </div>

        <DialogFooter class="gap-2 sm:gap-0 mt-2">
          <Button variant="outline" @click="startDrainDialogOpen = false" class="h-10">{{
            t('common.cancel')
          }}</Button>
          <Button class="bg-green-600 hover:bg-green-700 h-10 px-8" @click="confirmStartDrain">{{
            t('common.confirm')
          }}</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>

    <!-- Stop Drain Dialog -->
    <Dialog v-model:open="stopDrainDialogOpen">
      <DialogContent class="sm:max-w-[425px]">
        <DialogHeader>
          <DialogTitle>{{ t('truckScale.confirmStopDrainTimer') }}</DialogTitle>
          <DialogDescription class="sr-only">{{
            t('truckScale.confirmStopDrainDescription') || 'Confirm to stop drain timer.'
          }}</DialogDescription>
        </DialogHeader>

        <div class="space-y-4 py-2">
          <!-- Truck Card -->
          <div class="bg-muted/50 p-4 rounded-xl flex items-center justify-between border">
            <div class="flex items-center gap-3">
              <div class="bg-background p-2.5 rounded-lg border shadow-sm">
                <Truck class="w-6 h-6 text-blue-600" />
              </div>
              <div>
                <div class="font-bold text-lg leading-none mb-1">
                  {{ selectedDrainBooking?.truckRegister }}
                </div>
                <div
                  class="text-xs text-muted-foreground bg-white px-2 py-0.5 rounded border inline-block"
                >
                  {{ selectedDrainBooking?.truckType }}
                </div>
              </div>
            </div>
            <Badge class="bg-blue-600 hover:bg-blue-700 text-base px-3 py-0.5 shadow-sm">
              Q {{ selectedDrainBooking?.queueNo }}
            </Badge>
          </div>

          <!-- Details List -->
          <div class="space-y-3 px-1">
            <div class="grid grid-cols-[100px_1fr] text-sm">
              <span class="text-muted-foreground">{{ t('truckScale.supplier') }} :</span>
              <span class="font-medium text-foreground truncate">{{
                selectedDrainBooking?.supplierName
              }}</span>
            </div>
            <div class="grid grid-cols-[100px_1fr] text-sm">
              <span class="text-muted-foreground">{{ t('booking.bookingCode') }} :</span>
              <span class="font-medium font-mono text-foreground">{{
                selectedDrainBooking?.bookingCode
              }}</span>
            </div>
            <div class="grid grid-cols-[100px_1fr] text-sm">
              <span class="text-muted-foreground">Rubber Type :</span>
              <span class="font-medium text-foreground">{{
                getRubberTypeName(selectedDrainBooking?.rubberType)
              }}</span>
            </div>
          </div>

          <div class="border-t my-2"></div>

          <!-- Time Comparison -->
          <div class="grid grid-cols-2 gap-3">
            <div class="border p-3 rounded-lg bg-background">
              <div class="text-xs text-muted-foreground mb-1">{{ t('truckScale.startTime') }}</div>
              <div class="text-green-600 font-bold text-lg flex items-center gap-1.5">
                <Clock class="w-4 h-4" />
                {{
                  selectedDrainBooking?.startDrainAt
                    ? format(new Date(selectedDrainBooking.startDrainAt), 'HH:mm')
                    : '-'
                }}
              </div>
            </div>
            <div class="border p-3 rounded-lg bg-red-50 border-red-100">
              <div class="text-xs text-red-500 mb-1">{{ t('truckScale.stopTime') }}</div>
              <div class="text-red-600 font-bold text-lg flex items-center gap-1.5">
                <Clock class="w-4 h-4" /> {{ format(new Date(), 'HH:mm') }}
              </div>
            </div>
          </div>

          <div
            class="bg-orange-50 border border-orange-100 p-3 rounded-lg flex justify-between items-center"
          >
            <div class="flex items-center gap-2 text-orange-700 text-sm font-medium">
              <span>⏳ {{ t('truckScale.totalDuration') }}</span>
            </div>
            <div class="text-xl font-bold text-orange-700">
              {{ calculateDuration(selectedDrainBooking?.startDrainAt, new Date()) }}
            </div>
          </div>

          <div
            v-if="
              selectedDrainBooking?.startDrainAt &&
              (new Date().getTime() - new Date(selectedDrainBooking.startDrainAt).getTime()) /
                60000 <
                40
            "
            class="grid gap-2"
          >
            <Label class="text-red-600">{{ t('truckScale.reasonRequired') }} *</Label>
            <Textarea
              v-model="stopDrainReason"
              :placeholder="t('truckScale.specifyReason')"
              class="resize-none"
              rows="3"
            />
          </div>
        </div>

        <DialogFooter class="gap-2 sm:gap-0 mt-2">
          <Button variant="outline" @click="stopDrainDialogOpen = false" class="h-10">{{
            t('common.cancel')
          }}</Button>
          <Button class="bg-red-600 hover:bg-red-700 h-10 px-8" @click="confirmStopDrain">{{
            t('truckScale.confirmStop')
          }}</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>

    <!-- Weight In Dialog -->
    <Dialog v-model:open="weightInDialogOpen">
      <DialogContent class="sm:max-w-4xl">
        <DialogHeader>
          <DialogTitle>{{ t('truckScale.recordWeightIn') }}</DialogTitle>
          <DialogDescription class="sr-only">
            {{
              t('truckScale.recordWeightInDescription') ||
              'Record weight in data including rubber source and type.'
            }}
          </DialogDescription>
        </DialogHeader>

        <!-- Trailer Layout -->
        <div
          v-if="['10 ล้อ พ่วง', '10 ล้อ (พ่วง)'].includes(selectedDrainBooking?.truckType)"
          class="grid md:grid-cols-2 gap-8 py-4"
        >
          <!-- Main Truck -->
          <div class="space-y-4">
            <h3 class="font-semibold text-lg border-b pb-2 flex items-center gap-2">
              <div class="w-1 h-5 bg-primary rounded-full"></div>
              {{ t('truckScale.mainTruck') }}
            </h3>
            <div class="grid gap-4">
              <div class="grid gap-2">
                <Label>{{ t('truckScale.rubberSource') }}</Label>
                <Combobox
                  v-model="weightInData.rubberSource"
                  :options="provinceOptions"
                  :placeholder="t('truckScale.specifySource')"
                  :search-placeholder="t('admin.suppliers.dialog.placeholders.searchProvince')"
                  :empty-text="t('admin.suppliers.dialog.errors.provinceNotFound')"
                />
              </div>
              <div class="grid gap-2">
                <Label>{{ t('truckScale.rubberType') }}</Label>
                <Combobox
                  v-model="weightInData.rubberType"
                  :options="rubberTypeOptions"
                  :placeholder="t('truckScale.selectRubberType')"
                  :search-placeholder="t('truckScale.searchRubberType')"
                  :empty-text="t('truckScale.rubberTypeNotFound')"
                />
              </div>
              <div class="grid gap-2">
                <Label>{{ t('truckScale.weight') }} (kg)</Label>
                <Input
                  v-model="formattedWeightIn"
                  class="text-lg font-medium"
                  placeholder="0"
                  @keydown="
                    (e: KeyboardEvent) => {
                      if (
                        !/^[0-9]$/.test(e.key) &&
                        ![
                          'Backspace',
                          'Delete',
                          'ArrowLeft',
                          'ArrowRight',
                          'Tab',
                          'Enter',
                        ].includes(e.key)
                      ) {
                        e.preventDefault();
                      }
                    }
                  "
                />
              </div>
            </div>
          </div>

          <!-- Trailer -->
          <div class="space-y-4">
            <h3 class="font-semibold text-lg border-b pb-2 flex items-center gap-2">
              <div class="w-1 h-5 bg-orange-500 rounded-full"></div>
              {{ t('truckScale.trailer') }}
            </h3>
            <div class="grid gap-4">
              <div class="grid gap-2">
                <Label>{{ t('truckScale.rubberSource') }}</Label>
                <Combobox
                  v-model="weightInData.trailerRubberSource"
                  :options="provinceOptions"
                  :placeholder="t('truckScale.specifySource')"
                  :search-placeholder="t('admin.suppliers.dialog.placeholders.searchProvince')"
                  :empty-text="t('admin.suppliers.dialog.errors.provinceNotFound')"
                />
              </div>
              <div class="grid gap-2">
                <Label>{{ t('truckScale.rubberType') }}</Label>
                <Combobox
                  v-model="weightInData.trailerRubberType"
                  :options="rubberTypeOptions"
                  :placeholder="t('truckScale.selectRubberType')"
                  :search-placeholder="t('truckScale.searchRubberType')"
                  :empty-text="t('truckScale.rubberTypeNotFound')"
                />
              </div>
              <div class="grid gap-2">
                <Label>{{ t('truckScale.weight') }} (kg)</Label>
                <Input
                  v-model="formattedTrailerWeightIn"
                  class="text-lg font-medium"
                  placeholder="0"
                  @keydown="
                    (e: KeyboardEvent) => {
                      if (
                        !/^[0-9]$/.test(e.key) &&
                        ![
                          'Backspace',
                          'Delete',
                          'ArrowLeft',
                          'ArrowRight',
                          'Tab',
                          'Enter',
                        ].includes(e.key)
                      ) {
                        e.preventDefault();
                      }
                    }
                  "
                />
              </div>
            </div>
          </div>
        </div>

        <!-- Standard Layout (No Trailer) -->
        <div v-else class="grid grid-cols-2 gap-4 py-4">
          <div class="grid gap-2">
            <Label>{{ t('truckScale.rubberSource') }}</Label>
            <Combobox
              v-model="weightInData.rubberSource"
              :options="provinceOptions"
              :placeholder="t('truckScale.specifySource')"
              :search-placeholder="
                t('admin.suppliers.dialog.placeholders.searchProvince') || 'Search province...'
              "
              :empty-text="
                t('admin.suppliers.dialog.errors.provinceNotFound') || 'Province not found'
              "
            />
          </div>
          <div class="grid gap-2">
            <Label>{{ t('truckScale.rubberType') }}</Label>
            <Combobox
              v-model="weightInData.rubberType"
              :options="rubberTypeOptions"
              :placeholder="t('truckScale.selectRubberType')"
              :search-placeholder="t('truckScale.searchRubberType') || 'Search rubber type...'"
              :empty-text="t('truckScale.rubberTypeNotFound') || 'Rubber type not found'"
            />
          </div>
          <div class="grid gap-2 col-span-2">
            <Label>{{ t('truckScale.weight') }} (kg)</Label>
            <Input
              v-model="formattedWeightIn"
              class="text-lg font-medium"
              placeholder="0"
              @keydown="
                (e: KeyboardEvent) => {
                  if (
                    !/^[0-9]$/.test(e.key) &&
                    !['Backspace', 'Delete', 'ArrowLeft', 'ArrowRight', 'Tab', 'Enter'].includes(
                      e.key
                    )
                  ) {
                    e.preventDefault();
                  }
                }
              "
            />
          </div>
        </div>

        <DialogFooter>
          <Button variant="outline" @click="weightInDialogOpen = false">{{
            t('common.cancel')
          }}</Button>
          <Button class="bg-blue-600 hover:bg-blue-700" @click="saveWeightIn">{{
            t('common.save')
          }}</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>

    <!-- Weight Out Dialog -->
    <Dialog v-model:open="weightOutDialogOpen">
      <DialogContent class="sm:max-w-sm">
        <DialogHeader>
          <DialogTitle>{{ t('truckScale.recordWeightOut') }} (kg)</DialogTitle>
        </DialogHeader>

        <div class="grid gap-4 py-4">
          <div class="grid gap-2">
            <Label>{{ t('truckScale.weightOutLabel') }}</Label>
            <Input
              :model-value="
                weightOutData.weightOut ? Number(weightOutData.weightOut).toLocaleString() : ''
              "
              @input="
                (e: any) => {
                  const value = e.target.value.replace(/[^0-9]/g, '');
                  weightOutData.weightOut = value ? Number(value) : null;
                  e.target.value = value ? Number(value).toLocaleString() : '';
                }
              "
              type="text"
              class="text-xl h-12"
              placeholder="0"
            />
          </div>
        </div>

        <DialogFooter class="flex justify-between sm:justify-end gap-2">
          <Button variant="outline" @click="weightOutDialogOpen = false">{{
            t('common.cancel')
          }}</Button>
          <Button class="bg-blue-600 hover:bg-blue-700" @click="handleWeightOutNext">{{
            t('common.save')
          }}</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>

    <!-- Confirm Check Out Dialog -->
    <Dialog v-model:open="confirmCheckoutDialogOpen">
      <DialogContent class="max-w-md">
        <DialogHeader>
          <DialogTitle>{{ t('truckScale.confirmWeightOutRecord') }}</DialogTitle>
        </DialogHeader>

        <div class="bg-muted/30 border rounded-lg p-4 mb-4">
          <div class="flex items-center justify-between mb-1">
            <div class="flex items-center gap-2">
              <div class="bg-white border rounded p-1"><Truck class="w-4 h-4 text-blue-600" /></div>
              <div class="flex flex-col">
                <span class="font-bold text-lg leading-none">{{
                  selectedDrainBooking?.truckRegister
                }}</span>
                <span class="text-xs text-muted-foreground">{{
                  selectedDrainBooking?.truckType
                }}</span>
              </div>
            </div>
            <Badge class="bg-blue-600 text-sm px-3">Q {{ selectedDrainBooking?.queueNo }}</Badge>
          </div>
        </div>

        <div class="border rounded-lg p-4 space-y-3">
          <div class="flex justify-between items-center text-sm">
            <span class="text-muted-foreground">{{ t('truckScale.weightIn') }}:</span>
            <span class="font-medium text-lg"
              >{{ selectedDrainBooking?.weightIn?.toLocaleString() }} kg</span
            >
          </div>
          <div class="flex justify-between items-center text-sm border-b pb-3">
            <span class="text-muted-foreground">{{ t('truckScale.netWeightOut') }}</span>
            <span class="font-bold text-xl text-green-600"
              >{{ Number(weightOutData.weightOut).toLocaleString() }} kg</span
            >
          </div>
          <div class="flex justify-between items-center pt-1">
            <span class="text-blue-600 font-medium">{{ t('truckScale.netWeight') }}</span>
            <span class="font-bold text-2xl text-blue-600">
              {{
                Math.abs(
                  (selectedDrainBooking?.weightIn || 0) - Number(weightOutData.weightOut)
                ).toLocaleString()
              }}
              kg
            </span>
          </div>
        </div>

        <DialogFooter class="mt-4 gap-2">
          <Button variant="outline" class="w-full" @click="confirmCheckoutDialogOpen = false">{{
            t('common.cancel')
          }}</Button>
          <Button class="bg-green-600 hover:bg-green-700 w-full" @click="confirmWeightOut">{{
            t('common.confirm')
          }}</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>

    <!-- Request Edit Dialog -->
    <Dialog v-model:open="requestEditDialogOpen">
      <DialogContent class="sm:max-w-[425px]">
        <DialogHeader>
          <DialogTitle>{{ t('truckScale.requestEditTitle') }}</DialogTitle>
          <DialogDescription>
            {{ t('truckScale.requestEditDescription') }}
          </DialogDescription>
        </DialogHeader>

        <div class="grid gap-4 py-4">
          <div class="grid gap-2">
            <Label>{{ t('truckScale.reasonForEdit') }}</Label>
            <Textarea
              v-model="requestEditReason"
              :placeholder="t('truckScale.requestEditPlaceholder')"
              class="min-h-[100px]"
            />
          </div>
        </div>

        <DialogFooter>
          <Button variant="outline" @click="requestEditDialogOpen = false">{{
            t('common.cancel')
          }}</Button>
          <Button class="bg-blue-600 hover:bg-blue-700" @click="confirmRequestEdit">{{
            t('truckScale.sendRequest')
          }}</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>

    <!-- Booking Detail Dialog -->
    <Dialog v-model:open="detailDialogOpen">
      <DialogContent class="max-w-md">
        <DialogHeader>
          <DialogTitle>{{ t('truckScale.bookingDetails') || 'Booking Details' }}</DialogTitle>
        </DialogHeader>

        <div class="bg-muted/30 border rounded-lg p-4 mb-4">
          <div class="flex items-center justify-between mb-1">
            <div class="flex items-center gap-2">
              <div class="bg-white border rounded p-1"><Truck class="w-4 h-4 text-blue-600" /></div>
              <div class="flex flex-col">
                <span class="font-bold text-lg leading-none">{{
                  selectedDetailBooking?.truckRegister
                }}</span>
                <span class="text-xs text-muted-foreground">{{
                  selectedDetailBooking?.truckType
                }}</span>
              </div>
            </div>
            <Badge class="bg-blue-600 text-sm px-3">Q {{ selectedDetailBooking?.queueNo }}</Badge>
          </div>
          <div class="text-sm text-muted-foreground mt-2">
            <div>
              {{ selectedDetailBooking?.supplierCode }} : {{ selectedDetailBooking?.supplierName }}
            </div>
          </div>
        </div>

        <div class="border rounded-lg p-4 space-y-3">
          <div class="flex justify-between items-center text-sm">
            <span class="text-muted-foreground">{{ t('truckScale.rubberType') }}:</span>
            <span class="font-medium">{{ selectedDetailBooking?.rubberType }}</span>
          </div>
          <div class="flex justify-between items-center text-sm">
            <span class="text-muted-foreground">{{ t('truckScale.weightIn') }}:</span>
            <span class="font-medium text-lg"
              >{{ selectedDetailBooking?.weightIn?.toLocaleString() }} kg</span
            >
          </div>
          <div class="flex justify-between items-center text-sm border-b pb-3">
            <span class="text-muted-foreground">{{ t('truckScale.weightOutLabel') }}:</span>
            <span class="font-bold text-xl text-orange-600"
              >{{ selectedDetailBooking?.weightOut?.toLocaleString() }} kg</span
            >
          </div>
          <div class="flex justify-between items-center pt-1">
            <span class="text-blue-600 font-medium">{{ t('truckScale.netWeight') }}</span>
            <span class="font-bold text-2xl text-blue-600">
              {{
                Math.abs(
                  (selectedDetailBooking?.weightIn || 0) - (selectedDetailBooking?.weightOut || 0)
                ).toLocaleString()
              }}
              kg
            </span>
          </div>
        </div>

        <DialogFooter>
          <Button class="w-full" @click="detailDialogOpen = false">{{ t('common.close') }}</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>

    <!-- Time Log Dialog -->
    <Dialog v-model:open="timeLogDialogOpen">
      <DialogContent
        class="sm:max-w-md max-h-[90vh] overflow-hidden flex flex-col [&>button]:hidden"
      >
        <DialogHeader>
          <DialogTitle class="flex items-center justify-between">
            <span>{{ t('truckScale.timeLog') || 'Time Log' }}</span>
            <span class="text-sm font-normal text-blue-600">{{
              selectedDetailBooking?.checkinAt
                ? format(new Date(selectedDetailBooking.checkinAt), 'dd-MMM-yyyy')
                : ''
            }}</span>
          </DialogTitle>
        </DialogHeader>

        <div class="overflow-y-auto flex-1 px-1">
          <div class="space-y-1 mb-3 pb-3 border-b">
            <div class="flex items-center justify-between">
              <span class="font-semibold text-sm">{{ selectedDetailBooking?.bookingCode }}</span>
              <span class="text-xs text-muted-foreground">{{
                selectedDetailBooking?.truckRegister
              }}</span>
            </div>
            <div class="flex items-center justify-between">
              <span class="text-xs text-muted-foreground">
                {{ selectedDetailBooking?.supplierCode }} -
                {{ selectedDetailBooking?.supplierName }}
              </span>
              <span class="text-xs font-medium">{{ selectedDetailBooking?.truckType || '-' }}</span>
            </div>
          </div>

          <div class="relative pl-6 space-y-2 my-4">
            <!-- Vertical Line -->
            <div
              class="absolute left-2 top-0 bottom-0 w-0.5 bg-gradient-to-b from-blue-200 via-green-200 to-orange-200"
            ></div>

            <!-- Check-in -->
            <div class="relative flex items-baseline gap-3">
              <div
                class="absolute -left-[18px] w-4 h-4 rounded-full bg-blue-500 border-2 border-background"
              ></div>
              <span class="text-sm font-medium text-blue-700 dark:text-blue-400 min-w-[100px]"
                >Check-in</span
              >
              <span class="text-base font-bold">{{
                selectedDetailBooking?.checkinAt
                  ? format(new Date(selectedDetailBooking.checkinAt), 'HH:mm')
                  : '-'
              }}</span>
            </div>

            <!-- Weight In -->
            <div class="relative flex items-baseline gap-3">
              <div
                class="absolute -left-[18px] w-4 h-4 rounded-full bg-green-500 border-2 border-background"
              ></div>
              <span class="text-sm font-medium text-green-700 dark:text-green-400 min-w-[100px]"
                >Weight In</span
              >
              <span class="text-base font-bold text-green-600">{{
                selectedDetailBooking?.weightIn
                  ? selectedDetailBooking.weightIn.toLocaleString() + ' Kg.'
                  : '-'
              }}</span>
            </div>

            <!-- Start Drain -->
            <div class="relative flex items-baseline gap-3">
              <div
                class="absolute -left-[18px] w-4 h-4 rounded-full bg-yellow-500 border-2 border-background"
              ></div>
              <span class="text-sm font-medium text-yellow-700 dark:text-yellow-400 min-w-[100px]"
                >Start Drain</span
              >
              <span class="text-base font-bold">{{
                selectedDetailBooking?.startDrainAt
                  ? format(new Date(selectedDetailBooking.startDrainAt), 'HH:mm')
                  : '-'
              }}</span>
            </div>

            <!-- Stop Drain -->
            <div class="relative flex items-baseline gap-3">
              <div
                class="absolute -left-[18px] w-4 h-4 rounded-full bg-orange-500 border-2 border-background"
              ></div>
              <span class="text-sm font-medium text-orange-700 dark:text-orange-400 min-w-[100px]"
                >Stop Drain</span
              >
              <span class="text-base font-bold">{{
                selectedDetailBooking?.stopDrainAt
                  ? format(new Date(selectedDetailBooking.stopDrainAt), 'HH:mm:ss')
                  : '-'
              }}</span>
            </div>

            <!-- Total Drain -->
            <div
              v-if="selectedDetailBooking?.startDrainAt && selectedDetailBooking?.stopDrainAt"
              class="relative flex items-baseline gap-3"
            >
              <div
                class="absolute -left-[18px] w-4 h-4 rounded-full bg-amber-500 border-2 border-background"
              ></div>
              <span class="text-sm font-medium text-amber-700 dark:text-amber-400 min-w-[100px]"
                >Total Drain</span
              >
              <span class="text-base font-bold text-amber-600">
                {{
                  Math.floor(
                    (new Date(selectedDetailBooking.stopDrainAt).getTime() -
                      new Date(selectedDetailBooking.startDrainAt).getTime()) /
                      60000
                  )
                }}
                Min
              </span>
            </div>

            <!-- Weight Out -->
            <div class="relative flex items-baseline gap-3">
              <div
                class="absolute -left-[18px] w-4 h-4 rounded-full bg-red-500 border-2 border-background"
              ></div>
              <span class="text-sm font-medium text-red-700 dark:text-red-400 min-w-[100px]"
                >Weight Out</span
              >
              <span class="text-base font-bold text-red-600">{{
                selectedDetailBooking?.weightOut
                  ? selectedDetailBooking.weightOut.toLocaleString() + ' Kg'
                  : '-'
              }}</span>
            </div>

            <!-- Net Weight Summary -->
            <div
              v-if="selectedDetailBooking?.weightIn && selectedDetailBooking?.weightOut"
              class="relative flex items-baseline gap-3 pt-2 border-t mt-2"
            >
              <div
                class="absolute -left-[18px] w-4 h-4 rounded-full bg-purple-500 border-2 border-background"
              ></div>
              <span class="text-sm font-medium text-purple-700 dark:text-purple-400 min-w-[100px]"
                >Net Weight</span
              >
              <span class="text-lg font-bold text-purple-900 dark:text-purple-100">
                {{
                  Math.abs(
                    selectedDetailBooking.weightIn - selectedDetailBooking.weightOut
                  ).toLocaleString()
                }}
                Kg.
              </span>
            </div>
          </div>
        </div>

        <DialogFooter class="mt-2">
          <Button class="w-full" variant="outline" @click="timeLogDialogOpen = false">{{
            t('common.close')
          }}</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  </div>
</template>
```
