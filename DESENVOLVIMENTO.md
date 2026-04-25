# Como Desenvolver

## Importante: Como Visualizar o Site

Após a migração para o Vite, **NÃO** podes abrir os ficheiros HTML diretamente no browser (file://). O Vite requer um servidor para injetar o CSS e JavaScript.

### Opção 1: Servidor de Desenvolvimento (Recomendado)

```bash
npm run dev
```

Isto vai iniciar o servidor Vite em `http://localhost:5173` com hot-reload automático.

### Opção 2: Build de Produção

```bash
npm run build
npm run preview
```

Isto compila o site para a pasta `dist/` e serve a versão de produção.

## Estrutura do Projeto

```
├── index.html          # HTML (sem CSS injetado - usa o servidor!)
├── main.js             # Entry point do Vite
├── vite.config.js      # Configuração do Vite
├── src/
│   ├── script.js       # Navegação
│   ├── config.js       # Supabase config
│   ├── input.css       # Tailwind CSS
│   └── content/        # JSON catalogs
└── dist/               # Build de produção (CSS injetado)
```

## Porquê que o CSS não carrega?

O Vite usa **módulos ES6** para carregar CSS/JS. Quando abres o ficheiro HTML diretamente:
- O browser não consegue carregar módulos ES6 sem servidor (CORS)
- O CSS é injetado via JavaScript
- Os paths dos assets são relativos à raiz do servidor

**Solução:** Usa sempre `npm run dev` durante o desenvolvimento.
