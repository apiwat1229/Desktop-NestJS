<script setup lang="ts">
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import api from '@/services/api';
import { useAuthStore } from '@/stores/auth';
import { Bell, Camera, Lock, Shield, User } from 'lucide-vue-next';
import { computed, ref } from 'vue';
import { CircleStencil, Cropper } from 'vue-advanced-cropper';
import 'vue-advanced-cropper/dist/style.css';
import { toast } from 'vue-sonner';

// Get API URL from env or default
// const apiUrl = import.meta.env.VITE_API_URL || 'http://localhost:2530';

const authStore = useAuthStore();
const isLoading = ref(false);
const isUploading = ref(false);
const fileInput = ref<HTMLInputElement | null>(null);

// PIN Logic
const showPinDialog = ref(false);
const isSavingPin = ref(false);
const pinData = ref({ pin: '', confirmPin: '' });
const hasPin = computed(() => !!authStore.user?.pinCode); // Assuming backend sends a boolean or we check existence

const handleSavePin = async () => {
  if (pinData.value.pin.length < 4) {
    toast.error('PIN must be at least 4 digits');
    return;
  }
  if (pinData.value.pin !== pinData.value.confirmPin) {
    toast.error('PINs do not match');
    return;
  }

  isSavingPin.value = true;
  try {
    await api.patch(`/users/${authStore.user?.id}`, {
      pinCode: pinData.value.pin,
    });
    toast.success('PIN updated successfully');
    showPinDialog.value = false;
    pinData.value = { pin: '', confirmPin: '' };
    await authStore.fetchUser();
  } catch (error) {
    toast.error('Failed to update PIN');
  } finally {
    isSavingPin.value = false;
  }
};

// Cropper Logic
const showCropDialog = ref(false);
const cropImageSrc = ref('');
const cropperRef = ref<any>(null);
const selectedFileType = ref(''); // Store original file type
const StencilComponent = CircleStencil;

// Form Data - Initialize with store data
const formData = ref({
  username: authStore.user?.username || '',
  email: authStore.user?.email || '',
  firstName: authStore.user?.firstName || '',
  lastName: authStore.user?.lastName || '',
  displayName: authStore.user?.displayName || '',
});

const userInitials = () => {
  if (!authStore.user?.firstName) return 'U';
  return `${authStore.user.firstName.charAt(0)}${authStore.user.lastName ? authStore.user.lastName.charAt(0) : ''}`;
};

const handleSaveProfile = async () => {
  isLoading.value = true;
  try {
    // Simulate API call for profile update (separate from avatar)
    await api.patch(`/users/${authStore.user?.id}`, {
      firstName: formData.value.firstName,
      lastName: formData.value.lastName,
      displayName: formData.value.displayName,
    });

    await authStore.fetchUser(); // Refresh local data
    toast.success('Profile updated successfully');
  } catch (error) {
    toast.error('Failed to update profile');
  } finally {
    isLoading.value = false;
  }
};

const handleUploadPhoto = () => {
  fileInput.value?.click();
};

const onFileSelected = (event: Event) => {
  const input = event.target as HTMLInputElement;
  if (!input.files || input.files.length === 0) return;

  const file = input.files[0];

  // Basic validation
  if (file.size > 5 * 1024 * 1024) {
    toast.error('File size must be less than 5MB');
    return;
  }

  if (!file.type.startsWith('image/')) {
    toast.error('File must be an image');
    return;
  }

  selectedFileType.value = file.type;

  // Read file for cropper
  const reader = new FileReader();
  reader.onload = (e) => {
    if (e.target?.result) {
      cropImageSrc.value = e.target.result as string;
      showCropDialog.value = true;
    }
  };
  reader.readAsDataURL(file);

  // Reset input so same file can be selected again
  if (fileInput.value) fileInput.value.value = '';
};

const uploadCroppedImage = async () => {
  if (!cropperRef.value) return;

  const { canvas } = cropperRef.value.getResult();
  if (!canvas) return;

  isUploading.value = true;

  canvas.toBlob(async (blob: Blob | null) => {
    if (!blob) {
      isUploading.value = false;
      toast.error('Failed to crop image');
      return;
    }

    const uploadFormData = new FormData();
    const ext = selectedFileType.value.split('/')[1] || 'png';
    uploadFormData.append('file', blob, `avatar.${ext}`);

    try {
      if (!authStore.user?.id) throw new Error('User ID not found');

      await api.post(`/users/${authStore.user.id}/avatar`, uploadFormData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });

      await authStore.fetchUser();
      toast.success('Profile picture updated successfully');
      showCropDialog.value = false;
    } catch (error) {
      console.error(error);
      toast.error('Failed to upload profile picture');
    } finally {
      isUploading.value = false;
    }
  }, selectedFileType.value);
};
</script>

