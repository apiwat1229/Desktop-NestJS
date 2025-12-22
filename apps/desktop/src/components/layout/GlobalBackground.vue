<script setup lang="ts">
import { useThemeStore } from '@/stores/theme';
import { Fingerprint, Globe, Key, Lock, Server, Shield } from 'lucide-vue-next';
import { computed } from 'vue';

const themeStore = useThemeStore();

const iconClass = computed(() => {
  const color = themeStore.colors[themeStore.themeColor];
  return color?.colorClass || 'text-zinc-500';
});

const floatingIcons = [
  { icon: Shield, top: '10%', left: '8%', rotate: -15, size: 120, delay: 0 },
  { icon: Fingerprint, top: '12%', left: '88%', rotate: 20, size: 130, delay: 1 },
  { icon: Key, top: '50%', left: '5%', rotate: -10, size: 110, delay: 2 },
  { icon: Server, top: '55%', left: '90%', rotate: 15, size: 125, delay: 3 },
  { icon: Lock, top: '85%', left: '10%', rotate: -20, size: 140, delay: 4 },
  { icon: Globe, top: '82%', left: '85%', rotate: 18, size: 135, delay: 5 },
];
</script>

<template>
  <div
    class="fixed inset-0 z-[-1] bg-gray-50 dark:bg-zinc-950 overflow-hidden pointer-events-none transition-colors duration-300"
  >
    <div
      v-for="(item, index) in floatingIcons"
      :key="index"
      class="absolute opacity-[0.06] float-icon transition-colors duration-300"
      :class="iconClass"
      :style="{
        top: item.top,
        left: item.left,
        width: item.size + 'px',
        height: item.size + 'px',
        '--rotate': item.rotate + 'deg',
        animationDelay: item.delay + 's',
      }"
    >
      <component :is="item.icon" class="w-full h-full" stroke-width="1.5" />
    </div>
  </div>
</template>

<style scoped>
@keyframes float {
  0%,
  100% {
    transform: translateY(0px) rotate(var(--rotate));
  }
  50% {
    transform: translateY(-20px) rotate(calc(var(--rotate) + 5deg));
  }
}
.float-icon {
  animation: float 8s ease-in-out infinite;
}
</style>
