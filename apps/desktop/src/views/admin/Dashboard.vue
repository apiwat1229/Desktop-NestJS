<script setup lang="ts">
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Activity, Calendar, ShoppingCart, Users } from 'lucide-vue-next';

// Placeholder stats - in a real app, fetch these from API
const stats = [
  { title: 'Total Users', value: '1,234', icon: Users, change: '+12%', color: 'text-blue-600' },
  {
    title: 'Active Suppliers',
    value: '56',
    icon: ShoppingCart,
    change: '+3%',
    color: 'text-green-600',
  },
  { title: 'Today Bookings', value: '23', icon: Calendar, change: '-5%', color: 'text-orange-600' },
  { title: 'System Status', value: '98%', icon: Activity, change: '+1%', color: 'text-purple-600' },
];
</script>

<template>
  <div class="space-y-6">
    <div>
      <h2 class="text-3xl font-bold tracking-tight">Admin Dashboard</h2>
      <p class="text-muted-foreground">Overview of system metrics and performance.</p>
    </div>

    <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
      <Card v-for="(stat, index) in stats" :key="index">
        <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle class="text-sm font-medium">
            {{ stat.title }}
          </CardTitle>
          <component :is="stat.icon" :class="['h-4 w-4 text-muted-foreground', stat.color]" />
        </CardHeader>
        <CardContent>
          <div class="text-2xl font-bold">{{ stat.value }}</div>
          <p class="text-xs text-muted-foreground">{{ stat.change }} from last month</p>
        </CardContent>
      </Card>
    </div>

    <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
      <Card class="col-span-4">
        <CardHeader>
          <CardTitle>Recent Activity</CardTitle>
        </CardHeader>
        <CardContent>
          <div class="space-y-4">
            <div class="flex items-center">
              <div class="ml-4 space-y-1">
                <p class="text-sm font-medium leading-none">System Maintenance</p>
                <p class="text-sm text-muted-foreground">Scheduled for tonight at 2:00 AM</p>
              </div>
              <div class="ml-auto font-medium">+10m ago</div>
            </div>
            <!-- More items can be added here -->
          </div>
        </CardContent>
      </Card>

      <Card class="col-span-3">
        <CardHeader>
          <CardTitle>Quick Actions</CardTitle>
        </CardHeader>
        <CardContent>
          <p class="text-sm text-muted-foreground">
            Manage users, roles, and system settings directly.
          </p>
        </CardContent>
      </Card>
    </div>
  </div>
</template>
