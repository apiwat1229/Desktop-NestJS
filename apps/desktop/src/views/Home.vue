<script setup lang="ts">
import { Button } from '@/components/ui/button';
import { useRouter } from 'vue-router';
import { useAuthStore } from '../stores/auth';

import { onMounted } from 'vue';

const authStore = useAuthStore();
const router = useRouter();

onMounted(() => {
  authStore.fetchUser();
});

const logout = () => {
  authStore.logout();
  router.push('/login');
};
</script>

<template>
  <div class="p-8">
    <h1 class="text-3xl font-bold mb-4 font-sans">Dashboard</h1>
    <p class="mb-4">Welcome, {{ authStore.user?.email }}</p>

    <div class="bg-card text-card-foreground p-4 rounded shadow mb-4 border border-border">
      <h2 class="font-bold mb-2">User Profile (/auth/me)</h2>
      <pre class="bg-muted text-muted-foreground p-2 rounded text-sm overflow-auto">{{
        authStore.user
      }}</pre>
    </div>

    <Button @click="logout">Logout</Button>
  </div>
</template>
