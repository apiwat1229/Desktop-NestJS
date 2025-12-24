<script setup lang="ts">
const props = defineProps<{
  isVoided: boolean;
}>();
</script>

<template>
  <div class="relative">
    <slot />

    <!-- Watermark Overlay -->
    <div
      v-if="isVoided"
      class="absolute inset-0 flex items-center justify-center pointer-events-none z-10"
    >
      <div
        class="text-9xl font-bold text-red-500/10 rotate-[-45deg] select-none"
        style="text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.1)"
      >
        VOIDED
      </div>
    </div>
  </div>
</template>
