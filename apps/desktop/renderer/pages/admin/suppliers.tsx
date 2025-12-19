import { format } from 'date-fns';
import { Plus, Trash2, Truck } from 'lucide-react';
import React, { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import AdminLayout from '../../components/AdminLayout';
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '../../components/ui/alert-dialog';
import { DataTable } from '../../components/ui/data-table';
import { DatePicker } from '../../components/ui/date-picker';
import { Input } from '../../components/ui/input';
import { Label } from '../../components/ui/label';
import { MultiSelect } from '../../components/ui/multi-select';
import { SearchableSelect } from '../../components/ui/searchable-select';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '../../components/ui/select';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '../../components/ui/tabs';
import { useToast } from '../../components/ui/use-toast';
import { api } from '../../lib/api';
import { Supplier, useSupplierColumns } from './suppliers/columns';

// Create a dedicated wrapper relative to Axios instance if needed or reuse existing connection logic
// Assuming `api` is the axios instance from lib/api.ts

const suppliersApi = {
  getAll: async () => {
    const res = await api.get('/suppliers');
    return res.data;
  },
  create: async (data: any) => {
    const res = await api.post('/suppliers', data);
    return res.data;
  },
  update: async (id: string, data: any) => {
    const res = await api.patch(`/suppliers/${id}`, data);
    return res.data;
  },
  delete: async (id: string) => {
    return api.delete(`/suppliers/${id}`);
  },
};

const masterApi = {
  getProvinces: async () => {
    const res = await api.get('/master/provinces');
    return res.data;
  },
  getDistricts: async (provinceId: number) => {
    const res = await api.get(`/master/provinces/${provinceId}/districts`);
    return res.data;
  },
  getSubdistricts: async (districtId: number) => {
    const res = await api.get(`/master/districts/${districtId}/subdistricts`);
    return res.data;
  },
  getRubberTypes: async () => {
    const res = await api.get('/master/rubber-types');
    return res.data;
  },
};

export default function SuppliersPage() {
  const { t } = useTranslation();
  const [suppliers, setSuppliers] = useState<Supplier[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  // Modal State
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingSupplier, setEditingSupplier] = useState<Supplier | null>(null);
  const [deleteId, setDeleteId] = useState<string | null>(null);

  // Form Data
  const [formData, setFormData] = useState({
    code: '',
    name: '',
    firstName: '',
    lastName: '',
    title: '',
    taxId: '',
    phone: '',
    email: '',
    address: '',
    provinceId: undefined as number | undefined,
    districtId: undefined as number | undefined,
    subdistrictId: undefined as number | undefined,
    zipCode: '',
    status: 'ACTIVE',
    avatar: '',
    certificateNumber: '',
    certificateExpire: '',
    score: 0,
    eudrQuotaUsed: 0,
    eudrQuotaCurrent: 0,
    rubberTypeCodes: [] as string[],
    notes: '',
  });

  const { toast } = useToast();

  // Master Data State
  const [provinces, setProvinces] = useState<any[]>([]);
  const [districts, setDistricts] = useState<any[]>([]);
  const [subdistricts, setSubdistricts] = useState<any[]>([]);
  const [rubberTypes, setRubberTypes] = useState<any[]>([]);

  // Filters
  const [filterProvince, setFilterProvince] = useState<string>('all');
  const [filterRubberType, setFilterRubberType] = useState<string>('all');

  const filteredSuppliers = React.useMemo(() => {
    return suppliers.filter((s) => {
      const matchesProvince =
        filterProvince === 'all' || s.province?.id.toString() === filterProvince;
      const matchesRubberType =
        filterRubberType === 'all' || s.rubberTypeCodes?.includes(filterRubberType);
      return matchesProvince && matchesRubberType;
    });
  }, [suppliers, filterProvince, filterRubberType]);

  const fetchSuppliers = async () => {
    try {
      setIsLoading(true);
      const data = await suppliersApi.getAll();
      setSuppliers(data);
    } catch (error) {
      console.error('Failed to fetch suppliers:', error);
      toast({
        title: 'Error',
        description: 'Failed to fetch suppliers.',
        variant: 'destructive',
      });
    } finally {
      setIsLoading(false);
    }
  };

  const fetchMasterData = async () => {
    try {
      const [pData, rtData] = await Promise.all([
        masterApi.getProvinces(),
        masterApi.getRubberTypes(),
      ]);
      setProvinces(pData);
      setRubberTypes(rtData);
    } catch (error) {
      console.error('Failed to fetch master data:', error);
    }
  };

  useEffect(() => {
    fetchSuppliers();
    fetchMasterData();
  }, []);

  // Cascading Effects
  useEffect(() => {
    if (formData.provinceId) {
      masterApi.getDistricts(formData.provinceId).then(setDistricts);
    } else {
      setDistricts([]);
    }
  }, [formData.provinceId]);

  useEffect(() => {
    if (formData.districtId) {
      masterApi.getSubdistricts(formData.districtId).then(setSubdistricts);
    } else {
      setSubdistricts([]);
    }
  }, [formData.districtId]);

  // Fix: Auto-fill ZipCode in Edit mode if missing
  useEffect(() => {
    if (formData.subdistrictId && !formData.zipCode && subdistricts.length > 0) {
      const sub = subdistricts.find((s) => s.id === formData.subdistrictId);
      if (sub?.zip_code) {
        setFormData((prev) => ({ ...prev, zipCode: sub.zip_code }));
      }
    }
  }, [subdistricts, formData.subdistrictId, formData.zipCode]);

  const handlePhoneChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const rawValue = e.target.value.replace(/\D/g, '').slice(0, 10);
    let formatted = rawValue;
    if (rawValue.length > 6) {
      formatted = `${rawValue.slice(0, 3)}-${rawValue.slice(3, 6)}-${rawValue.slice(6)}`;
    } else if (rawValue.length > 3) {
      formatted = `${rawValue.slice(0, 3)}-${rawValue.slice(3)}`;
    }
    setFormData((prev) => ({ ...prev, phone: formatted }));
  };

  const handleOpenCreate = () => {
    setEditingSupplier(null);
    setFormData({
      code: '',
      name: '',
      firstName: '',
      lastName: '',
      title: '',
      taxId: '',
      phone: '',
      email: '',
      address: '',
      provinceId: undefined,
      districtId: undefined,
      subdistrictId: undefined,
      zipCode: '',
      status: 'ACTIVE',
      avatar: '',
      certificateNumber: '',
      certificateExpire: '',
      score: 0,
      eudrQuotaUsed: 0,
      eudrQuotaCurrent: 0,
      rubberTypeCodes: [],
      notes: '',
    });
    setIsModalOpen(true);
  };

  const handleOpenEdit = (supplier: Supplier) => {
    setEditingSupplier(supplier);
    setFormData({
      code: supplier.code,
      name: supplier.name,
      firstName: supplier.firstName || '',
      lastName: supplier.lastName || '',
      title: supplier.title || '',
      taxId: supplier.taxId || '',
      phone: supplier.phone || '',
      email: supplier.email || '',
      address: supplier.address || '',
      provinceId: supplier.province?.id, // Assuming province relation exists and has id
      districtId: supplier.districtId || undefined,
      subdistrictId: supplier.subdistrictId || undefined,
      zipCode: supplier.zipCode || '',
      status: supplier.status,
      avatar: supplier.avatar || '',
      certificateNumber: supplier.certificateNumber || '',
      // Handle date formatting if needed
      certificateExpire: supplier.certificateExpire
        ? new Date(supplier.certificateExpire).toISOString().split('T')[0]
        : '',
      score: supplier.score || 0,
      eudrQuotaUsed: supplier.eudrQuotaUsed || 0,
      eudrQuotaCurrent: supplier.eudrQuotaCurrent || 0,
      rubberTypeCodes: supplier.rubberTypeCodes || [],
      notes: supplier.notes || '',
    });
    setIsModalOpen(true);
  };

  const confirmDelete = async () => {
    if (!deleteId) return;
    try {
      await suppliersApi.delete(deleteId);
      toast({
        title: 'Success',
        description: 'Supplier deleted successfully.',
        variant: 'success',
      });
      fetchSuppliers();
      setDeleteId(null);
    } catch (error) {
      console.error('Failed to delete supplier:', error);
      toast({
        title: 'Error',
        description: 'Failed to delete supplier.',
        variant: 'destructive',
      });
    }
  };

  const handleDelete = async (id: string) => {
    setDeleteId(id);
    if (true) return; // Bypass old logic
    if (!confirm('Are you sure you want to delete this supplier?')) return;
    try {
      await suppliersApi.delete(id);
      toast({
        title: 'Success',
        description: 'Supplier deleted successfully.',
      });
      fetchSuppliers();
    } catch (error) {
      console.error('Failed to delete supplier:', error);
      toast({
        title: 'Error',
        description: 'Failed to delete supplier.',
        variant: 'destructive',
      });
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      // Strong Sanitization of Payload
      const payload: any = { ...formData };

      // Date Handling: Convert YYYY-MM-DD string to ISO string for backend
      if (payload.certificateExpire) {
        payload.certificateExpire = new Date(payload.certificateExpire).toISOString();
      } else {
        delete payload.certificateExpire;
      }

      // Numeric Fields: Ensure they are numbers
      ['score', 'eudrQuotaUsed', 'eudrQuotaCurrent'].forEach((field) => {
        payload[field] = Number(payload[field]) || 0;
      });

      // Optional IDs: Delete if falsy (0, undefined, null, NaN)
      ['provinceId', 'districtId', 'subdistrictId'].forEach((field) => {
        if (!payload[field]) delete payload[field];
      });

      // Optional String Fields: Delete if empty string
      [
        'firstName',
        'lastName',
        'title',
        'taxId',
        'phone',
        'email',
        'avatar',
        'certificateNumber',
        'zipCode',
        'notes',
      ].forEach((field) => {
        if (payload[field] === '') delete payload[field];
      });

      // Ensure required NAME is present. If empty, auto-generate from Title + First + Last
      if (!payload.name) {
        payload.name =
          `${payload.title || ''}${payload.firstName || ''} ${payload.lastName || ''}`.trim();
        // If still empty (unlikely with required inputs), set a fallback or let it fail validation naturally but as string
        if (!payload.name) payload.name = 'Unknown Supplier';
      }

      // Arrays
      if (!payload.rubberTypeCodes) payload.rubberTypeCodes = [];

      console.log('Submitting Payload:', payload); // Debug payload

      if (editingSupplier) {
        await suppliersApi.update(editingSupplier.id, payload);
        toast({
          title: 'Success',
          description: 'Supplier updated successfully.',
          variant: 'success',
        });
      } else {
        await suppliersApi.create(payload);
        toast({
          title: 'Success',
          description: 'Supplier created successfully.',
          variant: 'success',
        });
      }
      setIsModalOpen(false);
      fetchSuppliers();
    } catch (error: any) {
      console.error('Failed to save supplier:', error);
      console.error('Error Details:', error.response?.data); // Log detailed error from backend
      toast({
        title: 'Error',
        description: error.response?.data?.message || 'Failed to save supplier.',
        variant: 'destructive',
      });
    }
  };

  const columns = useSupplierColumns({
    onEdit: handleOpenEdit,
    onDelete: handleDelete,
  });

  const stats = React.useMemo(() => {
    return {
      total: suppliers.length,
      active: suppliers.filter((s) => s.status === 'ACTIVE').length,
      inactive: suppliers.filter((s) => s.status === 'INACTIVE').length,
      suspended: suppliers.filter((s) => s.status === 'SUSPENDED').length,
    };
  }, [suppliers]);

  return (
    <AdminLayout>
      <div className="p-6 w-full max-w-[1400px] mx-auto space-y-8">
        {/* Header */}
        {/* Header Card */}
        <div className="bg-card rounded-xl border border-border shadow-sm p-4 md:p-6 flex flex-col xl:flex-row items-center justify-between gap-6 transition-all hover:shadow-md">
          {/* Left: Title & Icon */}
          <div className="flex items-center gap-4 w-full xl:w-auto">
            <div className="p-3 bg-blue-50 dark:bg-blue-900/20 rounded-xl transition-transform hover:scale-105">
              <Truck className="h-6 w-6 text-blue-600 dark:text-blue-400" />
            </div>
            <div>
              <h1 className="text-xl font-bold tracking-tight text-foreground">
                {t('admin.suppliers.title')}
              </h1>
              <p className="text-sm text-muted-foreground">{t('admin.suppliers.subtitle')}</p>
            </div>
          </div>

          {/* Center: Stats Widget */}
          <div className="hidden md:flex items-center bg-background/50 rounded-xl border border-border p-1 shadow-sm">
            <div className="px-6 py-2 flex flex-col items-center min-w-[100px] border-r border-border/50 last:border-0">
              <span className="text-[10px] font-bold text-muted-foreground uppercase tracking-wider">
                {t('admin.status.total')}
              </span>
              <span className="text-lg font-bold text-foreground">{stats.total}</span>
            </div>
            <div className="w-px h-8 bg-border"></div>
            <div className="px-6 py-2 flex flex-col items-center min-w-[100px]">
              <span className="text-[10px] font-bold text-muted-foreground uppercase tracking-wider text-green-600">
                {t('admin.status.active')}
              </span>
              <span className="text-lg font-bold text-green-600">{stats.active}</span>
            </div>
            <div className="w-px h-8 bg-border"></div>
            <div className="px-6 py-2 flex flex-col items-center min-w-[100px]">
              <span className="text-[10px] font-bold text-muted-foreground uppercase tracking-wider text-destructive">
                {t('admin.status.inactive')}
              </span>
              <span className="text-lg font-bold text-destructive">{stats.inactive}</span>
            </div>
            <div className="w-px h-8 bg-border"></div>
            <div className="px-6 py-2 flex flex-col items-center min-w-[100px]">
              <span className="text-[10px] font-bold text-muted-foreground uppercase tracking-wider text-orange-500">
                {t('admin.status.suspended')}
              </span>
              <span className="text-lg font-bold text-orange-500">{stats.suspended}</span>
            </div>
          </div>

          {/* Right: Action Button */}
          <button
            onClick={handleOpenCreate}
            className="w-full xl:w-auto inline-flex items-center justify-center rounded-lg text-sm font-medium transition-all focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 bg-primary text-primary-foreground shadow-lg hover:bg-primary/90 hover:shadow-xl hover:-translate-y-0.5 h-11 px-8"
          >
            <Plus className="mr-2 h-4 w-4" />
            {t('admin.suppliers.addNew')}
          </button>
        </div>

        {/* Suppliers Table */}
        <div className="rounded-xl border border-border bg-card text-card-foreground shadow">
          <div className="bg-card rounded-lg border shadow-sm p-6">
            <DataTable columns={columns} data={filteredSuppliers} searchKey="name">
              <Select value={filterProvince} onValueChange={setFilterProvince}>
                <SelectTrigger className="w-[180px]">
                  <SelectValue placeholder="Filter Province" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">{t('admin.suppliers.allProvinces')}</SelectItem>
                  {provinces.map((p) => (
                    <SelectItem key={p.id} value={p.id.toString()}>
                      {p.name_th}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>

              <Select value={filterRubberType} onValueChange={setFilterRubberType}>
                <SelectTrigger className="w-[180px]">
                  <SelectValue placeholder="Filter Rubber Type" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">{t('admin.suppliers.allRubberTypes')}</SelectItem>
                  {rubberTypes.map((rt) => (
                    <SelectItem key={rt.code} value={rt.code}>
                      {rt.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </DataTable>
          </div>
        </div>

        {/* Create / Edit Modal */}
        {isModalOpen && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm p-4">
            <div className="bg-background rounded-lg shadow-lg w-full max-w-2xl overflow-hidden border border-border">
              <div className="px-6 py-4 border-b border-border flex justify-between items-center">
                <h3 className="text-lg font-semibold text-foreground">
                  {editingSupplier ? t('admin.suppliers.edit') : t('admin.suppliers.add')}
                </h3>
                <button
                  onClick={() => setIsModalOpen(false)}
                  className="text-muted-foreground hover:text-foreground transition-colors"
                >
                  ✕
                </button>
              </div>

              <form onSubmit={handleSubmit} className="px-6 py-4 flex flex-col h-[calc(80vh-60px)]">
                <Tabs defaultValue="basic" className="flex-1 flex flex-col overflow-hidden">
                  <div className="border-b border-border">
                    <TabsList className="bg-transparent h-auto p-0 gap-6">
                      <TabsTrigger
                        value="basic"
                        className="rounded-none border-b-2 border-transparent px-0 py-2 font-medium text-muted-foreground data-[state=active]:border-primary data-[state=active]:text-primary bg-transparent text-sm"
                      >
                        {t('admin.suppliers.basicInfo')}
                      </TabsTrigger>
                      <TabsTrigger
                        value="contact"
                        className="rounded-none border-b-2 border-transparent px-0 py-2 font-medium text-muted-foreground data-[state=active]:border-primary data-[state=active]:text-primary bg-transparent text-sm"
                      >
                        {t('admin.suppliers.contactInfo')}
                      </TabsTrigger>
                      <TabsTrigger
                        value="address"
                        className="rounded-none border-b-2 border-transparent px-0 py-2 font-medium text-muted-foreground data-[state=active]:border-primary data-[state=active]:text-primary bg-transparent text-sm"
                      >
                        {t('admin.suppliers.address')}
                      </TabsTrigger>
                      <TabsTrigger
                        value="business"
                        className="rounded-none border-b-2 border-transparent px-0 py-2 font-medium text-muted-foreground data-[state=active]:border-primary data-[state=active]:text-primary bg-transparent text-sm"
                      >
                        {t('admin.suppliers.businessDetails')}
                      </TabsTrigger>
                    </TabsList>
                  </div>

                  <div className="flex-1 overflow-y-auto pt-4 pb-2">
                    {/* Basic Information */}
                    <TabsContent value="basic" className="space-y-4 m-0">
                      <div className="grid grid-cols-2 gap-4">
                        <div>
                          <label className="text-sm font-medium text-foreground mb-1 block">
                            {t('admin.suppliers.code')} <span className="text-destructive">*</span>
                          </label>
                          <input
                            type="text"
                            required
                            className="w-full px-3 py-2 bg-background border border-input rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 text-foreground"
                            placeholder="SUP-0001"
                            value={formData.code}
                            onChange={(e) => setFormData({ ...formData, code: e.target.value })}
                          />
                        </div>
                        <div>
                          <label className="text-sm font-medium text-foreground mb-1 block">
                            {t('admin.suppliers.selectTitle')}
                          </label>
                          <Select
                            value={formData.title || ''}
                            onValueChange={(val) => setFormData({ ...formData, title: val })}
                          >
                            <SelectTrigger>
                              <SelectValue placeholder="Select Title" />
                            </SelectTrigger>
                            <SelectContent>
                              <SelectItem value="นาย">{t('common.titles.mr')}</SelectItem>
                              <SelectItem value="นาง">{t('common.titles.mrs')}</SelectItem>
                              <SelectItem value="นางสาว">{t('common.titles.ms')}</SelectItem>
                              <SelectItem value="บริษัท">{t('common.titles.company')}</SelectItem>
                              <SelectItem value="ว่าที่ ร.ต.">ว่าที่ ร.ต.</SelectItem>
                              <SelectItem value="สหกรณ์">{t('common.titles.coop')}</SelectItem>
                              <SelectItem value="หจก.">หจก.</SelectItem>
                            </SelectContent>
                          </Select>
                        </div>
                        <div>
                          <label className="text-sm font-medium text-foreground mb-1 block">
                            {t('admin.suppliers.firstName')}{' '}
                            <span className="text-destructive">*</span>
                          </label>
                          <input
                            type="text"
                            required
                            className="w-full px-3 py-2 bg-background border border-input rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 text-foreground"
                            value={formData.firstName}
                            onChange={(e) =>
                              setFormData({ ...formData, firstName: e.target.value })
                            }
                          />
                        </div>
                        <div>
                          <label className="text-sm font-medium text-foreground mb-1 block">
                            {t('admin.suppliers.lastName')}{' '}
                            <span className="text-destructive">*</span>
                          </label>
                          <input
                            type="text"
                            required
                            className="w-full px-3 py-2 bg-background border border-input rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 text-foreground"
                            value={formData.lastName}
                            onChange={(e) => setFormData({ ...formData, lastName: e.target.value })}
                          />
                        </div>
                        <div className="col-span-1">
                          <label className="text-sm font-medium text-foreground mb-1 block">
                            {t('admin.suppliers.displayName')}
                          </label>
                          <input
                            type="text"
                            className="w-full px-3 py-2 bg-background border border-input rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 text-foreground"
                            placeholder="Auto-generated if empty"
                            value={formData.name}
                            onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                          />
                        </div>
                        <div className="col-span-1">
                          <label className="text-sm font-medium text-foreground mb-1 block">
                            {t('admin.suppliers.avatarUrl')}
                          </label>
                          <div className="flex gap-2">
                            <input
                              type="text"
                              className="w-full px-3 py-2 bg-background border border-input rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 text-foreground"
                              value={formData.avatar}
                              onChange={(e) => setFormData({ ...formData, avatar: e.target.value })}
                            />
                            {/* Placeholder for Upload Button */}
                            {/* <Button variant="outline" size="sm" type="button">Upload</Button> */}
                          </div>
                        </div>
                      </div>
                    </TabsContent>

                    {/* Contact Information */}
                    <TabsContent value="contact" className="space-y-4 m-0">
                      <div className="grid grid-cols-2 gap-4">
                        <div>
                          <label className="text-sm font-medium text-foreground mb-1 block">
                            {t('admin.suppliers.phone')}
                          </label>
                          <input
                            type="text"
                            className="w-full px-3 py-2 bg-background border border-input rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 text-foreground"
                            placeholder="081-234-5678"
                            value={formData.phone}
                            onChange={handlePhoneChange}
                            maxLength={12}
                          />
                        </div>
                        <div>
                          <label className="text-sm font-medium text-foreground mb-1 block">
                            {t('admin.suppliers.email')}
                          </label>
                          <input
                            type="email"
                            className="w-full px-3 py-2 bg-background border border-input rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 text-foreground"
                            value={formData.email}
                            onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                          />
                        </div>
                      </div>
                    </TabsContent>

                    {/* Address */}
                    <TabsContent value="address" className="space-y-4 m-0">
                      <div className="grid grid-cols-2 gap-4">
                        <div>
                          <Label className="mb-1 block">{t('admin.suppliers.province')}</Label>
                          <SearchableSelect
                            value={formData.provinceId?.toString() || ''}
                            onChange={(val) => {
                              const provinceId = parseInt(val);
                              setFormData({
                                ...formData,
                                provinceId,
                                districtId: undefined,
                                subdistrictId: undefined,
                                zipCode: '',
                              });
                            }}
                            options={provinces.map((p) => ({
                              label: p.name_th,
                              value: p.id.toString(),
                            }))}
                            placeholder="Select Province"
                          />
                        </div>
                        <div>
                          <Label className="mb-1 block">{t('admin.suppliers.district')}</Label>
                          <SearchableSelect
                            value={formData.districtId?.toString() || ''}
                            disabled={!formData.provinceId}
                            onChange={(val) => {
                              const districtId = parseInt(val);
                              setFormData({
                                ...formData,
                                districtId,
                                subdistrictId: undefined,
                                zipCode: '',
                              });
                            }}
                            options={districts.map((d) => ({
                              label: d.name_th,
                              value: d.id.toString(),
                            }))}
                            placeholder="Select District"
                          />
                        </div>
                        <div>
                          <Label className="mb-1 block">{t('admin.suppliers.subDistrict')}</Label>
                          <SearchableSelect
                            value={formData.subdistrictId?.toString() || ''}
                            disabled={!formData.districtId}
                            onChange={(val) => {
                              const subdistrictId = parseInt(val);
                              const subdistrict = subdistricts.find((s) => s.id === subdistrictId);
                              setFormData({
                                ...formData,
                                subdistrictId,
                                zipCode: subdistrict?.zip_code || '',
                              });
                            }}
                            options={subdistricts.map((s) => ({
                              label: s.name_th,
                              value: s.id.toString(),
                            }))}
                            placeholder="Select Sub-District"
                          />
                        </div>
                        <div>
                          <Label className="mb-1 block">{t('admin.suppliers.zipcode')}</Label>
                          <Input value={formData.zipCode} readOnly placeholder="Auto-filled" />
                        </div>
                        <div className="col-span-2">
                          <Label className="mb-1 block">{t('admin.suppliers.addressLine')}</Label>
                          <textarea
                            rows={2}
                            className="w-full px-3 py-2 bg-background border border-input rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 text-foreground"
                            value={formData.address}
                            onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                          />
                        </div>
                      </div>
                    </TabsContent>

                    {/* Business Details */}
                    <TabsContent value="business" className="space-y-4 m-0">
                      <div className="grid grid-cols-2 gap-4">
                        <div className="col-span-2">
                          <label className="text-sm font-medium text-foreground mb-1 block">
                            {t('admin.analytics.rubberTypes')}
                          </label>
                          <MultiSelect
                            options={rubberTypes.map((rt) => ({
                              label: rt.name,
                              value: rt.code,
                              category: rt.category,
                            }))}
                            selected={formData.rubberTypeCodes}
                            onChange={(selected) =>
                              setFormData({ ...formData, rubberTypeCodes: selected })
                            }
                            placeholder="Select Rubber Types..."
                          />
                        </div>
                        <div>
                          <label className="text-sm font-medium text-foreground mb-1 block">
                            {t('admin.suppliers.certNum')}
                          </label>
                          <input
                            type="text"
                            className="w-full px-3 py-2 bg-background border border-input rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 text-foreground"
                            value={formData.certificateNumber}
                            onChange={(e) =>
                              setFormData({ ...formData, certificateNumber: e.target.value })
                            }
                          />
                        </div>
                        <div>
                          <Label className="mb-1 block">{t('admin.suppliers.certExp')}</Label>
                          <DatePicker
                            date={
                              formData.certificateExpire
                                ? new Date(formData.certificateExpire)
                                : undefined
                            }
                            setDate={(date) => {
                              // Keep the date as YYYY-MM-DD string in state
                              const dateStr = date ? format(date, 'yyyy-MM-dd') : '';
                              setFormData({ ...formData, certificateExpire: dateStr });
                            }}
                          />
                        </div>
                        <div>
                          <label className="text-sm font-medium text-foreground mb-1 block">
                            Status
                          </label>
                          <div className="flex gap-4 pt-1">
                            <label className="flex items-center gap-2">
                              <input
                                type="radio"
                                name="status"
                                value="ACTIVE"
                                checked={formData.status === 'ACTIVE'}
                                onChange={(e) =>
                                  setFormData({ ...formData, status: e.target.value })
                                }
                              />{' '}
                              Active
                            </label>
                            <label className="flex items-center gap-2">
                              <input
                                type="radio"
                                name="status"
                                value="INACTIVE"
                                checked={formData.status === 'INACTIVE'}
                                onChange={(e) =>
                                  setFormData({ ...formData, status: e.target.value })
                                }
                              />{' '}
                              Inactive
                            </label>
                            <label className="flex items-center gap-2">
                              <input
                                type="radio"
                                name="status"
                                value="SUSPENDED"
                                checked={formData.status === 'SUSPENDED'}
                                onChange={(e) =>
                                  setFormData({ ...formData, status: e.target.value })
                                }
                              />{' '}
                              Suspended
                            </label>
                          </div>
                        </div>
                        <div>
                          <label className="text-sm font-medium text-foreground mb-1 block">
                            Score
                          </label>
                          {/* Star rating placeholder or number input */}
                          <input
                            type="number"
                            min="0"
                            max="5"
                            className="w-full px-3 py-2 bg-background border border-input rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 text-foreground"
                            value={formData.score}
                            onChange={(e) =>
                              setFormData({
                                ...formData,
                                score: parseInt(e.target.value) || 0,
                              })
                            }
                          />
                        </div>
                        <div>
                          <label className="text-sm font-medium text-foreground mb-1 block">
                            EU DR Quota Used
                          </label>
                          <input
                            type="number"
                            className="w-full px-3 py-2 bg-background border border-input rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 text-foreground"
                            value={formData.eudrQuotaUsed}
                            onChange={(e) =>
                              setFormData({
                                ...formData,
                                eudrQuotaUsed: parseFloat(e.target.value) || 0,
                              })
                            }
                          />
                        </div>
                        <div>
                          <label className="text-sm font-medium text-foreground mb-1 block">
                            EU DR Quota Current
                          </label>
                          <input
                            type="number"
                            className="w-full px-3 py-2 bg-background border border-input rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 text-foreground"
                            value={formData.eudrQuotaCurrent}
                            onChange={(e) =>
                              setFormData({
                                ...formData,
                                eudrQuotaCurrent: parseFloat(e.target.value) || 0,
                              })
                            }
                          />
                        </div>
                        <div className="col-span-2">
                          <label className="text-sm font-medium text-foreground mb-1 block">
                            Note
                          </label>
                          <textarea
                            rows={3}
                            className="w-full px-3 py-2 bg-background border border-input rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-primary/50 text-foreground"
                            value={formData.notes}
                            onChange={(e) => setFormData({ ...formData, notes: e.target.value })}
                          />
                        </div>
                      </div>
                    </TabsContent>
                  </div>
                </Tabs>

                <div className="flex justify-end gap-3 pt-4 border-t border-border mt-auto">
                  <button
                    type="button"
                    onClick={() => setIsModalOpen(false)}
                    className="px-4 py-2 text-sm font-medium text-muted-foreground hover:bg-muted rounded-md transition-colors"
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    className="px-4 py-2 text-sm font-medium bg-primary text-primary-foreground hover:bg-primary/90 rounded-md transition-colors shadow-sm"
                  >
                    {editingSupplier ? 'Save Changes' : 'Create Supplier'}
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}

        <AlertDialog open={!!deleteId} onOpenChange={(open) => !open && setDeleteId(null)}>
          <AlertDialogContent>
            <AlertDialogHeader>
              <div className="mx-auto w-12 h-12 rounded-xl bg-red-50 flex items-center justify-center mb-2">
                <Trash2 className="w-6 h-6 text-red-600" />
              </div>
              <AlertDialogTitle>Delete Supplier?</AlertDialogTitle>
              <AlertDialogDescription>
                This will permanently delete this supplier. View Settings to manage related data.
              </AlertDialogDescription>
            </AlertDialogHeader>
            <AlertDialogFooter>
              <AlertDialogCancel onClick={() => setDeleteId(null)}>Cancel</AlertDialogCancel>
              <AlertDialogAction onClick={confirmDelete}>Delete</AlertDialogAction>
            </AlertDialogFooter>
          </AlertDialogContent>
        </AlertDialog>
      </div>
    </AdminLayout>
  );
}
