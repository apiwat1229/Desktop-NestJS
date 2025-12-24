import vue from '@vitejs/plugin-vue'
import path from 'node:path'
import Components from 'unplugin-vue-components/vite'
import { defineConfig } from 'vite'
import electron from 'vite-plugin-electron/simple'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    vue(),
    Components({
      dts: true,
      dirs: ['src/components'],
      resolvers: [
        // Custom resolver for UI components
        (componentName) => {
          // Auto-import from components/ui/*
          if (componentName.startsWith('Alert') ||
            componentName.startsWith('Dialog') ||
            componentName.startsWith('Button') ||
            componentName.startsWith('Input') ||
            componentName.startsWith('Label') ||
            componentName.startsWith('Select') ||
            componentName.startsWith('Card') ||
            componentName.startsWith('Badge') ||
            componentName.startsWith('Tabs') ||
            componentName.startsWith('Table') ||
            componentName.startsWith('Checkbox') ||
            componentName.startsWith('Avatar') ||
            componentName.startsWith('Dropdown') ||
            componentName.startsWith('Sheet') ||
            componentName.startsWith('Popover') ||
            componentName.startsWith('Command') ||
            componentName.startsWith('Separator') ||
            componentName.startsWith('Scroll') ||
            componentName.startsWith('Toast') ||
            componentName.startsWith('Switch') ||
            componentName.startsWith('Radio') ||
            componentName.startsWith('Slider') ||
            componentName.startsWith('Progress') ||
            componentName.startsWith('Skeleton')) {

            // Map component names to their directories
            const dirMap: Record<string, string> = {
              'Alert': 'alert',
              'AlertDialog': 'alert-dialog',
              'Button': 'button',
              'Card': 'card',
              'Dialog': 'dialog',
              'Input': 'input',
              'Label': 'label',
              'Select': 'select',
              'Badge': 'badge',
              'Tabs': 'tabs',
              'Table': 'table',
              'Checkbox': 'checkbox',
              'Avatar': 'avatar',
              'Dropdown': 'dropdown-menu',
              'Sheet': 'sheet',
              'Popover': 'popover',
              'Command': 'command',
              'Separator': 'separator',
              'Scroll': 'scroll-area',
              'Toast': 'toast',
              'Switch': 'switch',
              'Radio': 'radio-group',
              'Slider': 'slider',
              'Progress': 'progress',
              'Skeleton': 'skeleton',
            }

            // Find matching directory
            for (const [prefix, dir] of Object.entries(dirMap)) {
              if (componentName.startsWith(prefix)) {
                return {
                  name: componentName,
                  from: `@/components/ui/${dir}`
                }
              }
            }
          }
        }
      ]
    }),
    electron({
      main: {
        // Shortcut of `build.lib.entry`.
        entry: 'electron/main.ts',
      },
      preload: {
        // Shortcut of `build.rollupOptions.input`.
        // Preload scripts may contain Web assets, so use the `build.rollupOptions.input` instead `build.lib.entry`.
        input: path.join(__dirname, 'electron/preload.ts'),
      },
      // Ployfill the Electron and Node.js API for Renderer process.
      // If you want use Node.js in Renderer process, the `nodeIntegration` needs to be enabled in the Main process.
      // See 👉 https://github.com/electron-vite/vite-plugin-electron-renderer
      renderer: process.env.NODE_ENV === 'test'
        // https://github.com/electron-vite/vite-plugin-electron-renderer/issues/78#issuecomment-2053600808
        ? undefined
        : {},
    }),
  ],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
})
