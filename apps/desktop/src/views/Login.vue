<script setup lang="ts">
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Checkbox } from '@/components/ui/checkbox';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Eye, EyeOff } from 'lucide-vue-next';
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { toast } from 'vue-sonner';
import { useAuthStore } from '../stores/auth';

import { storage } from '../services/storage';

const savedEmail = storage.get('saved_email');
console.log('[Login] Initial saved_email:', savedEmail);

const email = ref(savedEmail || '');
const password = ref('');
const showPassword = ref(false);
const loading = ref(false);
const rememberMe = ref(true);
const loginError = ref('');
const showChangePasswordDialog = ref(false);
const tempToken = ref('');
console.log('[Login] Initial rememberMe:', rememberMe.value);

const authStore = useAuthStore();
const router = useRouter();

async function handleLogin() {
  loading.value = true;
  loginError.value = '';
  try {
    await authStore.login({ email: email.value, password: password.value }, rememberMe.value);
    toast.success('Login successful');
    router.push('/');
  } catch (err: any) {
    console.error('Login failed:', err);

    // Handle force password change
    if (err.response?.data?.code === 'MUST_CHANGE_PASSWORD') {
      tempToken.value = err.response.data.tempToken;
      showChangePasswordDialog.value = true;
      return;
    }

    // Handle account locked
    if (err.response?.data?.message?.includes('locked')) {
      loginError.value =
        'Your account has been locked due to multiple failed login attempts. Please contact IT support.';
      toast.error(loginError.value);
      return;
    }

    // Handle other errors
    loginError.value = err.response?.data?.message || err.message || 'Login failed';
    toast.error(loginError.value);
  } finally {
    loading.value = false;
  }
}

function handlePasswordChangeSuccess() {
  showChangePasswordDialog.value = false;
  toast.success('Password changed successfully! You are now logged in.');
  router.push('/');
}
</script>

<template>
  <div
    class="min-h-screen flex items-center justify-center px-4 relative overflow-hidden font-sans"
  >
    <Card class="w-full max-w-md relative z-10 shadow-lg rounded-xl border-none">
      <CardHeader class="space-y-1 text-center">
        <CardTitle class="text-3xl font-bold tracking-tight">Login</CardTitle>
        <CardDescription>Sign in to your account</CardDescription>
      </CardHeader>
      <CardContent>
        <!-- Error Alert -->
        <Alert v-if="loginError" variant="destructive" class="mb-4">
          <AlertCircle class="h-4 w-4" />
          <AlertDescription>{{ loginError }}</AlertDescription>
        </Alert>

        <form @submit.prevent="handleLogin" class="space-y-5">
          <div class="space-y-2">
            <Label for="email">Email</Label>
            <div class="relative">
              <Input
                id="email"
                v-model="email"
                type="text"
                placeholder="username or email"
                required
                class="pl-10 h-10"
              />
              <div
                class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-muted-foreground"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  width="16"
                  height="16"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  stroke-width="2"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  class="lucide lucide-user"
                >
                  <path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2" />
                  <circle cx="12" cy="7" r="4" />
                </svg>
              </div>
            </div>
          </div>

          <div class="space-y-2">
            <Label for="password">Password</Label>
            <div class="relative">
              <Input
                id="password"
                v-model="password"
                :type="showPassword ? 'text' : 'password'"
                placeholder="Password"
                required
                class="pl-10 h-10"
              />
              <div
                class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-muted-foreground"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  width="16"
                  height="16"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  stroke-width="2"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  class="lucide lucide-lock"
                >
                  <rect width="18" height="11" x="3" y="11" rx="2" ry="2" />
                  <path d="M7 11V7a5 5 0 0 1 10 0v4" />
                </svg>
              </div>
              <button
                type="button"
                @click="showPassword = !showPassword"
                class="absolute inset-y-0 right-0 pr-3 flex items-center text-muted-foreground hover:text-foreground"
              >
                <component :is="showPassword ? EyeOff : Eye" class="w-4 h-4" />
              </button>
            </div>
          </div>

          <div class="flex items-center justify-between">
            <div class="flex items-center space-x-2">
              <Checkbox id="remember" v-model="rememberMe" />
              <label
                for="remember"
                class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
              >
                Remember me
              </label>
            </div>
            <a href="#" class="text-sm text-blue-600 hover:text-blue-500 font-medium"
              >Forgot password?</a
            >
          </div>

          <Button type="submit" class="w-full h-10 text-base" :disabled="loading">
            <span v-if="loading">Signing in...</span>
            <span v-else>Log in</span>
          </Button>
        </form>
      </CardContent>
    </Card>

    <!-- Change Password Dialog -->
    <ChangePasswordDialog
      :open="showChangePasswordDialog"
      :temp-token="tempToken"
      @success="handlePasswordChangeSuccess"
    />
  </div>
</template>

<style scoped></style>
