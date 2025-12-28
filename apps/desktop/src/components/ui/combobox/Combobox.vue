<script setup lang="ts">
import { Button } from '@/components/ui/button';
import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
} from '@/components/ui/command';
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover';
import { cn } from '@/lib/utils';
import { Check, ChevronsUpDown } from 'lucide-vue-next';
import { computed, ref } from 'vue';

interface Option {
  value: string;
  label: string;
}

const props = defineProps<{
  options: Option[];
  modelValue?: string | number;
  placeholder?: string;
  searchPlaceholder?: string;
  emptyText?: string;
  disabled?: boolean;
}>();

const emit = defineEmits<{
  (e: 'update:modelValue', value: string): void;
}>();

const open = ref(false);

const selectedLabel = computed(() => {
  return props.options.find((option) => option.value === props.modelValue)?.label;
});

const handleSelect = (currentValue: string) => {
  emit('update:modelValue', currentValue === props.modelValue ? '' : currentValue);
  open.value = false;
};
</script>

<template>
  <Popover v-model:open="open">
    <PopoverTrigger as-child>
      <Button
        variant="outline"
        role="combobox"
        :aria-expanded="open"
        :disabled="disabled"
        class="w-full justify-between font-normal"
        :class="!modelValue && 'text-muted-foreground'"
      >
        {{ selectedLabel || placeholder || 'Select option...' }}
        <ChevronsUpDown class="ml-2 h-4 w-4 shrink-0 opacity-50" />
      </Button>
    </PopoverTrigger>
    <PopoverContent class="w-full p-0">
      <Command>
        <CommandInput :placeholder="searchPlaceholder || 'Search...'" />
        <CommandEmpty>{{ emptyText || 'No results found.' }}</CommandEmpty>
        <CommandList>
          <CommandGroup>
            <CommandItem
              v-for="option in options"
              :key="option.value"
              :value="option.label"
              @select="handleSelect(option.value)"
            >
              <Check
                :class="
                  cn('mr-2 h-4 w-4', modelValue === option.value ? 'opacity-100' : 'opacity-0')
                "
              />
              {{ option.label }}
            </CommandItem>
          </CommandGroup>
        </CommandList>
      </Command>
    </PopoverContent>
  </Popover>
</template>
