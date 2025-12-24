<script setup lang="ts">
import { Button } from '@/components/ui/button';
import DataTable from '@/components/ui/data-table/DataTable.vue';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Skeleton } from '@/components/ui/skeleton';
import { Textarea } from '@/components/ui/textarea';
import { rubberTypesApi, type RubberType } from '@/services/rubberTypes';
import type { ColumnDef } from '@tanstack/vue-table';
import { ArrowUpDown, Edit, Layers, Plus, Search, Trash2 } from 'lucide-vue-next';
import { computed, h, onMounted, ref } from 'vue';

// State
const rubberTypes = ref<RubberType[]>([]);
const isLoading = ref(true);
const searchQuery = ref('');
const statusFilter = ref('ALL');
const isModalOpen = ref(false);
const isDeleteModalOpen = ref(false);
const itemToDelete = ref<string | null>(null);

// Form State
const editingItem = ref<RubberType | null>(null);
const formData = ref({
  code: '',
  name: '',
  description: '',
  is_active: true,
});

// Computed Stats
const stats = computed(() => {
  return {
    total: rubberTypes.value.length,
    active: rubberTypes.value.filter((item) => item.is_active).length,
    inactive: rubberTypes.value.filter((item) => !item.is_active).length,
  };
});

// Filtered Data
const filteredData = computed(() => {
  let data = rubberTypes.value;

  // Status Filter
  if (statusFilter.value !== 'ALL') {
    const isActive = statusFilter.value === 'ACTIVE';
    data = data.filter((item) => item.is_active === isActive);
  }

  // Search Filter
  if (searchQuery.value) {
    const lowerQuery = searchQuery.value.toLowerCase();
    data = data.filter(
      (item) =>
        item.name.toLowerCase().includes(lowerQuery) || item.code.toLowerCase().includes(lowerQuery)
    );
  }

  return data;
});

// Actions
const fetchData = async () => {
  try {
    isLoading.value = true;
    rubberTypes.value = await rubberTypesApi.getAll();
  } catch (error) {
    console.error('Failed to fetch rubber types:', error);
  } finally {
    isLoading.value = false;
  }
};

const handleOpenCreate = () => {
  editingItem.value = null;
  formData.value = { code: '', name: '', description: '', is_active: true };
  isModalOpen.value = true;
};

const handleOpenEdit = (item: RubberType) => {
  editingItem.value = item;
  formData.value = {
    code: item.code,
    name: item.name,
    description: item.description || '',
    is_active: item.is_active,
  };
  isModalOpen.value = true;
};

const handleSubmit = async () => {
  try {
    if (editingItem.value) {
      await rubberTypesApi.update(editingItem.value.id, formData.value);
    } else {
      await rubberTypesApi.create(formData.value);
    }
    isModalOpen.value = false;
    await fetchData();
  } catch (error) {
    console.error('Failed to save:', error);
  }
};

const handleDeleteClick = (id: string) => {
  itemToDelete.value = id;
  isDeleteModalOpen.value = true;
};

const confirmDelete = async () => {
  if (!itemToDelete.value) return;
  try {
    await rubberTypesApi.delete(itemToDelete.value);
    isDeleteModalOpen.value = false;
    itemToDelete.value = null;
    await fetchData();
  } catch (error) {
    console.error('Failed to delete:', error);
  }
};

// Column Definitions
const columns: ColumnDef<RubberType>[] = [
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
    accessorKey: 'description',
    header: 'Description',
    cell: ({ row }) =>
      h('div', { class: 'text-muted-foreground' }, row.getValue('description') || '-'),
  },
  {
    accessorKey: 'is_active',
    header: 'Status',
    cell: ({ row }) => {
      const isActive = row.getValue('is_active');
      return h(
        'span',
        {
          class: [
            'inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold',
            isActive ? 'bg-emerald-500/10 text-emerald-500' : 'bg-muted text-muted-foreground',
          ].join(' '),
        },
        isActive ? 'Active' : 'Inactive'
      );
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
});
</script>

