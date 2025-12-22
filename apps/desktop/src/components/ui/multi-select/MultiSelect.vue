<script setup lang="ts">
import { Badge } from '@/components/ui/badge';
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
import { Check, ChevronsUpDown, X } from 'lucide-vue-next';
import { computed, ref } from 'vue';

interface Option {
  label: string;
  value: string;
}

const props = defineProps<{
  options: Option[];
  modelValue?: string[];
  placeholder?: string;
}>();

const emit = defineEmits<{
  (e: 'update:modelValue', value: string[]): void;
}>();

const open = ref(false);

const selected = computed({
  get: () => props.modelValue || [],
  set: (val) => emit('update:modelValue', val),
});

const handleSelect = (value: string) => {
  if (selected.value.includes(value)) {
    selected.value = selected.value.filter((item) => item !== value);
  } else {
    selected.value = [...selected.value, value];
  }
};

const handleRemove = (value: string) => {
  selected.value = selected.value.filter((item) => item !== value);
};
</script>

<template>
  <Popover v-model:open="open">
    <PopoverTrigger as-child>
      <Button
        variant="outline"
        role="combobox"
        :aria-expanded="open"
        class="w-full justify-between h-auto min-h-10 px-3 py-2 hover:bg-background"
      >
        <div class="flex flex-wrap gap-1">
          <template v-if="selected.length > 0">
            <Badge
              v-for="item in selected"
              :key="item"
              variant="secondary"
              class="mr-1 mb-1"
              @click.stop
            >
              {{ options.find((opt) => opt.value === item)?.label || item }}
              <button
                class="ml-1 ring-offset-background rounded-full outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2"
                @keydown.enter.stop="handleRemove(item)"
                @mousedown.prevent.stop="handleRemove(item)"
              >
                <X class="h-3 w-3 text-muted-foreground hover:text-foreground" />
              </button>
            </Badge>
          </template>
          <span v-else class="text-muted-foreground font-normal">
            {{ placeholder || 'Select options...' }}
          </span>
        </div>
        <ChevronsUpDown class="ml-2 h-4 w-4 shrink-0 opacity-50" />
      </Button>
    </PopoverTrigger>
    <PopoverContent class="w-full p-0" align="start">
      <Command>
        <CommandInput placeholder="Search..." />
        <CommandEmpty>No results found.</CommandEmpty>
        <CommandList>
          <CommandGroup>
            <CommandItem
              v-for="option in options"
              :key="option.value"
              :value="option.value"
              @select="handleSelect(option.value)"
            >
              <Check
                :class="
                  cn('mr-2 h-4 w-4', selected.includes(option.value) ? 'opacity-100' : 'opacity-0')
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
