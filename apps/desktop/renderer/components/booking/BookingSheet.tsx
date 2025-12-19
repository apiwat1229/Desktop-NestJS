import { format } from 'date-fns';
import React, { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { api, bookingsApi } from '../../lib/api';
import { useAuthStore } from '../../stores/authStore';
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '../ui/alert-dialog';
import { Button } from '../ui/button';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '../ui/dialog';
import { Input } from '../ui/input';
import { Label } from '../ui/label';
import { SearchableSelect } from '../ui/searchable-select';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '../ui/select';

interface BookingSheetProps {
  open: boolean;
  onClose: () => void;
  selectedDate: Date;
  selectedSlot: string;
  nextQueueNo: number | null;
  onSuccess: () => void;
  editingBooking?: any;
}

const TRUCK_TYPES = [
  { value: 'กระบะ', label: 'กระบะ' },
  { value: '6 ล้อ', label: '6 ล้อ' },
  { value: '10 ล้อ', label: '10 ล้อ' },
  { value: '10 ล้อ พ่วง', label: '10 ล้อ (พ่วง)' },
  { value: 'เทรลเลอร์', label: 'เทรลเลอร์' },
];

function genBookingCode(date: Date, queueNo: number): string {
  const yy = String(date.getFullYear()).slice(-2);
  const mm = String(date.getMonth() + 1).padStart(2, '0');
  const dd = String(date.getDate()).padStart(2, '0');
  const q = String(queueNo).padStart(2, '0');
  return `${yy}${mm}${dd}${q}`;
}

export default function BookingSheet({
  open,
  onClose,
  selectedDate,
  selectedSlot,
  nextQueueNo,
  onSuccess,
  editingBooking,
}: BookingSheetProps) {
  const { t } = useTranslation();
  const { user } = useAuthStore();
  const [loading, setLoading] = useState(false);
  const [suppliers, setSuppliers] = useState<any[]>([]);
  const [rubberTypes, setRubberTypes] = useState<any[]>([]);

  const [supplierId, setSupplierId] = useState('');
  const [truckType, setTruckType] = useState('');
  const [truckRegister, setTruckRegister] = useState('');
  const [rubberType, setRubberType] = useState('');

  // Alert Dialog states
  const [alertOpen, setAlertOpen] = useState(false);
  const [alertTitle, setAlertTitle] = useState('');
  const [alertMessage, setAlertMessage] = useState('');
  const [alertType, setAlertType] = useState<'error' | 'success'>('error');

  const [startTime, endTime] = selectedSlot.split('-');
  const isEditMode = !!editingBooking;

  useEffect(() => {
    if (!open) return;

    const fetchData = async () => {
      try {
        const [suppliersResp, rubberTypesResp] = await Promise.all([
          api.get('/suppliers'),
          api.get('/rubber-types'),
        ]);

        setSuppliers(suppliersResp.data || []);
        setRubberTypes(rubberTypesResp.data || []);
      } catch (err) {
        console.error('Failed to fetch data:', err);
      }
    };

    fetchData();

    if (isEditMode && editingBooking) {
      setSupplierId(editingBooking.supplierId || '');
      setTruckType(editingBooking.truckType || '');
      setTruckRegister(editingBooking.truckRegister || '');
      setRubberType(editingBooking.rubberType || '');
    } else {
      setSupplierId('');
      setTruckType('');
      setTruckRegister('');
      setRubberType('');
    }
  }, [open, isEditMode, editingBooking]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!supplierId || !rubberType) {
      setAlertTitle('ข้อมูลไม่ครบถ้วน');
      setAlertMessage('กรุณากรอกข้อมูล Supplier และ Rubber Type ให้ครบถ้วน');
      setAlertType('error');
      setAlertOpen(true);
      return;
    }

    try {
      setLoading(true);

      const selectedSupplier = suppliers.find((s) => s.id === supplierId);
      const supplierCode = selectedSupplier?.code || '';
      const supplierName = selectedSupplier?.name || selectedSupplier?.displayName || '';

      // Get current user from Auth Store
      const user = useAuthStore.getState().user;
      const recorderName = user?.name || user?.username || user?.email || 'System';

      const payload: any = {
        date: format(selectedDate, 'yyyy-MM-dd'),
        startTime,
        endTime,
        supplierId,
        supplierCode,
        supplierName,
        truckType,
        truckRegister,
        rubberType,
        recorder: recorderName,
      };

      if (isEditMode && editingBooking?.id) {
        await bookingsApi.update(editingBooking.id, payload);
      } else {
        await bookingsApi.create(payload);
      }

      onSuccess();
      onClose();
    } catch (err: any) {
      console.error('Save booking error:', err);
      setAlertTitle('เกิดข้อผิดพลาด');
      setAlertMessage(err?.response?.data?.message || 'บันทึกการจองไม่สำเร็จ กรุณาลองใหม่อีกครั้ง');
      setAlertType('error');
      setAlertOpen(true);
    } finally {
      setLoading(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={onClose}>
      <DialogContent className="max-w-3xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>
            {isEditMode ? t('admin.users.editUser') : t('booking.addBooking')}
          </DialogTitle>
          <DialogDescription>
            {format(selectedDate, 'dd MMM yyyy')} • {selectedSlot}
          </DialogDescription>
        </DialogHeader>

        <form onSubmit={handleSubmit} className="space-y-4 mt-6">
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label>Start Time</Label>
              <Input value={startTime} readOnly disabled />
            </div>
            <div className="space-y-2">
              <Label>End Time</Label>
              <Input value={endTime} readOnly disabled />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label>Queue No.</Label>
              <Input value={nextQueueNo !== null ? nextQueueNo : '-'} readOnly disabled />
            </div>
            <div className="space-y-2">
              <Label>Booking Code</Label>
              <Input
                value={nextQueueNo !== null ? genBookingCode(selectedDate, nextQueueNo) : '-'}
                readOnly
                disabled
              />
            </div>
          </div>

          <div className="space-y-2">
            <Label>Supplier</Label>
            <SearchableSelect
              options={suppliers.map((supplier) => ({
                value: supplier.id,
                label: `${supplier.code} - ${supplier.name || supplier.displayName}`,
              }))}
              value={supplierId}
              onChange={setSupplierId}
              placeholder="เลือก Supplier"
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label>Truck Type</Label>
              <Select value={truckType} onValueChange={setTruckType}>
                <SelectTrigger>
                  <SelectValue placeholder="เลือกประเภทรถ" />
                </SelectTrigger>
                <SelectContent>
                  {TRUCK_TYPES.map((type) => (
                    <SelectItem key={type.value} value={type.value}>
                      {type.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-2">
              <Label>License Plate</Label>
              <Input
                value={truckRegister}
                onChange={(e) => setTruckRegister(e.target.value)}
                placeholder="เช่น 10 ยธ 59343"
              />
            </div>
          </div>

          <div className="space-y-2">
            <Label>Rubber Type *</Label>
            <Select value={rubberType} onValueChange={setRubberType}>
              <SelectTrigger>
                <SelectValue placeholder="เลือก Rubber Type" />
              </SelectTrigger>
              <SelectContent>
                {rubberTypes
                  .filter((rt) => rt.code === 'CL' || rt.name?.includes('CL'))
                  .map((type) => (
                    <SelectItem key={type.id} value={type.code}>
                      {type.name}
                    </SelectItem>
                  ))}
              </SelectContent>
            </Select>
          </div>

          <DialogFooter className="mt-6">
            <Button type="button" variant="outline" onClick={onClose}>
              {t('common.cancel')}
            </Button>
            <Button type="submit" disabled={loading}>
              {loading
                ? `${t('common.loading')}`
                : isEditMode
                  ? t('common.update')
                  : t('common.save')}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>

      {/* Alert Dialog for validation and errors */}
      <AlertDialog open={alertOpen} onOpenChange={setAlertOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>{alertTitle}</AlertDialogTitle>
            <AlertDialogDescription>{alertMessage}</AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogAction onClick={() => setAlertOpen(false)}>ตกลง</AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </Dialog>
  );
}
