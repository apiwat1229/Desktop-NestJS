import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import { en } from './locales/en';
import { th } from './locales/th';

// Get saved language or default to English
const savedLanguage = typeof window !== 'undefined'
    ? localStorage.getItem('language') || 'en'
    : 'en';

console.log('Loaded EN translation keys:', Object.keys(en)); // Debug logging
console.log('Does userProfile exist?', 'userProfile' in en); // Debug logging

i18n
    .use(initReactI18next)
    .init({
        resources: {
            en: { translation: en },
            th: { translation: th },
        },
        lng: savedLanguage,
        fallbackLng: 'en',
        interpolation: {
            escapeValue: false,
        },
        react: {
            useSuspense: false,
        },
        debug: true, // Force reload
    });


export default i18n; // Rebuild trigger
