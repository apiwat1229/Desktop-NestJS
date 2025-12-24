<script setup lang="ts">
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { ref } from 'vue';

const emit = defineEmits<{
  submit: [{ email: string; password: string }];
}>();

const email = ref('');
const password = ref('');
const loading = ref(false);

const handleSubmit = () => {
  emit('submit', { email: email.value, password: password.value });
};

defineExpose({
  setLoading: (value: boolean) => {
    loading.value = value;
  },
  setEmail: (value: string) => {
    email.value = value;
  },
  setPassword: (value: string) => {
    password.value = value;
  },
});
</script>

<template>
  <Card class="mx-auto max-w-sm">
    <CardHeader>
      <CardTitle class="text-2xl">Login</CardTitle>
      <CardDescription> Enter your email below to login to your account </CardDescription>
    </CardHeader>
    <CardContent>
      <form @submit.prevent="handleSubmit" class="grid gap-4">
        <div class="grid gap-2">
          <Label for="email">Email or Username</Label>
          <Input
            id="email"
            v-model="email"
            type="text"
            required
          />
        </div>
        <div class="grid gap-2">
          <div class="flex items-center">
            <Label for="password">Password</Label>
            <a href="#" class="ml-auto inline-block text-sm underline"> Forgot your password? </a>
          </div>
          <Input id="password" v-model="password" type="password" required />
        </div>
        <Button type="submit" class="w-full" :disabled="loading">
          <span v-if="loading">Signing in...</span>
          <span v-else>Login</span>
        </Button>
      </form>
      <div class="mt-4 text-center text-sm">
        Don't have an account?
        <router-link to="/signup" class="underline"> Sign up </router-link>
      </div>
    </CardContent>
  </Card>
</template>
