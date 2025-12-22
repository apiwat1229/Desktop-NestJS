<script setup lang="ts">
import { useAuthStore } from '@/stores/auth';
import { computed } from 'vue';
import { useRoute } from 'vue-router';
import Navbar from './Navbar.vue';
import Sidebar from './Sidebar.vue';

const authStore = useAuthStore();
const route = useRoute();

const showSidebar = computed(() => {
  return authStore.user?.role === 'admin' && route.path.startsWith('/admin');
});
</script>

<template>
  <div class="flex h-screen bg-transparent text-foreground overflow-hidden font-sans">
    <!-- Sidebar -->
    <Sidebar v-if="showSidebar" />

    <!-- Main Content Area -->
    <div class="flex-1 flex flex-col min-w-0 overflow-hidden">
      <!-- Top Navbar -->
      <Navbar :show-brand="!showSidebar" />

      <!-- Page Content -->
      <main class="flex-1 overflow-x-hidden overflow-y-auto p-6">
        <router-view v-slot="{ Component }">
          <transition name="fade" mode="out-in">
            <component :is="Component" />
          </transition>
        </router-view>
      </main>
    </div>
  </div>
</template>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.15s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
