import { defineConfig } from 'vite'
import { resolve } from 'path'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
  plugins: [
    tailwindcss(),
  ],
  root: '.',
  publicDir: 'public',
  build: {
    outDir: 'dist',
    emptyOutDir: true,
    rollupOptions: {
      input: {
        main: resolve(__dirname, 'index.html'),
        artigos: resolve(__dirname, 'artigos.html'),
        artigo: resolve(__dirname, 'artigo.html'),
        eventos: resolve(__dirname, 'eventos.html'),
        evento: resolve(__dirname, 'evento.html'),
        inscricao: resolve(__dirname, 'inscricao.html'),
        sobre: resolve(__dirname, 'sobre.html'),
        lives: resolve(__dirname, 'lives.html'),
        livesList: resolve(__dirname, 'lives-list.html'),
      },
    },
  },
  server: {
    port: 5173,
    open: false,
  },
})
