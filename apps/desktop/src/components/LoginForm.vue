<script setup lang="ts">
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Checkbox } from '@/components/ui/checkbox';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Eye, EyeOff } from 'lucide-vue-next';
import { ref } from 'vue';

const emit = defineEmits<{
  submit: [{ email: string; password: string; rememberMe: boolean }];
}>();

const email = ref('');
const password = ref('');
const rememberMe = ref(false);
const showPassword = ref(false);
const loading = ref(false);

const handleSubmit = () => {
  emit('submit', {
    email: email.value,
    password: password.value,
    rememberMe: rememberMe.value,
  });
};

const togglePasswordVisibility = () => {
  showPassword.value = !showPassword.value;
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
  setRememberMe: (value: boolean) => {
    rememberMe.value = value;
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
          <Input id="email" v-model="email" type="text" required />
        </div>
        <div class="grid gap-2">
          <div class="flex items-center">
            <Label for="password">Password</Label>
            <a href="#" class="ml-auto inline-block text-sm underline"> Forgot your password? </a>
          </div>
          <div class="relative">
            <Input
              id="password"
              v-model="password"
              :type="showPassword ? 'text' : 'password'"
              required
              class="pr-10"
            />
            <button
              type="button"
              @click="togglePasswordVisibility"
              class="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground transition-colors"
              tabindex="-1"
            >
              <Eye v-if="!showPassword" class="h-4 w-4" />
              <EyeOff v-else class="h-4 w-4" />
            </button>
          </div>
        </div>

        <!-- Remember Me Checkbox -->
        <div class="flex items-center space-x-2">
          <Checkbox id="remember" v-model:checked="rememberMe" />
          <Label for="remember" class="text-sm font-normal cursor-pointer select-none">
            Remember me
          </Label>
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
