<script setup lang="ts">
import { Toaster } from '@/components/ui/sonner';
import { useThemeStore } from '@/stores/theme';
import { onMounted, onUnmounted } from 'vue';
import GlobalBackground from './components/layout/GlobalBackground.vue';

useThemeStore();

onMounted(() => {
  // socketService managed in Navbar
});

onUnmounted(() => {
  // socketService managed in Navbar
});
</script>

<template>
  <GlobalBackground />
  <router-view />
  <Toaster richColors position="top-center" :duration="5000" />
</template>

<style>
/* Global Styles handled by style.css */
</style>
