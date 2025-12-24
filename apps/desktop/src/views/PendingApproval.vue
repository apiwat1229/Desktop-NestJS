<script setup lang="ts">
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { useAuthStore } from '@/stores/auth';
import { Clock } from 'lucide-vue-next';
import { useRouter } from 'vue-router';

const authStore = useAuthStore();
const router = useRouter();

const handleLogout = () => {
  authStore.logout();
  router.push('/login');
};
</script>

<template>
  <div class="flex min-h-svh w-full items-center justify-center p-6">
    <Card class="mx-auto max-w-md">
      <CardHeader class="text-center">
        <div
          class="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-orange-100"
        >
          <Clock class="h-6 w-6 text-orange-600" />
        </div>
        <CardTitle class="text-2xl">Account Pending Approval</CardTitle>
        <CardDescription> Your account is waiting for administrator approval </CardDescription>
      </CardHeader>
      <CardContent class="space-y-4">
        <p class="text-sm text-muted-foreground text-center">
          Thank you for registering! An administrator will review your account and assign
          appropriate permissions soon.
        </p>
        <p class="text-sm text-muted-foreground text-center">
          You will receive an email notification once your account has been approved.
        </p>
        <Button @click="handleLogout" variant="outline" class="w-full"> Logout </Button>
      </CardContent>
    </Card>
  </div>
</template>
