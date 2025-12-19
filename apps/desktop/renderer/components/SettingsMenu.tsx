import { useTranslation } from 'react-i18next';
import { useSettings } from '../contexts/SettingsContext';

interface SettingsMenuProps {
  onClose: () => void;
}

export default function SettingsMenu({ onClose }: SettingsMenuProps) {
  const {
    theme,
    fontSize,
    primaryColor,
    borderRadius,
    fontFamily,
    setTheme,
    setFontSize,
    setPrimaryColor,
    setBorderRadius,
    setFontFamily,
  } = useSettings();
  const { t } = useTranslation();

  const colors = [
    '#3B82F6', // Blue
    '#EF4444', // Red
    '#F97316', // Orange
    '#22C55E', // Green
    '#06B6D4', // Cyan
    '#8B5CF6', // Purple
    '#EC4899', // Pink
    '#000000', // Black
  ];

  const fonts = [
    'Sarabun',
    'Kanit',
    'Prompt',
    'Mitr',
    'Taviraj',
    'Trirong',
    'Chakra Petch',
    'Bai Jamjuree',
    'Noto Sans Thai',
  ];

  return (
    <div className="absolute right-0 mt-2 w-80 bg-white dark:bg-gray-800 backdrop-blur-xl border border-gray-200 dark:border-gray-700 rounded-lg shadow-2xl p-6 z-[60] animate-in fade-in zoom-in duration-200 origin-top-right">
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-lg font-bold text-gray-900 dark:text-white">{t('settings.title')}</h2>
      </div>

      <div className="space-y-6">
        {/* Theme Mode */}
        <div className="flex items-center justify-between">
          <span className="text-sm font-medium text-gray-700 dark:text-gray-300">
            {t('settings.themeMode')}
          </span>
          <div className="flex bg-gray-100 dark:bg-gray-800 p-1 rounded-full border border-gray-200 dark:border-gray-700">
            <button
              onClick={() => setTheme('light')}
              className={`p-2 rounded-full transition-all ${
                theme === 'light'
                  ? 'bg-white text-yellow-500 shadow-sm'
                  : 'text-gray-400 hover:text-gray-600 dark:hover:text-gray-300'
              }`}
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                width="20"
                height="20"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
              >
                <circle cx="12" cy="12" r="4" />
                <path d="M12 2v2" />
                <path d="M12 20v2" />
                <path d="m4.93 4.93 1.41 1.41" />
                <path d="m17.66 17.66 1.41 1.41" />
                <path d="M2 12h2" />
                <path d="M20 12h2" />
                <path d="m6.34 17.66-1.41 1.41" />
                <path d="m19.07 4.93-1.41 1.41" />
              </svg>
            </button>
            <button
              onClick={() => setTheme('dark')}
              className={`p-2 rounded-full transition-all ${
                theme === 'dark'
                  ? 'bg-gray-700 text-blue-400 shadow-sm'
                  : 'text-gray-400 hover:text-gray-600 dark:hover:text-gray-300'
              }`}
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                width="20"
                height="20"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
              >
                <path d="M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z" />
              </svg>
            </button>
          </div>
        </div>

        <div className="h-px bg-gray-100" />

        {/* Font Size */}
        <div>
          <div className="flex items-center justify-between mb-4">
            <span className="text-sm font-medium text-gray-700">{t('settings.fontSize')}</span>
            <span className="text-sm font-semibold text-gray-500">{fontSize}px</span>
          </div>
          <div className="flex gap-2">
            <button
              onClick={() => setFontSize(Math.max(12, fontSize - 1))}
              className="flex-1 py-2.5 bg-gray-50 hover:bg-gray-100 dark:bg-gray-700 dark:hover:bg-gray-600 rounded-lg text-sm font-medium transition-colors border border-gray-100 dark:border-gray-600 text-gray-900 dark:text-gray-100"
            >
              A-
            </button>
            <button
              onClick={() => setFontSize(Math.min(24, fontSize + 1))}
              className="flex-1 py-2.5 bg-gray-50 hover:bg-gray-100 dark:bg-gray-700 dark:hover:bg-gray-600 rounded-lg text-sm font-medium transition-colors border border-gray-100 dark:border-gray-600 text-gray-900 dark:text-gray-100"
            >
              A+
            </button>
          </div>
        </div>

        <div className="h-px bg-gray-100" />

        {/* Primary Color */}
        <div>
          <span className="block text-sm font-medium text-gray-700 mb-4">
            {t('settings.primaryColor')}
          </span>
          <div className="grid grid-cols-8 gap-2">
            {colors.map((color) => (
              <button
                key={color}
                onClick={() => setPrimaryColor(color)}
                className={`w-7 h-7 rounded-full transition-all hover:scale-110 active:scale-95 border-2 ${
                  primaryColor.toLowerCase() === color.toLowerCase()
                    ? 'border-gray-900 dark:border-white ring-2 ring-offset-2 ring-offset-white dark:ring-offset-gray-900 ring-transparent'
                    : 'border-transparent'
                }`}
                style={{ backgroundColor: color }}
              />
            ))}
          </div>
        </div>

        <div className="h-px bg-gray-100" />

        {/* Border Radius */}
        <div>
          <div className="flex items-center justify-between mb-4">
            <span className="text-sm font-medium text-gray-700 dark:text-gray-300">
              {t('settings.roundness')}
            </span>
            <span className="text-sm font-semibold text-gray-500">{borderRadius}px</span>
          </div>
          <div className="flex gap-2">
            {[0, 4, 8, 12, 16].map((radius) => (
              <button
                key={radius}
                onClick={() => setBorderRadius(radius)}
                className={`flex-1 py-2 bg-gray-50 hover:bg-gray-100 dark:bg-gray-700 dark:hover:bg-gray-600 border border-gray-200 dark:border-gray-600 transition-all ${
                  borderRadius === radius ? 'ring-2 ring-blue-500 border-transparent' : ''
                }`}
                style={{ borderRadius: radius }}
              >
                <div
                  className="w-4 h-4 border-2 border-current mx-auto"
                  style={{ borderRadius: radius === 0 ? 0 : Math.min(radius, 6) }}
                />
              </button>
            ))}
          </div>
        </div>

        <div className="h-px bg-gray-100" />

        {/* Font Family */}
        <div>
          <span className="block text-sm font-medium text-gray-700 mb-4">
            {t('settings.fontFamily')}
          </span>
          <div className="grid grid-cols-2 gap-2">
            {fonts.map((font) => (
              <button
                key={font}
                onClick={() => setFontFamily(font)}
                className={`px-3 py-2.5 rounded-lg text-sm transition-all text-left ${
                  fontFamily === font
                    ? 'bg-blue-50 text-blue-600 font-medium'
                    : 'text-gray-600 hover:bg-gray-50'
                }`}
                style={{ fontFamily: font }}
              >
                {font}
              </button>
            ))}
          </div>
        </div>

        {/* Admin Panel Link */}
        {(() => {
          try {
            const userStr = localStorage.getItem('user');
            if (userStr) {
              const user = JSON.parse(userStr);
              if (user.role && (user.role === 'admin' || user.role === 'ADMIN')) {
                return (
                  <div>
                    <div className="h-px bg-gray-100 mb-6" />
                    <button
                      onClick={() => (window.location.href = '/admin')}
                      className="w-full flex items-center justify-center gap-2 px-4 py-2 bg-primary/10 hover:bg-primary/20 text-primary rounded-xl font-medium transition-colors"
                    >
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        width="18"
                        height="18"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        strokeWidth="2"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                      >
                        <rect width="18" height="18" x="3" y="3" rx="2" ry="2" />
                        <line x1="3" x2="21" y1="9" y2="9" />
                        <line x1="9" x2="9" y1="21" y2="9" />
                      </svg>
                      {t('settings.adminPanel')}
                    </button>
                  </div>
                );
              }
            }
          } catch (e) {
            console.error('Error parsing user data', e);
          }
          return null;
        })()}
      </div>
    </div>
  );
}
