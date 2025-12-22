<script setup lang="ts">
import { Button } from '@/components/ui/button';
import { Label } from '@/components/ui/label';
import { RadioGroup, RadioGroupItem } from '@/components/ui/radio-group';
import { useThemeStore } from '@/stores/theme';
import { Moon, Sun } from 'lucide-vue-next';

const themeStore = useThemeStore();

const colors = [
  { name: 'Zinc', value: 'zinc', bg: 'bg-zinc-900' },
  { name: 'Red', value: 'red', bg: 'bg-red-600' },
  { name: 'Cyan', value: 'cyan', bg: 'bg-cyan-500' },
  { name: 'Orange', value: 'orange', bg: 'bg-orange-500' },
  { name: 'Green', value: 'green', bg: 'bg-green-600' },
  { name: 'Blue', value: 'blue', bg: 'bg-blue-600' },
  { name: 'Yellow', value: 'yellow', bg: 'bg-yellow-500' },
  { name: 'Violet', value: 'violet', bg: 'bg-violet-600' },
];

const fontSizes = [
  { name: 'Small', value: 'small', class: 'text-sm' },
  { name: 'Medium', value: 'medium', class: 'text-base' },
  { name: 'Large', value: 'large', class: 'text-lg' },
  { name: 'XL', value: 'xl', class: 'text-xl' },
];
</script>

<template>
  <div class="space-y-6">
    <div class="space-y-4">
      <div class="font-medium">Theme Mode</div>
      <div class="grid grid-cols-2 gap-4">
        <Button
          variant="outline"
          class="h-20 flex flex-col items-center justify-center gap-2"
          :class="{ 'border-primary border-2': !themeStore.isDark }"
          @click="themeStore.isDark = false"
        >
          <Sun class="size-6" />
          <span>Light</span>
        </Button>
        <Button
          variant="outline"
          class="h-20 flex flex-col items-center justify-center gap-2"
          :class="{ 'border-primary border-2': themeStore.isDark }"
          @click="themeStore.isDark = true"
        >
          <Moon class="size-6" />
          <span>Dark</span>
        </Button>
      </div>
    </div>

    <div class="space-y-2">
      <div class="font-medium">Theme Color</div>
      <div class="grid grid-cols-3 gap-2">
        <button
          v-for="color in colors"
          :key="color.value"
          @click="themeStore.themeColor = color.value"
          class="flex items-center gap-2 rounded-md border p-2 hover:bg-accent transition-colors"
          :class="{ 'border-primary ring-1 ring-primary': themeStore.themeColor === color.value }"
        >
          <div class="h-4 w-4 rounded-full shrink-0" :class="color.bg" />
          <span class="text-sm font-medium">{{ color.name }}</span>
        </button>
      </div>
    </div>

    <div class="space-y-2">
      <div class="font-medium">Font Size</div>
      <RadioGroup v-model="themeStore.fontSize" class="flex flex-col space-y-2">
        <div v-for="size in fontSizes" :key="size.value" class="flex items-center space-x-2">
          <RadioGroupItem :id="size.value" :value="size.value" />
          <Label :for="size.value" :class="size.class">
            {{ size.name }} -
            <span class="text-muted-foreground text-xs"
              >The quick brown fox jumps over the lazy dog.</span
            >
          </Label>
        </div>
      </RadioGroup>
    </div>
  </div>
</template>
