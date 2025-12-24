<script setup lang="ts">
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
import { Badge } from '@/components/ui/badge';
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
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { rolesApi } from '@/services/roles';
import { usersApi, type User } from '@/services/users';
import type { RoleDto } from '@my-app/types';
import type { ColumnDef } from '@tanstack/vue-table';
import { ArrowUpDown, Edit, Plus, Search, Trash2, Unlock, Users } from 'lucide-vue-next';
import { computed, h, onMounted, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { toast } from 'vue-sonner';

// --- State ---
const users = ref<User[]>([]);
const roles = ref<RoleDto[]>([]);
const isLoading = ref(true);
const searchQuery = ref('');

// Filters
const filterRole = ref<string>('all');
const filterStatus = ref<string>('all');

// Modal State
const isModalOpen = ref(false);
const isDeleteModalOpen = ref(false);
const itemToDelete = ref<string | null>(null);
const editingItem = ref<User | null>(null);

// Bulk Delete State
const isBulkDeleteDialogOpen = ref(false);
const usersToDelete = ref<User[]>([]);

const { t } = useI18n();

// --- Constants ---
// Dynamic role options from API
const ROLE_OPTIONS = computed(() =>
  roles.value.map((role) => ({
    value: role.id,
    label: role.name,
  }))
);

const DEPARTMENT_OPTIONS = computed(() => [
  t('admin.departments.qa'),
  t('admin.departments.it'),
  t('admin.departments.hr'),
  t('admin.departments.accounting'),
  t('admin.departments.production'),
  t('admin.departments.rawMaterial'),
  t('admin.departments.finance'),
  t('admin.departments.purchasing'),
  t('admin.departments.shipping'),
  t('admin.departments.maintenance'),
  t('admin.departments.safety'),
  t('admin.departments.management'),
]);

const POSITION_OPTIONS = computed(() => [
  t('admin.positions.md'),
  t('admin.positions.gm'),
  t('admin.positions.manager'),
  t('admin.positions.asstMgr'),
  t('admin.positions.seniorSup'),
  t('admin.positions.sup'),
  t('admin.positions.seniorStaff2'),
  t('admin.positions.seniorStaff1'),
  t('admin.positions.staff2'),
  t('admin.positions.staff1'),
  t('admin.positions.opLeader'),
  t('admin.positions.op'),
]);

const getRoleLabel = (roleVal: string) => {
  const found = ROLE_OPTIONS.value.find((r) => r.value === roleVal);
  return found ? found.label : roleVal;
};

// Form Data
const formData = ref<Partial<User>>({
  email: '',
  username: '',
  password: '',
  firstName: '',
  lastName: '',
  displayName: '',
  role: 'staff_1',
  department: '',
  position: '',
  status: 'ACTIVE',
  employeeId: '',
  forceChangePassword: true,
});

// --- Computed ---
const stats = computed(() => ({
  total: users.value.length,
  active: users.value.filter((u) => u.status === 'ACTIVE').length,
  inactive: users.value.filter((u) => u.status === 'INACTIVE').length,
  suspended: users.value.filter((u) => u.status === 'SUSPENDED').length,
}));

const filteredData = computed(() => {
  let data = users.value;

  // Global Search
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase();
    data = data.filter(
      (u) =>
        u.firstName?.toLowerCase().includes(query) ||
        u.lastName?.toLowerCase().includes(query) ||
        u.email.toLowerCase().includes(query) ||
        u.username?.toLowerCase().includes(query)
    );
  }

  // Filter Role
  if (filterRole.value && filterRole.value !== 'all') {
    data = data.filter((u) => u.role === filterRole.value);
  }

  // Filter Status
  if (filterStatus.value && filterStatus.value !== 'all') {
    data = data.filter((u) => u.status === filterStatus.value);
  }

  return data;
});

// --- Actions ---
const fetchRoles = async () => {
  try {
    roles.value = await rolesApi.getAll();
  } catch (error) {
    console.error('Failed to fetch roles:', error);
  }
};

