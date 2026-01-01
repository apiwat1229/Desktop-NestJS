<script setup lang="ts">
import { Button } from '@/components/ui/button';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { ChevronDown } from 'lucide-vue-next';
import { computed } from 'vue';
import { useI18n } from 'vue-i18n';

const { locale } = useI18n();

const locales = [
  { code: 'en', name: 'English', flag: '🇬🇧', label: 'EN' },
  { code: 'th', name: 'ไทย', flag: '🇹🇭', label: 'TH' },
];

const currentLocale = computed(() => locales.find((l) => l.code === locale.value) || locales[0]);

const switchLanguage = (lang: 'en' | 'th') => {
  locale.value = lang;
  localStorage.setItem('language', lang);
};

// Load saved language preference on mount
const savedLang = localStorage.getItem('language');
if (savedLang && (savedLang === 'en' || savedLang === 'th')) {
  locale.value = savedLang;
}
</script>

<template>
  <DropdownMenu>
    <DropdownMenuTrigger as-child>
      <Button variant="ghost" size="sm" class="h-8 gap-2 px-2">
        <span class="text-base leading-none">{{ currentLocale.flag }}</span>
        <span class="font-medium text-xs">{{ currentLocale.label }}</span>
        <ChevronDown class="h-3 w-3 opacity-50" />
      </Button>
    </DropdownMenuTrigger>
    <DropdownMenuContent align="end" class="w-32">
      <DropdownMenuItem
        v-for="lang in locales"
        :key="lang.code"
        @click="switchLanguage(lang.code as 'en' | 'th')"
        class="gap-2 cursor-pointer"
        :class="{ 'bg-accent': locale === lang.code }"
      >
        <span class="text-base leading-none">{{ lang.flag }}</span>
        <span>{{ lang.name }}</span>
      </DropdownMenuItem>
    </DropdownMenuContent>
  </DropdownMenu>
</template>
