import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  base: '/open-source/tools/ask-the-program/',
  plugins: [react()]
})
