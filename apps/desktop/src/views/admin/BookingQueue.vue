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
// const { t } = useI18n();
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
    toast.error('Failed to load queues');
    queues.value = [];
    totalDailyQueues.value = 0;
  } finally {
    loading.value = false;
  }
}

// ... handleCreateBooking and others use computeds, so no change needed mostly

function handleCreateBooking() {
  if (isSlotFull.value) {
    toast.error('Slot is full');
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
    await bookingsApi.delete(bookingToDelete.value.id);
    toast.success('Booking deleted');
    fetchQueues();
  } catch (err) {
    console.error('Delete error:', err);
    toast.error('Failed to delete booking');
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

function handleBookingSuccess(booking?: any) {
  fetchQueues();
  // Auto-open ticket dialog disabled per user request
  // if (booking && booking.bookingCode) {
  //   selectedTicket.value = booking;
  //   ticketDialogOpen.value = true;
  // }
}

onMounted(() => {
  fetchQueues();
});
</script>

<template>
  <div class="h-full flex-1 flex-col space-y-8 p-8 md:flex">
    <!-- Header -->
    <div class="flex items-center justify-between space-y-2">
      <div>
        <h2 class="text-2xl font-bold tracking-tight">Booking Queue</h2>
        <p class="text-muted-foreground">
          Manage booking queue for supplier deliveries on
          {{ format(selectedDateJS, 'dd-MMM-yyyy') }}
        </p>
      </div>
      <div class="flex items-center space-x-2">
        <Button variant="outline" size="sm" @click="fetchQueues">
          <RefreshCw class="mr-2 h-4 w-4" />
          Refresh
        </Button>
        <Button size="sm" :disabled="isSlotFull" @click="handleCreateBooking">
          <Plus class="mr-2 h-4 w-4" />
          {{ isSlotFull ? 'Slot Full' : 'Add Booking' }}
        </Button>
      </div>
    </div>

    <!-- Filters/Selection -->
    <Card class="p-4">
      <div class="flex flex-col lg:flex-row gap-6 items-center justify-between">
        <!-- Left: Inputs -->
        <div class="flex flex-col sm:flex-row gap-4 flex-1 w-full lg:w-auto">
          <!-- Date Picker -->
          <div class="flex flex-col gap-2 min-w-[200px]">
            <span class="text-sm text-muted-foreground">Select Date</span>
            <Popover>
              <PopoverTrigger as-child>
                <Button
                  variant="outline"
                  class="w-full justify-start text-left font-normal"
                  :class="!selectedDate && 'text-muted-foreground'"
                >
                  <CalendarIcon class="mr-2 h-4 w-4" />
                  {{ selectedDate ? format(selectedDateJS, 'dd-MMM-yyyy') : 'Pick a date' }}
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
            <span class="text-sm text-muted-foreground">Time Slot</span>
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
            Time Slot {{ selectedSlot }}
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
      <Card class="p-4 flex flex-col items-center justify-center text-center">
        <p class="text-sm text-muted-foreground mb-1">Total Queues Today</p>
        <p class="text-3xl font-bold">{{ totalDailyQueues }}</p>
      </Card>
      <Card class="p-4 flex flex-col items-center justify-center text-center">
        <p class="text-sm text-muted-foreground mb-1">Current Queue</p>
        <p class="text-3xl font-bold text-primary">
          {{ queues.length > 0 ? Math.max(...queues.map((q) => Number(q.queueNo) || 0)) : '-' }}
        </p>
      </Card>
      <Card class="p-4 flex flex-col items-center justify-center text-center">
        <p class="text-sm text-muted-foreground mb-1">Next Queue</p>
        <p class="text-3xl font-bold text-green-600">
          {{ nextQueueNo !== null ? nextQueueNo : '-' }}
        </p>
      </Card>
      <Card class="p-4 flex flex-col items-center justify-center text-center">
        <p class="text-sm text-muted-foreground mb-1">Available</p>
        <p class="text-3xl font-bold text-blue-600">
          {{
            currentSlotConfig.limit
              ? Math.max(0, currentSlotConfig.limit - queues.length)
              : 'Unlimited'
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
      <h3 class="text-lg font-semibold">No data available</h3>
      <p class="text-muted-foreground mt-1">No bookings found for this slot.</p>
    </div>

    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
      <Card
        v-for="queue in queues"
        :key="queue.id"
        class="p-4 transition-all hover:shadow-md border-l-4"
        :style="{ borderLeftColor: DAY_COLORS[selectedDateJS.getDay()].queueBg }"
      >
        <div class="flex justify-between items-center mb-3">
          <span class="font-semibold text-sm">Queue Number : {{ queue.queueNo }}</span>
          <div class="flex items-center gap-1">
            <TooltipProvider>
              <Tooltip>
                <TooltipTrigger as-child>
                  <Button variant="ghost" size="icon" class="h-8 w-8" @click="handleEdit(queue)">
                    <Edit2 class="h-4 w-4" />
                  </Button>
                </TooltipTrigger>
                <TooltipContent>Edit</TooltipContent>
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
                <TooltipContent>Delete</TooltipContent>
              </Tooltip>
            </TooltipProvider>
          </div>
        </div>

        <div class="space-y-2 text-sm">
          <div>
            <p class="text-xs text-muted-foreground">Supplier Code</p>
            <p class="font-medium">{{ queue.supplierCode }}</p>
          </div>
          <div>
            <p class="text-xs text-muted-foreground">Supplier Name</p>
            <p class="truncate" :title="queue.supplierName">{{ queue.supplierName }}</p>
          </div>
          <div>
            <p class="text-xs text-muted-foreground">Type</p>
            <p>
              {{ RUBBER_TYPE_MAP[queue.rubberType] || queue.rubberTypeName || queue.rubberType }}
            </p>
          </div>
          <div>
            <p class="text-xs text-muted-foreground">Booking Code</p>
            <p>{{ queue.bookingCode }}</p>
          </div>
        </div>

        <div class="mt-4 pt-4 border-t flex justify-end">
          <Button variant="link" size="sm" class="h-auto p-0" @click="handleShowTicket(queue)">
            <FileText class="h-3 w-3 mr-1" />
            Ticket
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
          <AlertDialogTitle>Confirm Delete</AlertDialogTitle>
          <AlertDialogDescription class="space-y-2">
            <div v-if="bookingToDelete" class="bg-muted/50 p-3 rounded-md text-sm text-foreground">
              <p><strong>Queue:</strong> {{ bookingToDelete.queueNo }}</p>
              <p><strong>Code:</strong> {{ bookingToDelete.bookingCode }}</p>
              <p><strong>Supplier:</strong> {{ bookingToDelete.supplierName }}</p>
            </div>
            <p>Are you sure you want to delete this booking? This action cannot be undone.</p>
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel @click="deleteDialogOpen = false">Cancel</AlertDialogCancel>
          <AlertDialogAction class="bg-destructive hover:bg-destructive/90" @click="confirmDelete"
            >Delete</AlertDialogAction
          >
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  </div>
</template>
