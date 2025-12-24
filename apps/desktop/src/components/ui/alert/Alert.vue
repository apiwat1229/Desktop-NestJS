<script setup lang="ts">
import { cn } from '@/lib/utils';
import { cva, type VariantProps } from 'class-variance-authority';
import { computed } from 'vue';

const alertVariants = cva(
  'relative w-full rounded-lg border p-4 [&>svg~*]:pl-7 [&>svg+div]:translate-y-[-3px] [&>svg]:absolute [&>svg]:left-4 [&>svg]:top-4 [&>svg]:text-foreground',
  {
    variants: {
      variant: {
        default: 'bg-background text-foreground',
        destructive:
          'border-destructive/50 text-destructive dark:border-destructive [&>svg]:text-destructive',
      },
    },
    defaultVariants: {
      variant: 'default',
    },
  }
);

type AlertVariants = VariantProps<typeof alertVariants>;

const props = withDefaults(
  defineProps<{
    variant?: AlertVariants['variant'];
    class?: string;
  }>(),
  {
    variant: 'default',
  }
);

const alertClass = computed(() => cn(alertVariants({ variant: props.variant }), props.class));
</script>

<template>
  <div :class="alertClass" role="alert">
    <slot />
  </div>
</template>
