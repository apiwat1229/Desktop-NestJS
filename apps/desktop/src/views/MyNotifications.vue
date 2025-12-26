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
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from '@/components/ui/tooltip';
import { notificationsApi } from '@/services/notifications';
import { socketService } from '@/services/socket';
import type { NotificationDto } from '@my-app/types';
import type { ColumnDef } from '@tanstack/vue-table';
import { format } from 'date-fns';
import { Bell, Check, CheckCheck, Trash2 } from 'lucide-vue-next';
import { computed, h, onMounted, onUnmounted, ref } from 'vue';
import { useRouter } from 'vue-router';
import { toast } from 'vue-sonner';

const router = useRouter();
const notifications = ref<NotificationDto[]>([]);
const isLoading = ref(true);
const filter = ref<'all' | 'unread'>('all');

// Delete confirmation
const deleteDialogOpen = ref(false);
const notificationToDelete = ref<{ id: string; title: string } | null>(null);

// Mark as read confirmation
const markReadDialogOpen = ref(false);
const notificationToMarkRead = ref<{ id: string; title: string } | null>(null);

// Mark all as read confirmation
const markAllReadDialogOpen = ref(false);

// Bulk delete confirmation
const bulkDeleteDialogOpen = ref(false);
const notificationsToBulkDelete = ref<NotificationDto[]>([]);

const confirmDelete = (id: string, title: string) => {
  notificationToDelete.value = { id, title };
  deleteDialogOpen.value = true;
};

const confirmMarkAsRead = (id: string, title: string) => {
  notificationToMarkRead.value = { id, title };
  markReadDialogOpen.value = true;
};

const confirmMarkAllAsRead = () => {
  markAllReadDialogOpen.value = true;
};

const executeDelete = async () => {
  if (!notificationToDelete.value) return;
  await handleDelete(notificationToDelete.value.id);
  deleteDialogOpen.value = false;
  notificationToDelete.value = null;
};

const executeMarkAsRead = async () => {
  if (!notificationToMarkRead.value) return;
  await handleMarkAsRead(notificationToMarkRead.value.id);
  markReadDialogOpen.value = false;
  notificationToMarkRead.value = null;
};

const executeMarkAllAsRead = async () => {
  await handleMarkAllAsRead();
  markAllReadDialogOpen.value = false;
};

const fetchNotifications = async () => {
  isLoading.value = true;
  try {
    const response = await notificationsApi.getAll();
    console.log('[MyNotifications] Fetched notifications:', response.data);
    notifications.value = response.data;
  } catch (error) {
    console.error('Failed to fetch notifications:', error);
    toast.error('Failed to load notifications');
  } finally {
    isLoading.value = false;
  }
};

const handleMarkAsRead = async (id: string) => {
  try {
    await notificationsApi.markAsRead(id);
    const notif = notifications.value.find((n) => n.id === id);
    if (notif) notif.isRead = true;
    toast.success('Marked as read');
  } catch (error) {
    toast.error('Failed to mark as read');
  }
};

const handleMarkAllAsRead = async () => {
  try {
    await notificationsApi.markAllAsRead();
    notifications.value.forEach((n) => (n.isRead = true));
    toast.success('All marked as read');
  } catch (error) {
    toast.error('Failed to mark all as read');
  }
};

const handleDelete = async (id: string) => {
  try {
    await notificationsApi.delete(id);
    notifications.value = notifications.value.filter((n) => n.id !== id);
    toast.success('Notification removed');
  } catch (error) {
    console.error('Failed to delete notification', error);
    toast.error('Failed to remove notification');
  }
};

const handleBulkDelete = async (selectedNotifications: NotificationDto[]) => {
  console.log('[handleBulkDelete] Called with:', selectedNotifications.length, 'notifications');
  if (selectedNotifications.length === 0) return;

  // Store selected notifications and open confirmation dialog
  notificationsToBulkDelete.value = selectedNotifications;
  bulkDeleteDialogOpen.value = true;
  console.log('[handleBulkDelete] Dialog opened');
};

const executeBulkDelete = async () => {
  if (notificationsToBulkDelete.value.length === 0) return;

  try {
    await Promise.all(notificationsToBulkDelete.value.map((n) => notificationsApi.delete(n.id)));
    const deletedIds = notificationsToBulkDelete.value.map((n) => n.id);
    notifications.value = notifications.value.filter((n) => !deletedIds.includes(n.id));
    toast.success(`${notificationsToBulkDelete.value.length} notification(s) deleted`);
    bulkDeleteDialogOpen.value = false;
    notificationsToBulkDelete.value = [];
  } catch (error) {
    console.error('Failed to delete notifications:', error);
    toast.error('Failed to delete some notifications');
  }
};

