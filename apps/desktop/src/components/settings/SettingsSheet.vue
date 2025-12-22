<script setup lang="ts">
import { Button } from '@/components/ui/button';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog';
import { Settings } from 'lucide-vue-next';
import AppearanceSettings from './AppearanceSettings.vue';
</script>

<template>
  <Dialog>
    <DialogTrigger as-child>
      <Button variant="ghost" size="icon" class="rounded-full">
        <Settings class="w-5 h-5 text-muted-foreground" />
      </Button>
    </DialogTrigger>
    <DialogContent class="sm:max-w-[425px]">
      <DialogHeader>
        <DialogTitle>Theme Settings</DialogTitle>
        <DialogDescription> Customize the appearance of the application. </DialogDescription>
      </DialogHeader>
      <div class="py-4">
        <AppearanceSettings />
      </div>
    </DialogContent>
  </Dialog>
</template>
