<script setup lang="ts">
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { ref } from 'vue';

const emit = defineEmits<{
  submit: [{ email: string; password: string; firstName: string; lastName: string }];
}>();

const email = ref('');
const password = ref('');
const confirmPassword = ref('');
const firstName = ref('');
const lastName = ref('');
const loading = ref(false);
const passwordError = ref('');

const handleSubmit = () => {
  passwordError.value = '';

  if (password.value !== confirmPassword.value) {
    passwordError.value = 'Passwords do not match';
    return;
  }

  if (password.value.length < 8) {
    passwordError.value = 'Password must be at least 8 characters';
    return;
  }

  emit('submit', {
    email: email.value,
    password: password.value,
    firstName: firstName.value,
    lastName: lastName.value,
  });
};

defineExpose({
  setLoading: (value: boolean) => {
    loading.value = value;
  },
});
</script>

<template>
  <Card class="mx-auto max-w-sm">
    <CardHeader>
      <CardTitle class="text-2xl">Create an account</CardTitle>
      <CardDescription> Enter your information below to create your account </CardDescription>
    </CardHeader>
    <CardContent>
      <form @submit.prevent="handleSubmit" class="grid gap-4">
        <div class="grid gap-2">
          <Label for="firstName">Full Name</Label>
          <Input id="firstName" v-model="firstName" placeholder="Username" required />
        </div>

        <div class="grid gap-2">
          <Label for="email">Email</Label>
          <Input id="email" v-model="email" type="email" placeholder="user@example.com" required />
          <p class="text-xs text-muted-foreground">
            We'll use this to contact you. We will not share your email with anyone else.
          </p>
        </div>

        <div class="grid gap-2">
          <Label for="password">Password</Label>
          <Input id="password" v-model="password" type="password" required />
          <p class="text-xs text-muted-foreground">Must be at least 8 characters long</p>
        </div>

        <div class="grid gap-2">
          <Label for="confirmPassword">Confirm Password</Label>
          <Input
            id="confirmPassword"
            v-model="confirmPassword"
            type="password"
            :class="{ 'border-destructive': passwordError }"
            required
          />
          <p v-if="passwordError" class="text-xs text-destructive">
            {{ passwordError }}
          </p>
          <p v-else class="text-xs text-muted-foreground">Please confirm your password</p>
        </div>

        <Button type="submit" class="w-full" :disabled="loading">
          <span v-if="loading">Creating account...</span>
          <span v-else>Create Account</span>
        </Button>
      </form>

      <div class="mt-4 text-center text-sm">
        Already have an account?
        <router-link to="/login" class="underline"> Sign in </router-link>
      </div>
    </CardContent>
  </Card>
</template>
