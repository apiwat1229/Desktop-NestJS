<script setup lang="ts">
import SettingsSheet from '@/components/settings/SettingsSheet.vue';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar/index';
import { Button } from '@/components/ui/button';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { useAuthStore } from '@/stores/auth';
import {
  ArrowLeft,
  ArrowRight,
  Bell,
  Home,
  LayoutDashboard,
  LogOut,
  RotateCw,
  User,
} from 'lucide-vue-next';
import { computed } from 'vue';
import { useRoute, useRouter } from 'vue-router';

const authStore = useAuthStore();
const router = useRouter();
const route = useRoute();

const props = defineProps<{
  showBrand?: boolean;
}>();

const handleLogout = () => {
  authStore.logout();
  router.push('/login');
};

const userInitials = () => {
  if (!authStore.user?.firstName) return 'U';
  return `${authStore.user.firstName.charAt(0)}${authStore.user.lastName ? authStore.user.lastName.charAt(0) : ''}`;
};

const pageTitle = computed(() => {
  const name = route.name?.toString() || '';
  if (name === 'Home') return 'Dashboard';
  if (name === 'AdminDashboard') return 'Admin Panel';
  return name;
});
</script>

<template>
  <header
    class="h-14 border-b border-border bg-card/80 backdrop-blur px-6 flex items-center justify-between sticky top-0 z-10"
  >
    <div class="flex items-center gap-4">
      <!-- Navigation Controls -->
      <div class="flex items-center gap-1 border-r border-border pr-4 mr-2">
        <Button variant="ghost" size="icon" class="h-8 w-8" @click="router.back()" title="Back">
          <ArrowLeft class="w-4 h-4" />
        </Button>
        <Button
          variant="ghost"
          size="icon"
          class="h-8 w-8"
          @click="router.forward()"
          title="Forward"
        >
          <ArrowRight class="w-4 h-4" />
        </Button>
        <Button variant="ghost" size="icon" class="h-8 w-8" @click="router.go(0)" title="Refresh">
          <RotateCw class="w-4 h-4" />
        </Button>
        <Button variant="ghost" size="icon" class="h-8 w-8" @click="router.push('/')" title="Home">
          <Home class="w-4 h-4" />
        </Button>
      </div>
    </div>

    <!-- Centered Title -->
    <div
      class="absolute left-1/2 top-1/2 transform -translate-x-1/2 -translate-y-1/2 flex flex-col items-center"
    >
      <span class="text-lg text-foreground font-semibold">
        {{ pageTitle }}
      </span>
    </div>

    <div class="flex items-center gap-4">
      <SettingsSheet />

      <Button variant="ghost" size="icon" class="rounded-full">
        <Bell class="w-5 h-5 text-muted-foreground" />
      </Button>

      <DropdownMenu>
        <DropdownMenuTrigger as-child>
          <Button variant="ghost" class="relative h-9 w-9 rounded-full">
            <Avatar class="h-9 w-9">
              <AvatarImage
                :src="authStore.user?.avatar || ''"
                :alt="authStore.user?.username || ''"
              />
              <AvatarFallback>{{ userInitials() }}</AvatarFallback>
            </Avatar>
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent class="w-56" align="end">
          <DropdownMenuLabel class="font-normal">
            <div class="flex flex-col space-y-1">
              <p class="text-sm font-medium leading-none">
                {{ authStore.user?.displayName || authStore.user?.username }}
              </p>
              <p class="text-xs leading-none text-muted-foreground">
                {{ authStore.user?.email }}
              </p>
            </div>
          </DropdownMenuLabel>
          <DropdownMenuSeparator />

          <DropdownMenuItem v-if="authStore.user?.role === 'admin'" @click="router.push('/admin')">
            <LayoutDashboard class="mr-2 h-4 w-4" />
            <span>Admin Panel</span>
          </DropdownMenuItem>

          <DropdownMenuItem>
            <User class="mr-2 h-4 w-4" />
            <span>Profile</span>
          </DropdownMenuItem>
          <DropdownMenuSeparator />
          <DropdownMenuItem @click="handleLogout" class="text-red-600 focus:text-red-600">
            <LogOut class="mr-2 h-4 w-4" />
            <span>Log out</span>
          </DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
    </div>
  </header>
</template>
