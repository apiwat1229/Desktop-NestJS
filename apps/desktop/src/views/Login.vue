<script setup lang="ts">
import ChangePasswordDialog from '@/components/auth/ChangePasswordDialog.vue';
import LoginForm from '@/components/LoginForm.vue';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { AlertCircle } from 'lucide-vue-next';
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { toast } from 'vue-sonner';
import { storage } from '../services/storage';
import { useAuthStore } from '../stores/auth';

const savedEmail = storage.get('saved_email');
const loginError = ref('');
const showChangePasswordDialog = ref(false);
const tempToken = ref('');
const loginFormRef = ref<InstanceType<typeof LoginForm> | null>(null);

const authStore = useAuthStore();
const router = useRouter();

// Set saved email if exists
if (savedEmail && loginFormRef.value) {
  loginFormRef.value.setEmail(savedEmail);
}

async function handleLogin({ email, password }: { email: string; password: string }) {
  if (loginFormRef.value) {
    loginFormRef.value.setLoading(true);
  }
  loginError.value = '';

  try {
    await authStore.login({ email, password }, true);
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
    if (loginFormRef.value) {
      loginFormRef.value.setLoading(false);
    }
  }
}

function handlePasswordChangeSuccess() {
  showChangePasswordDialog.value = false;
  toast.success('Password changed successfully! You are now logged in.');
  router.push('/');
}
</script>

<template>
  <div class="flex min-h-svh w-full items-center justify-center p-6 md:p-10">
    <div class="w-full max-w-sm">
      <!-- Error Alert -->
      <Alert v-if="loginError" variant="destructive" class="mb-4">
        <AlertCircle class="h-4 w-4" />
        <AlertDescription>{{ loginError }}</AlertDescription>
      </Alert>

      <LoginForm ref="loginFormRef" @submit="handleLogin" />
    </div>

    <!-- Change Password Dialog -->
    <ChangePasswordDialog
      :open="showChangePasswordDialog"
      :temp-token="tempToken"
      @success="handlePasswordChangeSuccess"
    />
  </div>
</template>