const fetchData = async () => {
  try {
    isLoading.value = true;
    await Promise.all([usersApi.getAll(), fetchRoles()]).then(([usersData]) => {
      users.value = usersData;
    });
  } catch (error) {
    console.error('Failed to fetch users:', error);
    toast.error(t('admin.users.fetchError'));
  } finally {
    isLoading.value = false;
  }
};

const handleOpenCreate = () => {
  editingItem.value = null;
  formData.value = {
    email: '',
    username: '',
    firstName: '',
    lastName: '',
    displayName: '',
    role: 'staff_1',
    department: '',
    position: '',
    status: 'ACTIVE',
    employeeId: '',
    forceChangePassword: true,
  };
  isModalOpen.value = true;
};

const handleOpenEdit = (item: User) => {
  editingItem.value = item;
  formData.value = { ...item };
  isModalOpen.value = true;
};

const handleSubmit = async () => {
  try {
    const payload: Partial<User> = {
      username: formData.value.username,
      email: formData.value.email,
      firstName: formData.value.firstName,
      lastName: formData.value.lastName,
      displayName: formData.value.displayName,
      department: formData.value.department,
      position: formData.value.position,
      role: formData.value.role,
      status: formData.value.status,
      employeeId: formData.value.employeeId,
      pinCode: formData.value.pinCode,
      // hodId: formData.value.hodId, // Uncomment if used
      forceChangePassword: formData.value.forceChangePassword,
    };

    if (formData.value.password) {
      payload.password = formData.value.password;
    }

    if (editingItem.value) {
      await usersApi.update(editingItem.value.id, payload);
      toast.success(t('admin.users.updateSuccess'));
    } else {
      await usersApi.create(payload as User);
      toast.success(t('admin.users.createSuccess'));
    }
    isModalOpen.value = false;
    await fetchData();
  } catch (error) {
    console.error('Failed to save user:', error);
    toast.error(t('admin.users.saveError'));
  }
};

const handleDeleteClick = (id: string) => {
  itemToDelete.value = id;
  isDeleteModalOpen.value = true;
};

const confirmDelete = async () => {
  if (!itemToDelete.value) return;
  try {
    await usersApi.delete(itemToDelete.value);
    toast.success(t('admin.users.deleteSuccess'));
    isDeleteModalOpen.value = false;
    itemToDelete.value = null;
    await fetchData();
  } catch (error) {
    console.error('Failed to delete user:', error);
    toast.error(t('admin.users.deleteError'));
  }
};

const handleUnlock = async (userId: string) => {
  try {
    await usersApi.unlock(userId);
    toast.success('User account unlocked successfully');
    await fetchData();
  } catch (error) {
    console.error('Failed to unlock user:', error);
    toast.error('Failed to unlock user account');
  }
};

const handleBulkDelete = async (selectedRows: User[]) => {
  if (selectedRows.length === 0) return;

  // Store selected users and open confirmation dialog
  usersToDelete.value = selectedRows;
  isBulkDeleteDialogOpen.value = true;
};

const confirmBulkDelete = async () => {
  if (usersToDelete.value.length === 0) return;

  try {
    // Delete all selected users
    await Promise.all(usersToDelete.value.map((user) => usersApi.delete(user.id)));
    toast.success(`Successfully deleted ${usersToDelete.value.length} user(s)`);

    // Close dialog and reset state
    isBulkDeleteDialogOpen.value = false;
    usersToDelete.value = [];

    await fetchData();
  } catch (error) {
    console.error('Failed to delete users:', error);
    toast.error('Failed to delete selected users');
  }
};

