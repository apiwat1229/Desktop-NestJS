<script setup lang="ts">
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Checkbox } from '@/components/ui/checkbox';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Eye, EyeOff } from 'lucide-vue-next';
import { ref } from 'vue';
import { useI18n } from 'vue-i18n';

const { t } = useI18n();

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
      <CardTitle class="text-2xl">{{ t('auth.login') }}</CardTitle>
      <CardDescription> {{ t('auth.loginDescription') }} </CardDescription>
    </CardHeader>
    <CardContent>
      <form @submit.prevent="handleSubmit" class="grid gap-4">
        <div class="grid gap-2">
          <Label for="email">{{ t('auth.emailOrUsername') }}</Label>
          <Input id="email" v-model="email" type="text" required />
        </div>
        <div class="grid gap-2">
          <div class="flex items-center">
            <Label for="password">{{ t('auth.password') }}</Label>
            <a href="#" class="ml-auto inline-block text-sm underline">
              {{ t('auth.forgotPassword') }}
            </a>
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
            {{ t('auth.rememberMe') }}
          </Label>
        </div>

        <Button type="submit" class="w-full" :disabled="loading">
          <span v-if="loading">{{ t('auth.signingIn') }}</span>
          <span v-else>{{ t('auth.login') }}</span>
        </Button>
      </form>
      <div class="mt-4 text-center text-sm">
        {{ t('auth.noAccount') }}
        <router-link to="/signup" class="underline"> {{ t('auth.signUp') }} </router-link>
      </div>
    </CardContent>
  </Card>
</template>
