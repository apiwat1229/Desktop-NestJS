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
  if (!searchQuery.value) return bookings.value;
  const lowerQuery = searchQuery.value.toLowerCase();
  return bookings.value.filter(
    (b) =>
      b.bookingCode.toLowerCase().includes(lowerQuery) ||
      b.supplierName.toLowerCase().includes(lowerQuery) ||
      b.truckRegister?.toLowerCase().includes(lowerQuery)
  );
});

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
            disabled
          >
            Weight Scale In
          </TabsTrigger>
          <TabsTrigger
            value="scale-out"
            class="px-4 text-sm font-medium transition-all data-[state=active]:bg-blue-600 data-[state=active]:text-white data-[state=active]:shadow-sm rounded-md"
            disabled
          >
            Weight Scale Out
          </TabsTrigger>
          <TabsTrigger
            value="dashboard"
            class="px-4 text-sm font-medium transition-all data-[state=active]:bg-blue-600 data-[state=active]:text-white data-[state=active]:shadow-sm rounded-md"
            disabled
          >
            Dashboard
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
  </div>
</template>
