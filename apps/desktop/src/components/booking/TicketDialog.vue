<script setup lang="ts">
import { Button } from '@/components/ui/button';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import html2canvas from 'html2canvas';
import { Copy, Download } from 'lucide-vue-next';
import QrcodeVue from 'qrcode.vue';
import { computed, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { toast } from 'vue-sonner';

// --- Props ---
const props = defineProps<{
  open: boolean;
  ticket: any;
}>();

const emit = defineEmits(['update:open']);

// --- State ---
const { t } = useI18n();
const ticketRef = ref<HTMLDivElement | null>(null);

// --- Constants ---
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

// --- Computeds ---
const theme = computed(() => {
  if (!props.ticket?.date) return DAY_COLORS[0];
  const date = new Date(props.ticket.date);
  return DAY_COLORS[date.getDay()];
});

const truckPreview = computed(() => {
  if (!props.ticket) return '-';
  return (
    [props.ticket.truckType, props.ticket.truckRegister].filter(Boolean).join(' ').trim() || '-'
  );
});

const formattedDate = computed(() => {
  if (!props.ticket?.date) return '-';
  const date = new Date(props.ticket.date);
  return thaiDateWithWeekday(date);
});

// --- Helpers ---
function thaiDateWithWeekday(dateField: Date): string {
  const weekdays = ['อาทิตย์', 'จันทร์', 'อังคาร', 'พุธ', 'พฤหัสบดี', 'ศุกร์', 'เสาร์'];
  const months = [
    'ม.ค.',
    'ก.พ.',
    'มี.ค.',
    'เม.ย.',
    'พ.ค.',
    'มิ.ย.',
    'ก.ค.',
    'ส.ค.',
    'ก.ย.',
    'ต.ค.',
    'พ.ย.',
    'ธ.ค.',
  ];

  const weekday = weekdays[dateField.getDay()];
  const day = dateField.getDate();
  const month = months[dateField.getMonth()];
  const year = dateField.getFullYear() + 543;

  return `( ${weekday} ) ${day} ${month} ${year}`;
}

const handleSaveTicketImage = async () => {
  if (!ticketRef.value) return;
  try {
    const canvas = await html2canvas(ticketRef.value, {
      backgroundColor: null,
      scale: 3,
      useCORS: true,
    });
    const link = document.createElement('a');
    link.download = `ticket_${props.ticket?.bookingCode || 'booking'}.png`;
    link.href = canvas.toDataURL('image/png');
    link.click();
    toast.success(t('common.toast.success'), {
      description: t('common.toast.imageSaved', 'Ticket image saved successfully'),
    });
  } catch (err) {
    console.error('Save error:', err);
    toast.error(t('common.error'), {
      description: t('booking.errorSaving', 'Failed to save ticket image'),
    });
  }
};

const handleCopyTicketImage = async () => {
  if (!ticketRef.value) return;
  try {
    const canvas = await html2canvas(ticketRef.value, {
      backgroundColor: null,
      scale: 3,
      useCORS: true,
    });
    canvas.toBlob(async (blob: Blob | null) => {
      if (!blob) return;
      const item = new ClipboardItem({ [blob.type]: blob });
      await navigator.clipboard.write([item]);
      toast.success(t('common.toast.success'), {
        description: t('common.toast.ticketCopied', 'Ticket copied to clipboard'),
      });
    }, 'image/png');
  } catch (err: any) {
    console.error('Copy error:', err);
    toast.error(t('common.error'), {
      description: t('booking.errorCopying', 'Failed to copy ticket image'),
    });
  }
};
</script>

<template>
  <Dialog :open="open" @update:open="$emit('update:open', $event)">
    <DialogContent class="max-w-md">
      <DialogHeader>
        <DialogTitle>Ticket Details</DialogTitle>
        <DialogDescription> Preview of the booking ticket details. </DialogDescription>
      </DialogHeader>

      <div v-if="ticket" class="space-y-4">
        <!-- Ticket Card -->
        <div
          ref="ticketRef"
          :style="{
            background: theme.cardBg,
            border: `2px solid ${theme.border}`,
            padding: '16px',
            borderRadius: '12px',
            fontFamily: '\'Sarabun\', \'Kanit\', sans-serif',
          }"
        >
          <!-- Header -->
          <div class="flex items-center justify-between mb-4">
            <div class="flex items-center gap-2">
              <img
                src="/logo-dark.png"
                alt="YTRC Logo"
                class="h-8 w-auto"
                @error="(e: any) => (e.target.style.display = 'none')"
              />
            </div>
            <span class="text-lg font-bold">บัตรคิว CL</span>
          </div>

          <!-- Details -->
          <div class="space-y-2">
            <div class="flex justify-between text-sm">
              <span class="font-semibold">Code:</span>
              <span class="text-right flex-1 ml-2">{{ ticket.supplierCode || '-' }}</span>
            </div>
            <div class="flex justify-between text-sm">
              <span class="font-semibold">Name:</span>
              <span class="text-right flex-1 ml-2">{{ ticket.supplierName || '-' }}</span>
            </div>
            <div class="flex justify-between text-sm">
              <span class="font-semibold">Date:</span>
              <span class="text-right flex-1 ml-2">{{ formattedDate }}</span>
            </div>
            <div class="flex justify-between text-sm">
              <span class="font-semibold">Time:</span>
              <span class="text-right flex-1 ml-2">{{ ticket.startTime || '-' }}</span>
            </div>
            <div class="flex justify-between text-sm">
              <span class="font-semibold">Truck:</span>
              <span class="text-right flex-1 ml-2">{{ truckPreview }}</span>
            </div>
            <div class="flex justify-between text-sm">
              <span class="font-semibold">Type:</span>
              <span class="text-right flex-1 ml-2">
                {{
                  RUBBER_TYPE_MAP[ticket.rubberType] ||
                  ticket.rubberTypeName ||
                  ticket.rubberType ||
                  '-'
                }}
              </span>
            </div>
            <div class="flex justify-between text-sm">
              <span class="font-semibold">Booking:</span>
              <span class="text-right flex-1 ml-2">{{ ticket.bookingCode || '-' }}</span>
            </div>
            <div class="flex justify-between text-sm">
              <span class="font-semibold">Recorder:</span>
              <span class="text-right flex-1 ml-2">{{ ticket.recorder || '-' }}</span>
            </div>
          </div>

          <!-- Queue Number -->
          <div class="flex justify-between items-center my-4">
            <span class="font-bold">Queue:</span>
            <div
              :style="{
                width: '56px',
                height: '56px',
                borderRadius: '10px',
                background: theme.queueBg,
                color: '#fff',
                fontSize: '28px',
                fontWeight: 700,
                border: `2px solid ${theme.border}`,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }"
            >
              {{ ticket.queueNo ?? '-' }}
            </div>
          </div>

          <!-- Warning -->
          <div class="text-center my-4 leading-tight">
            <p class="text-xs font-semibold">สามารถนำรถมาจอดค้างคืนเพื่อรอ</p>
            <p class="text-xs font-semibold">ที่หน้าโรงงานได้</p>
            <p class="text-xs font-bold text-red-600 mt-2">
              * ห้ามจอดรถบนทางเข้าหน้าโรงงานเด็ดขาด *
            </p>
          </div>

          <!-- QR Code -->
          <div class="flex justify-center mt-4">
            <QrcodeVue
              v-if="ticket.bookingCode"
              :value="String(ticket.bookingCode)"
              :size="128"
              level="M"
              render-as="svg"
              class="p-1 bg-white rounded"
            />
            <div
              v-else
              class="w-32 h-32 bg-muted/50 rounded border border-dashed border-muted-foreground/30 flex items-center justify-center"
            >
              <span class="text-gray-500 text-sm">No Code</span>
            </div>
          </div>
        </div>

        <!-- Actions -->
        <div class="flex justify-center gap-2">
          <Button
            @click="handleSaveTicketImage"
            class="gap-2 bg-green-600 hover:bg-green-700 text-white"
          >
            <Download class="h-4 w-4" />
            Save Ticket
          </Button>
          <Button @click="handleCopyTicketImage" variant="outline" class="gap-2">
            <Copy class="h-4 w-4" />
            Copy Ticket
          </Button>
        </div>
      </div>
    </DialogContent>
  </Dialog>
</template>
