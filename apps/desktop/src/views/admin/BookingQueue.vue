<script setup lang="ts">
import { bookingsApi } from '@/services/bookings';
import { fromDate, getLocalTimeZone, type DateValue } from '@internationalized/date';
import { format } from 'date-fns';
import {
  Calendar as CalendarIcon,
  Edit2,
  FileText,
  Plus,
  RefreshCw,
  Trash2,
} from 'lucide-vue-next';
import { computed, onMounted, ref, watch, type Ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { toast } from 'vue-sonner';

import BookingSheet from '@/components/booking/BookingSheet.vue';
import TicketDialog from '@/components/booking/TicketDialog.vue';
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog';
import { Button } from '@/components/ui/button';
import { Calendar } from '@/components/ui/calendar';
import { Card } from '@/components/ui/card';
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover';
import { Tabs, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from '@/components/ui/tooltip';
import { useRoute } from 'vue-router';

// --- Constants ---
const TIME_SLOTS: any[] = [
  { label: '08:00-09:00', value: '08:00-09:00', startTime: '08:00', endTime: '09:00', limit: 4 },
  { label: '09:00-10:00', value: '09:00-10:00', startTime: '09:00', endTime: '10:00', limit: 4 },
  { label: '10:00-11:00', value: '10:00-11:00', startTime: '10:00', endTime: '11:00', limit: 4 },
  { label: '11:00-12:00', value: '11:00-12:00', startTime: '11:00', endTime: '12:00', limit: 4 },
  { label: '13:00-14:00', value: '13:00-14:00', startTime: '13:00', endTime: '14:00', limit: null },
];

const RUBBER_TYPE_MAP: Record<string, string> = {
  EUDR_CL: 'EUDR CL',
  EUDR_NCL: 'EUDR North-East CL',
  EUDR_USS: 'EUDR USS',
  FSC_CL: 'FSC CL',
  FSC_USS: 'FSC USS',
  North_East_CL: 'North East CL',
  Regular_CL: 'Regular CL',
  Regular_USS: 'Regular USS',
};

const DAY_COLORS = [
  { cardBg: '#fde2e2', border: '#d46b6b', queueBg: '#e11d48' }, // Sun
  { cardBg: '#fff7cc', border: '#d1b208', queueBg: '#eab308' }, // Mon
  { cardBg: '#ffd8e8', border: '#e26c9a', queueBg: '#ec4899' }, // Tue
  { cardBg: '#dff5df', border: '#63a463', queueBg: '#22c55e' }, // Wed
  { cardBg: '#ffe4cc', border: '#d58a4a', queueBg: '#f97316' }, // Thu
  { cardBg: '#dbeeff', border: '#5e97c2', queueBg: '#38bdf8' }, // Fri
  { cardBg: '#eadbff', border: '#8b6abf', queueBg: '#a855f7' }, // Sat
];

const SLOT_QUEUE_CONFIG: Record<string, { start: number; limit: number | null }> = {
  '08:00-09:00': { start: 1, limit: 4 },
  '09:00-10:00': { start: 5, limit: 4 },
  '10:00-11:00': { start: 9, limit: 4 },
  '11:00-12:00': { start: 13, limit: 4 },
  '13:00-14:00': { start: 17, limit: null },
};

// --- State ---
const { t } = useI18n();
// const authStore = useAuthStore();
const selectedDate = ref(fromDate(new Date(), getLocalTimeZone())) as Ref<DateValue>;
const selectedSlot = ref<string>('08:00-09:00'); // Default slot
const queues = ref<any[]>([]);
const totalDailyQueues = ref(0);
const loading = ref(false);

const sheetOpen = ref(false);
const ticketDialogOpen = ref(false);
const deleteDialogOpen = ref(false);

const editingBooking = ref<any>(null);
const selectedTicket = ref<any>(null);
const bookingToDelete = ref<any>(null);

// --- Helpers ---
const selectedDateJS = computed(() => {
  return selectedDate.value ? selectedDate.value.toDate(getLocalTimeZone()) : new Date();
});

// --- Computeds ---
const currentSlotConfig = computed(() => {
  const dayOfWeek = selectedDateJS.value.getDay();
  // Special case: Saturday 10:00-11:00
  if (dayOfWeek === 6 && selectedSlot.value === '10:00-11:00') {
    return { start: 9, limit: null };
  }
  return SLOT_QUEUE_CONFIG[selectedSlot.value] || { start: 1, limit: null };
});

const isSlotFull = computed(() => {
  if (currentSlotConfig.value.limit === null) return false;
  return queues.value.length >= currentSlotConfig.value.limit;
});

const nextQueueNo = computed(() => {
  if (isSlotFull.value) return null;

  const used = queues.value
    .map((q) => Number(q.queueNo))
    .filter((n) => !Number.isNaN(n))
    .sort((a, b) => a - b);

  if (currentSlotConfig.value.limit === null) {
    if (used.length === 0) return currentSlotConfig.value.start;
    return used[used.length - 1] + 1;
  }

  // Find gaps for limited slots
  let candidate = currentSlotConfig.value.start;
  const max = currentSlotConfig.value.start + currentSlotConfig.value.limit;

  while (candidate < max) {
    if (!used.includes(candidate)) {
      return candidate;
    }
    candidate++;
  }
  return null;
});

const availableSlots = computed(() => {
  const dayOfWeek = selectedDateJS.value.getDay();
  if (dayOfWeek === 6) {
    // Saturday
    return TIME_SLOTS.filter(
      (slot) =>
        slot.value === '08:00-09:00' || slot.value === '09:00-10:00' || slot.value === '10:00-11:00'
    );
  }
  return TIME_SLOTS;
});

// --- Methods ---
async function fetchQueues() {
  if (!selectedDate.value || !selectedSlot.value) return;

  try {
    loading.value = true;
    const dateParam = format(selectedDateJS.value, 'yyyy-MM-dd');

    // Fetch slot queues
    const resp = await bookingsApi.getAll({
      date: dateParam,
      slot: selectedSlot.value,
    });
    queues.value = resp || [];

    // Fetch daily total
    const dailyResp = await bookingsApi.getAll({ date: dateParam });
    totalDailyQueues.value = dailyResp?.length || 0;
  } catch (err) {
    console.error('Fetch queues error:', err);
    toast.error(t('bookingQueue.toast.loadFailed'));
    queues.value = [];
    totalDailyQueues.value = 0;
  } finally {
    loading.value = false;
  }
}

// ... handleCreateBooking and others use computeds, so no change needed mostly

function handleCreateBooking() {
  if (isSlotFull.value) {
    toast.error(t('bookingQueue.slotFull'));
    return;
  }
  editingBooking.value = null;
  sheetOpen.value = true;
}

function handleEdit(booking: any) {
  editingBooking.value = booking;
  sheetOpen.value = true;
}

function handleDeleteClick(booking: any) {
  bookingToDelete.value = booking;
  deleteDialogOpen.value = true;
}

async function confirmDelete() {
  if (!bookingToDelete.value) return;
  try {
    const res = await bookingsApi.delete(bookingToDelete.value.id);
    if (res && res.status === 'PENDING_APPROVAL') {
      toast.info(t('bookingQueue.toast.cancellationSent'));
    } else {
      toast.success(t('bookingQueue.toast.deleted'));
    }
    fetchQueues();
  } catch (err) {
    console.error('Delete error:', err);
    toast.error(t('bookingQueue.toast.deleteError'));
  } finally {
    deleteDialogOpen.value = false;
    bookingToDelete.value = null;
  }
}

function handleShowTicket(booking: any) {
  selectedTicket.value = booking;
  ticketDialogOpen.value = true;
}

// Watch for date/slot changes
watch([selectedDate, selectedSlot], () => {
  fetchQueues();
});

function handleBookingSuccess(_booking?: any) {
  fetchQueues();
  // Auto-open ticket dialog disabled per user request
  // if (booking && booking.bookingCode) {
  //   selectedTicket.value = booking;
  //   ticketDialogOpen.value = true;
  // }
}

// Use VueUse for persistence if available, or manual localStorage
// Since we don't have vueuse explicit here, let's use manual local storage helper
const STORAGE_KEY = 'booking_queue_slot_pref';

onMounted(async () => {
  // 1. Check for 'code' query param implies Deep Link
  const route = useRoute();
  const code = route.query.code as string;

  if (code) {
    try {
      loading.value = true;
      console.log(`[BookingQueue] Deep Linking for code: ${code}`);
      // Fetch booking by code to get date/slot
      // We use getAll with code filter
      const bookings = await bookingsApi.getAll({ code });

      if (bookings && bookings.length > 0) {
        const booking = bookings[0];
        console.log(`[BookingQueue] Found booking:`, booking);

        // Set Date and Slot
        selectedDate.value = fromDate(new Date(booking.date), getLocalTimeZone());
        selectedSlot.value = booking.slot;

        // Highlight/Scroll logic could go here

        // We don't save persistence here because this is a specific overwrite
      } else {
        toast.error('Booking not found');
      }
    } catch (error) {
      console.error('Deep link failed', error);
      toast.error('Failed to load linked booking');
    } finally {
      loading.value = false;
    }
  } else {
    // 2. Normal load: Check persistence
    const savedSlot = localStorage.getItem(STORAGE_KEY);
    if (savedSlot) {
      selectedSlot.value = savedSlot;
    }
  }

  // Always fetch queues after setting state
  fetchQueues();
});

// Watch slot to persist
watch(selectedSlot, (newSlot) => {
  localStorage.setItem(STORAGE_KEY, newSlot);
});

// Watch for date/slot changes (Existing watcher)
// Note: We need to be careful not to double fetch if we set values in onMounted.
// But existing watcher calls fetchQueues() on change.
// In onMounted we manually called fetchQueues().
// Let's rely on the watcher if we change values, but if we don't change (e.g. no deep link, no saved slot), we might need an initial fetch.
// Actually, the existing code:
// watch([selectedDate, selectedSlot], () => fetchQueues())
// onMounted(() => fetchQueues())
// This implies double fetch if onMounted changes values.
// Ideally we remove the explicit fetchQueues in onMounted if we change values.
</script>

<template>
  <div class="h-full flex-1 flex-col space-y-4 p-4 md:flex">
    <!-- Header -->
    <div class="flex items-center justify-between space-y-2">
      <div>
        <h2 class="text-2xl font-bold tracking-tight">{{ t('bookingQueue.title') }}</h2>
        <p class="text-muted-foreground">
          {{ t('bookingQueue.manageQueue') }}
          {{ format(selectedDateJS, 'dd-MMM-yyyy') }}
        </p>
      </div>
      <div class="flex items-center space-x-2">
        <Button variant="outline" size="sm" @click="fetchQueues">
          <RefreshCw class="mr-2 h-4 w-4" />
          <RefreshCw class="mr-2 h-4 w-4" />
          {{ t('bookingQueue.refresh') }}
        </Button>
        <Button size="sm" :disabled="isSlotFull" @click="handleCreateBooking">
          <Plus class="mr-2 h-4 w-4" />
          {{ isSlotFull ? t('bookingQueue.slotFull') : t('bookingQueue.addBooking') }}
        </Button>
      </div>
    </div>

    <!-- Filters/Selection -->
    <Card class="p-3">
      <div class="flex flex-col lg:flex-row gap-6 items-center justify-between">
        <!-- Left: Inputs -->
        <div class="flex flex-col sm:flex-row gap-4 flex-1 w-full lg:w-auto">
          <!-- Date Picker -->
          <div class="flex flex-col gap-2 min-w-[200px]">
            <span class="text-sm text-muted-foreground">{{ t('bookingQueue.selectDate') }}</span>
            <Popover>
              <PopoverTrigger as-child>
                <Button
                  variant="outline"
                  class="w-full justify-start text-left font-normal"
                  :class="!selectedDate && 'text-muted-foreground'"
                >
                  <CalendarIcon class="mr-2 h-4 w-4" />
                  {{
                    selectedDate
                      ? format(selectedDateJS, 'dd-MMM-yyyy')
                      : t('bookingQueue.pickDate')
                  }}
                </Button>
              </PopoverTrigger>
              <PopoverContent class="w-auto p-0" align="start">
                <Calendar
                  v-model="selectedDate"
                  class="rounded-md border shadow-sm"
                  initial-focus
                />
              </PopoverContent>
            </Popover>
          </div>

          <!-- Time Slot Tabs -->
          <div class="flex-1 flex flex-col gap-2 w-full">
            <span class="text-sm text-muted-foreground">{{ t('bookingQueue.timeSlot') }}</span>
            <Tabs v-model="selectedSlot" class="w-full">
              <TabsList
                class="grid w-full h-auto flex-wrap gap-1 bg-muted p-1"
                :style="{
                  gridTemplateColumns: `repeat(${Math.min(availableSlots.length, 5)}, minmax(0, 1fr))`,
                }"
              >
                <TabsTrigger
                  v-for="slot in availableSlots"
                  :key="slot.value"
                  :value="slot.value"
                  class="whitespace-nowrap px-2 py-1 text-xs data-[state=active]:bg-primary data-[state=active]:text-primary-foreground sm:text-sm"
                >
                  {{ slot.label }}
                </TabsTrigger>
              </TabsList>
            </Tabs>
          </div>
        </div>

        <!-- Right: Slot Info -->
        <div class="flex flex-col items-end text-right border-l pl-6 min-w-[240px]">
          <h3 class="text-lg font-semibold tracking-tight text-primary">
            {{ t('bookingQueue.timeSlot') }} {{ selectedSlot }}
          </h3>
          <p class="text-sm text-muted-foreground mt-1">
            {{ format(selectedDateJS, 'dd-MMM-yyyy') }} • Queue
            <span class="font-medium text-foreground">
              {{ currentSlotConfig.start }}
              <span v-if="currentSlotConfig.limit"
                >- {{ currentSlotConfig.start + currentSlotConfig.limit - 1 }}</span
              >
              <span v-else>Upwards</span>
            </span>
          </p>
        </div>
      </div>
    </Card>

    <!-- Stats -->
    <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
      <Card class="p-3 flex flex-col items-center justify-center text-center">
        <p class="text-sm text-muted-foreground mb-1">{{ t('bookingQueue.totalToday') }}</p>
        <p class="text-3xl font-bold">{{ totalDailyQueues }}</p>
      </Card>
      <Card class="p-3 flex flex-col items-center justify-center text-center">
        <p class="text-sm text-muted-foreground mb-1">{{ t('bookingQueue.currentQueue') }}</p>
        <p class="text-3xl font-bold text-primary">
          {{ queues.length > 0 ? Math.max(...queues.map((q) => Number(q.queueNo) || 0)) : '-' }}
        </p>
      </Card>
      <Card class="p-3 flex flex-col items-center justify-center text-center">
        <p class="text-sm text-muted-foreground mb-1">{{ t('bookingQueue.nextQueue') }}</p>
        <p class="text-3xl font-bold text-green-600">
          {{ nextQueueNo !== null ? nextQueueNo : '-' }}
        </p>
      </Card>
      <Card class="p-3 flex flex-col items-center justify-center text-center">
        <p class="text-sm text-muted-foreground mb-1">{{ t('bookingQueue.available') }}</p>
        <p class="text-3xl font-bold text-blue-600">
          {{
            currentSlotConfig.limit
              ? Math.max(0, currentSlotConfig.limit - queues.length)
              : t('bookingQueue.unlimited')
          }}
        </p>
      </Card>
    </div>

    <!-- Queue Grid -->
    <div v-if="loading" class="flex justify-center p-12">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
    </div>

    <div
      v-else-if="queues.length === 0"
      class="flex flex-col items-center justify-center p-12 text-center border-2 border-dashed border-border rounded-xl bg-background/50 min-h-[300px]"
    >
      <div
        class="w-16 h-16 bg-blue-50 dark:bg-blue-900/20 rounded-full flex items-center justify-center mb-4"
      >
        <FileText class="w-8 h-8 text-blue-500" />
      </div>
      <h3 class="text-lg font-semibold">{{ t('bookingQueue.noData') }}</h3>
      <p class="text-muted-foreground mt-1">{{ t('bookingQueue.noBookings') }}</p>
    </div>

    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
      <Card
        v-for="queue in queues"
        :key="queue.id"
        class="p-3 transition-all hover:shadow-md border-l-4"
        :style="{ borderLeftColor: DAY_COLORS[selectedDateJS.getDay()].queueBg }"
      >
        <div class="flex justify-between items-center mb-2">
          <span class="font-semibold text-sm"
            >{{ t('bookingQueue.queueNumber') }} : {{ queue.queueNo }}</span
          >
          <div class="flex items-center gap-1">
            <TooltipProvider>
              <Tooltip>
                <TooltipTrigger as-child>
                  <Button variant="ghost" size="icon" class="h-8 w-8" @click="handleEdit(queue)">
                    <Edit2 class="h-4 w-4" />
                  </Button>
                </TooltipTrigger>
                <TooltipContent>{{ t('common.edit') }}</TooltipContent>
              </Tooltip>
            </TooltipProvider>

            <TooltipProvider>
              <Tooltip>
                <TooltipTrigger as-child>
                  <Button
                    variant="ghost"
                    size="icon"
                    class="h-8 w-8 text-destructive hover:bg-destructive/10"
                    @click="handleDeleteClick(queue)"
                  >
                    <Trash2 class="h-4 w-4" />
                  </Button>
                </TooltipTrigger>
                <TooltipContent>{{ t('common.delete') }}</TooltipContent>
              </Tooltip>
            </TooltipProvider>
          </div>
        </div>

        <div class="space-y-1 text-sm">
          <div>
            <p class="text-xs text-muted-foreground">{{ t('bookingQueue.supplierCode') }}</p>
            <p class="font-medium">{{ queue.supplierCode }}</p>
          </div>
          <div>
            <p class="text-xs text-muted-foreground">{{ t('bookingQueue.supplierName') }}</p>
            <p class="font-medium break-words">{{ queue.supplierName }}</p>
          </div>
          <div v-if="queue.truckType || queue.truckRegister">
            <p class="text-xs text-muted-foreground">{{ t('bookingQueue.truck') }}</p>
            <p>{{ [queue.truckType, queue.truckRegister].filter(Boolean).join(' - ') }}</p>
          </div>
          <div>
            <p class="text-xs text-muted-foreground">{{ t('bookingQueue.type') }}</p>
            <p>
              {{ RUBBER_TYPE_MAP[queue.rubberType] || queue.rubberTypeName || queue.rubberType }}
            </p>
          </div>
          <div>
            <p class="text-xs text-muted-foreground">{{ t('bookingQueue.bookingCode') }}</p>
            <p>{{ queue.bookingCode }}</p>
          </div>
        </div>

        <div class="mt-4 pt-4 border-t flex justify-end">
          <Button variant="link" size="sm" class="h-auto p-0" @click="handleShowTicket(queue)">
            <FileText class="h-3 w-3 mr-1" />
            {{ t('bookingQueue.ticket') }}
          </Button>
        </div>
      </Card>
    </div>

    <!-- Modals -->
    <BookingSheet
      v-model:open="sheetOpen"
      :selectedDate="selectedDateJS"
      :selectedSlot="selectedSlot"
      :nextQueueNo="nextQueueNo || 1"
      :editingBooking="editingBooking"
      @success="handleBookingSuccess"
    />

    <TicketDialog v-model:open="ticketDialogOpen" :ticket="selectedTicket" />

    <AlertDialog :open="deleteDialogOpen" @update:open="deleteDialogOpen = $event">
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>{{ t('bookingQueue.confirmDelete') }}</AlertDialogTitle>
          <AlertDialogDescription class="space-y-4">
            <div
              v-if="bookingToDelete"
              class="bg-muted/50 p-4 rounded-md text-sm text-foreground space-y-3 border"
            >
              <div class="grid grid-cols-[100px_1fr] gap-2">
                <span class="text-muted-foreground">{{ t('bookingQueue.queueNumber') }}:</span>
                <span class="font-bold">{{ bookingToDelete.queueNo }}</span>
              </div>
              <div class="grid grid-cols-[100px_1fr] gap-2">
                <span class="text-muted-foreground">{{ t('bookingQueue.supplierCode') }}:</span>
                <span>{{ bookingToDelete.supplierCode }}</span>
              </div>
              <div class="grid grid-cols-[100px_1fr] gap-2">
                <span class="text-muted-foreground">{{ t('bookingQueue.supplierName') }}:</span>
                <span class="break-words font-medium">{{ bookingToDelete.supplierName }}</span>
              </div>
              <div
                v-if="bookingToDelete.truckType || bookingToDelete.truckRegister"
                class="grid grid-cols-[100px_1fr] gap-2"
              >
                <span class="text-muted-foreground">{{ t('bookingQueue.truck') }}:</span>
                <span>{{
                  [bookingToDelete.truckType, bookingToDelete.truckRegister]
                    .filter(Boolean)
                    .join(' - ')
                }}</span>
              </div>
              <div class="grid grid-cols-[100px_1fr] gap-2">
                <span class="text-muted-foreground">{{ t('bookingQueue.type') }}:</span>
                <span>{{
                  RUBBER_TYPE_MAP[bookingToDelete.rubberType] ||
                  bookingToDelete.rubberTypeName ||
                  bookingToDelete.rubberType
                }}</span>
              </div>
              <div class="grid grid-cols-[100px_1fr] gap-2">
                <span class="text-muted-foreground">{{ t('bookingQueue.bookingCode') }}:</span>
                <span>{{ bookingToDelete.bookingCode }}</span>
              </div>
            </div>
            <p>{{ t('bookingQueue.deleteWarning') }}</p>
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel @click="deleteDialogOpen = false">{{
            t('common.cancel')
          }}</AlertDialogCancel>
          <AlertDialogAction
            class="bg-destructive hover:bg-destructive/90"
            @click="confirmDelete"
            >{{ t('common.delete') }}</AlertDialogAction
          >
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  </div>
</template>
