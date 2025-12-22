<script setup lang="ts">
import { useThemeStore } from '@/stores/theme';
import GlobalBackground from './components/layout/GlobalBackground.vue';

const themeStore = useThemeStore();
</script>

<template>
  <GlobalBackground />
  <router-view />
</template>

<style>
/* Global Styles handled by style.css */
</style>
