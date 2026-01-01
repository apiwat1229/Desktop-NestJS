<script setup lang="ts">
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import { approvalsApi } from '@/services/approvals';
import { bookingsApi } from '@/services/bookings';
import { notificationsApi } from '@/services/notifications';
import { usersApi } from '@/services/users';
import { format } from 'date-fns';
import { Activity, AlertCircle, Bell, Calendar, CheckCircle, Clock, Users } from 'lucide-vue-next';
import { onMounted, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter } from 'vue-router';

const router = useRouter();
const { t } = useI18n();

// State
const stats = ref({
  bookingsToday: 0,
  pendingApprovals: 0,
  unreadNotifications: 0,
  totalUsers: 0,
});

const recentApprovals = ref<any[]>([]);
const systemHealth = ref('Healthy');
const isLoading = ref(true);

const fetchDashboardData = async () => {
  isLoading.value = true;
  try {
    const today = new Date();

    // Parallel Fetch
    const [bookingsData, approvalsRes, notificationsRes, usersData] = await Promise.all([
      bookingsApi.getAll({ date: titleDate(today) }), // Note: check API date format if needed, simplistic strictly for count
      approvalsApi.getAll({ status: 'PENDING' }),
      notificationsApi.getAll(),
      usersApi.getAll(),
    ]);

    // Calculate Stats
    // Bookings & Users APIs return data directly
    stats.value.bookingsToday = Array.isArray(bookingsData) ? bookingsData.length : 0;

    // Approvals & Notifications APIs return Axios Response
    stats.value.pendingApprovals = Array.isArray(approvalsRes.data) ? approvalsRes.data.length : 0;

    // Notifications
    stats.value.unreadNotifications = Array.isArray(notificationsRes.data)
      ? notificationsRes.data.filter((n: any) => !n.isRead).length
      : 0;

    // Users
    stats.value.totalUsers = Array.isArray(usersData) ? usersData.length : 0;

    // Recent Activity (Approvals)
    if (Array.isArray(approvalsRes.data)) {
      // Fetch ALL approvals for history list if possible, but the API call above was filtered PENDING.
      // Let's fetch recent history separately or just show pending ones.
      // Better: Fetch ALL approvals limited to 5 for the "Recent Activity" list.
      const allApprovals = await approvalsApi.getAll(); // Unfiltered
      recentApprovals.value = Array.isArray(allApprovals.data)
        ? allApprovals.data
            .sort(
              (a: any, b: any) =>
                new Date(b.submittedAt).getTime() - new Date(a.submittedAt).getTime()
            )
            .slice(0, 5)
        : [];
    }
  } catch (error) {
    console.error('Failed to fetch dashboard data:', error);
  } finally {
    isLoading.value = false;
  }
};

// Helper for date param (assuming simplified YYYY-MM-DD or similar if needed)
// Actually BookingsService uses `new Date(date)` so string ISO works.
const titleDate = (date: Date) => date.toISOString().split('T')[0];

const formatTime = (dateStr: string) => format(new Date(dateStr), 'dd MMM, HH:mm');

onMounted(() => {
  fetchDashboardData();

  // Real-time refresh could be added here via socketService
});
</script>

