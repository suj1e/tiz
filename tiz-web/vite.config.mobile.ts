import path from 'path'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), tailwindcss()],
  root: '.',
  publicDir: 'public',
  build: {
    outDir: 'dist/mobile',
    rollupOptions: {
      input: {
        main: path.resolve(__dirname, 'index.mobile.html'),
      },
    },
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src/shared'),
      '@mobile': path.resolve(__dirname, './src/mobile'),
      '@lark': path.resolve(__dirname, './src/lark'),
    },
  },
  server: {
    port: 5174,
  },
})