<template>
  <div class="p-6 space-y-8 max-w-[1600px] mx-auto">
    <!-- Header / Stats -->
    <div class="p-6 rounded-xl border border-border bg-card shadow-sm relative overflow-hidden">
      <div class="absolute top-1/2 right-12 -translate-y-1/2 pointer-events-none opacity-5">
        <Layers class="w-64 h-64" />
      </div>

      <div class="flex items-center justify-between gap-6 relative z-10">
        <!-- Title Section -->
        <div class="flex items-center gap-6">
          <div
            class="p-4 bg-primary/10 rounded-xl text-primary flex items-center justify-center h-16 w-16"
          >
            <Layers class="h-8 w-8" />
          </div>
          <div>
            <h1 class="text-2xl font-bold tracking-tight text-foreground">Rubber Types</h1>
            <p class="text-sm text-muted-foreground mt-1">
              Manage rubber type classifications and codes.
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
            <div class="text-xs font-bold text-muted-foreground uppercase tracking-wider mb-1">
              Inactive
            </div>
            <div class="text-3xl font-bold text-muted-foreground">{{ stats.inactive }}</div>
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

    <!-- Controls & Search -->
    <div class="flex items-center justify-between gap-4">
      <div class="relative w-full max-w-sm">
        <Search class="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
        <Input v-model="searchQuery" placeholder="Search code or name..." class="pl-9" />
      </div>

      <Select v-model="statusFilter">
        <SelectTrigger class="w-[180px]">
          <SelectValue placeholder="All Status" />
        </SelectTrigger>
        <SelectContent>
          <SelectItem value="ALL">All Status</SelectItem>
          <SelectItem value="ACTIVE">Active</SelectItem>
          <SelectItem value="INACTIVE">Inactive</SelectItem>
        </SelectContent>
      </Select>
    </div>

    <!-- Loading State -->
    <div v-if="isLoading" class="space-y-4">
      <div v-for="i in 5" :key="i" class="flex items-center space-x-4">
        <Skeleton class="h-12 w-full" />
      </div>
    </div>

    <!-- Data Table -->
    <DataTable v-else :columns="columns" :data="filteredData" enable-selection />

    <!-- Create/Edit Dialog -->
    <Dialog v-model:open="isModalOpen">
      <DialogContent class="sm:max-w-[500px]">
        <DialogHeader>
          <DialogTitle>{{ editingItem ? 'Edit Rubber Type' : 'Add New Rubber Type' }}</DialogTitle>
          <DialogDescription>
            {{
              editingItem
                ? 'Update the details below.'
                : 'Fill in the information to create a new rubber type.'
            }}
          </DialogDescription>
        </DialogHeader>
        <div class="grid gap-4 py-4">
          <div class="grid gap-2">
            <Label for="code">Code <span class="text-destructive">*</span></Label>
            <Input id="code" v-model="formData.code" placeholder="e.g. RT-001" />
          </div>
          <div class="grid gap-2">
            <Label for="name">Name <span class="text-destructive">*</span></Label>
            <Input id="name" v-model="formData.name" placeholder="e.g. Latex 100%" />
          </div>
          <div class="grid gap-2">
            <Label for="description">Description</Label>
            <Textarea
              id="description"
              v-model="formData.description"
              placeholder="Optional description..."
            />
          </div>
          <div class="flex items-center gap-2">
            <input
              type="checkbox"
              id="is_active"
              v-model="formData.is_active"
              class="h-4 w-4 rounded border-input text-primary focus:ring-primary"
            />
            <Label for="is_active" class="cursor-pointer">Active</Label>
          </div>
        </div>
        <DialogFooter>
          <Button variant="outline" @click="isModalOpen = false">Cancel</Button>
          <Button @click="handleSubmit">Save Changes</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>

    <!-- Delete Confirmation Dialog -->
    <Dialog v-model:open="isDeleteModalOpen">
      <DialogContent class="sm:max-w-[425px]">
        <DialogHeader>
          <DialogTitle>Delete Rubber Type?</DialogTitle>
          <DialogDescription>
            Are you sure you want to delete this rubber type? This action cannot be undone.
          </DialogDescription>
        </DialogHeader>
        <DialogFooter>
          <Button variant="outline" @click="isDeleteModalOpen = false">Cancel</Button>
          <Button variant="destructive" @click="confirmDelete">Delete</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  </div>
</template>
