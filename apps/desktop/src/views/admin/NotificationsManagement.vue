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
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Checkbox } from '@/components/ui/checkbox';
import DataTable from '@/components/ui/data-table/DataTable.vue';
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog';
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import MultiSelect from '@/components/ui/multi-select/MultiSelect.vue';
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Textarea } from '@/components/ui/textarea';
import { notificationsApi } from '@/services/notifications';
import { rolesApi } from '@/services/roles';
import { usersApi } from '@/services/users';
import type {
    BroadcastDto,
    CreateBroadcastDto,
    CreateNotificationGroupDto,
    NotificationGroupDto,
    NotificationSettingDto,
    RoleDto,
    UserDto,
} from '@my-app/types';
import type { ColumnDef } from '@tanstack/vue-table';
import { format } from 'date-fns';
import {
    AlertCircle,
    AlertTriangle,
    Bell,
    Briefcase,
    CheckCircle2,
    Edit2,
    Info,
    Layers,
    Lock,
    MoreHorizontal,
    Plus,
    Send,
    Settings,
    Shield,
    Trash2,
    Users,
} from 'lucide-vue-next';
import { computed, h, onMounted, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { toast } from 'vue-sonner';

const { t } = useI18n();

// --- Helpers ---
// --- Helpers ---
const ICON_MAP: Record<string, any> = {
  Shield,
  Briefcase,
  User: Users, // Fallback or map specific
  Users,
  Layers,
  Lock,
};

const AVAILABLE_ICONS = ['Shield', 'Briefcase', 'Users', 'Layers', 'Lock'];

const AVAILABLE_COLORS = [
  'bg-blue-600',
  'bg-purple-600',
  'bg-emerald-500',
  'bg-orange-500',
  'bg-indigo-500',
  'bg-green-500',
  'bg-slate-500',
];

const getGroupGradient = (group: NotificationGroupDto, index: number) => {
  // If group has color, use it (mapped to gradient)
  if (group.color) {
    const colorMap: Record<string, { from: string; to: string; shadow: string }> = {
      'bg-blue-600': { from: '#2563eb', to: '#1e40af', shadow: 'rgba(37, 99, 235, 0.5)' },
      'bg-purple-600': { from: '#9333ea', to: '#7e22ce', shadow: 'rgba(147, 51, 234, 0.5)' },
      'bg-emerald-500': { from: '#10b981', to: '#059669', shadow: 'rgba(16, 185, 129, 0.5)' },
      'bg-orange-500': { from: '#f97316', to: '#ea580c', shadow: 'rgba(249, 115, 22, 0.5)' },
      'bg-orange-400': { from: '#fb923c', to: '#f97316', shadow: 'rgba(251, 146, 60, 0.5)' },
      'bg-indigo-500': { from: '#6366f1', to: '#4f46e5', shadow: 'rgba(99, 102, 241, 0.5)' },
      'bg-indigo-400': { from: '#818cf8', to: '#6366f1', shadow: 'rgba(129, 140, 248, 0.5)' },
      'bg-green-500': { from: '#22c55e', to: '#16a34a', shadow: 'rgba(34, 197, 94, 0.5)' },
      'bg-slate-500': { from: '#64748b', to: '#475569', shadow: 'rgba(100, 116, 139, 0.5)' },
    };
    return (
      colorMap[group.color] || {
        from: '#94a3b8',
        to: '#64748b',
        shadow: 'rgba(148, 163, 184, 0.5)',
      }
    );
  }

  // Fallback to index based
  const gradients = [
    { from: '#2563eb', to: '#1e40af', shadow: 'rgba(37, 99, 235, 0.5)' }, // Blue
    { from: '#9333ea', to: '#7e22ce', shadow: 'rgba(147, 51, 234, 0.5)' }, // Purple
    { from: '#10b981', to: '#059669', shadow: 'rgba(16, 185, 129, 0.5)' }, // Emerald
    { from: '#f97316', to: '#ea580c', shadow: 'rgba(249, 115, 22, 0.5)' }, // Orange
    { from: '#6366f1', to: '#4f46e5', shadow: 'rgba(99, 102, 241, 0.5)' }, // Indigo
    { from: '#22c55e', to: '#16a34a', shadow: 'rgba(34, 197, 94, 0.5)' }, // Green
  ];
  return gradients[index % gradients.length];
};

const getGroupIcon = (iconName?: string) => {
  return iconName && ICON_MAP[iconName] ? ICON_MAP[iconName] : Users;
};

const getUserAvatar = (userId: string) => {
  const user = users.value.find((u) => u.id === userId);
  return user?.avatar || '';
};

// --- Computed ---
const totalGroupMembers = computed(() => {
  return groups.value.reduce((acc, group) => acc + (group.memberIds?.length || 0), 0);
});

const headerIcon = computed(() => {
  if (activeTab.value === 'broadcast') return Bell;
  if (activeTab.value === 'groups') return Users;
  return Settings;
});

const headerTitle = computed(() => {
  if (activeTab.value === 'broadcast') return t('admin.notifications.title');
  if (activeTab.value === 'groups') return t('admin.notifications.groups');
  return t('admin.notifications.configuration');
});

const headerSubtitle = computed(() => {
  return t('admin.notifications.subtitle');
});

// State
const activeTab = ref('broadcast');
const broadcasts = ref<BroadcastDto[]>([]);

// Bulk delete confirmation
const bulkDeleteDialogOpen = ref(false);
const broadcastsToBulkDelete = ref<BroadcastDto[]>([]);
const groups = ref<NotificationGroupDto[]>([]);
const roles = ref<RoleDto[]>([]);
const users = ref<UserDto[]>([]);
const loading = ref(false);

// Settings
const settings = ref<NotificationSettingDto[]>([]);
const settingDefinitions = [
  { sourceApp: 'Booking', actionType: 'CREATE', label: 'New Booking Created' },
  { sourceApp: 'Booking', actionType: 'UPDATE', label: 'Booking Updated' },
  { sourceApp: 'Booking', actionType: 'DELETE', label: 'Booking Cancelled' },
];

const fetchSettings = async () => {
  try {
    const res = await notificationsApi.getSettings();
    settings.value = res.data || [];
  } catch (err) {
    console.error(err);
  }
};

const getSetting = (sourceApp: string, actionType: string) => {
  return (
    settings.value.find((s) => s.sourceApp === sourceApp && s.actionType === actionType) || {
      sourceApp,
      actionType,
      isActive: true,
      recipientRoles: [],
      recipientGroups: [],
      recipientUsers: [],
    }
  );
};

const saveSetting = async (
  sourceApp: string,
  actionType: string,
  isActive: any, // Checkbox checked value can be boolean or 'indeterminate'
  roles: string[],
  groups: string[]
) => {
  try {
    await notificationsApi.updateSetting({
      sourceApp,
      actionType,
      isActive: isActive === true,
      recipientRoles: roles,
      recipientGroups: groups,
    });
    toast.success('Setting updated');
    fetchSettings();
  } catch (err) {
    toast.error('Failed to update setting');
  }
};

// Delete confirmation
const isDeleteDialogOpen = ref(false);
const deleteTarget = ref<{ type: 'broadcast' | 'group'; id: string; name: string } | null>(null);

// Broadcast Dialog
const isBroadcastDialogOpen = ref(false);
const broadcastForm = ref<CreateBroadcastDto>({
  title: '',
  message: '',
  type: 'INFO',
  recipientRoles: [],
  recipientUsers: [],
  recipientGroups: [],
  actionUrl: '',
});

// Group Dialog
const isGroupDialogOpen = ref(false);
const editingGroup = ref<NotificationGroupDto | null>(null);
const groupForm = ref<CreateNotificationGroupDto>({
  name: '',
  description: '',
  memberIds: [],
  icon: 'Users',
  color: 'bg-blue-600',
});

// Broadcast Columns
const broadcastColumns: ColumnDef<BroadcastDto>[] = [
  {
    accessorKey: 'type',
    header: () => t('admin.notifications.type'),
    cell: ({ row }) => {
      const type = row.original.type;
      const variants: Record<
        string,
        { variant: 'default' | 'destructive' | 'secondary' | 'outline'; class: string }
      > = {
        INFO: { variant: 'default', class: 'bg-blue-500 hover:bg-blue-600' },
        SUCCESS: { variant: 'default', class: 'bg-green-500 hover:bg-green-600' },
        WARNING: { variant: 'default', class: 'bg-yellow-500 hover:bg-yellow-600 text-black' },
        ERROR: { variant: 'destructive', class: '' },
        REQUEST: { variant: 'default', class: 'bg-purple-500 hover:bg-purple-600' },
        APPROVE: { variant: 'default', class: 'bg-teal-500 hover:bg-teal-600' },
      };
      const config = variants[type] || variants.INFO;

      // Resolve Recipients
      const { recipientGroups, recipientRoles, recipientUsers } = row.original;
      let recipientText = 'All';

      if (recipientGroups?.length) {
        const groupNames = recipientGroups
          .map((id) => groups.value.find((g) => g.id === id)?.name || 'Unknown Group')
          .join(', ');
        recipientText = `Group: ${groupNames}`;
      } else if (recipientRoles?.length) {
        recipientText = `Role: ${recipientRoles.join(', ')}`;
      } else if (recipientUsers?.length) {
        const userNames = recipientUsers
          .map((id) => {
            const u = users.value.find((user) => user.id === id);
            return u?.displayName || u?.username || 'Unknown User';
          })
          .join(', ');
        recipientText = `User: ${userNames}`;
      }

      return h('div', { class: 'flex flex-col gap-1 items-start' }, [
        h(
          Badge,
          {
            variant: config.variant,
            class: config.class,
          },
          () => type
        ),
        h('div', { class: 'flex items-center text-xs text-muted-foreground gap-1' }, [
          // h(recipientIcon, { class: 'w-3 h-3' }),
          h('span', {}, recipientText),
        ]),
      ]);
    },
  },
  {
    id: 'status',
    header: () => t('admin.notifications.status'),
    cell: ({ row }) => {
      const type = row.original.type;

      const statusMap: Record<
        string,
        {
          label: string;
          icon: any;
          class: string;
          variant: 'default' | 'secondary' | 'destructive' | 'outline';
        }
      > = {
        APPROVE: {
          label: 'Approved',
          icon: CheckCircle2,
          class: 'text-green-600 border-green-200 bg-green-50',
          variant: 'outline',
        },
        REQUEST: {
          label: 'Pending',
          icon: AlertCircle,
          class: 'text-orange-600 border-orange-200 bg-orange-50',
          variant: 'outline',
        },
        SUCCESS: {
          label: 'Complete',
          icon: CheckCircle2,
          class: 'text-emerald-600 border-emerald-200 bg-emerald-50',
          variant: 'outline',
        },
        ERROR: {
          label: 'Failed',
          icon: AlertTriangle,
          class: 'text-red-600 border-red-200 bg-red-50',
          variant: 'outline',
        },
        WARNING: {
          label: 'Warning',
          icon: AlertTriangle,
          class: 'text-yellow-600 border-yellow-200 bg-yellow-50',
          variant: 'outline',
        },
        INFO: {
          label: 'Sent',
          icon: CheckCircle2,
          class: 'text-blue-600 border-blue-200 bg-blue-50',
          variant: 'outline',
        },
      };

      const config = statusMap[type] || statusMap.INFO;

      return h(Badge, { variant: config.variant, class: config.class }, () => [
        h(config.icon, { class: 'w-3 h-3 mr-1' }),
        config.label,
      ]);
    },
  },
  {
    accessorKey: 'title',
    header: () => t('admin.notifications.titleLabel'),
    cell: ({ row }) => {
      return h('span', { class: 'font-medium' }, row.original.title);
    },
  },
  {
    accessorKey: 'message',
    header: () => t('admin.notifications.message'),
    cell: ({ row }) => {
      return h('div', { class: 'max-w-md truncate text-muted-foreground' }, row.original.message);
    },
  },
  {
    accessorKey: 'createdAt',
    header: () => t('admin.notifications.date'),
    cell: ({ row }) => {
      return h('span', { class: 'text-sm' }, formatDate(row.original.createdAt));
    },
  },
  {
    id: 'actions',
    header: () => t('common.actions'),
    cell: ({ row }) => {
      const broadcast = row.original;
      return h('div', { class: 'flex gap-2' }, [
        h(
          Button,
          {
            variant: 'ghost',
            size: 'icon',
            class: 'text-destructive hover:text-destructive hover:bg-destructive/10',
            onClick: () => confirmDelete('broadcast', broadcast.id, broadcast.title),
          },
          () => h(Trash2, { class: 'w-4 h-4' })
        ),
      ]);
    },
  },
];

// Removed groupColumns as we are switching to card layout

// Fetch data
const fetchData = async () => {
  loading.value = true;
  try {
    const [broadcastsRes, groupsRes, rolesRes, usersRes] = await Promise.all([
      notificationsApi.getBroadcastHistory(),
      notificationsApi.getGroups(),
      rolesApi.getAll(),
      usersApi.getAll(),
    ]);
    broadcasts.value = broadcastsRes.data || [];
    groups.value = (groupsRes.data || []).map((g: any) => ({
      ...g,
      memberIds: g.members?.map((m: any) => m.id) || g.memberIds || [],
    }));
    roles.value = rolesRes || [];
    users.value = (usersRes || []).map((u) => ({
      ...u,
      username: u.username ?? null,
    })) as UserDto[];
  } catch (error) {
    console.error('Failed to fetch data:', error);
    toast.error(t('common.errorLoading'));
  } finally {
    loading.value = false;
  }
};

// Delete confirmation
const confirmDelete = (type: 'broadcast' | 'group', id: string, name: string) => {
  deleteTarget.value = { type, id, name };
  isDeleteDialogOpen.value = true;
};

const handleDelete = async () => {
  if (!deleteTarget.value) return;

  try {
    if (deleteTarget.value.type === 'broadcast') {
      await notificationsApi.deleteBroadcast(deleteTarget.value.id);
      toast.success(t('admin.notifications.notificationDeleted'));
    } else {
      await notificationsApi.deleteGroup(deleteTarget.value.id);
      toast.success('Group deleted');
    }
    // Close dialog safely before refetching
    isDeleteDialogOpen.value = false;
    deleteTarget.value = null;

    // Slight delay to allow UI to settle? Not strictly needed but safer for "freeze" feeling
    await fetchData();
  } catch (error) {
    console.error('Failed to delete:', error);
    toast.error('Failed to delete');
    isDeleteDialogOpen.value = false; // Ensure dialog closes even on error
  }
};

// Broadcast functions
const handleSendBroadcast = async () => {
  // Validate that at least one recipient is selected
  const hasRecipients =
    (broadcastForm.value.recipientUsers?.length ?? 0) > 0 ||
    (broadcastForm.value.recipientRoles?.length ?? 0) > 0 ||
    (broadcastForm.value.recipientGroups?.length ?? 0) > 0;

  if (!hasRecipients) {
    toast.error('กรุณาเลือกผู้รับการแจ้งเตือนอย่างน้อย 1 ช่อง (Users, Roles หรือ Groups)');
    return;
  }

  try {
    console.log(
      '[Frontend] Sending Broadcast payload:',
      JSON.parse(JSON.stringify(broadcastForm.value))
    );
    await notificationsApi.broadcast(broadcastForm.value);
    toast.success(t('admin.notifications.notificationCreated'));
    isBroadcastDialogOpen.value = false;
    resetBroadcastForm();
    fetchData();
  } catch (error) {
    console.error('Failed to send broadcast:', error);
    toast.error('Failed to send broadcast');
  }
};

const resetBroadcastForm = () => {
  broadcastForm.value = {
    title: '',
    message: '',
    type: 'INFO',
    recipientRoles: [],
    recipientUsers: [],
    recipientGroups: [],
    actionUrl: '',
  };
};

const handleBulkDeleteBroadcasts = async (selectedBroadcasts: BroadcastDto[]) => {
  console.log('[handleBulkDeleteBroadcasts] Called with:', selectedBroadcasts.length, 'broadcasts');
  if (selectedBroadcasts.length === 0) return;

  broadcastsToBulkDelete.value = selectedBroadcasts;
  bulkDeleteDialogOpen.value = true;
  console.log('[handleBulkDeleteBroadcasts] Dialog opened');
};

const executeBulkDeleteBroadcasts = async () => {
  if (broadcastsToBulkDelete.value.length === 0) return;

  try {
    await Promise.all(
      broadcastsToBulkDelete.value.map((b) => notificationsApi.deleteBroadcast(b.id))
    );
    const deletedIds = broadcastsToBulkDelete.value.map((b) => b.id);
    broadcasts.value = broadcasts.value.filter((b) => !deletedIds.includes(b.id));
    toast.success(`${broadcastsToBulkDelete.value.length} broadcast(s) deleted`);
    bulkDeleteDialogOpen.value = false;
    broadcastsToBulkDelete.value = [];
  } catch (error) {
    console.error('Failed to delete broadcasts:', error);
    toast.error('Failed to delete some broadcasts');
  }
};

const handleOpenBroadcastDialog = () => {
  resetBroadcastForm();
  isBroadcastDialogOpen.value = true;
};

// Group functions
const handleCreateGroup = () => {
  editingGroup.value = null;
  groupForm.value = {
    name: '',
    description: '',
    memberIds: [],
    icon: 'Users',
    color: 'bg-blue-600',
  };
  isGroupDialogOpen.value = true;
};

const handleEditGroup = (group: NotificationGroupDto) => {
  editingGroup.value = group;
  groupForm.value = {
    name: group.name,
    description: group.description,
    memberIds: group.memberIds || [],
    icon: group.icon || 'Users',
    color: group.color || 'bg-blue-600',
  };
  isGroupDialogOpen.value = true;
};

const handleSaveGroup = async () => {
  try {
    if (editingGroup.value?.id) {
      await notificationsApi.updateGroup(editingGroup.value.id, groupForm.value);
      toast.success('Group updated');
    } else {
      await notificationsApi.createGroup(groupForm.value);
      toast.success('Group created');
    }
    isGroupDialogOpen.value = false;
    fetchData();
  } catch (error) {
    console.error('Failed to save group:', error);
    toast.error('Failed to save');
  }
};

const formatDate = (date: Date | string) => {
  return format(new Date(date), 'dd-MMM-yyyy, HH:mm:ss');
};

onMounted(() => {
  fetchData();
  fetchSettings();
});
</script>

<template>
  <div class="space-y-6">
    <!-- Dynamic Header Card -->
    <div
      class="rounded-xl border border-border/60 bg-card/40 backdrop-blur-xl p-6 relative overflow-hidden shadow-sm z-0"
    >
      <div class="absolute top-1/2 right-12 -translate-y-1/2 pointer-events-none opacity-[0.03]">
        <component :is="headerIcon" class="w-64 h-64 rotate-12" />
      </div>

      <div class="flex flex-col md:flex-row items-center justify-between gap-6 relative z-10">
        <div class="flex items-center gap-4 w-full md:w-auto">
          <div
            class="h-12 w-12 flex items-center justify-center bg-blue-100/50 dark:bg-blue-900/30 rounded-lg text-blue-600 dark:text-blue-400 shadow-sm backdrop-blur-sm"
          >
            <component :is="headerIcon" class="h-6 w-6" />
          </div>
          <div>
            <h1 class="text-xl font-bold tracking-tight text-foreground">
              {{ headerTitle }}
            </h1>
            <p class="text-sm text-muted-foreground mt-0.5">
              {{ headerSubtitle }}
            </p>
          </div>
        </div>

        <!-- Dynamic Actions/Stats based on Tab -->
        <div class="flex flex-1 items-center justify-end gap-8 md:gap-12 text-center">
          <!-- Broadcast Stats -->
          <div v-if="activeTab === 'broadcast'">
            <p class="text-[10px] font-bold text-muted-foreground uppercase tracking-widest mb-1">
              Total Broadcasts
            </p>
            <p class="text-2xl font-bold text-foreground">{{ broadcasts.length }}</p>
          </div>

          <!-- Groups Stats -->
          <template v-if="activeTab === 'groups'">
            <div>
              <p class="text-[10px] font-bold text-muted-foreground uppercase tracking-widest mb-1">
                {{ t('admin.notifications.totalGroups') }}
              </p>
              <p class="text-2xl font-bold text-foreground">{{ groups.length }}</p>
            </div>
            <div>
              <p class="text-[10px] font-bold text-emerald-600 uppercase tracking-widest mb-1">
                {{ t('admin.notifications.totalMembers') }}
              </p>
              <p class="text-2xl font-bold text-emerald-600">{{ totalGroupMembers }}</p>
            </div>
          </template>

          <div class="flex items-center gap-2">
            <Button
              v-if="activeTab === 'broadcast'"
              @click="handleOpenBroadcastDialog"
              class="gap-2"
            >
              <Send class="w-4 h-4" />
              {{ t('admin.notifications.sendManualBroadcast') }}
            </Button>

            <Button v-if="activeTab === 'groups'" @click="handleCreateGroup" class="gap-2">
              <Plus class="w-4 h-4" />
              {{ t('admin.notifications.newGroup') }}
            </Button>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabs -->
    <Tabs v-model="activeTab" default-value="broadcast" class="w-full">
      <TabsList class="grid w-full grid-cols-3">
        <TabsTrigger value="broadcast" class="gap-2">
          <Bell class="w-4 h-4" />
          {{ t('admin.notifications.broadcast') }}
        </TabsTrigger>
        <TabsTrigger value="groups" class="gap-2">
          <Users class="w-4 h-4" />
          {{ t('admin.notifications.groups') }}
        </TabsTrigger>
        <TabsTrigger value="settings" class="gap-2">
          <Settings class="w-4 h-4" />
          {{ t('admin.notifications.configuration') }}
        </TabsTrigger>
      </TabsList>

      <!-- Broadcast Tab -->
      <TabsContent value="broadcast" class="space-y-6 pt-4">
        <DataTable
          :columns="broadcastColumns"
          :data="broadcasts"
          enable-selection
          @delete-selected="handleBulkDeleteBroadcasts"
        />
      </TabsContent>

      <!-- Groups Tab -->
      <TabsContent value="groups" class="space-y-6 pt-4">
        <!-- Groups Grid -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          <div
            v-for="(group, index) in groups"
            :key="group.id"
            class="group flex flex-col justify-between rounded-lg border-2 border-border bg-card/20 backdrop-blur-md p-4 transition-all duration-300 hover:shadow-lg hover:-translate-y-1 hover:border-border/80 relative overflow-hidden"
          >
            <!-- Watermark Icon -->
            <component
              :is="getGroupIcon(group.icon)"
              class="absolute -right-5 -bottom-4 w-32 h-32 opacity-[0.03] group-hover:opacity-20 rotate-[-15deg] transition-all duration-500 group-hover:scale-110 group-hover:rotate-[-5deg] pointer-events-none"
              :style="{
                color: getGroupGradient(group, index).from,
              }"
            />

            <CardContent class="p-0 z-10">
              <div class="flex justify-between items-start mb-3">
                <!-- Icon with Gradient -->
                <div
                  class="relative h-12 w-12 flex items-center justify-center rounded-xl transition-all duration-300 group-hover:scale-110 group-hover:rotate-3 shadow-lg"
                  :style="{
                    background: `linear-gradient(135deg, ${
                      getGroupGradient(group, index).from
                    } 0%, ${getGroupGradient(group, index).to} 100%)`,
                    boxShadow: `0 10px 25px -5px ${getGroupGradient(group, index).shadow}, 0 8px 10px -6px ${
                      getGroupGradient(group, index).shadow
                    }`,
                  }"
                >
                  <component
                    :is="getGroupIcon(group.icon)"
                    class="w-6 h-6 text-white drop-shadow-md"
                  />
                </div>

                <DropdownMenu>
                  <DropdownMenuTrigger as-child>
                    <Button
                      variant="ghost"
                      size="icon"
                      class="h-8 w-8 text-muted-foreground/60 hover:text-foreground hover:bg-foreground/5 rounded-full"
                    >
                      <MoreHorizontal class="w-4 h-4" />
                    </Button>
                  </DropdownMenuTrigger>
                  <DropdownMenuContent
                    align="end"
                    class="rounded-lg border-border/60 backdrop-blur-md bg-card/90"
                  >
                    <DropdownMenuItem @click="handleEditGroup(group)">
                      <Edit2 class="w-4 h-4 mr-2" />
                      {{ t('admin.notifications.editGroup') }}
                    </DropdownMenuItem>
                    <DropdownMenuItem
                      @click="confirmDelete('group', group.id, group.name)"
                      class="text-red-600 focus:text-red-600"
                    >
                      <Trash2 class="w-4 h-4 mr-2" />
                      {{ t('common.delete') }}
                    </DropdownMenuItem>
                  </DropdownMenuContent>
                </DropdownMenu>
              </div>

              <h3 class="font-bold text-base mb-0.5 text-foreground tracking-tight">
                {{ group.name }}
              </h3>
              <p class="text-[11px] text-muted-foreground line-clamp-2 h-7 mb-2 leading-relaxed">
                {{ group.description || t('admin.notifications.noDescription') }}
              </p>

              <div
                class="flex items-center justify-between pt-2.5 border-t border-dashed border-border/40 mt-auto"
              >
                <!-- Avatar Pile -->
                <div class="flex -space-x-2 hover:space-x-1 transition-all duration-300">
                  <template
                    v-for="(memberId, i) in (group.memberIds || []).slice(0, 3)"
                    :key="memberId"
                  >
                    <Avatar
                      class="w-6 h-6 border-2 border-background ring-2 ring-background transition-transform hover:scale-110 hover:z-10"
                    >
                      <AvatarImage :src="getUserAvatar(memberId)" />
                      <AvatarFallback class="text-[9px] bg-muted text-muted-foreground font-bold">
                        U{{ i + 1 }}
                      </AvatarFallback>
                    </Avatar>
                  </template>
                  <div
                    v-if="(group.memberIds?.length || 0) > 3"
                    class="w-6 h-6 rounded-full border-2 border-background bg-muted flex items-center justify-center text-[8px] font-bold text-muted-foreground z-0 pl-0.5"
                  >
                    +{{ (group.memberIds?.length || 0) - 3 }}
                  </div>
                </div>

                <Badge variant="secondary" class="text-[10px] px-2 py-0.5 font-semibold">
                  {{ group.memberIds?.length || 0 }} {{ t('admin.notifications.members') }}
                </Badge>
              </div>
            </CardContent>
          </div>
        </div>
      </TabsContent>

      <!-- Settings Tab -->
      <TabsContent value="settings" class="space-y-6 pt-4">
        <Card>
          <CardHeader>
            <CardTitle>{{ t('admin.notificationSettings.title') }}</CardTitle>
            <CardDescription>{{ t('admin.notificationSettings.subtitle') }}</CardDescription>
          </CardHeader>
          <CardContent class="space-y-6">
            <div
              v-for="def in settingDefinitions"
              :key="def.sourceApp + def.actionType"
              class="flex flex-col gap-4 border-b last:border-0 pb-6 last:pb-0"
            >
              <div class="flex items-center justify-between">
                <div class="space-y-0.5">
                  <Label class="text-base font-medium">{{ def.label }}</Label>
                  <p class="text-sm text-muted-foreground">
                    Source: {{ def.sourceApp }} | Event: {{ def.actionType }}
                  </p>
                </div>
                <div class="flex items-center gap-2">
                  <Label>Active</Label>
                  <Checkbox
                    :checked="getSetting(def.sourceApp, def.actionType).isActive ?? true"
                    @update:checked="
                      (val: boolean) =>
                        saveSetting(
                          def.sourceApp,
                          def.actionType,
                          val,
                          getSetting(def.sourceApp, def.actionType).recipientRoles as string[],
                          getSetting(def.sourceApp, def.actionType).recipientGroups as string[]
                        )
                    "
                  />
                </div>
              </div>

              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div class="space-y-2">
                  <Label class="text-xs">Notify Roles</Label>
                  <MultiSelect
                    :modelValue="
                      (getSetting(def.sourceApp, def.actionType).recipientRoles as string[]) || []
                    "
                    @update:modelValue="
                      (val) =>
                        saveSetting(
                          def.sourceApp,
                          def.actionType,
                          getSetting(def.sourceApp, def.actionType).isActive,
                          val,
                          getSetting(def.sourceApp, def.actionType).recipientGroups as string[]
                        )
                    "
                    :options="roles.map((r) => ({ label: r.name, value: r.name }))"
                    placeholder="Select Roles..."
                  />
                </div>
                <div class="space-y-2">
                  <Label class="text-xs">Notify Groups</Label>
                  <MultiSelect
                    :modelValue="
                      (getSetting(def.sourceApp, def.actionType).recipientGroups as string[]) || []
                    "
                    @update:modelValue="
                      (val) =>
                        saveSetting(
                          def.sourceApp,
                          def.actionType,
                          getSetting(def.sourceApp, def.actionType).isActive,
                          getSetting(def.sourceApp, def.actionType).recipientRoles as string[],
                          val
                        )
                    "
                    :options="groups.map((g) => ({ label: g.name, value: g.id }))"
                    placeholder="Select Groups..."
                  />
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      </TabsContent>
    </Tabs>

    <!-- Broadcast Dialog -->
    <Dialog v-model:open="isBroadcastDialogOpen">
      <DialogContent class="sm:max-w-5xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>{{ t('admin.notifications.sendManualBroadcast') }}</DialogTitle>
          <DialogDescription>{{
            t('admin.notifications.sendBroadcastDescription')
          }}</DialogDescription>
        </DialogHeader>

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 py-4">
          <!-- Left Column: Form -->
          <div class="space-y-4">
            <div class="space-y-2">
              <Label>{{ t('admin.notifications.notificationTitle') }}</Label>
              <Input
                v-model="broadcastForm.title"
                :placeholder="t('admin.notifications.titlePlaceholder')"
              />
            </div>
            <div class="space-y-2">
              <Label>{{ t('admin.notifications.message') }}</Label>
              <Textarea
                v-model="broadcastForm.message"
                :placeholder="t('admin.notifications.messagePlaceholder')"
                rows="4"
              />
            </div>

            <!-- Recipients Section -->
            <div class="space-y-4 border-t pt-4">
              <h3 class="text-sm font-semibold">{{ t('admin.notifications.recipients') }}</h3>
              <div class="space-y-2">
                <Label>Recipients (Roles)</Label>
                <MultiSelect
                  v-model="broadcastForm.recipientRoles"
                  :options="roles.map((r) => ({ label: r.name, value: r.name }))"
                  placeholder="Select Roles..."
                />
              </div>
              <div class="space-y-2">
                <Label>Recipients (Groups)</Label>
                <MultiSelect
                  v-model="broadcastForm.recipientGroups"
                  :options="groups.map((g) => ({ label: g.name, value: g.id }))"
                  placeholder="Select Groups..."
                />
              </div>
              <div class="space-y-2">
                <Label>Recipients (Users)</Label>
                <MultiSelect
                  v-model="broadcastForm.recipientUsers"
                  :options="
                    users.map((u) => ({
                      label: u.displayName || u.username || 'User',
                      value: u.id,
                    }))
                  "
                  placeholder="Select Users..."
                />
              </div>
            </div>
          </div>

          <!-- Right Column: Preview -->
          <div class="space-y-4">
            <div class="sticky top-0 space-y-4">
              <!-- Type Selection -->
              <div class="space-y-2">
                <Label>{{ t('admin.notifications.type') }}</Label>
                <Select v-model="broadcastForm.type">
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="INFO">INFO</SelectItem>
                    <SelectItem value="SUCCESS">SUCCESS</SelectItem>
                    <SelectItem value="WARNING">WARNING</SelectItem>
                    <SelectItem value="ERROR">ERROR</SelectItem>
                    <SelectItem value="REQUEST">REQUEST</SelectItem>
                    <SelectItem value="APPROVE">APPROVE</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <!-- Action URL (Optional) -->
              <div class="space-y-2">
                <Label>Action URL (Optional)</Label>
                <Input
                  v-model="broadcastForm.actionUrl"
                  placeholder="https://example.com/approval/123"
                  type="url"
                />
                <p class="text-xs text-muted-foreground">
                  Add a link for users to take action (e.g., approval page)
                </p>
              </div>

              <!-- Preview Label -->
              <h3 class="text-sm font-semibold">ตัวอย่างการแจ้งเตือน</h3>

              <!-- Preview Card -->
              <div
                class="flex w-full items-start gap-4 rounded-md border bg-white p-4 shadow-lg transition-all duration-200"
                :class="[
                  broadcastForm.type === 'ERROR' ? 'border-red-500/20' : '',
                  broadcastForm.type === 'SUCCESS' ? 'border-green-500/20' : '',
                  broadcastForm.type === 'WARNING' ? 'border-yellow-500/20' : '',
                  broadcastForm.type === 'INFO' ? 'border-blue-500/20' : '',
                  broadcastForm.type === 'REQUEST' ? 'border-purple-500/20' : '',
                  broadcastForm.type === 'APPROVE' ? 'border-teal-500/20' : '',
                ]"
              >
                <!-- Icon -->
                <div class="mt-0.5">
                  <CheckCircle2
                    v-if="broadcastForm.type === 'SUCCESS' || broadcastForm.type === 'APPROVE'"
                    :class="[
                      'h-5 w-5',
                      broadcastForm.type === 'SUCCESS' ? 'text-green-600' : 'text-teal-600',
                    ]"
                  />
                  <AlertCircle
                    v-else-if="broadcastForm.type === 'ERROR'"
                    class="h-5 w-5 text-red-600"
                  />
                  <AlertTriangle
                    v-else-if="broadcastForm.type === 'WARNING'"
                    class="h-5 w-5 text-yellow-600"
                  />
                  <Info v-else class="h-5 w-5 text-blue-600" />
                </div>

                <!-- Content -->
                <div class="flex-1 grid gap-1">
                  <div
                    class="font-semibold"
                    :class="[
                      broadcastForm.type === 'SUCCESS' ? 'text-green-600' : '',
                      broadcastForm.type === 'APPROVE' ? 'text-teal-600' : '',
                      broadcastForm.type === 'ERROR' ? 'text-red-600' : '',
                      broadcastForm.type === 'WARNING' ? 'text-yellow-600' : '',
                      broadcastForm.type === 'INFO' ? 'text-blue-600' : '',
                      broadcastForm.type === 'REQUEST' ? 'text-purple-600' : '',
                    ]"
                  >
                    {{ broadcastForm.title || 'ชื่อการแจ้งเตือน' }}
                  </div>
                  <div class="text-sm text-gray-600 break-words">
                    {{ broadcastForm.message || 'ข้อความการแจ้งเตือนจะแสดงที่นี่...' }}
                  </div>
                </div>

                <!-- Action Button -->
                <Button
                  size="sm"
                  :class="[
                    'h-8 px-3 text-xs font-medium text-white hover:opacity-90 transition-opacity',
                    broadcastForm.type === 'SUCCESS' ? 'bg-green-600' : '',
                    broadcastForm.type === 'APPROVE' ? 'bg-teal-600' : '',
                    broadcastForm.type === 'ERROR' ? 'bg-red-600' : '',
                    broadcastForm.type === 'WARNING' ? 'bg-yellow-600' : '',
                    broadcastForm.type === 'INFO' ? 'bg-blue-600' : '',
                    broadcastForm.type === 'REQUEST' ? 'bg-purple-600' : '',
                  ]"
                >
                  View
                </Button>
              </div>

              <!-- Preview Info -->
              <div class="mt-4 p-3 bg-muted rounded-lg text-xs space-y-1">
                <p class="font-semibold">หมายเหตุ:</p>
                <p>• การแจ้งเตือนจะแสดงในรูปแบบนี้</p>
                <p>• สีจะเปลี่ยนตามประเภทที่เลือก</p>
              </div>
            </div>
          </div>
        </div>
        <DialogFooter>
          <Button variant="outline" @click="isBroadcastDialogOpen = false">{{
            t('common.cancel')
          }}</Button>
          <Button @click="handleSendBroadcast">{{ t('admin.notifications.sendBroadcast') }}</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
    <!-- Group Dialog -->
    <Dialog v-model:open="isGroupDialogOpen">
      <DialogContent>
        <DialogHeader>
          <DialogTitle>{{
            editingGroup ? t('admin.notifications.editGroup') : t('admin.notifications.newGroup')
          }}</DialogTitle>
        </DialogHeader>
        <div class="space-y-4 py-4">
          <div class="space-y-2">
            <Label>{{ t('admin.notifications.groupName') }}</Label>
            <Input v-model="groupForm.name" />
          </div>
          <div class="space-y-2">
            <Label>{{ t('admin.notifications.description') }}</Label>
            <Textarea v-model="groupForm.description" rows="3" />
          </div>

          <!-- Members Selection -->
          <div class="space-y-2">
            <Label>{{ t('admin.notifications.members') }}</Label>
            <Select
              :model-value="''"
              @update:model-value="
                (val) => {
                  if (val && !groupForm.memberIds?.includes(val)) {
                    groupForm.memberIds = [...(groupForm.memberIds || []), val];
                  }
                }
              "
            >
              <SelectTrigger>
                <SelectValue :placeholder="t('admin.notifications.selectUsersPlaceholder')" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem
                  v-for="user in users"
                  :key="user.id"
                  :value="user.id"
                  :disabled="groupForm.memberIds?.includes(user.id)"
                >
                  <div class="flex items-center gap-2">
                    <Avatar class="w-5 h-5">
                      <AvatarImage :src="user.avatar || ''" />
                      <AvatarFallback>{{ user.firstName?.charAt(0) || 'U' }}</AvatarFallback>
                    </Avatar>
                    <span>{{ user.displayName || user.email }}</span>
                    <span v-if="user.department" class="text-xs text-muted-foreground"
                      >({{ user.department }})</span
                    >
                  </div>
                </SelectItem>
              </SelectContent>
            </Select>

            <!-- Selected Members Badges -->
            <div
              v-if="groupForm.memberIds && groupForm.memberIds.length > 0"
              class="flex flex-wrap gap-2 mt-2 p-2 border rounded-md bg-muted/50 max-h-32 overflow-y-auto"
            >
              <Badge
                v-for="userId in groupForm.memberIds"
                :key="userId"
                variant="secondary"
                class="gap-1 pl-1 pr-2 py-1 items-center"
              >
                <Avatar class="w-4 h-4 mr-1">
                  <AvatarImage :src="getUserAvatar(userId)" />
                  <AvatarFallback class="text-[8px]">U</AvatarFallback>
                </Avatar>
                {{
                  users.find((u) => u.id === userId)?.displayName ||
                  users.find((u) => u.id === userId)?.email
                }}
                <button
                  @click="groupForm.memberIds = groupForm.memberIds.filter((id) => id !== userId)"
                  class="ml-1 text-muted-foreground hover:text-destructive transition-colors rounded-full p-0.5"
                >
                  <div class="h-3 w-3 flex items-center justify-center">×</div>
                </button>
              </Badge>
            </div>
          </div>

          <!-- Icon Selection -->
          <div class="space-y-2">
            <Label>Icon</Label>
            <div class="flex flex-wrap gap-3">
              <div
                v-for="icon in AVAILABLE_ICONS"
                :key="icon"
                @click="groupForm.icon = icon"
                class="cursor-pointer p-2 rounded-lg border-2 transition-all hover:bg-muted"
                :class="
                  groupForm.icon === icon
                    ? 'border-primary bg-primary/10 text-primary'
                    : 'border-transparent bg-muted/50 text-muted-foreground'
                "
              >
                <component :is="ICON_MAP[icon]" class="w-5 h-5" />
              </div>
            </div>
          </div>

          <!-- Color Selection -->
          <div class="space-y-2">
            <Label>Color</Label>
            <div class="flex flex-wrap gap-3">
              <div
                v-for="color in AVAILABLE_COLORS"
                :key="color"
                @click="groupForm.color = color"
                class="h-8 w-8 rounded-full cursor-pointer transition-all hover:scale-110 ring-2 ring-offset-2"
                :class="[
                  color.replace('bg-', 'bg-'),
                  groupForm.color === color ? 'ring-primary' : 'ring-transparent',
                ]"
              ></div>
            </div>
          </div>
        </div>
        <DialogFooter>
          <Button variant="outline" @click="isGroupDialogOpen = false">{{
            t('common.cancel')
          }}</Button>
          <Button @click="handleSaveGroup">{{ t('admin.notifications.saveGroup') }}</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>

    <!-- Delete Confirmation Dialog -->
    <AlertDialog v-model:open="isDeleteDialogOpen">
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>{{ t('common.deleteConfirm') }}</AlertDialogTitle>
          <AlertDialogDescription>
            {{
              deleteTarget?.type === 'broadcast'
                ? t('admin.notifications.deleteConfirmMessage')
                : t('admin.notifications.deleteGroupMessage')
            }}
            <span class="font-semibold">{{ deleteTarget?.name }}</span
            >?
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel>{{ t('common.cancel') }}</AlertDialogCancel>
          <AlertDialogAction
            @click="handleDelete"
            class="bg-destructive text-destructive-foreground hover:bg-destructive/90"
          >
            {{ t('common.delete') }}
          </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>

    <!-- Bulk Delete Confirmation Dialog -->
    <AlertDialog v-model:open="bulkDeleteDialogOpen">
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>Delete Multiple Broadcasts</AlertDialogTitle>
          <AlertDialogDescription>
            Are you sure you want to delete
            <strong>{{ broadcastsToBulkDelete.length }}</strong> broadcast(s)?
            <br />
            This action cannot be undone.
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel>Cancel</AlertDialogCancel>
          <AlertDialogAction
            class="bg-destructive hover:bg-destructive/90"
            @click="executeBulkDeleteBroadcasts"
          >
            Delete {{ broadcastsToBulkDelete.length }} Broadcast(s)
          </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  </div>
</template>
