<script setup lang="ts">
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Calendar } from '@/components/ui/calendar';
import { Card, CardContent } from '@/components/ui/card';
import DataTable from '@/components/ui/data-table/DataTable.vue';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { cn } from '@/lib/utils';
import { bookingsApi } from '@/services/bookings';
import { useAuthStore } from '@/stores/auth';
import { getLocalTimeZone, today } from '@internationalized/date';
import type { ColumnDef } from '@tanstack/vue-table';
import { format } from 'date-fns';
import { Calendar as CalendarIcon, CheckCircle, Clock, Search, Truck } from 'lucide-vue-next';
import { computed, h, onMounted, ref, watch } from 'vue';
import { toast } from 'vue-sonner';

// State
const activeTab = ref('checkin');
const bookings = ref<any[]>([]);
const isLoading = ref(false);
const searchQuery = ref('');

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
    toast.error('กรุณาเลือกประเภทรถ');
    return;
  }
  checkInStep.value = 2;
};

const confirmCheckIn = async () => {
  if (!selectedBooking.value) return;
  try {
    await bookingsApi.checkIn(selectedBooking.value.id, checkInData.value);
    toast.success('Check-in successful');
    checkInDialogOpen.value = false;
    fetchBookings();
  } catch (error) {
    console.error('Check-in failed:', error);
    toast.error('Failed to check-in');
  }
};

