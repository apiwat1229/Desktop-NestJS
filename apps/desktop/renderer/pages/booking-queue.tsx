import { format } from 'date-fns';
import html2canvas from 'html2canvas';
import {
  Calendar as CalendarIcon,
  Copy,
  Download,
  Edit2,
  FileText,
  Plus,
  RefreshCw,
  Trash2,
} from 'lucide-react';
import { useRouter } from 'next/router';
import { QRCodeSVG } from 'qrcode.react';
import { useEffect, useMemo, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import AnimatedBackground from '../components/AnimatedBackground';
import BookingSheet from '../components/booking/BookingSheet';
import Navbar from '../components/Navbar';
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '../components/ui/alert-dialog';
import { Badge } from '../components/ui/badge';
import { Button } from '../components/ui/button';
import { Calendar } from '../components/ui/calendar';
import { Card } from '../components/ui/card';
import { Dialog, DialogContent } from '../components/ui/dialog';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '../components/ui/dropdown-menu';
import { Popover, PopoverContent, PopoverTrigger } from '../components/ui/popover';
import { Spinner } from '../components/ui/spinner';
import { Tabs, TabsList, TabsTrigger } from '../components/ui/tabs';
import { useToast } from '../components/ui/use-toast';
import { bookingsApi } from '../lib/api';

interface TimeSlot {
  label: string;
  value: string;
  startTime: string;
  endTime: string;
  limit: number | null;
}

const TIME_SLOTS: TimeSlot[] = [
  { label: '08:00-09:00', value: '08:00-09:00', startTime: '08:00', endTime: '09:00', limit: 4 },
  { label: '09:00-10:00', value: '09:00-10:00', startTime: '09:00', endTime: '10:00', limit: 4 },
  { label: '10:00-11:00', value: '10:00-11:00', startTime: '10:00', endTime: '11:00', limit: 4 },
  { label: '11:00-12:00', value: '11:00-12:00', startTime: '11:00', endTime: '12:00', limit: 4 },
  { label: '13:00-14:00', value: '13:00-14:00', startTime: '13:00', endTime: '14:00', limit: null },
];

// Day colors for ticket design
const DAY_COLORS = [
  { cardBg: '#fde2e2', border: '#d46b6b', queueBg: '#e11d48' }, // Sun
  { cardBg: '#fff7cc', border: '#d1b208', queueBg: '#eab308' }, // Mon
  { cardBg: '#ffd8e8', border: '#e26c9a', queueBg: '#ec4899' }, // Tue
  { cardBg: '#dff5df', border: '#63a463', queueBg: '#22c55e' }, // Wed
  { cardBg: '#ffe4cc', border: '#d58a4a', queueBg: '#f97316' }, // Thu
  { cardBg: '#dbeeff', border: '#5e97c2', queueBg: '#38bdf8' }, // Fri
  { cardBg: '#eadbff', border: '#8b6abf', queueBg: '#a855f7' }, // Sat
];

// Rubber type code to name mapping
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

function getSlotConfig(slotValue: string, selectedDate: Date) {
  const foundSlot = TIME_SLOTS.find((s) => s.value === slotValue);
  if (!foundSlot) return { start: 1, limit: null };

  const dayOfWeek = selectedDate.getDay();
  if (dayOfWeek === 6 && slotValue === '10:00-11:00') {
    return { start: 9, limit: null };
  }
  return { start: 1, limit: foundSlot.limit };
}

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

function getAvailableSlots(selectedDate: Date | undefined) {
  if (!selectedDate) return TIME_SLOTS;
  const dayOfWeek = selectedDate.getDay();
  if (dayOfWeek === 6) {
    return TIME_SLOTS.filter(
      (slot) =>
        slot.value === '08:00-09:00' || slot.value === '09:00-10:00' || slot.value === '10:00-11:00'
    );
  }
  return TIME_SLOTS;
}

export default function BookingQueue() {
  const router = useRouter();
  const { toast } = useToast();
  const { t } = useTranslation();
  const [selectedDate, setSelectedDate] = useState<Date>(new Date());
  const [selectedTimeSlot, setSelectedTimeSlot] = useState<string>('08:00-09:00');
  const [queues, setQueues] = useState<any[]>([]);
  const [totalDailyQueues, setTotalDailyQueues] = useState(0);
  const [loading, setLoading] = useState(false);
  const [deleteId, setDeleteId] = useState<string | null>(null);
  const [sheetOpen, setSheetOpen] = useState(false);
  const [editingBooking, setEditingBooking] = useState<any>(null);
  const [ticketDialogOpen, setTicketDialogOpen] = useState(false);
  const [selectedTicket, setSelectedTicket] = useState<any>(null);
  const ticketRef = useRef<HTMLDivElement>(null);

  const slotConfig = getSlotConfig(selectedTimeSlot, selectedDate);
  const isSlotFull = slotConfig.limit ? queues.length >= slotConfig.limit : false;

  const nextQueueNo = useMemo(() => {
    if (isSlotFull) return null;

    const used = queues
      .map((q) => Number(q.queueNo))
      .filter((n) => !Number.isNaN(n))
      .sort((a, b) => a - b);

    let candidate = slotConfig.start;
    while (true) {
      if (!slotConfig.limit || candidate < slotConfig.start + slotConfig.limit) {
        if (!used.includes(candidate)) {
          return candidate;
        }
        candidate += 1;
      } else {
        return slotConfig.start + used.length;
      }
    }
  }, [slotConfig, queues, isSlotFull]);

  const fetchQueues = async () => {
    if (!selectedDate || !selectedTimeSlot) return;

    try {
      setLoading(true);
      const dateParam = format(selectedDate, 'yyyy-MM-dd');

      const resp = await bookingsApi.getAll({
        date: dateParam,
        slot: selectedTimeSlot,
      });
      setQueues(resp || []);

      const dailyResp = await bookingsApi.getAll({ date: dateParam });
      setTotalDailyQueues(dailyResp?.length || 0);
    } catch (err) {
      console.error('[BookingQueue] fetch error:', err);
      setQueues([]);
      setTotalDailyQueues(0);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchQueues();
  }, [selectedDate, selectedTimeSlot]);

  const handleDelete = async () => {
    if (!deleteId) return;
    try {
      await bookingsApi.delete(deleteId);
      setDeleteId(null);
      fetchQueues();
    } catch (err) {
      console.error('Delete error:', err);
    }
  };

  const handleCreateBooking = () => {
    if (isSlotFull) {
      alert('ช่วงเวลานี้เต็มแล้ว');
      return;
    }
    setEditingBooking(null);
    setSheetOpen(true);
  };

  const handleEdit = (booking: any) => {
    setEditingBooking(booking);
    setSheetOpen(true);
  };

  const handleShowTicket = (booking: any) => {
    setSelectedTicket(booking);
    setTicketDialogOpen(true);
  };

  const handleSaveTicketImage = async () => {
    if (!ticketRef.current) return;
    try {
      const canvas = await html2canvas(ticketRef.current, {
        backgroundColor: null,
        scale: 3,
        useCORS: true,
      });
      const link = document.createElement('a');
      link.download = `ticket_${selectedTicket?.bookingCode || 'booking'}.png`;
      link.href = canvas.toDataURL('image/png');
      link.click();
      toast({
        title: 'สำเร็จ',
        description: 'บันทึกรูปภาพสำเร็จ',
        className: 'bg-green-600 text-white border-green-700',
      });
    } catch (err) {
      console.error('Save error:', err);
      toast({
        title: t('common.error'),
        description: t('booking.errorSaving'),
        variant: 'destructive',
      });
    }
  };

  const handleCopyTicketImage = async () => {
    if (!ticketRef.current) return;
    try {
      const canvas = await html2canvas(ticketRef.current, {
        backgroundColor: null,
        scale: 3,
        useCORS: true,
      });
      canvas.toBlob(async (blob: Blob | null) => {
        if (!blob) return;
        const item = new ClipboardItem({ [blob.type]: blob });
        await navigator.clipboard.write([item]);
        toast({
          title: 'สำเร็จ',
          description: 'คัดลอก Ticket แล้ว',
          className: 'bg-green-600 text-white border-green-700',
        });
      }, 'image/png');
    } catch (err) {
      console.error('Copy error:', err);
      toast({
        title: t('common.error'),
        description: t('booking.errorCopying'),
        variant: 'destructive',
      });
    }
  };

  return (
    <div className="min-h-screen bg-background relative overflow-hidden flex flex-col">
      <Navbar />

      <div className="absolute inset-0 pointer-events-none z-0">
        <AnimatedBackground />
      </div>

      <main className="flex-1 container mx-auto px-6 py-12 relative z-10 max-w-7xl">
        {/* Header */}
        <div className="mb-8">
          <div className="flex justify-between items-center mb-4">
            <div>
              <h1 className="text-3xl font-bold text-foreground">{t('booking.title')}</h1>
              <p className="text-muted-foreground">
                {t('booking.subtitle')} {format(selectedDate, 'dd-MMM-yyyy')}
              </p>
            </div>
            <div className="flex gap-2">
              <Button variant="outline" size="sm" onClick={fetchQueues}>
                <RefreshCw className="h-4 w-4 mr-2" />
                {t('common.refresh')}
              </Button>
              <Button size="sm" disabled={isSlotFull} onClick={handleCreateBooking}>
                <Plus className="h-4 w-4 mr-2" />
                {isSlotFull ? t('booking.slotFull') : t('booking.addBooking')}
              </Button>
            </div>
          </div>

          {/* Date and Time Slot Selection */}
          <Card className="p-4">
            <div className="flex gap-4 items-center">
              <div className="flex flex-col gap-2">
                <span className="text-sm text-muted-foreground">{t('booking.selectDate')}</span>
                <Popover>
                  <PopoverTrigger asChild>
                    <Button
                      variant="outline"
                      className="w-[200px] justify-start text-left font-normal"
                    >
                      <CalendarIcon className="mr-2 h-4 w-4" />
                      {format(selectedDate, 'dd-MMM-yyyy')}
                    </Button>
                  </PopoverTrigger>
                  <PopoverContent className="w-auto p-0" align="start">
                    <Calendar
                      mode="single"
                      selected={selectedDate}
                      onSelect={(date) => date && setSelectedDate(date)}
                      initialFocus
                    />
                  </PopoverContent>
                </Popover>
              </div>

              <div className="flex-1 flex flex-col gap-2">
                <span className="text-sm text-muted-foreground">{t('booking.timeSlot')}</span>
                <Tabs value={selectedTimeSlot} onValueChange={setSelectedTimeSlot}>
                  <TabsList className="grid w-full grid-cols-5">
                    {getAvailableSlots(selectedDate).map((slot) => (
                      <TabsTrigger key={slot.value} value={slot.value}>
                        {slot.label}
                      </TabsTrigger>
                    ))}
                  </TabsList>
                </Tabs>
              </div>
            </div>
          </Card>
        </div>

        {/* Slot Header */}
        <div className="flex justify-between items-center mb-6">
          <div>
            <h2 className="text-xl font-semibold">
              {t('booking.timeSlot')} {selectedTimeSlot}
            </h2>
            <p className="text-sm text-muted-foreground">
              {format(selectedDate, 'dd-MMM-yyyy (EEE)')} •{' '}
              {slotConfig.limit
                ? `Queue ${slotConfig.start} - ${slotConfig.start + slotConfig.limit - 1}`
                : `Queue ${slotConfig.start} ขึ้นไป (ไม่จำกัด)`}
            </p>
          </div>
          <div className="flex gap-2">
            <Badge variant="secondary">
              {t('booking.currentQueue')}: {queues.length}
            </Badge>
            {slotConfig.limit && (
              <Badge variant={isSlotFull ? 'destructive' : 'default'}>
                {isSlotFull
                  ? t('booking.full')
                  : `${t('booking.available')} ${slotConfig.limit - queues.length} ${t('booking.queue')}`}
              </Badge>
            )}
          </div>
        </div>

        {/* Queue Cards Grid */}
        {loading ? (
          <div className="flex flex-col items-center justify-center p-12 text-center h-[300px]">
            <Spinner size="lg" className="mb-4" />
            <p className="text-muted-foreground animate-pulse">กำลังโหลดข้อมูล...</p>
          </div>
        ) : queues.length === 0 ? (
          <div className="flex flex-col items-center justify-center p-12 text-center border-2 border-dashed border-border rounded-xl bg-background/50 h-[300px]">
            <div className="w-16 h-16 bg-blue-50 dark:bg-blue-900/20 rounded-full flex items-center justify-center mb-4">
              <FileText className="w-8 h-8 text-blue-500" />
            </div>
            <h3 className="text-lg font-semibold text-foreground">{t('common.noData')}</h3>
            <p className="text-muted-foreground mt-1">{t('booking.noBookingsFound')}</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            {queues.map((queue) => {
              // Determine theme based on selected date (or queue date if needed, but usually selectedDate)
              const date = new Date(selectedDate);
              const dayOfWeek = date.getDay();
              const dayTheme = DAY_COLORS[dayOfWeek];

              return (
                <Card
                  key={queue.id}
                  className="p-4 transition-all hover:shadow-md border-l-4"
                  style={{ borderLeftColor: dayTheme.queueBg }}
                >
                  <div className="flex justify-between items-center mb-3">
                    <span className="font-semibold text-sm">QUEUE : {queue.queueNo}</span>
                    <DropdownMenu>
                      <DropdownMenuTrigger asChild>
                        <Button variant="ghost" size="sm" className="h-8 w-8 p-0">
                          <span className="sr-only">Open menu</span>
                          <Edit2 className="h-4 w-4" />
                        </Button>
                      </DropdownMenuTrigger>
                      <DropdownMenuContent align="end">
                        <DropdownMenuItem onClick={() => handleEdit(queue)}>
                          <Edit2 className="mr-2 h-4 w-4" />
                          Edit
                        </DropdownMenuItem>
                        <DropdownMenuItem
                          className="text-red-600"
                          onClick={() => setDeleteId(queue.id)}
                        >
                          <Trash2 className="mr-2 h-4 w-4" />
                          Delete
                        </DropdownMenuItem>
                      </DropdownMenuContent>
                    </DropdownMenu>
                  </div>

                  <div className="space-y-2 text-sm">
                    <div>
                      <p className="text-xs text-muted-foreground">Code</p>
                      <p className="font-medium">{queue.supplierCode}</p>
                    </div>
                    <div>
                      <p className="text-xs text-muted-foreground">Supplier</p>
                      <p className="truncate" title={queue.supplierName}>
                        {queue.supplierName}
                      </p>
                    </div>
                    <div>
                      <p className="text-xs text-muted-foreground">Truck</p>
                      <p>
                        {[queue.truckType, queue.truckRegister].filter(Boolean).join(' ') || '-'}
                      </p>
                    </div>
                    <div>
                      <p className="text-xs text-muted-foreground">Type</p>
                      <p>
                        {RUBBER_TYPE_MAP[queue.rubberType] ||
                          queue.rubberTypeName ||
                          queue.rubberType}
                      </p>
                    </div>
                    <div>
                      <p className="text-xs text-muted-foreground">Recorder</p>
                      <p>{queue.recorder}</p>
                    </div>
                  </div>

                  <div className="mt-4 pt-4 border-t flex justify-between items-center">
                    <span className="text-xs text-muted-foreground">
                      Booking: {queue.bookingCode}
                    </span>
                    <Button
                      variant="link"
                      size="sm"
                      className="h-auto p-0"
                      onClick={() => handleShowTicket(queue)}
                    >
                      <FileText className="h-3 w-3 mr-1" />
                      Ticket
                    </Button>
                  </div>
                </Card>
              );
            })}
          </div>
        )}

        {/* Statistics */}
        <div className="grid grid-cols-4 gap-4 mt-8">
          <Card className="p-4 flex flex-col items-center justify-center text-center min-h-[100px]">
            <p className="text-sm text-muted-foreground mb-2">{t('booking.totalToday')}</p>
            <p className="text-3xl font-bold">{totalDailyQueues}</p>
          </Card>
          <Card className="p-4 flex flex-col items-center justify-center text-center min-h-[100px]">
            <p className="text-sm text-muted-foreground mb-2">{t('booking.currentQueue')}</p>
            <p className="text-3xl font-bold text-primary">{queues.length}</p>
          </Card>
          <Card className="p-4 flex flex-col items-center justify-center text-center min-h-[100px]">
            <p className="text-sm text-muted-foreground mb-2">{t('booking.nextQueue')}</p>
            <p className="text-3xl font-bold text-green-600">
              {nextQueueNo !== null ? nextQueueNo : '-'}
            </p>
          </Card>
          <Card className="p-4 flex flex-col items-center justify-center text-center min-h-[100px]">
            <p className="text-sm text-muted-foreground mb-2">{t('common.status')}</p>
            {isSlotFull ? (
              <p className="text-3xl font-bold text-red-600">{t('booking.full')}</p>
            ) : slotConfig.limit ? (
              <p className="text-3xl font-bold text-blue-500">
                {t('booking.availableCount', { count: slotConfig.limit - queues.length })}
              </p>
            ) : (
              <p className="text-3xl font-bold text-green-600">{t('booking.available')}</p>
            )}
          </Card>
        </div>
      </main>

      {/* Booking Sheet */}
      <BookingSheet
        open={sheetOpen}
        onClose={() => {
          setSheetOpen(false);
          setEditingBooking(null);
        }}
        selectedDate={selectedDate}
        selectedSlot={selectedTimeSlot}
        nextQueueNo={nextQueueNo || 1}
        onSuccess={() => {
          setSheetOpen(false);
          setEditingBooking(null);
          fetchQueues();
        }}
        editingBooking={editingBooking}
      />

      {/* Ticket Dialog */}
      <Dialog open={ticketDialogOpen} onOpenChange={setTicketDialogOpen}>
        <DialogContent className="max-w-md">
          {selectedTicket &&
            (() => {
              const date = new Date(selectedTicket.date);
              const dayOfWeek = date.getDay();
              const theme = DAY_COLORS[dayOfWeek];
              const truckPreview =
                [selectedTicket.truckType, selectedTicket.truckRegister]
                  .filter(Boolean)
                  .join(' ')
                  .trim() || '-';
              const hasBookingCode = !!selectedTicket.bookingCode;

              return (
                <div className="space-y-4">
                  {/* Ticket Card */}
                  <div
                    ref={ticketRef}
                    style={{
                      background: theme.cardBg,
                      border: `2px solid ${theme.border}`,
                      padding: '16px',
                      borderRadius: '12px',
                      fontFamily: "'Sarabun', 'Kanit', sans-serif",
                    }}
                  >
                    {/* Header */}
                    <div className="flex items-center justify-between mb-4">
                      <div className="flex items-center gap-2">
                        <img
                          src="/logo-dark.png"
                          alt="YTRC Logo"
                          className="h-8 w-auto"
                          onError={(e) => {
                            e.currentTarget.style.display = 'none';
                          }}
                        />
                      </div>
                      <span className="text-lg font-bold">บัตรคิว CL</span>
                    </div>

                    {/* Details */}
                    <div className="space-y-2">
                      {[
                        ['Code:', selectedTicket.supplierCode || '-'],
                        ['Name:', selectedTicket.supplierName || '-'],
                        ['Date:', thaiDateWithWeekday(date)],
                        ['Time:', selectedTicket.startTime || '-'],
                        ['Truck:', truckPreview],
                        [
                          'Type:',
                          RUBBER_TYPE_MAP[selectedTicket.rubberType] ||
                            selectedTicket.rubberTypeName ||
                            selectedTicket.rubberType ||
                            '-',
                        ],
                        ['Booking:', selectedTicket.bookingCode || '-'],
                        ['Recorder:', selectedTicket.recorder || '-'],
                      ].map(([label, value]) => (
                        <div key={label} className="flex justify-between text-sm">
                          <span className="font-semibold">{label}</span>
                          <span className="text-right flex-1 ml-2">{value}</span>
                        </div>
                      ))}
                    </div>

                    {/* Queue Number */}
                    <div className="flex justify-between items-center my-4">
                      <span className="font-bold">Queue:</span>
                      <div
                        style={{
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
                        }}
                      >
                        {selectedTicket.queueNo ?? '-'}
                      </div>
                    </div>

                    {/* Warning */}
                    <div className="text-center my-4 leading-tight">
                      <p className="text-xs font-semibold">สามารถนำรถมาจอดค้างคืนเพื่อรอ</p>
                      <p className="text-xs font-semibold">ที่หน้าโรงงานได้</p>
                      <p className="text-xs font-bold text-red-600 mt-2">
                        * ห้ามจอดรถบนทางเข้าหน้าโรงงานเด็ดขาด *
                      </p>
                    </div>

                    {/* QR Code */}
                    <div className="flex justify-center mt-4">
                      {hasBookingCode ? (
                        <QRCodeSVG
                          value={String(selectedTicket.bookingCode)}
                          size={128}
                          bgColor="#ffffff"
                          fgColor="#000000"
                          level="M"
                          style={{
                            padding: '4px',
                            background: '#fff',
                            borderRadius: '4px',
                          }}
                        />
                      ) : (
                        <div className="w-32 h-32 bg-white/50 rounded border border-dashed border-gray-400 flex items-center justify-center">
                          <span className="text-gray-500 text-sm">No Code</span>
                        </div>
                      )}
                    </div>
                  </div>

                  {/* Actions */}
                  <div className="flex justify-center gap-2">
                    <Button
                      onClick={handleSaveTicketImage}
                      className="gap-2 bg-green-600 hover:bg-green-700"
                    >
                      <Download className="h-4 w-4" />
                      Save Ticket
                    </Button>
                    <Button onClick={handleCopyTicketImage} variant="outline" className="gap-2">
                      <Copy className="h-4 w-4" />
                      Copy Ticket
                    </Button>
                  </div>
                </div>
              );
            })()}
        </DialogContent>
      </Dialog>

      {/* Delete Confirmation Dialog */}
      <AlertDialog open={!!deleteId} onOpenChange={() => setDeleteId(null)}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>ยืนยันการลบคิว</AlertDialogTitle>
            <AlertDialogDescription>
              คุณต้องการลบคิวนี้ใช่หรือไม่? การดำเนินการนี้ไม่สามารถย้อนกลับได้
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>ยกเลิก</AlertDialogCancel>
            <AlertDialogAction onClick={handleDelete} className="bg-red-600 hover:bg-red-700">
              ลบ
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