const handleNotificationClick = async (notification: NotificationDto) => {
  if (!notification.isRead) {
    await handleMarkAsRead(notification.id);
  }
  if (notification.actionUrl) {
    router.push(notification.actionUrl);
  }
};

const filteredNotifications = computed(() => {
  if (filter.value === 'unread') {
    return notifications.value.filter((n) => !n.isRead);
  }
  return notifications.value;
});

const unreadCount = computed(() => notifications.value.filter((n) => !n.isRead).length);

const formatTime = (dateStr: string | Date) => {
  return format(new Date(dateStr), 'dd-MMM-yyyy, HH:mm:ss');
};

// Column Definitions
const notificationColumns: ColumnDef<NotificationDto>[] = [
  {
    accessorKey: 'type',
    header: 'Type',
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
      };
      const config = variants[type] || variants.INFO;
      return h(
        Badge,
        {
          variant: config.variant,
          class: config.class,
        },
        () => type
      );
    },
  },
  {
    accessorKey: 'title',
    header: 'Title',
    cell: ({ row }) => {
      const isRead = row.original.isRead;
      return h(
        'div',
        {
          class: 'flex items-center gap-2 cursor-pointer group',
          onClick: () => handleNotificationClick(row.original),
        },
        [
          !isRead ? h('div', { class: 'w-2 h-2 rounded-full bg-primary animate-pulse' }) : null,
          h(
            'span',
            {
              class: [
                isRead ? 'font-medium text-muted-foreground' : 'font-semibold',
                'group-hover:underline text-foreground',
              ],
            },
            row.original.title
          ),
        ]
      );
    },
  },
  {
    accessorKey: 'message',
    header: 'Message',
    cell: ({ row }) => {
      // Simple formatter to bold key parts of the message
      const formatMessage = (msg: string) => {
        return msg
          .replace(/(Booking \w+)/, '<span class="font-bold text-primary">$1</span>')
          .replace(/\((.*?)\)/, '<span class="text-muted-foreground">($1)</span>')
          .replace(/(at \d{2}:\d{2}-\d{2}:\d{2})/, '<span class="font-medium">$1</span>');
      };

      return h(TooltipProvider, { delayDuration: 0 }, () =>
        h(Tooltip, {}, () => [
          h(TooltipTrigger, { asChild: true }, () =>
            h(
              'div',
              { class: 'max-w-md truncate text-muted-foreground text-sm cursor-help' },
              row.original.message
            )
          ),
          h(
            TooltipContent,
            {
              class:
                'max-w-prose p-4 text-sm leading-relaxed shadow-lg border-primary/20 bg-popover',
            },
            () => h('div', { innerHTML: formatMessage(row.original.message) })
          ),
        ])
      );
    },
  },
  {
    accessorKey: 'createdAt',
    header: 'Date',
    cell: ({ row }) => {
      return h(
        'span',
        { class: 'text-sm text-muted-foreground' },
        formatTime(row.original.createdAt)
      );
    },
  },
  {
    id: 'actions',
    header: 'Actions',
    cell: ({ row }) => {
      const notification = row.original;
      return h('div', { class: 'flex gap-1' }, [
        !notification.isRead
          ? h(
              Button,
              {
                variant: 'ghost',
                size: 'icon',
                class: 'h-8 w-8 text-primary hover:text-primary hover:bg-primary/10',
                onClick: () => confirmMarkAsRead(notification.id, notification.title),
                title: 'Mark as read',
              },
              () => h(Check, { class: 'w-4 h-4' })
            )
          : null,
        h(
          Button,
          {
            variant: 'ghost',
            size: 'icon',
            class: 'h-8 w-8 text-destructive hover:text-destructive hover:bg-destructive/10',
            onClick: () => confirmDelete(notification.id, notification.title),
            title: 'Delete',
          },
          () => h(Trash2, { class: 'w-4 h-4' })
        ),
      ]);
    },
  },
];

onMounted(() => {
  fetchNotifications();

  // Real-time listener
  socketService.on('notification', (newNotification: any) => {
    console.log('[MyNotifications] Real-time update received:', newNotification);
    if (newNotification) {
      notifications.value.unshift(newNotification);
    }
  });
});

onUnmounted(() => {
  socketService.off('notification');
});
</script>