<template>
  <div class="p-8 space-y-8 max-w-7xl mx-auto">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-3xl font-bold tracking-tight">{{ t('admin.dashboard.title') }}</h1>
        <p class="text-muted-foreground">
          {{ t('admin.dashboard.subtitle') }}
        </p>
      </div>
      <div class="flex items-center gap-2">
        <Badge variant="outline" class="gap-1 px-3 py-1">
          <div class="w-2 h-2 rounded-full bg-green-500 animate-pulse"></div>
          {{ t('admin.dashboard.systemHealth.system') }} {{ systemHealth }}
        </Badge>
        <Button variant="outline" size="sm" @click="fetchDashboardData">
          {{ t('admin.dashboard.refresh') }}
        </Button>
      </div>
    </div>

    <!-- Stats Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      <!-- Bookings Card -->
      <Card
        class="hover:shadow-md transition-shadow cursor-pointer"
        @click="router.push('/admin/bookings')"
      >
        <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle class="text-sm font-medium">{{
            t('admin.dashboard.bookingsToday')
          }}</CardTitle>
          <Calendar class="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div class="text-2xl font-bold">{{ stats.bookingsToday }}</div>
          <p class="text-xs text-muted-foreground">{{ t('admin.dashboard.bookingsTodayDesc') }}</p>
        </CardContent>
      </Card>

      <!-- Approvals Card -->
      <Card
        class="hover:shadow-md transition-shadow cursor-pointer"
        @click="router.push('/admin/approvals')"
      >
        <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle class="text-sm font-medium">{{
            t('admin.dashboard.pendingApprovals')
          }}</CardTitle>
          <CheckCircle class="h-4 w-4 text-orange-500" />
        </CardHeader>
        <CardContent>
          <div class="text-2xl font-bold text-orange-600">{{ stats.pendingApprovals }}</div>
          <p class="text-xs text-muted-foreground">
            {{ t('admin.dashboard.pendingApprovalsDesc') }}
          </p>
        </CardContent>
      </Card>

      <!-- Notifications Card -->
      <Card
        class="hover:shadow-md transition-shadow cursor-pointer"
        @click="router.push('/admin/notifications')"
      >
        <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle class="text-sm font-medium">{{ t('admin.dashboard.unreadAlerts') }}</CardTitle>
          <Bell class="h-4 w-4 text-blue-500" />
        </CardHeader>
        <CardContent>
          <div class="text-2xl font-bold text-blue-600">{{ stats.unreadNotifications }}</div>
          <p class="text-xs text-muted-foreground">{{ t('admin.dashboard.unreadAlertsDesc') }}</p>
        </CardContent>
      </Card>

      <!-- Users Card -->
      <Card
        class="hover:shadow-md transition-shadow cursor-pointer"
        @click="router.push('/admin/users')"
      >
        <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle class="text-sm font-medium">{{ t('admin.dashboard.totalUsers') }}</CardTitle>
          <Users class="h-4 w-4 text-purple-500" />
        </CardHeader>
        <CardContent>
          <div class="text-2xl font-bold">{{ stats.totalUsers }}</div>
          <p class="text-xs text-muted-foreground">{{ t('admin.dashboard.totalUsersDesc') }}</p>
        </CardContent>
      </Card>
    </div>

    <!-- Recent Activity & System Status -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
      <!-- Recent Approvals (Takes up 2 cols) -->
      <Card class="lg:col-span-2">
        <CardHeader>
          <CardTitle>{{ t('admin.dashboard.recentActivity') }}</CardTitle>
          <CardDescription>{{ t('admin.dashboard.recentActivityDesc') }}</CardDescription>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>{{ t('admin.dashboard.table.type') }}</TableHead>
                <TableHead>{{ t('admin.dashboard.table.requester') }}</TableHead>
                <TableHead>{{ t('admin.dashboard.table.status') }}</TableHead>
                <TableHead class="text-right">{{ t('admin.dashboard.table.time') }}</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              <TableRow v-for="item in recentApprovals" :key="item.id">
                <TableCell class="font-medium">
                  {{ item.requestType }}
                </TableCell>
                <TableCell>
                  <div class="flex items-center gap-2">
                    <div
                      class="w-6 h-6 rounded-full bg-primary/10 flex items-center justify-center text-xs font-bold text-primary"
                    >
                      {{ item.requester?.displayName?.charAt(0) || 'U' }}
                    </div>
                    <span>{{ item.requester?.displayName }}</span>
                  </div>
                </TableCell>
                <TableCell>
                  <Badge
                    :variant="
                      item.status === 'PENDING'
                        ? 'outline'
                        : item.status === 'APPROVED'
                          ? 'default'
                          : 'destructive'
                    "
                  >
                    {{ item.status }}
                  </Badge>
                </TableCell>
                <TableCell class="text-right text-muted-foreground text-sm">
                  {{ formatTime(item.submittedAt) }}
                </TableCell>
              </TableRow>
              <TableRow v-if="recentApprovals.length === 0">
                <TableCell colspan="4" class="text-center py-8 text-muted-foreground">
                  {{ t('admin.dashboard.table.noActivity') }}
                </TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      <!-- System Health / Quick Links -->
      <div class="space-y-6">
        <Card>
          <CardHeader>
            <CardTitle>{{ t('admin.dashboard.systemHealth.title') }}</CardTitle>
            <CardDescription>{{ t('admin.dashboard.systemHealth.subtitle') }}</CardDescription>
          </CardHeader>
          <CardContent class="space-y-4">
            <div class="flex items-center justify-between">
              <span class="text-sm font-medium">{{
                t('admin.dashboard.systemHealth.database')
              }}</span>
              <Badge class="bg-green-500 hover:bg-green-600">{{
                t('admin.dashboard.systemHealth.connected')
              }}</Badge>
            </div>
            <div class="flex items-center justify-between">
              <span class="text-sm font-medium">{{
                t('admin.dashboard.systemHealth.apiServer')
              }}</span>
              <Badge class="bg-green-500 hover:bg-green-600">{{
                t('admin.dashboard.systemHealth.online')
              }}</Badge>
            </div>
            <div class="flex items-center justify-between">
              <span class="text-sm font-medium">{{
                t('admin.dashboard.systemHealth.socketIo')
              }}</span>
              <Badge class="bg-green-500 hover:bg-green-600">{{
                t('admin.dashboard.systemHealth.active')
              }}</Badge>
            </div>
            <div class="pt-4 border-t">
              <div class="flex items-center gap-2 text-xs text-muted-foreground">
                <Clock class="w-3 h-3" />
                <span>{{ t('admin.dashboard.systemHealth.lastCheck') }}</span>
              </div>
            </div>
          </CardContent>
        </Card>

        <!-- Quick Actions (Optional, maybe specific monitoring tools) -->
        <Card>
          <CardHeader>
            <CardTitle>{{ t('admin.dashboard.systemHealth.monitoringTools') }}</CardTitle>
          </CardHeader>
          <CardContent class="grid gap-2">
            <Button
              variant="ghost"
              class="justify-start gap-2"
              @click="router.push('/admin/analytics')"
            >
              <Activity class="w-4 h-4 text-blue-500" />
              {{ t('admin.dashboard.systemHealth.trafficAnalytics') }}
            </Button>
            <Button
              variant="ghost"
              class="justify-start gap-2"
              @click="router.push('/admin/notifications')"
            >
              <AlertCircle class="w-4 h-4 text-red-500" />
              {{ t('admin.dashboard.systemHealth.systemLogs') }}
            </Button>
          </CardContent>
        </Card>
      </div>
    </div>
  </div>
</template>
