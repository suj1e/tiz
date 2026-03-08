import path from 'path'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), tailwindcss()],
  root: path.resolve(__dirname, '.'),
  publicDir: 'public',
  build: {
    outDir: 'dist/desktop',
    rollupOptions: {
      input: {
        main: path.resolve(__dirname, 'index.desktop.html'),
      },
    },
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src/shared'),
      '@desktop': path.resolve(__dirname, './src/desktop'),
      '@lark': path.resolve(__dirname, './src/lark'),
    },
  },
  server: {
    port: 5173,
  },
})
