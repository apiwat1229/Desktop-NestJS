<script setup lang="ts">
import { usePermissions } from '@/composables/usePermissions';
import { computed } from 'vue';

interface Props {
  permission?: string;
  permissions?: string[];
  requireAll?: boolean; // If true, requires ALL permissions. If false, requires ANY permission
}

const props = withDefaults(defineProps<Props>(), {
  requireAll: false,
});

const { hasPermission, hasAnyPermission, hasAllPermissions } = usePermissions();

const canShow = computed(() => {
  // If single permission specified
  if (props.permission) {
    return hasPermission(props.permission);
  }

  // If multiple permissions specified
  if (props.permissions && props.permissions.length > 0) {
    return props.requireAll
      ? hasAllPermissions(props.permissions)
      : hasAnyPermission(props.permissions);
  }

  // No permissions specified, show by default
  return true;
});
</script>

<template>
  <slot v-if="canShow"></slot>
</template>
