<script setup lang="ts">
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Combobox } from '@/components/ui/combobox';
import DataTable from '@/components/ui/data-table/DataTable.vue';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import EmptyState from '@/components/ui/empty-state/EmptyState.vue';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { MultiSelect } from '@/components/ui/multi-select';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Skeleton } from '@/components/ui/skeleton';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Textarea } from '@/components/ui/textarea';
import { masterApi, type District, type Province, type Subdistrict } from '@/services/master';
import { suppliersApi, type Supplier } from '@/services/suppliers';
import type { ColumnDef } from '@tanstack/vue-table';
import { ArrowUpDown, Edit, Plus, Search, Trash2, Truck } from 'lucide-vue-next';
import { computed, h, onMounted, ref, watch } from 'vue';
import { toast } from 'vue-sonner';

// --- State ---
const suppliers = ref<Supplier[]>([]);
const isLoading = ref(true);
const searchQuery = ref('');

// Master Data
const provinces = ref<Province[]>([]);
const districts = ref<District[]>([]);
const subdistricts = ref<Subdistrict[]>([]);
const rubberTypes = ref<any[]>([]);

// Filters
const filterProvince = ref<string>('all');
const filterRubberType = ref<string>('all');

// Modal State
const isModalOpen = ref(false);
const isDeleteModalOpen = ref(false);
const itemToDelete = ref<string | null>(null);
const editingItem = ref<Supplier | null>(null);

// Form Data
const formData = ref<Partial<Supplier>>({
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
  rubberTypeCodes: [],
  notes: '',
});

// --- Computed ---
const stats = computed(() => ({
  total: suppliers.value.length,
  active: suppliers.value.filter((s) => s.status === 'ACTIVE').length,
  inactive: suppliers.value.filter((s) => s.status === 'INACTIVE').length,
  suspended: suppliers.value.filter((s) => s.status === 'SUSPENDED').length,
}));

const filteredData = computed(() => {
  let data = suppliers.value;

  // Global Search
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase();
    data = data.filter(
      (s) =>
        s.name.toLowerCase().includes(query) ||
        s.code.toLowerCase().includes(query) ||
        s.phone?.includes(query)
    );
  }

  // Filter Province
  if (filterProvince.value && filterProvince.value !== 'all') {
    data = data.filter((s) => s.province?.id?.toString() === filterProvince.value);
  }

  // Filter Rubber Type
  if (filterRubberType.value && filterRubberType.value !== 'all') {
    data = data.filter((s) => s.rubberTypeCodes?.includes(filterRubberType.value));
  }

  return data;
});

// --- Actions ---
const fetchData = async () => {
  try {
    isLoading.value = true;
    suppliers.value = await suppliersApi.getAll();
  } catch (error) {
    console.error('Failed to fetch suppliers:', error);
  } finally {
    isLoading.value = false;
  }
};

const fetchMasterData = async () => {
  try {
    provinces.value = await masterApi.getProvinces();
    rubberTypes.value = await masterApi.getRubberTypes();
  } catch (error) {
    console.error('Failed to fetch master data:', error);
  }
};

const handleOpenCreate = () => {
  editingItem.value = null;
  formData.value = {
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
    rubberTypeCodes: [],
  };
  districts.value = [];
  subdistricts.value = [];
  isModalOpen.value = true;
};

const handleOpenEdit = async (item: Supplier) => {
  editingItem.value = item;
  formData.value = { ...item }; // Clone data

  // Load cascading data for edit
  if (item.provinceId) {
    districts.value = await masterApi.getDistricts(item.provinceId);
  }
  if (item.districtId) {
    subdistricts.value = await masterApi.getSubdistricts(item.districtId);

    // Ensure Zip Code is set if missing or just to be safe based on subdistrict
    if (item.subdistrictId) {
      const sub = subdistricts.value.find((s) => s.id === item.subdistrictId);
      if (sub) {
        const zip = (sub as any).zip_code || (sub as any).zipCode || sub.zip_code;
        if (zip) formData.value.zipCode = zip.toString();
      }
    }
  }

  isModalOpen.value = true;
};

const handleSubmit = async () => {
  try {
    // Auto-generate name if empty
    if (!formData.value.name) {
      formData.value.name = [
        formData.value.title,
        formData.value.firstName,
        formData.value.lastName,
      ]
        .filter(Boolean)
        .join(' ');
    }

    if (editingItem.value) {
      await suppliersApi.update(editingItem.value.id, formData.value);
      toast.success('Supplier updated successfully');
    } else {
      await suppliersApi.create(formData.value);
      toast.success('Supplier created successfully');
    }
    isModalOpen.value = false;
    await fetchData();
  } catch (error) {
    console.error('Failed to save supplier:', error);
    toast.error('Failed to save supplier');
  }
};

