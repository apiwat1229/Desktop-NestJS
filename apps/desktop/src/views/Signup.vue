<script setup lang="ts">
import SignupForm from '@/components/SignupForm.vue';
import { Alert, AlertDescription } from '@/components/ui/alert';
import axios from 'axios';
import { AlertCircle, CheckCircle } from 'lucide-vue-next';
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { toast } from 'vue-sonner';

const signupError = ref('');
const signupSuccess = ref(false);
const signupFormRef = ref<InstanceType<typeof SignupForm> | null>(null);
const router = useRouter();

async function handleSignup({ email, password, firstName, lastName }: any) {
  if (signupFormRef.value) {
    signupFormRef.value.setLoading(true);
  }
  signupError.value = '';
  signupSuccess.value = false;

  try {
    await axios.post(`${import.meta.env.VITE_API_URL}/auth/signup`, {
      email,
      password,
      firstName,
      lastName,
    });

    signupSuccess.value = true;
    toast.success('Account created successfully!');

    // Redirect to login after 2 seconds
    setTimeout(() => {
      router.push('/login');
    }, 2000);
  } catch (err: any) {
    console.error('Signup failed:', err);
    signupError.value = err.response?.data?.message || 'Signup failed';
    toast.error(signupError.value);
  } finally {
    if (signupFormRef.value) {
      signupFormRef.value.setLoading(false);
    }
  }
}
</script>

<template>
  <div class="flex min-h-svh w-full items-center justify-center p-6 md:p-10">
    <div class="w-full max-w-sm">
      <!-- Success Alert -->
      <Alert v-if="signupSuccess" class="mb-4 border-green-500">
        <CheckCircle class="h-4 w-4 text-green-500" />
        <AlertDescription class="text-green-700">
          Account created successfully! Please wait for admin approval. Redirecting to login...
        </AlertDescription>
      </Alert>

      <!-- Error Alert -->
      <Alert v-if="signupError" variant="destructive" class="mb-4">
        <AlertCircle class="h-4 w-4" />
        <AlertDescription>{{ signupError }}</AlertDescription>
      </Alert>

      <SignupForm ref="signupFormRef" @submit="handleSignup" />
    </div>
  </div>
</template>