// --- Columns ---
const columns: ColumnDef<User>[] = [
  {
    accessorKey: 'firstName', // Using firstName as primary sort/display key along with lastName
    header: ({ column }) => {
      return h(
        Button,
        {
          variant: 'ghost',
          onClick: () => column.toggleSorting(column.getIsSorted() === 'asc'),
        },
        () => [t('common.name'), h(ArrowUpDown, { class: 'ml-2 h-4 w-4' })]
      );
    },
    cell: ({ row }) => {
      const u = row.original;
      const name = u.displayName || `${u.firstName || ''} ${u.lastName || ''}`.trim() || u.username;
      return h('div', { class: 'font-medium' }, name);
    },
  },
  {
    accessorKey: 'email',
    header: ({ column }) => {
      return h(
        Button,
        {
          variant: 'ghost',
          onClick: () => column.toggleSorting(column.getIsSorted() === 'asc'),
        },
        () => [t('common.email'), h(ArrowUpDown, { class: 'ml-2 h-4 w-4' })]
      );
    },
    cell: ({ row }) => h('div', row.getValue('email')),
  },
  {
    accessorKey: 'role',
    header: t('admin.users.role'),
    cell: ({ row }) => {
      const roleVal = row.getValue('role') as string;
      const label = getRoleLabel(roleVal);
      // Use different color variants if needed, or simple outline
      return h(Badge, { variant: 'outline' }, () => label);
    },
  },
  {
    accessorKey: 'department',
    header: t('admin.userProfile.department'),
    cell: ({ row }) => h('div', row.getValue('department') || '-'),
  },
  {
    accessorKey: 'position',
    header: t('admin.userProfile.position'),
    cell: ({ row }) => h('div', row.getValue('position') || '-'),
  },
  {
    accessorKey: 'status',
    header: t('common.status'),
    cell: ({ row }) => {
      const status = row.getValue('status') as string;
      const colorClass =
        status === 'ACTIVE'
          ? 'bg-emerald-500/10 text-emerald-500'
          : status === 'SUSPENDED'
            ? 'bg-orange-500/10 text-orange-500'
            : 'bg-muted text-muted-foreground';

      return h(
        'span',
        {
          class: `inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold ${colorClass}`,
        },
        status
      );
    },
  },
  {
    id: 'actions',
    enableHiding: false,
    header: () => h('div', { class: 'text-right' }, t('common.actions')),
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
        // Show unlock button if user is suspended
        item.status === 'SUSPENDED'
          ? h(
              Button,
              {
                variant: 'ghost',
                size: 'icon',
                class: 'h-8 w-8 text-orange-500 hover:text-orange-600',
                onClick: () => handleUnlock(item.id),
                title: 'Unlock Account',
              },
              () => h(Unlock, { class: 'h-4 w-4' })
            )
          : null,
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
        <Users class="w-64 h-64" />
      </div>

      <div class="flex items-center justify-between gap-6 relative z-10">
        <!-- Title Section -->
        <div class="flex items-center gap-6">
          <div
            class="p-4 bg-primary/10 rounded-xl text-primary flex items-center justify-center h-16 w-16"
          >
            <Users class="h-8 w-8" />
          </div>
          <div>
            <h1 class="text-2xl font-bold tracking-tight text-foreground">
              {{ t('admin.users.title') }}
            </h1>
            <p class="text-sm text-muted-foreground mt-1">
              {{ t('admin.users.subtitle') }}
            </p>
          </div>
        </div>

        <!-- Stats Section -->
        <div class="flex items-center gap-8">
          <div class="text-center">
            <div class="text-xs font-bold text-muted-foreground uppercase tracking-wider mb-1">
              {{ t('admin.status.total') }}
            </div>
            <div class="text-3xl font-bold">{{ stats.total }}</div>
          </div>
          <div class="text-center">
            <div class="text-xs font-bold text-emerald-500 uppercase tracking-wider mb-1">
              {{ t('admin.status.active') }}
            </div>
            <div class="text-3xl font-bold text-emerald-500">{{ stats.active }}</div>
          </div>
          <div class="text-center">
            <div class="text-xs font-bold text-orange-500 uppercase tracking-wider mb-1">
              {{ t('admin.status.suspended') }}
            </div>
            <div class="text-3xl font-bold text-orange-500">{{ stats.suspended }}</div>
          </div>
        </div>

        <!-- Add Button -->
        <div class="flex-shrink-0">
          <Button @click="handleOpenCreate" size="lg" class="shadow-lg shadow-primary/20">
            <Plus class="mr-2 h-5 w-5" />
            {{ t('admin.users.addUser') }}
          </Button>
        </div>
      </div>
    </div>

    <!-- Controls -->
    <div class="flex items-center justify-between gap-4">
      <div class="relative w-full max-w-sm">
        <Search class="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
        <Input v-model="searchQuery" :placeholder="t('common.search')" class="pl-9" />
      </div>
      <div class="flex items-center gap-2">
        <Select v-model="filterRole">
          <SelectTrigger class="w-[180px]">
            <SelectValue :placeholder="t('admin.users.allRoles')" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">{{ t('admin.users.allRoles') }}</SelectItem>
            <SelectItem v-for="option in ROLE_OPTIONS" :key="option.value" :value="option.value">
              {{ option.label }}
            </SelectItem>
          </SelectContent>
        </Select>
        <Select v-model="filterStatus">
          <SelectTrigger class="w-[180px]">
            <SelectValue :placeholder="t('admin.users.allStatus')" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">{{ t('admin.users.allStatus') }}</SelectItem>
            <SelectItem value="ACTIVE">{{ t('admin.status.active') }}</SelectItem>
            <SelectItem value="INACTIVE">{{ t('admin.status.inactive') }}</SelectItem>
            <SelectItem value="SUSPENDED">{{ t('admin.status.suspended') }}</SelectItem>
          </SelectContent>
        </Select>
      </div>
    </div>

    <!-- Data Display -->
    <DataTable
      :columns="columns"
      :data="filteredData"
      enable-selection
      @delete-selected="handleBulkDelete"
    />

    <!-- Create/Edit Modal -->
    <Dialog v-model:open="isModalOpen">
      <DialogContent class="sm:max-w-[700px]">
        <DialogHeader>
          <DialogTitle>{{
            editingItem ? t('admin.users.editUser') : t('admin.users.addUser')
          }}</DialogTitle>
          <DialogDescription>{{ t('admin.users.fillDetails') }}</DialogDescription>
        </DialogHeader>

        <Tabs default-value="basic" class="w-full">
          <TabsList class="grid w-full grid-cols-3">
            <TabsTrigger value="basic">{{ t('admin.users.basicInfo') }}</TabsTrigger>
            <TabsTrigger value="work">{{ t('admin.users.workInfo') }}</TabsTrigger>
            <TabsTrigger value="security">{{ t('admin.users.security') }}</TabsTrigger>
          </TabsList>

          <!-- Basic Info -->
          <TabsContent value="basic" class="space-y-4 py-4">
            <div class="grid grid-cols-2 gap-4">
              <div class="space-y-2">
                <Label>{{ t('admin.users.username') }}</Label>
                <Input v-model="formData.username" placeholder="jdoe" />
              </div>
              <div class="space-y-2">
                <Label>{{ t('common.email') }}</Label>
                <Input v-model="formData.email" type="email" placeholder="john@example.com" />
              </div>
              <div class="space-y-2">
                <Label>{{ t('admin.userProfile.firstName') }}</Label>
                <Input v-model="formData.firstName" />
              </div>
              <div class="space-y-2">
                <Label>{{ t('admin.userProfile.lastName') }}</Label>
                <Input v-model="formData.lastName" />
              </div>
              <div class="col-span-2 space-y-2">
                <Label>{{ t('admin.userProfile.displayName') }}</Label>
                <Input v-model="formData.displayName" />
              </div>
            </div>
          </TabsContent>

          <!-- Work Info -->
          <TabsContent value="work" class="space-y-4 py-4">
            <div class="grid grid-cols-2 gap-4">
              <div class="space-y-2">
                <Label>{{ t('admin.users.employeeId') }}</Label>
                <Input v-model="formData.employeeId" placeholder="EMP-001" />
              </div>
              <div class="space-y-2">
                <Label>{{ t('admin.users.role') }}</Label>
                <Select v-model="formData.role">
                  <SelectTrigger
                    ><SelectValue :placeholder="t('admin.users.selectRole')"
                  /></SelectTrigger>
                  <SelectContent>
                    <SelectItem
                      v-for="option in ROLE_OPTIONS"
                      :key="option.value"
                      :value="option.value"
                    >
                      {{ option.label }}
                    </SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div class="space-y-2">
                <Label>{{ t('admin.userProfile.department') }}</Label>
                <Select v-model="formData.department">
                  <SelectTrigger
                    ><SelectValue :placeholder="t('admin.users.selectDepartment')"
                  /></SelectTrigger>
                  <SelectContent>
                    <SelectItem v-for="dept in DEPARTMENT_OPTIONS" :key="dept" :value="dept">
                      {{ dept }}
                    </SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div class="space-y-2">
                <Label>{{ t('admin.userProfile.position') }}</Label>
                <Select v-model="formData.position">
                  <SelectTrigger
                    ><SelectValue :placeholder="t('admin.users.selectPosition')"
                  /></SelectTrigger>
                  <SelectContent>
                    <SelectItem v-for="pos in POSITION_OPTIONS" :key="pos" :value="pos">
                      {{ pos }}
                    </SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>
          </TabsContent>

          <!-- Security -->
          <TabsContent value="security" class="space-y-4 py-4">
            <div class="grid grid-cols-2 gap-4">
              <div class="space-y-2">
                <Label>{{ t('common.status') }}</Label>
                <Select v-model="formData.status">
                  <SelectTrigger><SelectValue /></SelectTrigger>
                  <SelectContent>
                    <SelectItem value="ACTIVE">{{ t('admin.status.active') }}</SelectItem>
                    <SelectItem value="INACTIVE">{{ t('admin.status.inactive') }}</SelectItem>
                    <SelectItem value="SUSPENDED">{{ t('admin.status.suspended') }}</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div v-if="!editingItem" class="space-y-2">
                <Label>{{ t('auth.password') }}</Label>
                <Input v-model="formData.password" type="password" placeholder="••••••" />
              </div>
              <div class="flex items-center space-x-2 mt-8">
                <input
                  type="checkbox"
                  id="forcePwd"
                  v-model="formData.forceChangePassword"
                  class="h-4 w-4 rounded border-gray-300 text-sky-600 focus:ring-sky-500"
                />
                <Label for="forcePwd">{{ t('admin.users.forcePasswordChange') }}</Label>
              </div>

              <!-- Unlock Button for Suspended Users -->
              <div v-if="editingItem && editingItem.status === 'SUSPENDED'" class="col-span-2">
                <Button
                  @click="handleUnlock(editingItem.id)"
                  variant="outline"
                  class="w-full border-orange-500 text-orange-500 hover:bg-orange-50"
                >
                  <Unlock class="mr-2 h-4 w-4" />
                  Unlock Account
                </Button>
              </div>
            </div>
          </TabsContent>
        </Tabs>

        <DialogFooter>
          <Button variant="outline" @click="isModalOpen = false">{{ t('common.cancel') }}</Button>
          <Button @click="handleSubmit">{{ t('common.saveChanges') }}</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>

    <!-- Delete Confirmation -->
    <Dialog v-model:open="isDeleteModalOpen">
      <DialogContent class="sm:max-w-[425px]">
        <DialogHeader>
          <DialogTitle>{{ t('admin.users.deleteTitle') }}</DialogTitle>
          <DialogDescription>
            {{ t('admin.users.deleteDesc') }}
          </DialogDescription>
        </DialogHeader>
        <DialogFooter>
          <Button variant="outline" @click="isDeleteModalOpen = false">{{
            t('common.cancel')
          }}</Button>
          <Button variant="destructive" @click="confirmDelete">{{ t('common.delete') }}</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>

    <!-- Bulk Delete Confirmation AlertDialog -->
    <AlertDialog v-model:open="isBulkDeleteDialogOpen">
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>Delete Multiple Users?</AlertDialogTitle>
          <AlertDialogDescription>
            Are you sure you want to delete <strong>{{ usersToDelete.length }}</strong> user(s)?
            This action cannot be undone and will permanently remove these users from the system.
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel @click="isBulkDeleteDialogOpen = false">Cancel</AlertDialogCancel>
          <AlertDialogAction
            @click="confirmBulkDelete"
            class="bg-destructive text-destructive-foreground hover:bg-destructive/90"
          >
            Delete {{ usersToDelete.length }} User(s)
          </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  </div>
</template>