const handleDeleteClick = (id: string) => {
  itemToDelete.value = id;
  isDeleteModalOpen.value = true;
};

const confirmDelete = async () => {
  if (!itemToDelete.value) return;
  try {
    await suppliersApi.delete(itemToDelete.value);
    toast.success('Supplier deleted successfully');
    isDeleteModalOpen.value = false;
    itemToDelete.value = null;
    await fetchData();
  } catch (error) {
    console.error('Failed to delete supplier:', error);
    toast.error('Failed to delete supplier');
  }
};

// --- Watchers for Cascading Selects ---
watch(
  () => formData.value.provinceId,
  async (newVal) => {
    if (newVal) {
      // Only reset if changing (not initial load if editing)
      if (!editingItem.value || editingItem.value.provinceId !== newVal) {
        formData.value.districtId = undefined;
        formData.value.subdistrictId = undefined;
        formData.value.zipCode = '';
        subdistricts.value = [];
      }
      districts.value = await masterApi.getDistricts(newVal);
    } else {
      districts.value = [];
    }
  }
);

watch(
  () => formData.value.districtId,
  async (newVal) => {
    if (newVal) {
      if (!editingItem.value || editingItem.value.districtId !== newVal) {
        formData.value.subdistrictId = undefined;
        formData.value.zipCode = '';
      }
      subdistricts.value = await masterApi.getSubdistricts(newVal);
    } else {
      subdistricts.value = [];
    }
  }
);

watch(
  () => formData.value.subdistrictId,
  (newVal) => {
    if (newVal) {
      const sub = subdistricts.value.find((s) => s.id === newVal);
      if (sub) {
        // Handle potential snake_case or camelCase from API
        const zip = (sub as any).zip_code || (sub as any).zipCode || sub.zip_code;
        if (zip) formData.value.zipCode = zip.toString();
      }
    }
  }
);

// --- Helpers ---
const formatPhone = (phone?: string) => {
  if (!phone) return '-';
  const clean = phone.replace(/\D/g, '');
  if (clean.length === 10) {
    return `${clean.slice(0, 3)}-${clean.slice(3, 6)}-${clean.slice(6)}`;
  }
  return phone;
};

const handlePhoneInput = (event: Event) => {
  const input = event.target as HTMLInputElement;
  let val = input.value.replace(/\D/g, '');

  if (val.length > 10) val = val.slice(0, 10);

  // Format as 08x-xxx-xxxx
  if (val.length > 6) {
    val = `${val.slice(0, 3)}-${val.slice(3, 6)}-${val.slice(6)}`;
  } else if (val.length > 3) {
    val = `${val.slice(0, 3)}-${val.slice(3)}`;
  }

  formData.value.phone = val;
};

const getRubberTypeColor = (code: string, name?: string) => {
  if (name) {
    const n = name.toLowerCase();
    if (n.includes('eudr'))
      return 'bg-emerald-100 text-emerald-800 border-emerald-200 hover:bg-emerald-100';
    if (n.includes('north east') || n.includes('ตะวันออกเฉียงเหนือ'))
      return 'bg-red-100 text-red-800 border-red-200 hover:bg-red-100';
  }

  // Simple deterministic color generation based on code
  const colors = [
    'bg-blue-100 text-blue-800 border-blue-200 hover:bg-blue-100',
    'bg-amber-100 text-amber-800 border-amber-200 hover:bg-amber-100',
    'bg-purple-100 text-purple-800 border-purple-200 hover:bg-purple-100',
    'bg-indigo-100 text-indigo-800 border-indigo-200 hover:bg-indigo-100',
    'bg-pink-100 text-pink-800 border-pink-200 hover:bg-pink-100',
    'bg-cyan-100 text-cyan-800 border-cyan-200 hover:bg-cyan-100',
  ];
  let hash = 0;
  for (let i = 0; i < code.length; i++) {
    hash = code.charCodeAt(i) + ((hash << 5) - hash);
  }
  return colors[Math.abs(hash) % colors.length];
};

