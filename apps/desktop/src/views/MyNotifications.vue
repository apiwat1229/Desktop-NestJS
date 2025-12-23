<script setup lang="ts">
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { notificationsApi } from '@/services/notifications';
import { socketService } from '@/services/socket';
import type { NotificationDto } from '@my-app/types';
import { format } from 'date-fns';
import {
  AlertTriangle,
  Bell,
  Check,
  CheckCheck,
  Clock,
  Info,
  Trash2,
  XCircle,
} from 'lucide-vue-next';
import { computed, onMounted, onUnmounted, ref } from 'vue';
import { toast } from 'vue-sonner';

// const { t } = useI18n(); // access if needed later

const notifications = ref<NotificationDto[]>([]);
const isLoading = ref(true);
const filter = ref<'all' | 'unread'>('all');

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
    // Optimistic update
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

const filteredNotifications = computed(() => {
  if (filter.value === 'unread') {
    return notifications.value.filter((n) => !n.isRead);
  }
  return notifications.value;
});

const unreadCount = computed(() => notifications.value.filter((n) => !n.isRead).length);

const getIcon = (type: string) => {
  switch (type) {
    case 'SUCCESS':
      return Check;
    case 'WARNING':
      return AlertTriangle;
    case 'ERROR':
      return XCircle;
    default:
      return Info;
  }
};

const getTypeColor = (type: string) => {
  switch (type) {
    case 'SUCCESS':
      return 'text-green-500 bg-green-500/10';
    case 'WARNING':
      return 'text-yellow-500 bg-yellow-500/10';
    case 'ERROR':
      return 'text-destructive bg-destructive/10';
    default:
      return 'text-blue-500 bg-blue-500/10';
  }
};

const formatTime = (dateStr: string | Date) => {
  return format(new Date(dateStr), 'dd/MM/yyyy HH:mm');
};

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
  <div class="p-6 md:p-8 space-y-8 max-w-5xl mx-auto">
    <!-- Header -->
    <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
      <div>
        <h1 class="text-3xl font-bold tracking-tight text-foreground flex items-center gap-3">
          <div class="p-2 rounded-lg bg-primary/10 text-primary">
            <Bell class="w-6 h-6" />
          </div>
          My Notifications
        </h1>
        <p class="text-muted-foreground mt-1">
          Stay updated with your latest system alerts and messages.
        </p>
      </div>
      <div class="flex items-center gap-2">
        <Button
          variant="outline"
          size="sm"
          @click="handleMarkAllAsRead"
          :disabled="unreadCount === 0"
        >
          <CheckCheck class="w-4 h-4 mr-2" />
          Mark all as read
        </Button>
      </div>
    </div>

    <!-- Filters -->
    <div class="flex items-center gap-2 border-b pb-4">
      <Button
        variant="ghost"
        :class="filter === 'all' ? 'bg-muted text-foreground' : 'text-muted-foreground'"
        class="rounded-full px-4"
        @click="filter = 'all'"
      >
        All
        <Badge variant="secondary" class="ml-2 bg-background/50">{{ notifications.length }}</Badge>
      </Button>
      <Button
        variant="ghost"
        :class="filter === 'unread' ? 'bg-muted text-foreground' : 'text-muted-foreground'"
        class="rounded-full px-4"
        @click="filter = 'unread'"
      >
        Unread
        <Badge v-if="unreadCount > 0" variant="destructive" class="ml-2">{{ unreadCount }}</Badge>
      </Button>
    </div>

    <!-- Content -->
    <div v-if="isLoading" class="space-y-4">
      <Skeleton class="h-24 w-full rounded-xl" v-for="i in 3" :key="i" />
    </div>

    <div
      v-else-if="filteredNotifications.length === 0"
      class="text-center py-20 text-muted-foreground"
    >
      <div class="bg-muted/30 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
        <Bell class="w-8 h-8 opacity-50" />
      </div>
      <p class="text-lg font-medium">No notifications found</p>
      <p class="text-sm">You're all caught up!</p>
    </div>

    <div v-else class="space-y-3">
      <Card
        v-for="notification in filteredNotifications"
        :key="notification.id"
        class="transition-all duration-200 hover:shadow-md border-l-4"
        :class="[
          notification.isRead ? 'border-l-transparent opacity-80' : 'border-l-primary bg-primary/5',
        ]"
      >
        <CardContent class="p-4 flex items-start gap-4">
          <!-- Icon -->
          <div class="mt-1 p-2 rounded-full shrink-0" :class="getTypeColor(notification.type)">
            <component :is="getIcon(notification.type)" class="w-5 h-5" />
          </div>

          <!-- Text -->
          <div class="flex-1 min-w-0">
            <div class="flex justify-between items-start gap-2">
              <h3
                class="font-semibold text-base"
                :class="{ 'text-muted-foreground': notification.isRead }"
              >
                {{ notification.title }}
              </h3>
              <span class="text-xs text-muted-foreground whitespace-nowrap flex items-center gap-1">
                <Clock class="w-3 h-3" />
                {{ formatTime(notification.createdAt) }}
              </span>
            </div>
            <p class="text-sm text-muted-foreground mt-1 leading-relaxed">
              {{ notification.message }}
            </p>
          </div>

          <!-- Actions -->
          <div class="flex flex-col gap-1 self-center">
            <Button
              v-if="!notification.isRead"
              variant="ghost"
              size="icon"
              class="h-8 w-8 text-primary hover:text-primary hover:bg-primary/10"
              title="Mark as read"
              @click.stop="handleMarkAsRead(notification.id)"
            >
              <div class="w-2 h-2 rounded-full bg-primary" />
            </Button>
            <Button
              variant="ghost"
              size="icon"
              class="h-8 w-8 text-muted-foreground hover:text-destructive hover:bg-destructive/10"
              title="Remove"
              @click.stop="handleDelete(notification.id)"
            >
              <Trash2 class="w-4 h-4" />
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  </div>
</template>
```
