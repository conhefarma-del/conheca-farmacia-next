import { defineConfig } from "vite";
import { resolve } from "path";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  plugins: [tailwindcss()],
  root: ".",
  publicDir: "public",
  build: {
    outDir: "dist",
    emptyOutDir: true,
    rollupOptions: {
      input: {
        main: resolve(__dirname, "index.html"),
        artigos: resolve(__dirname, "artigos.html"),
        artigo: resolve(__dirname, "artigo.html"),
        eventos: resolve(__dirname, "eventos.html"),
        evento: resolve(__dirname, "evento.html"),
        inscricao: resolve(__dirname, "inscricao.html"),
        sobre: resolve(__dirname, "sobre.html"),
        lives: resolve(__dirname, "lives.html"),
        livesList: resolve(__dirname, "lives-list.html"),
        notFound: resolve(__dirname, "404.html"),
        unsubscribe: resolve(__dirname, "unsubscribe.html"),
        // Admin CMS
        adminLogin: resolve(__dirname, "src/admin/index.html"),
        adminDashboard: resolve(__dirname, "src/admin/dashboard.html"),
        adminArtigosIndex: resolve(__dirname, "src/admin/artigos/index.html"),
        adminArtigosNew: resolve(__dirname, "src/admin/artigos/new.html"),
        adminArtigosEdit: resolve(__dirname, "src/admin/artigos/edit.html"),
        adminEventosIndex: resolve(__dirname, "src/admin/eventos/index.html"),
        adminEventosNew: resolve(__dirname, "src/admin/eventos/new.html"),
        adminEventosEdit: resolve(__dirname, "src/admin/eventos/edit.html"),
        adminLivesIndex: resolve(__dirname, "src/admin/lives/index.html"),
        adminLivesNew: resolve(__dirname, "src/admin/lives/new.html"),
        adminLivesEdit: resolve(__dirname, "src/admin/lives/edit.html"),
        adminDefinicoes: resolve(__dirname, "src/admin/definicoes.html"),
        adminNewsletter: resolve(__dirname, "src/admin/newsletter.html"),
      },
    },
  },
  server: {
    port: 5173,
    open: false,
  },
});