// Fetch Data
const fetchBookings = async () => {
  isLoading.value = true;
  try {
    const response = await bookingsApi.getAll({ date: selectedDate.value });
    // Assuming backend returns array directly as per previous fix
    bookings.value = Array.isArray(response) ? response : (response as any).data || [];
  } catch (error) {
    console.error('Failed to fetch bookings:', error);
    toast.error('Failed to load bookings');
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
const weightOutData = ref({ weightOut: 0 });

const openWeightOut = (booking: any) => {
  selectedDrainBooking.value = booking;
  weightOutData.value = { weightOut: 0 };
  weightOutDialogOpen.value = true;
};

const handleWeightOutNext = () => {
  // Validate
  if (!weightOutData.value.weightOut || weightOutData.value.weightOut <= 0) {
    toast.error('กรุณาระบุน้ำหนักขาออก');
    return;
  }
  weightOutDialogOpen.value = false;
  confirmCheckoutDialogOpen.value = true;
};

const confirmWeightOut = async () => {
  if (!selectedDrainBooking.value) return;
  try {
    await bookingsApi.saveWeightOut(selectedDrainBooking.value.id, weightOutData.value);
    toast.success('บันทึกน้ำหนักขาออกสำเร็จ');
    confirmCheckoutDialogOpen.value = false;
    fetchBookings();
  } catch (e) {
    toast.error('Failed to save weight out');
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
const stopDrainDialogOpen = ref(false);
const weightInDialogOpen = ref(false);
const selectedDrainBooking = ref<any>(null);
const weightInData = ref({
  rubberSource: '',
  rubberType: '',
  weightIn: 0,
});

const openStartDrain = (booking: any) => {
  selectedDrainBooking.value = booking;
  startDrainDialogOpen.value = true;
};

const openStopDrain = (booking: any) => {
  selectedDrainBooking.value = booking;
  stopDrainDialogOpen.value = true;
};

const openWeightIn = (booking: any) => {
  selectedDrainBooking.value = booking;
  weightInData.value = {
    rubberSource: '',
    rubberType: booking.rubberType || '',
    weightIn: 0,
  };
  weightInDialogOpen.value = true;
};

const confirmStartDrain = async () => {
  if (!selectedDrainBooking.value) return;
  try {
    await bookingsApi.startDrain(selectedDrainBooking.value.id);
    toast.success('Started Drain');
    startDrainDialogOpen.value = false;
    fetchBookings();
  } catch (e) {
    toast.error('Failed to start');
  }
};

const confirmStopDrain = async () => {
  if (!selectedDrainBooking.value) return;
  try {
    await bookingsApi.stopDrain(selectedDrainBooking.value.id);
    toast.success('Stopped Drain');
    stopDrainDialogOpen.value = false;
    fetchBookings();
  } catch (e) {
    toast.error('Failed to stop');
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
  if (!start || !end) return '00 นาที';
  const s = new Date(start).getTime();
  const e = new Date(end).getTime();
  const diff = Math.floor((e - s) / 60000); // minutes
  return `${diff} นาที`;
};

// Columns
const columns: ColumnDef<any>[] = [
  {
    accessorKey: 'queueNo',
    header: 'Queue',
    cell: ({ row }) => h('div', { class: 'font-bold text-center w-12' }, row.original.queueNo),
  },
  {
    accessorKey: 'date',
    header: 'Date',
    cell: ({ row }) => format(new Date(row.original.date), 'dd-MMM-yyyy'),
  },
  {
    accessorKey: 'time',
    header: 'Time',
    cell: ({ row }) => `${row.original.startTime} - ${row.original.endTime}`,
  },
  {
    accessorKey: 'bookingCode',
    header: 'Booking',
    cell: ({ row }) => row.original.bookingCode,
  },
  {
    accessorKey: 'supplierName',
    header: 'Supplier',
    cell: ({ row }) => `${row.original.supplierCode} - ${row.original.supplierName}`,
  },
  {
    accessorKey: 'truckRegister',
    header: 'Truck',
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
    header: 'Status',
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
    header: 'Supplier',
    cell: ({ row }) =>
      h('div', { class: 'flex flex-col' }, [
        h('span', { class: 'font-medium' }, row.original.supplierCode),
        h('span', { class: 'text-sm text-muted-foreground' }, row.original.supplierName),
      ]),
  },
  {
    accessorKey: 'queueNo',
    header: 'Queue',
    cell: ({ row }) =>
      h('div', {}, `${row.original.startTime} - ${row.original.endTime} (${row.original.queueNo})`),
  },
  {
    accessorKey: 'truckRegister',
    header: 'ทะเบียนรถ',
    cell: ({ row }) => row.original.truckRegister || '-',
  },
  {
    accessorKey: 'truckType',
    header: 'ประเภท',
    cell: ({ row }) => row.original.truckType || '-',
  },
  {
    accessorKey: 'startDrainAt',
    header: 'Start Drain',
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
        () => 'Start'
      );
    },
  },
  {
    accessorKey: 'stopDrainAt',
    header: 'Stop Drain',
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
        () => 'Stop'
      );
    },
  },
  {
    header: 'Total Drain',
    cell: ({ row }) => {
      if (row.original.startDrainAt && row.original.stopDrainAt) {
        return calculateDuration(row.original.startDrainAt, row.original.stopDrainAt);
      }
      return '00 นาที';
    },
  },
  {
    accessorKey: 'weightIn',
    header: 'Weight In',
    cell: ({ row }) =>
      row.original.weightIn ? `${row.original.weightIn.toLocaleString()} กก.` : '-',
  },
  {
    id: 'action',
    header: 'Action',
    cell: ({ row }) => {
      const hasWeight = !!row.original.weightIn;
      if (hasWeight) {
        return h(
          Button,
          {
            size: 'sm',
            variant: 'outline',
            class: 'text-blue-600 border-blue-200 bg-blue-50',
            onClick: () => openWeightIn(row.original),
          },
          () => 'แก้ไข'
        );
      }
      return h(
        Button,
        {
          size: 'sm',
          class: 'bg-gray-200 text-gray-700 hover:bg-gray-300',
          onClick: () => openWeightIn(row.original),
        },
        () => 'บันทึก'
      );
    },
  },
];

const scaleOutColumns: ColumnDef<any>[] = [
  ...scaleInColumns.slice(0, 3), // Supplier, Queue, Truck
  {
    accessorKey: 'truckType',
    header: 'ประเภท',
    cell: ({ row }) => row.original.truckType || '-',
  },
  {
    accessorKey: 'startDrainAt',
    header: 'Start Drain',
    cell: ({ row }) =>
      row.original.startDrainAt ? format(new Date(row.original.startDrainAt), 'HH:mm') : '-',
  },
  {
    accessorKey: 'stopDrainAt',
    header: 'Stop Drain',
    cell: ({ row }) =>
      row.original.stopDrainAt ? format(new Date(row.original.stopDrainAt), 'HH:mm') : '-',
  },
  {
    header: 'Total Drain',
    cell: ({ row }) => {
      if (row.original.startDrainAt && row.original.stopDrainAt) {
        return calculateDuration(row.original.startDrainAt, row.original.stopDrainAt);
      }
      return '00 นาที';
    },
  },
  {
    accessorKey: 'weightIn',
    header: 'Weight In',
    cell: ({ row }) =>
      row.original.weightIn ? `${row.original.weightIn.toLocaleString()} กก.` : '-',
  },
  {
    id: 'action',
    header: 'Action',
    cell: ({ row }) => {
      return h(
        Button,
        {
          size: 'sm',
          class: 'bg-blue-100 text-blue-600 hover:bg-blue-200 border-none shadow-none',
          onClick: () => openWeightOut(row.original),
        },
        () => 'บันทึก'
      );
    },
  },
];

const dashboardColumns: ColumnDef<any>[] = [
  {
    accessorKey: 'date',
    header: 'วันที่',
    cell: ({ row }) => format(new Date(row.original.date), 'dd-MMM-yyyy'),
  },
  {
    accessorKey: 'supplierName',
    header: 'Supplier',
    cell: ({ row }) => `${row.original.supplierCode} : ${row.original.supplierName}`,
  },
  {
    accessorKey: 'truckRegister',
    header: 'ทะเบียนรถ',
    cell: ({ row }) => row.original.truckRegister || '-',
  },
  {
    accessorKey: 'truckType',
    header: 'ประเภท',
    cell: ({ row }) => row.original.truckType || '-',
  },
  {
    header: 'Rubber Type / จังหวัด',
    cell: ({ row }) =>
      h('div', { class: 'flex flex-col' }, [
        h('span', { class: 'font-medium' }, row.original.rubberType || '-'),
        h(
          'span',
          { class: 'text-xs text-muted-foreground' },
          row.original.rubberSource || 'ไม่ระบุจังหวัด'
        ),
      ]),
  },
  {
    accessorKey: 'weightIn',
    header: 'Weight In',
    cell: ({ row }) =>
      row.original.weightIn ? `${row.original.weightIn.toLocaleString()} Kg.` : '-',
  },
  {
    accessorKey: 'weightOut',
    header: 'Weight Out',
    cell: ({ row }) =>
      row.original.weightOut ? `${row.original.weightOut.toLocaleString()} Kg.` : '-',
  },
  {
    header: 'Net',
    cell: ({ row }) => {
      const net = Math.abs((row.original.weightIn || 0) - (row.original.weightOut || 0));
      return h('span', { class: 'font-bold' }, `${net.toLocaleString()} Kg.`);
    },
  },
  {
    id: 'actions',
    header: 'Actions',
    cell: ({ row }) =>
      h('div', { class: 'flex gap-2' }, [
        h(
          Button,
          { size: 'icon', variant: 'ghost', class: 'h-8 w-8 bg-green-50 text-green-600' },
          () => h(CheckCircle, { class: 'w-4 h-4' })
        ),
        h(
          Button,
          { size: 'icon', variant: 'ghost', class: 'h-8 w-8 bg-blue-50 text-blue-600' },
          () => h(Clock, { class: 'w-4 h-4' })
        ), // Just placeholders/icons as per image
      ]),
  },
];

onMounted(async () => {
  await authStore.fetchUser();
  fetchBookings();
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
          <h1 class="text-3xl font-bold tracking-tight">Truck Scale System</h1>
          <p class="text-muted-foreground">Manage truck weigh-ins and gate operations.</p>
        </div>

        <!-- Tabs List (Right Aligned) -->
        <TabsList class="h-10 bg-muted/50 p-1 rounded-lg self-start md:self-center">
          <TabsTrigger
            value="checkin"
            class="px-4 text-sm font-medium transition-all data-[state=active]:bg-blue-600 data-[state=active]:text-white data-[state=active]:shadow-sm rounded-md"
          >
            Booking Check-in
          </TabsTrigger>
          <TabsTrigger
            value="scale-in"
            class="px-4 text-sm font-medium transition-all data-[state=active]:bg-blue-600 data-[state=active]:text-white data-[state=active]:shadow-sm rounded-md"
          >
            Weight Scale In
          </TabsTrigger>
          <TabsTrigger
            value="scale-out"
            class="px-4 text-sm font-medium transition-all data-[state=active]:bg-blue-600 data-[state=active]:text-white data-[state=active]:shadow-sm rounded-md"
          >
            Weight Scale Out
          </TabsTrigger>
          <TabsTrigger
            value="dashboard"
            class="px-4 text-sm font-medium transition-all data-[state=active]:bg-blue-600 data-[state=active]:text-white data-[state=active]:shadow-sm rounded-md"
          >
            Weight Summary Dashboard
          </TabsTrigger>
        </TabsList>
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
                  <Label>Select Date</Label>
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
                  <Label>Search Booking</Label>
                  <div class="relative">
                    <Search class="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
                    <Input
                      v-model="searchQuery"
                      placeholder="Code / Supplier / Truck..."
                      class="pl-9"
                    />
                  </div>
                </div>
                <Button
                  class="bg-blue-600 hover:bg-blue-700 w-full md:w-auto"
                  @click="fetchBookings"
                >
                  <Search class="w-4 h-4 mr-2" />
                  Search
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
                    <span class="text-xs text-muted-foreground font-medium">Total Expected</span>
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
                    <span class="text-xs text-muted-foreground font-medium">Checked In</span>
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
                    <span class="text-xs text-muted-foreground font-medium">Pending</span>
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
                  <Label>Select Date</Label>
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
                  <Label>Search Booking</Label>
                  <div class="relative">
                    <Search class="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
                    <Input
                      v-model="searchQuery"
                      placeholder="Code / Supplier / Truck..."
                      class="pl-9"
                    />
                  </div>
                </div>
                <Button
                  class="bg-blue-600 hover:bg-blue-700 w-full md:w-auto"
                  @click="fetchBookings"
                >
                  <Search class="w-4 h-4 mr-2" />
                  Search
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
                    <span class="text-xs text-muted-foreground font-medium">Total Expected</span>
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
                    <span class="text-xs text-muted-foreground font-medium">Checked In</span>
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
                    <span class="text-xs text-muted-foreground font-medium">Pending</span>
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
                  <Label>Select Date</Label>
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
                  <Label>Search Booking</Label>
                  <div class="relative">
                    <Search class="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
                    <Input
                      v-model="searchQuery"
                      placeholder="Code / Supplier / Truck..."
                      class="pl-9"
                    />
                  </div>
                </div>
                <Button
                  class="bg-blue-600 hover:bg-blue-700 w-full md:w-auto"
                  @click="fetchBookings"
                >
                  <Search class="w-4 h-4 mr-2" />
                  Search
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
                    <span class="text-xs text-muted-foreground font-medium">Total Expected</span>
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
                    <span class="text-xs text-muted-foreground font-medium">Checked In</span>
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
                    <span class="text-xs text-muted-foreground font-medium">Pending</span>
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
                  <Label>Select Date</Label>
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
                  <Label>Search Booking</Label>
                  <div class="relative">
                    <Search class="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
                    <Input
                      v-model="searchQuery"
                      placeholder="Code / Supplier / Truck..."
                      class="pl-9"
                    />
                  </div>
                </div>
                <Button
                  class="bg-blue-600 hover:bg-blue-700 w-full md:w-auto"
                  @click="fetchBookings"
                >
                  <Search class="w-4 h-4 mr-2" />
                  Search
                </Button>
              </div>

              <!-- Stats Cards Group (Dashboard Specific) -->
              <div class="grid grid-cols-1 md:grid-cols-4 gap-4 w-full xl:w-auto mt-4 xl:mt-0">
                <div
                  class="rounded-lg border bg-background px-4 py-2 flex flex-col justify-center gap-1 border-l-4 border-l-blue-500 shadow-sm min-w-[150px]"
                >
                  <span class="text-xs text-muted-foreground font-medium">จำนวนเที่ยว</span>
                  <span class="text-xl font-bold leading-none">{{ dashboardStats.count }} คัน</span>
                </div>

                <div
                  class="rounded-lg border bg-background px-4 py-2 flex flex-col justify-center gap-1 border-l-4 border-l-green-500 shadow-sm min-w-[150px]"
                >
                  <span class="text-xs text-muted-foreground font-medium">Total Net Weight</span>
                  <span class="text-xl font-bold leading-none text-green-600">{{
                    dashboardStats.net.toLocaleString()
                  }}</span>
                </div>

                <div
                  class="rounded-lg border bg-background px-4 py-2 flex flex-col justify-center gap-1 border-l-4 border-l-blue-400 shadow-sm min-w-[150px]"
                >
                  <span class="text-xs text-muted-foreground font-medium">Total Gross</span>
                  <span class="text-xl font-bold leading-none text-blue-500">{{
                    dashboardStats.gross.toLocaleString()
                  }}</span>
                </div>

                <div
                  class="rounded-lg border bg-background px-4 py-2 flex flex-col justify-center gap-1 border-l-4 border-l-orange-500 shadow-sm min-w-[150px]"
                >
                  <span class="text-xs text-muted-foreground font-medium">In / Out</span>
                  <div class="flex items-baseline gap-1">
                    <span class="text-lg font-bold text-blue-600"
                      >{{ (dashboardStats.weightIn / 1000).toFixed(0) }}k</span
                    >
                    <span class="text-muted-foreground">/</span>
                    <span class="text-lg font-bold text-orange-600"
                      >{{ (dashboardStats.weightOut / 1000).toFixed(0) }}k</span
                    >
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
            <DialogTitle class="text-xl">บันทึก Check-in</DialogTitle>
          </DialogHeader>

          <!-- Booking Details Card -->
          <div class="bg-muted/30 rounded-lg p-4 mb-6 border">
            <div class="flex items-center gap-2 mb-4">
              <div class="w-1 h-6 bg-blue-600 rounded-full"></div>
              <span class="font-semibold text-base">รายละเอียด Booking</span>
              <Badge
                variant="secondary"
                class="ml-auto bg-blue-100 text-blue-700 hover:bg-blue-100 text-lg px-3 py-1"
              >
                Q{{ selectedBooking?.queueNo }}
              </Badge>
            </div>

            <div class="space-y-2 text-sm">
              <div class="grid grid-cols-[100px_1fr] items-center">
                <span class="text-muted-foreground">วันที่</span>
                <span class="font-medium">
                  {{
                    selectedBooking?.date
                      ? format(new Date(selectedBooking.date), 'dd-MMM-yyyy')
                      : '-'
                  }}
                </span>
              </div>
              <div class="grid grid-cols-[100px_1fr] items-center">
                <span class="text-muted-foreground">ช่วงเวลา</span>
                <span class="font-medium">
                  {{ selectedBooking?.startTime }} - {{ selectedBooking?.endTime }}
                </span>
              </div>
              <div class="grid grid-cols-[100px_1fr] items-center">
                <span class="text-muted-foreground">Booking</span>
                <span class="font-medium">{{ selectedBooking?.bookingCode }}</span>
              </div>
              <div class="grid grid-cols-[100px_1fr] items-center">
                <span class="text-muted-foreground">Supplier</span>
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
                <Label>เวลา Check-in</Label>
                <Input
                  :model-value="checkInTime ? format(checkInTime, 'HH:mm') : '-'"
                  readonly
                  class="bg-muted font-mono"
                />
              </div>
              <div class="grid gap-2">
                <Label>ผู้บันทึก</Label>
                <Input :model-value="recorderName" readonly class="bg-muted" />
              </div>
            </div>

            <!-- Row 2: Truck Info -->
            <div class="grid grid-cols-2 gap-4">
              <div class="grid gap-2">
                <Label>ประเภทตัวรถ <span class="text-destructive">*</span></Label>
                <Select v-model="checkInData.truckType">
                  <SelectTrigger>
                    <SelectValue placeholder="เลือกประเภทรถ" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="กระบะ">กระบะ</SelectItem>
                    <SelectItem value="6 ล้อ">6 ล้อ</SelectItem>
                    <SelectItem value="10 ล้อ">10 ล้อ</SelectItem>
                    <SelectItem value="10 ล้อ (พ่วง)">10 ล้อ (พ่วง)</SelectItem>
                    <SelectItem value="เทรลเลอร์">เทรลเลอร์</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div class="grid grid-cols-2 gap-4">
                <div class="grid gap-2 col-span-2">
                  <Label>เลขทะเบียน</Label>
                  <Input v-model="checkInData.truckRegister" placeholder="Ex. 1กข 1234" />
                </div>
              </div>
            </div>

            <!-- Note -->
            <div class="grid gap-2">
              <Label>หมายเหตุ</Label>
              <Textarea
                v-model="checkInData.note"
                placeholder="รายละเอียดเพิ่มเติม (ถ้ามี)"
                class="min-h-[100px]"
              />
            </div>
          </div>

          <DialogFooter>
            <Button variant="outline" @click="checkInDialogOpen = false"> ปิด </Button>
            <Button class="bg-blue-600 hover:bg-blue-700" @click="handleNextStep">
              ยืนยัน Check-in
            </Button>
          </DialogFooter>
        </div>

        <!-- STEP 2: CONFIRMATION -->
        <div v-else class="flex flex-col items-center justify-center py-6 text-center space-y-6">
          <DialogHeader class="mb-2">
            <DialogTitle class="text-2xl font-bold">ยืนยันการ Check-in</DialogTitle>
          </DialogHeader>

          <div class="space-y-2">
            <p class="text-muted-foreground text-sm">กรุณาตรวจสอบความถูกต้องก่อนยืนยัน</p>
          </div>

          <div class="bg-muted/30 border rounded-xl p-6 w-full max-w-sm mx-auto space-y-6">
            <!-- Primary Info: Supplier & Time -->
            <div class="space-y-2">
              <div class="text-sm text-muted-foreground font-medium">Supplier</div>
              <div class="text-2xl font-bold text-foreground leading-tight">
                {{ selectedBooking?.supplierCode }} — {{ selectedBooking?.supplierName }}
              </div>
            </div>

            <div class="space-y-2">
              <div class="text-sm text-muted-foreground font-medium">เวลา Check-in</div>
              <div
                class="text-3xl font-extrabold text-blue-600 bg-blue-50 py-3 rounded-lg border border-blue-100"
              >
                {{ checkInTime ? format(checkInTime, 'HH:mm') : '-' }}
              </div>
            </div>

            <div class="border-t pt-4 space-y-3">
              <div class="grid grid-cols-2 gap-2 text-sm">
                <div class="text-muted-foreground">Booking No.</div>
                <div class="font-medium text-right">{{ selectedBooking?.bookingCode }}</div>

                <div class="text-muted-foreground">Truck</div>
                <div class="font-medium text-right">
                  {{ checkInData.truckType || '-' }} • {{ checkInData.truckRegister || '-' }}
                </div>
              </div>
            </div>
          </div>

          <div class="flex gap-4 w-full max-w-sm justify-center pt-4">
            <Button variant="outline" class="w-full h-11" @click="checkInStep = 1"> ยกเลิก </Button>
            <Button class="w-full h-11 bg-blue-600 hover:bg-blue-700" @click="confirmCheckIn">
              ยืนยัน
            </Button>
          </div>
        </div>
      </DialogContent>
    </Dialog>

    <!-- Start Drain Dialog -->
    <Dialog v-model:open="startDrainDialogOpen">
      <DialogContent>
        <DialogHeader>
          <DialogTitle>ยืนยันเริ่มจับเวลา Drain</DialogTitle>
        </DialogHeader>
        <div class="bg-muted p-4 rounded-lg flex items-center justify-between">
          <div class="flex items-center gap-3">
            <div class="bg-white p-2 rounded border"><Truck class="w-6 h-6 text-blue-600" /></div>
            <div>
              <div class="font-bold text-lg">{{ selectedDrainBooking?.truckRegister }}</div>
              <div class="text-sm text-muted-foreground">{{ selectedDrainBooking?.truckType }}</div>
            </div>
          </div>
          <Badge class="bg-blue-600">Q {{ selectedDrainBooking?.queueNo }}</Badge>
        </div>

        <div class="border-t my-4"></div>

        <div class="flex justify-between items-center bg-gray-50 p-4 rounded-lg">
          <span class="text-gray-500">เวลาเริ่ม (Start):</span>
          <span class="text-green-600 font-mono text-xl font-bold bg-green-100 px-3 py-1 rounded">{{
            format(new Date(), 'HH:mm')
          }}</span>
        </div>

        <DialogFooter class="gap-2 sm:gap-0 mt-4">
          <Button variant="outline" @click="startDrainDialogOpen = false">ยกเลิก</Button>
          <Button class="bg-green-600 hover:bg-green-700" @click="confirmStartDrain">ยืนยัน</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>

    <!-- Stop Drain Dialog -->
    <Dialog v-model:open="stopDrainDialogOpen">
      <DialogContent>
        <DialogHeader>
          <DialogTitle>ยืนยันหยุดจับเวลา Drain</DialogTitle>
        </DialogHeader>
        <div class="bg-muted p-4 rounded-lg flex items-center justify-between">
          <div class="flex items-center gap-3">
            <div class="bg-white p-2 rounded border"><Truck class="w-6 h-6 text-blue-600" /></div>
            <div>
              <div class="font-bold text-lg">{{ selectedDrainBooking?.truckRegister }}</div>
              <div class="text-sm text-muted-foreground">{{ selectedDrainBooking?.truckType }}</div>
            </div>
          </div>
          <Badge class="bg-blue-600">Q {{ selectedDrainBooking?.queueNo }}</Badge>
        </div>

        <div class="grid grid-cols-2 gap-4 mt-6">
          <div class="border p-4 rounded-lg">
            <div class="text-sm text-gray-500 mb-1">Start Time</div>
            <div class="text-green-600 font-bold text-xl flex items-center gap-2">
              <Clock class="w-4 h-4" />
              {{
                selectedDrainBooking?.startDrainAt
                  ? format(new Date(selectedDrainBooking.startDrainAt), 'HH:mm')
                  : '-'
              }}
            </div>
          </div>
          <div class="border p-4 rounded-lg bg-red-50 border-red-100">
            <div class="text-sm text-red-500 mb-1">Stop Time</div>
            <div class="text-red-600 font-bold text-xl flex items-center gap-2">
              <Clock class="w-4 h-4" /> {{ format(new Date(), 'HH:mm') }}
            </div>
          </div>
        </div>

        <div
          class="bg-orange-50 border border-orange-100 p-4 rounded-lg flex justify-between items-center mt-4"
        >
          <div class="flex items-center gap-2 text-orange-700">
            <span>⏳ รวมเวลา (Duration)</span>
          </div>
          <div class="text-2xl font-bold text-foreground">
            {{ calculateDuration(selectedDrainBooking?.startDrainAt, new Date()) }}
          </div>
        </div>

        <DialogFooter class="gap-2 sm:gap-0 mt-4">
          <Button variant="outline" @click="stopDrainDialogOpen = false">ยกเลิก</Button>
          <Button class="bg-red-600 hover:bg-red-700" @click="confirmStopDrain">ยืนยัน</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>

    <!-- Weight In Dialog -->
    <Dialog v-model:open="weightInDialogOpen">
      <DialogContent>
        <DialogHeader>
          <DialogTitle>บันทึกน้ำหนักขาเข้า (กก.)</DialogTitle>
        </DialogHeader>

        <div class="grid grid-cols-2 gap-4 py-4">
          <div class="grid gap-2">
            <Label>ที่มาของยาง</Label>
            <div class="relative">
              <Input v-model="weightInData.rubberSource" placeholder="ระบุที่มา" />
              <span
                class="absolute right-3 top-2.5 cursor-pointer text-gray-400 hover:text-gray-600"
                >×</span
              >
            </div>
          </div>
          <div class="grid gap-2">
            <Label>ประเภทยาง</Label>
            <div class="relative">
              <Input v-model="weightInData.rubberType" placeholder="Regular CL" />
              <span
                class="absolute right-3 top-2.5 cursor-pointer text-gray-400 hover:text-gray-600"
                >×</span
              >
            </div>
          </div>
          <div class="grid gap-2 col-span-2">
            <Label>น้ำหนัก (กก.)</Label>
            <Input
              v-model="weightInData.weightIn"
              type="number"
              class="text-lg font-medium"
              ```
              placeholder="0"
            />
          </div>
        </div>

        <DialogFooter>
          <Button variant="outline" @click="weightInDialogOpen = false">ยกเลิก</Button>
          <Button class="bg-blue-600 hover:bg-blue-700" @click="saveWeightIn">บันทึก</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>

    <!-- Weight Out Dialog -->
    <Dialog v-model:open="weightOutDialogOpen">
      <DialogContent class="sm:max-w-sm">
        <DialogHeader>
          <DialogTitle>บันทึกน้ำหนักขาออก (กก.)</DialogTitle>
        </DialogHeader>

        <div class="grid gap-4 py-4">
          <div class="grid gap-2">
            <Label>น้ำหนักขาออก</Label>
            <Input
              v-model="weightOutData.weightOut"
              type="number"
              class="text-xl h-12"
              placeholder="0"
            />
          </div>
        </div>

        <DialogFooter class="flex justify-between sm:justify-end gap-2">
          <Button variant="outline" @click="weightOutDialogOpen = false">ยกเลิก</Button>
          <Button class="bg-blue-600 hover:bg-blue-700" @click="handleWeightOutNext">บันทึก</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>

    <!-- Confirm Check Out Dialog -->
    <Dialog v-model:open="confirmCheckoutDialogOpen">
      <DialogContent class="max-w-md">
        <DialogHeader>
          <DialogTitle>ยืนยันบันทึกน้ำหนักขาออก (Check-OUT)</DialogTitle>
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
            <span class="text-muted-foreground">น้ำหนักขาเข้า:</span>
            <span class="font-medium text-lg"
              >{{ selectedDrainBooking?.weightIn?.toLocaleString() }} กก.</span
            >
          </div>
          <div class="flex justify-between items-center text-sm border-b pb-3">
            <span class="text-muted-foreground">น้ำหนักขาออกสุทธิ</span>
            <span class="font-bold text-xl text-green-600"
              >{{ Number(weightOutData.weightOut).toLocaleString() }} กก.</span
            >
          </div>
          <div class="flex justify-between items-center pt-1">
            <span class="text-blue-600 font-medium">น้ำหนักสุทธิ (Net Weight)</span>
            <span class="font-bold text-2xl text-blue-600">
              {{
                Math.abs(
                  (selectedDrainBooking?.weightIn || 0) - Number(weightOutData.weightOut)
                ).toLocaleString()
              }}
              กก.
            </span>
          </div>
        </div>

        <DialogFooter class="mt-4 gap-2">
          <Button variant="outline" class="w-full" @click="confirmCheckoutDialogOpen = false"
            >ยกเลิก</Button
          >
          <Button class="bg-green-600 hover:bg-green-700 w-full" @click="confirmWeightOut"
            >ยืนยัน</Button
          >
        </DialogFooter>
      </DialogContent>
    </Dialog>
  </div>
</template>
```
