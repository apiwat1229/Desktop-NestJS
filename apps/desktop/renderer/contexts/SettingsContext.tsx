import React, { createContext, ReactNode, useContext, useEffect, useState } from 'react';

export type Theme = 'light' | 'dark';

export interface SettingsContextType {
  theme: Theme;
  fontSize: number;
  primaryColor: string;
  borderRadius: number;
  fontFamily: string;
  setTheme: (theme: Theme) => void;
  setFontSize: (size: number) => void;
  setPrimaryColor: (color: string) => void;
  setBorderRadius: (radius: number) => void;
  setFontFamily: (font: string) => void;
}

const SettingsContext = createContext<SettingsContextType | undefined>(undefined);

export const useSettings = () => {
  const context = useContext(SettingsContext);
  if (!context) {
    throw new Error('useSettings must be used within a SettingsProvider');
  }
  return context;
};

// Helper to convert Hex to HSL
const hexToHSL = (hex: string) => {
  let r = 0,
    g = 0,
    b = 0;
  if (hex.length === 4) {
    r = parseInt('0x' + hex[1] + hex[1]);
    g = parseInt('0x' + hex[2] + hex[2]);
    b = parseInt('0x' + hex[3] + hex[3]);
  } else if (hex.length === 7) {
    r = parseInt('0x' + hex[1] + hex[2]);
    g = parseInt('0x' + hex[3] + hex[4]);
    b = parseInt('0x' + hex[5] + hex[6]);
  }

  r /= 255;
  g /= 255;
  b /= 255;

  let cmin = Math.min(r, g, b),
    cmax = Math.max(r, g, b),
    delta = cmax - cmin,
    h = 0,
    s = 0,
    l = 0;

  if (delta === 0) h = 0;
  else if (cmax === r) h = ((g - b) / delta) % 6;
  else if (cmax === g) h = (b - r) / delta + 2;
  else h = (r - g) / delta + 4;

  h = Math.round(h * 60);

  if (h < 0) h += 360;

  l = (cmax + cmin) / 2;
  s = delta === 0 ? 0 : delta / (1 - Math.abs(2 * l - 1));

  s = +(s * 100).toFixed(1);
  l = +(l * 100).toFixed(1);

  return `${h} ${s}% ${l}%`;
};

interface SettingsProviderProps {
  children: ReactNode;
}

export const SettingsProvider: React.FC<SettingsProviderProps> = ({ children }) => {
  const [theme, setTheme] = useState<Theme>('light');
  const [fontSize, setFontSize] = useState(15);
  const [primaryColor, setPrimaryColor] = useState('#3B82F6');
  const [borderRadius, setBorderRadius] = useState(8);
  const [fontFamily, setFontFamily] = useState('Bai Jamjuree');

  // Load settings from localStorage on mount
  useEffect(() => {
    const savedTheme = localStorage.getItem('theme') as Theme;
    const savedFontSize = localStorage.getItem('fontSize');
    const savedPrimaryColor = localStorage.getItem('primaryColor');
    const savedBorderRadius = localStorage.getItem('borderRadius');
    const savedFontFamily = localStorage.getItem('fontFamily');

    if (savedTheme) setTheme(savedTheme);
    if (savedFontSize) setFontSize(parseInt(savedFontSize));
    if (savedPrimaryColor) setPrimaryColor(savedPrimaryColor);
    // Force default border radius of 8px
    setBorderRadius(8);
    // if (savedBorderRadius) setBorderRadius(parseInt(savedBorderRadius));
    if (savedFontFamily) setFontFamily(savedFontFamily);
  }, []);

  // Apply settings to document root
  useEffect(() => {
    const root = document.documentElement;

    // Apply theme
    root.setAttribute('data-theme', theme);
    localStorage.setItem('theme', theme);

    // Apply font size
    root.style.setProperty('--base-font-size', `${fontSize}px`);
    // Force global font size scaling on HTML element
    root.style.fontSize = `${fontSize}px`;
    localStorage.setItem('fontSize', fontSize.toString());

    // Apply primary color (Hex for simple usage)
    root.style.setProperty('--primary-color', primaryColor);

    // Apply primary color (HSL for Tailwind/Shadcn)
    const hsl = hexToHSL(primaryColor);
    root.style.setProperty('--primary', hsl);
    // Also update ring color to match primary for focus states
    root.style.setProperty('--ring', hsl);

    localStorage.setItem('primaryColor', primaryColor);

    // Apply border radius
    root.style.setProperty('--border-radius', `${borderRadius}px`);
    root.style.setProperty('--radius', `${borderRadius / 16}rem`); // Update Tailwind's --radius
    localStorage.setItem('borderRadius', borderRadius.toString());

    // Apply font family
    root.style.setProperty('--font-family', fontFamily);
    // Force global font family on HTML element
    root.style.fontFamily = fontFamily;
    localStorage.setItem('fontFamily', fontFamily);
  }, [theme, fontSize, primaryColor, borderRadius, fontFamily]);

  const value: SettingsContextType = {
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
  };

  return <SettingsContext.Provider value={value}>{children}</SettingsContext.Provider>;
};
