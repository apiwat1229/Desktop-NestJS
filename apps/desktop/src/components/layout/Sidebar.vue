<script setup lang="ts">
import { usePermissions } from '@/composables/usePermissions';
import { cn } from '@/lib/utils';
import {
  Activity,
  Bell,
  Calendar,
  ClipboardCheck,
  Layers,
  LayoutDashboard,
  Shield,
  Truck,
  Users,
} from 'lucide-vue-next';
import { computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRoute } from 'vue-router';

const route = useRoute();
const { hasPermission, isAdmin } = usePermissions();

const { t } = useI18n();

const allMenuGroups = computed(() => [
  {
    title: t('admin.sidebar.main'),
    items: [
      { name: t('admin.sidebar.dashboard'), path: '/admin', icon: LayoutDashboard }, // Public for admin panel
      {
        name: t('admin.sidebar.roles'),
        path: '/admin/roles',
        icon: Shield,
        permission: 'roles:read',
      },
      {
        name: t('admin.sidebar.users'),
        path: '/admin/users',
        icon: Users,
        permission: 'users:read',
      },
      {
        name: t('admin.sidebar.suppliers'),
        path: '/admin/suppliers',
        icon: Truck,
        permission: 'suppliers:read',
      },
      {
        name: t('admin.sidebar.rubberTypes'),
        path: '/admin/rubber-types',
        icon: Layers,
        permission: 'rubberTypes:read',
      },
      {
        name: t('admin.sidebar.notifications'),
        path: '/admin/notifications',
        icon: Bell,
        permission: 'notifications:read',
      },
      {
        name: t('admin.sidebar.bookingQueue'),
        path: '/bookings',
        icon: Calendar,
        permission: 'bookings:read',
      },
      {
        name: t('admin.sidebar.truckScale'),
        path: '/scale',
        icon: Truck,
        permission: 'bookings:read',
      },
      { name: t('admin.sidebar.approvals'), path: '/admin/approvals', icon: ClipboardCheck }, // Pending permission module
    ],
  },
  {
    title: t('admin.sidebar.system'),
    items: [{ name: t('admin.sidebar.analytics'), path: '/admin/analytics', icon: Activity }], // Pending permission module
  },
]);

const menuGroups = computed(() => {
  return allMenuGroups.value
    .map((group) => ({
      ...group,
      items: group.items.filter((item) => {
        // If no permission required, show it
        if (!item.permission) return true;
        // If admin, always show (unless logic changes)
        if (isAdmin.value) return true;
        // Otherwise check permission
        return hasPermission(item.permission);
      }),
    }))
    .filter((group) => group.items.length > 0); // Hide empty groups
});
</script>

<template>
  <aside class="w-64 h-full flex flex-col">
    <nav class="flex-1 p-4 space-y-6 overflow-y-auto">
      <div v-for="(group, index) in menuGroups" :key="index">
        <h4 class="px-2 text-xs font-semibold text-muted-foreground uppercase tracking-wider mb-2">
          {{ group.title }}
        </h4>
        <div class="space-y-1">
          <router-link
            v-for="item in group.items"
            :key="item.path"
            :to="item.path"
            :class="
              cn(
                'flex items-center gap-3 px-3 py-2 text-sm font-medium rounded-md transition-colors',
                route.path === item.path
                  ? 'bg-primary/10 text-primary'
                  : 'text-muted-foreground hover:bg-muted hover:text-foreground'
              )
            "
          >
            <component :is="item.icon" class="w-4 h-4" />
            <span>{{ item.name }}</span>
          </router-link>
        </div>
      </div>
    </nav>

    <div class="p-4">
      <p class="text-xs text-center text-muted-foreground">Version 0.0.1</p>
    </div>
  </aside>
</template>