<template>
  <div class="relative z-0">
    <div class="space-y-6">
      <!-- Dynamic Header Card -->
      <div
        class="rounded-xl border border-border/60 bg-card/40 backdrop-blur-xl p-6 relative overflow-hidden shadow-sm z-0"
      >
        <div class="absolute top-1/2 right-12 -translate-y-1/2 pointer-events-none opacity-[0.03]">
          <Bell class="w-64 h-64 rotate-12" />
        </div>

        <div class="flex flex-col md:flex-row items-center justify-between gap-6 relative z-10">
          <div class="flex items-center gap-4 w-full md:w-auto">
            <div
              class="h-12 w-12 flex items-center justify-center bg-blue-100/50 dark:bg-blue-900/30 rounded-lg text-blue-600 dark:text-blue-400 shadow-sm backdrop-blur-sm"
            >
              <Bell class="h-6 w-6" />
            </div>
            <div>
              <h1 class="text-xl font-bold tracking-tight text-foreground">My Notifications</h1>
              <p class="text-sm text-muted-foreground mt-0.5">
                Stay updated with your latest system alerts and messages.
              </p>
            </div>
          </div>

          <!-- Stats & Actions -->
          <div class="flex flex-1 items-center justify-end gap-8 md:gap-12 text-center">
            <div>
              <p class="text-[10px] font-bold text-muted-foreground uppercase tracking-widest mb-1">
                Total Notifications
              </p>
              <p class="text-2xl font-bold text-foreground">{{ notifications.length }}</p>
            </div>

            <div class="flex items-center gap-2">
              <Button
                class="gap-2 bg-green-600 hover:bg-green-700"
                @click="confirmMarkAllAsRead"
                :disabled="unreadCount === 0"
              >
                <CheckCheck class="w-4 h-4" />
                Mark all as read
              </Button>
            </div>
          </div>
        </div>
      </div>

      <!-- Content Card with Tabs -->
      <div class="bg-card rounded-lg border relative z-0">
        <div class="border-b px-6 py-3">
          <div class="flex items-center gap-2">
            <Button
              variant="ghost"
              size="sm"
              :class="{ 'bg-muted': filter === 'all' }"
              @click="filter = 'all'"
            >
              All
              <Badge variant="secondary" class="ml-2">{{ notifications.length }}</Badge>
            </Button>
            <Button
              variant="ghost"
              size="sm"
              :class="{ 'bg-muted': filter === 'unread' }"
              @click="filter = 'unread'"
            >
              Unread
              <Badge v-if="unreadCount > 0" class="ml-2 bg-primary text-primary-foreground">
                {{ unreadCount }}
              </Badge>
            </Button>
          </div>
        </div>

        <!-- Data Table -->
        <div class="p-6">
          <DataTable
            :columns="notificationColumns"
            :data="filteredNotifications"
            enable-selection
            @delete-selected="handleBulkDelete"
          />
        </div>
      </div>
    </div>

    <!-- Delete Confirmation Dialog -->
    <AlertDialog v-model:open="deleteDialogOpen">
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>Delete Notification</AlertDialogTitle>
          <AlertDialogDescription>
            Are you sure you want to delete "{{ notificationToDelete?.title }}"?
            <br />
            This action cannot be undone.
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel>Cancel</AlertDialogCancel>
          <AlertDialogAction class="bg-destructive hover:bg-destructive/90" @click="executeDelete">
            Delete
          </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>

    <!-- Mark as Read Confirmation Dialog -->
    <AlertDialog v-model:open="markReadDialogOpen">
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>Mark as Read</AlertDialogTitle>
          <AlertDialogDescription>
            Are you sure you want to mark "{{ notificationToMarkRead?.title }}" as read?
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel>Cancel</AlertDialogCancel>
          <AlertDialogAction @click="executeMarkAsRead"> Mark as Read </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>

    <!-- Mark All as Read Confirmation Dialog -->
    <AlertDialog v-model:open="markAllReadDialogOpen">
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>Mark All as Read</AlertDialogTitle>
          <AlertDialogDescription>
            Are you sure you want to mark all {{ unreadCount }} unread notifications as read?
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel>Cancel</AlertDialogCancel>
          <AlertDialogAction @click="executeMarkAllAsRead"> Mark All as Read </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>

    <!-- Bulk Delete Confirmation Dialog -->
    <AlertDialog v-model:open="bulkDeleteDialogOpen">
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>Delete Multiple Notifications</AlertDialogTitle>
          <AlertDialogDescription>
            Are you sure you want to delete
            <strong>{{ notificationsToBulkDelete.length }}</strong> notification(s)?
            <br />
            This action cannot be undone.
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel>Cancel</AlertDialogCancel>
          <AlertDialogAction
            class="bg-destructive hover:bg-destructive/90"
            @click="executeBulkDelete"
          >
            Delete {{ notificationsToBulkDelete.length }} Notification(s)
          </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  </div>
</template>