// --- Columns ---
const columns: ColumnDef<Supplier>[] = [
  {
    accessorKey: 'code',
    header: ({ column }) => {
      return h(
        Button,
        {
          variant: 'ghost',
          onClick: () => column.toggleSorting(column.getIsSorted() === 'asc'),
        },
        () => ['Code', h(ArrowUpDown, { class: 'ml-2 h-4 w-4' })]
      );
    },
    cell: ({ row }) => h('div', { class: 'font-medium' }, row.getValue('code')),
  },
  {
    accessorKey: 'name',
    header: ({ column }) => {
      return h(
        Button,
        {
          variant: 'ghost',
          onClick: () => column.toggleSorting(column.getIsSorted() === 'asc'),
        },
        () => ['Name', h(ArrowUpDown, { class: 'ml-2 h-4 w-4' })]
      );
    },
    cell: ({ row }) => h('div', row.getValue('name')),
  },
  {
    accessorKey: 'province.name_th',
    header: 'Province',
    cell: ({ row }) => h('div', row.original.province?.name_th || '-'),
  },
  {
    accessorKey: 'phone',
    header: 'Phone',
    cell: ({ row }) => h('div', formatPhone(row.getValue('phone'))),
  },
  {
    accessorKey: 'rubberTypeCodes',
    header: () => h('div', { class: 'text-center w-full' }, 'Rubber Types'),
    cell: ({ row }) => {
      const codes = (row.getValue('rubberTypeCodes') as string[]) || [];
      if (!codes.length)
        return h('div', { class: 'text-center w-full text-muted-foreground' }, '-');

      return h(
        'div',
        { class: 'flex flex-wrap gap-1 justify-center' },
        codes.map((code) => {
          const rt = rubberTypes.value.find((r) => r.code === code);
          return h(
            Badge,
            { variant: 'outline', class: getRubberTypeColor(code, rt?.name) },
            () => rt?.name || code
          );
        })
      );
    },
  },
  {
    accessorKey: 'status',
    header: () => h('div', { class: 'text-center w-full' }, 'Status'),
    cell: ({ row }) => {
      const status = row.getValue('status') as string;
      const colorClass =
        status === 'ACTIVE'
          ? 'bg-emerald-500/10 text-emerald-500'
          : status === 'SUSPENDED'
            ? 'bg-orange-500/10 text-orange-500'
            : 'bg-muted text-muted-foreground';

      return h('div', { class: 'flex justify-center' }, [
        h(
          'span',
          {
            class: `inline-flex items-center justify-center rounded-md px-1.5 py-0 text-[9px] font-bold uppercase tracking-wide h-5 min-w-[60px] ${colorClass}`,
          },
          status
        ),
      ]);
    },
  },
  {
    id: 'actions',
    enableHiding: false,
    header: () => h('div', { class: 'text-right' }, 'Actions'),
    cell: ({ row }) => {
      const item = row.original;
      return h('div', { class: 'flex items-center justify-end gap-2' }, [
        h(
          Button,
          {
            variant: 'ghost',
            size: 'icon',
            class: 'h-8 w-8 text-muted-foreground hover:text-foreground',
            onClick: () => handleOpenEdit(item),
          },
          () => h(Edit, { class: 'h-4 w-4' })
        ),
        h(
          Button,
          {
            variant: 'ghost',
            size: 'icon',
            class: 'h-8 w-8 text-muted-foreground hover:text-destructive',
            onClick: () => handleDeleteClick(item.id),
          },
          () => h(Trash2, { class: 'h-4 w-4' })
        ),
      ]);
    },
  },
];

onMounted(() => {
  fetchData();
  fetchMasterData();
});
</script>

