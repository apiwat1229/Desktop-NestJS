import { defineStore } from 'pinia';
import { ref, watch } from 'vue';
import { storage } from '../services/storage';

export const useThemeStore = defineStore('theme', () => {
    const themeColor = ref(storage.get('theme_color') || 'zinc');
    const fontSize = ref(storage.get('font_size') || 'medium');
    const isDark = ref(storage.get('is_dark') || false);

    // Define color palettes (HSL values without hsl())
    // Based on Shadcn UI themes
    const colors: Record<string, any> = {
        zinc: {
            primary: '240 5.9% 10%',
            primaryForeground: '0 0% 98%',
            colorClass: 'text-zinc-500',
        },
        slate: {
            primary: '222.2 47.4% 11.2%',
            primaryForeground: '210 40% 98%',
            colorClass: 'text-slate-500',
        },
        stone: {
            primary: '24 9.8% 10%',
            primaryForeground: '60 9.1% 97.8%',
            colorClass: 'text-stone-500',
        },
        red: {
            primary: '0 72.2% 50.6%',
            primaryForeground: '0 85.7% 97.3%',
            colorClass: 'text-red-500',
        },
        cyan: {
            primary: '190 95% 39%',
            primaryForeground: '0 0% 100%',
            colorClass: 'text-cyan-500',
        },
        orange: {
            primary: '24.6 95% 53.1%',
            primaryForeground: '60 9.1% 97.8%',
            colorClass: 'text-orange-500',
        },
        green: {
            primary: '142.1 76.2% 36.3%',
            primaryForeground: '355.7 100% 97.3%',
            colorClass: 'text-green-500',
        },
        blue: {
            primary: '221.2 83.2% 53.3%',
            primaryForeground: '210 40% 98%',
            colorClass: 'text-blue-500',
        },
        yellow: {
            primary: '47.9 95.8% 53.1%',
            primaryForeground: '26 83.3% 14.1%',
            colorClass: 'text-yellow-500',
        },
        violet: {
            primary: '262.1 83.3% 57.8%',
            primaryForeground: '210 40% 98%',
            colorClass: 'text-violet-500',
        },
    };

    const fontSizes: Record<string, string> = {
        small: '14px',
        medium: '15px',
        large: '16px',
        xl: '18px',
    };

    // Apply changes to DOM
    const applyTheme = () => {
        const root = document.documentElement;

        // Apply Color
        const color = colors[themeColor.value] || colors.zinc;
        root.style.setProperty('--primary', color.primary);
        root.style.setProperty('--primary-foreground', color.primaryForeground);

        // Apply Font Size
        const size = fontSizes[fontSize.value] || fontSizes.medium;
        root.style.fontSize = size;

        // Apply Dark Mode (Using class)
        if (isDark.value) {
            document.documentElement.classList.add('dark');
        } else {
            document.documentElement.classList.remove('dark');
        }
    };

    // Persist changes
    watch(themeColor, (val) => {
        storage.set('theme_color', val);
        applyTheme();
    });

    watch(fontSize, (val) => {
        storage.set('font_size', val);
        applyTheme();
    });

    watch(isDark, (val) => {
        storage.set('is_dark', val);
        applyTheme();
    });

    // Initialize
    applyTheme();

    return {
        themeColor,
        fontSize,
        colors,
        isDark,
        toggleDark: () => (isDark.value = !isDark.value),
    };
});