<template>
  <div class="container max-w-4xl py-6 space-y-8 animate-in fade-in duration-500">
    <!-- Header -->
    <div class="space-y-1">
      <h2 class="text-3xl font-bold tracking-tight">User Profile</h2>
      <p class="text-muted-foreground">Manage your personal information and security settings.</p>
    </div>

    <!-- Profile Configuration Section (Always Visible) -->
    <Card>
      <CardHeader>
        <CardTitle>Profile Configuration</CardTitle>
        <CardDescription
          >Manage your profile picture and view your account details.</CardDescription
        >
      </CardHeader>
      <CardContent>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-8 divide-y md:divide-y-0 md:divide-x">
          <!-- Left: Profile Picture -->
          <div class="flex flex-col items-center justify-center gap-6 py-4">
            <Avatar class="h-32 w-32 border-4 border-background shadow-lg ring-2 ring-muted">
              <AvatarImage
                :src="authStore.userAvatarUrl"
                :alt="authStore.user?.username || ''"
                class="object-cover"
              />
              <AvatarFallback class="text-4xl font-bold">{{ userInitials() }}</AvatarFallback>
            </Avatar>

            <div class="text-center space-y-2">
              <h4 class="font-medium text-lg">
                {{ authStore.user?.displayName || authStore.user?.username }}
              </h4>
              <p class="text-xs text-muted-foreground uppercase tracking-widest font-bold">
                {{ authStore.user?.role }}
              </p>
            </div>

            <div class="flex items-center gap-3">
              <input
                type="file"
                ref="fileInput"
                class="hidden"
                accept="image/*"
                @change="onFileSelected"
              />
              <Button
                variant="outline"
                size="sm"
                @click="handleUploadPhoto"
                :disabled="isUploading"
              >
                <Camera class="w-4 h-4 mr-2" />
                {{ isUploading ? 'Uploading...' : 'Upload New Picture' }}
              </Button>
            </div>
          </div>

          <!-- Right: User Details -->
          <div class="space-y-6 md:pl-8 py-4">
            <div class="space-y-4">
              <h4 class="font-semibold flex items-center gap-2">
                <Shield class="w-4 h-4 text-primary" />
                Account Details
              </h4>

              <div class="grid grid-cols-2 gap-4">
                <div class="space-y-1">
                  <span class="text-xs text-muted-foreground">Department</span>
                  <p class="font-medium text-sm">{{ authStore.user?.department || '-' }}</p>
                </div>
                <div class="space-y-1">
                  <span class="text-xs text-muted-foreground">Position</span>
                  <p class="font-medium text-sm">{{ authStore.user?.position || '-' }}</p>
                </div>
                <div class="space-y-1">
                  <span class="text-xs text-muted-foreground">Employee ID</span>
                  <p class="font-medium text-sm">{{ authStore.user?.employeeId || '-' }}</p>
                </div>
                <div class="space-y-1">
                  <span class="text-xs text-muted-foreground">Status</span>
                  <div class="flex items-center gap-2">
                    <div
                      class="h-2 w-2 rounded-full"
                      :class="authStore.user?.status === 'ACTIVE' ? 'bg-green-500' : 'bg-red-500'"
                    ></div>
                    <p class="font-medium text-sm">{{ authStore.user?.status }}</p>
                  </div>
                </div>
              </div>
            </div>

            <div class="space-y-4 pt-4 border-t">
              <h4 class="font-semibold flex items-center gap-2">
                <Bell class="w-4 h-4 text-primary" />
                Notifications
              </h4>
              <div class="text-sm text-muted-foreground">
                <p>You are subscribed to standard notifications for your role.</p>
              </div>
            </div>
          </div>
        </div>
      </CardContent>
    </Card>

    <Tabs default-value="general" class="space-y-6">
      <TabsList class="bg-muted/50 p-1">
        <TabsTrigger value="general" class="gap-2">
          <User class="w-4 h-4" />
          General Info
        </TabsTrigger>
        <TabsTrigger value="security" class="gap-2">
          <Lock class="w-4 h-4" />
          Security
        </TabsTrigger>
      </TabsList>

      <!-- General Info Tab -->
      <TabsContent value="general" class="space-y-6">
        <!-- Personal Information Section -->
        <Card>
          <CardHeader>
            <CardTitle>Personal Information</CardTitle>
            <CardDescription>Manage your personal information.</CardDescription>
          </CardHeader>
          <CardContent class="space-y-6">
            <div class="grid grid-cols-2 gap-6">
              <div class="space-y-2">
                <Label for="username">Username</Label>
                <div class="relative">
                  <Input id="username" v-model="formData.username" disabled class="bg-muted/50" />
                  <Lock class="w-3 h-3 absolute right-3 top-3 text-muted-foreground" />
                </div>
              </div>
              <div class="space-y-2">
                <Label for="email">Email</Label>
                <div class="relative">
                  <Input id="email" v-model="formData.email" disabled class="bg-muted/50" />
                  <Lock class="w-3 h-3 absolute right-3 top-3 text-muted-foreground" />
                </div>
              </div>
            </div>

            <div class="grid grid-cols-2 gap-6">
              <div class="space-y-2">
                <Label for="firstName">First Name</Label>
                <Input id="firstName" v-model="formData.firstName" />
              </div>
              <div class="space-y-2">
                <Label for="lastName">Last Name</Label>
                <Input id="lastName" v-model="formData.lastName" />
              </div>
            </div>

            <div class="space-y-2">
              <Label for="displayName">Display Name</Label>
              <Input id="displayName" v-model="formData.displayName" />
            </div>

            <div class="flex justify-end pt-4">
              <Button @click="handleSaveProfile" :disabled="isLoading">
                {{ isLoading ? 'Saving...' : 'Save Changes' }}
              </Button>
            </div>
          </CardContent>
        </Card>
      </TabsContent>

      <!-- Security Tab -->
      <TabsContent value="security" class="space-y-6">
        <Card>
          <CardHeader>
            <CardTitle>Security Settings</CardTitle>
            <CardDescription>Manage your password and security preferences.</CardDescription>
          </CardHeader>
          <CardContent class="space-y-6">
            <!-- Password Section -->
            <div class="flex items-center justify-between p-4 border rounded-lg bg-card">
              <div class="flex items-center gap-4">
                <div class="p-2 bg-primary/10 rounded-full">
                  <Lock class="w-5 h-5 text-primary" />
                </div>
                <div>
                  <h4 class="font-medium">Password</h4>
                  <p class="text-sm text-muted-foreground">Change your password logic here.</p>
                </div>
              </div>
              <Button variant="outline" @click="$router.push('/change-password')">
                Change Password
              </Button>
            </div>

            <!-- PIN Code Section -->
            <div class="flex items-center justify-between p-4 border rounded-lg bg-card">
              <div class="flex items-center gap-4">
                <div class="p-2 bg-primary/10 rounded-full">
                  <Shield class="w-5 h-5 text-primary" />
                </div>
                <div>
                  <h4 class="font-medium">Transaction PIN</h4>
                  <p class="text-sm text-muted-foreground">
                    Set up a PIN for verifying sensitive actions.
                  </p>
                </div>
              </div>
              <Button variant="outline" @click="showPinDialog = true">
                {{ hasPin ? 'Change PIN' : 'Set PIN' }}
              </Button>
            </div>
          </CardContent>
        </Card>
      </TabsContent>
    </Tabs>

    <!-- Background Decorations -->
    <div
      class="fixed font-bold text-[300px] text-muted-foreground/5 opacity-[0.02] -z-10 top-0 right-0 pointer-events-none select-none rotate-12"
    >
      <User />
    </div>

    <!-- PIN Dialog -->
    <Dialog v-model:open="showPinDialog">
      <DialogContent>
        <DialogHeader>
          <DialogTitle>{{ hasPin ? 'Change Transaction PIN' : 'Set Transaction PIN' }}</DialogTitle>
          <DialogDescription>
            Enter a 4-6 digit PIN for verifying sensitive transactions.
          </DialogDescription>
        </DialogHeader>
        <div class="space-y-4 py-4">
          <div class="space-y-2">
            <Label>New PIN</Label>
            <Input v-model="pinData.pin" type="password" maxlength="6" placeholder="Enter PIN" />
          </div>
          <div class="space-y-2">
            <Label>Confirm PIN</Label>
            <Input
              v-model="pinData.confirmPin"
              type="password"
              maxlength="6"
              placeholder="Confirm PIN"
            />
          </div>
        </div>
        <DialogFooter>
          <Button variant="outline" @click="showPinDialog = false">Cancel</Button>
          <Button @click="handleSavePin" :disabled="isSavingPin">
            {{ isSavingPin ? 'Saving...' : 'Save PIN' }}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>

    <!-- Crop Image Dialog -->
    <Dialog v-model:open="showCropDialog">
      <DialogContent class="sm:max-w-xl">
        <DialogHeader>
          <DialogTitle>Crop Profile Picture</DialogTitle>
          <DialogDescription> Adjust your profile picture. </DialogDescription>
        </DialogHeader>
        <div class="py-4 w-full overflow-hidden flex justify-center">
          <div class="w-full max-w-[500px] h-[400px] rounded-lg overflow-hidden border">
            <Cropper
              ref="cropperRef"
              class="h-full w-full"
              :src="cropImageSrc"
              :stencil-component="StencilComponent"
              :stencil-props="{
                aspectRatio: 1,
              }"
              image-restriction="stencil"
            />
          </div>
        </div>
        <DialogFooter>
          <Button variant="outline" @click="showCropDialog = false">Cancel</Button>
          <Button @click="uploadCroppedImage" :disabled="isUploading">
            {{ isUploading ? 'Uploading...' : 'Save & Upload' }}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  </div>
</template>