<template>
  <div>
    <div class="p-6 space-y-8 max-w-[1600px] mx-auto">
      <!-- Header / Stats -->
      <div class="p-6 rounded-xl border border-border bg-card shadow-sm relative overflow-hidden">
        <div class="absolute top-1/2 right-12 -translate-y-1/2 pointer-events-none opacity-5">
          <Truck class="w-64 h-64" />
        </div>

        <div class="flex items-center justify-between gap-6 relative z-10">
          <!-- Title Section -->
          <div class="flex items-center gap-6">
            <div
              class="p-4 bg-primary/10 rounded-xl text-primary flex items-center justify-center h-16 w-16"
            >
              <Truck class="h-8 w-8" />
            </div>
            <div>
              <h1 class="text-2xl font-bold tracking-tight text-foreground">Suppliers</h1>
              <p class="text-sm text-muted-foreground mt-1">
                Manage supplier information and contacts.
              </p>
            </div>
          </div>

          <!-- Stats Section -->
          <div class="flex items-center gap-8">
            <div class="text-center">
              <div class="text-xs font-bold text-muted-foreground uppercase tracking-wider mb-1">
                Total
              </div>
              <div class="text-3xl font-bold">{{ stats.total }}</div>
            </div>
            <div class="text-center">
              <div class="text-xs font-bold text-emerald-500 uppercase tracking-wider mb-1">
                Active
              </div>
              <div class="text-3xl font-bold text-emerald-500">{{ stats.active }}</div>
            </div>
            <div class="text-center">
              <div class="text-xs font-bold text-orange-500 uppercase tracking-wider mb-1">
                Suspended
              </div>
              <div class="text-3xl font-bold text-orange-500">{{ stats.suspended }}</div>
            </div>
          </div>

          <!-- Add Button -->
          <div class="flex-shrink-0">
            <Button @click="handleOpenCreate" size="lg" class="shadow-lg shadow-primary/20">
              <Plus class="mr-2 h-5 w-5" />
              Add New
            </Button>
          </div>
        </div>
      </div>

      <!-- Controls -->
      <div class="flex items-center justify-between gap-4">
        <div class="relative w-full max-w-sm">
          <Search class="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
          <Input v-model="searchQuery" placeholder="Search suppliers..." class="pl-9" />
        </div>
        <div class="flex items-center gap-2">
          <Select v-model="filterProvince">
            <SelectTrigger class="w-[180px]">
              <SelectValue placeholder="All Provinces" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Provinces</SelectItem>
              <SelectItem v-for="p in provinces" :key="p.id" :value="p.id.toString()">
                {{ p.name_th }}
              </SelectItem>
            </SelectContent>
          </Select>
          <Select v-model="filterRubberType">
            <SelectTrigger class="w-[180px]">
              <SelectValue placeholder="All Rubber Types" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Rubber Types</SelectItem>
              <SelectItem v-for="rt in rubberTypes" :key="rt.id" :value="rt.code">
                {{ rt.name }}
              </SelectItem>
            </SelectContent>
          </Select>
        </div>
      </div>

      <!-- DataTable -->
      <!-- Data Display -->
      <div v-if="isLoading" class="space-y-4">
        <div v-for="i in 5" :key="i" class="flex items-center space-x-4">
          <Skeleton class="h-12 w-full" />
        </div>
      </div>

      <EmptyState
        v-else-if="filteredData.length === 0"
        :icon="Truck"
        title="No Suppliers Found"
        description="No suppliers match your current filters or search query."
        action-label="Add New Supplier"
        :action="handleOpenCreate"
      />

      <DataTable v-else :columns="columns" :data="filteredData" enable-selection />

      <!-- Create/Edit Modal -->
      <Dialog v-model:open="isModalOpen">
        <DialogContent class="sm:max-w-[700px] max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>{{ editingItem ? 'Edit Supplier' : 'Add New Supplier' }}</DialogTitle>
            <DialogDescription>Fill in the supplier details below.</DialogDescription>
          </DialogHeader>

          <Tabs default-value="basic" class="w-full">
            <TabsList class="grid w-full grid-cols-4">
              <TabsTrigger value="basic">Basic</TabsTrigger>
              <TabsTrigger value="contact">Contact</TabsTrigger>
              <TabsTrigger value="address">Address</TabsTrigger>
              <TabsTrigger value="business">Business</TabsTrigger>
            </TabsList>

            <!-- Basic Info -->
            <TabsContent value="basic" class="space-y-4 py-4">
              <div class="grid grid-cols-2 gap-4">
                <div class="space-y-2">
                  <Label>Code</Label>
                  <Input v-model="formData.code" placeholder="SUP-001" />
                </div>
                <div class="space-y-2">
                  <Label>Title</Label>
                  <Select v-model="formData.title">
                    <SelectTrigger><SelectValue placeholder="Select Title" /></SelectTrigger>
                    <SelectContent>
                      <SelectItem value="นาย">นาย</SelectItem>
                      <SelectItem value="นาง">นาง</SelectItem>
                      <SelectItem value="นางสาว">นางสาว</SelectItem>
                      <SelectItem value="บริษัท">บริษัท</SelectItem>
                      <SelectItem value="หจก.">หจก.</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <div class="space-y-2">
                  <Label>First Name</Label>
                  <Input v-model="formData.firstName" />
                </div>
                <div class="space-y-2">
                  <Label>Last Name</Label>
                  <Input v-model="formData.lastName" />
                </div>
                <div class="col-span-2 space-y-2">
                  <Label>Display Name (Auto-generated if empty)</Label>
                  <Input v-model="formData.name" placeholder="Leave empty to auto-generate" />
                </div>
              </div>
            </TabsContent>

            <!-- Contact Info -->
            <TabsContent value="contact" class="space-y-4 py-4">
              <div class="grid grid-cols-2 gap-4">
                <div class="space-y-2">
                  <Label>Phone</Label>
                  <Input
                    :model-value="formData.phone"
                    @input="handlePhoneInput"
                    placeholder="08x-xxx-xxxx"
                  />
                </div>
                <div class="space-y-2">
                  <Label>Email</Label>
                  <Input v-model="formData.email" type="email" />
                </div>
              </div>
            </TabsContent>

            <!-- Address Info -->
            <TabsContent value="address" class="space-y-4 py-4">
              <div class="grid grid-cols-2 gap-4">
                <div class="space-y-2">
                  <Label>Province</Label>
                  <Combobox
                    :options="provinces.map((p) => ({ value: p.id.toString(), label: p.name_th }))"
                    :model-value="formData.provinceId?.toString()"
                    @update:model-value="(v) => (formData.provinceId = v ? parseInt(v) : undefined)"
                    placeholder="Select Province"
                  />
                </div>
                <div class="space-y-2">
                  <Label>District</Label>
                  <Combobox
                    :options="districts.map((d) => ({ value: d.id.toString(), label: d.name_th }))"
                    :model-value="formData.districtId?.toString()"
                    @update:model-value="(v) => (formData.districtId = v ? parseInt(v) : undefined)"
                    placeholder="Select District"
                    :disabled="!formData.provinceId"
                  />
                </div>
                <div class="space-y-2">
                  <Label>Subdistrict</Label>
                  <Combobox
                    :options="
                      subdistricts.map((s) => ({ value: s.id.toString(), label: s.name_th }))
                    "
                    :model-value="formData.subdistrictId?.toString()"
                    @update:model-value="
                      (v) => (formData.subdistrictId = v ? parseInt(v) : undefined)
                    "
                    placeholder="Select Subdistrict"
                    :disabled="!formData.districtId"
                  />
                </div>
                <div class="space-y-2">
                  <Label>Zip Code</Label>
                  <Input v-model="formData.zipCode" readonly />
                </div>
                <div class="col-span-2 space-y-2">
                  <Label>Address Line</Label>
                  <Textarea v-model="formData.address" />
                </div>
              </div>
            </TabsContent>

            <!-- Business Info -->
            <TabsContent value="business" class="space-y-4 py-4">
              <div class="grid grid-cols-2 gap-4">
                <div class="col-span-2 space-y-2">
                  <Label>Rubber Types</Label>
                  <MultiSelect
                    :options="rubberTypes.map((rt) => ({ label: rt.name, value: rt.code }))"
                    :model-value="formData.rubberTypeCodes"
                    @update:model-value="(v) => (formData.rubberTypeCodes = v)"
                    placeholder="Select Rubber Types"
                  />
                </div>
                <div class="space-y-2">
                  <Label>Tax ID</Label>
                  <Input v-model="formData.taxId" />
                </div>
                <div class="space-y-2">
                  <Label>Status</Label>
                  <Select v-model="formData.status">
                    <SelectTrigger><SelectValue /></SelectTrigger>
                    <SelectContent>
                      <SelectItem value="ACTIVE">Active</SelectItem>
                      <SelectItem value="INACTIVE">Inactive</SelectItem>
                      <SelectItem value="SUSPENDED">Suspended</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>
            </TabsContent>
          </Tabs>

          <DialogFooter>
            <Button variant="outline" @click="isModalOpen = false">Cancel</Button>
            <Button @click="handleSubmit">Save Changes</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <!-- Delete Confirmation -->
      <Dialog v-model:open="isDeleteModalOpen">
        <DialogContent class="sm:max-w-[425px]">
          <DialogHeader>
            <DialogTitle>Delete Supplier?</DialogTitle>
            <DialogDescription>
              Are you sure you want to delete this supplier? This action cannot be undone.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button variant="outline" @click="isDeleteModalOpen = false">Cancel</Button>
            <Button variant="destructive" @click="confirmDelete">Delete</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  </div>
</template>
