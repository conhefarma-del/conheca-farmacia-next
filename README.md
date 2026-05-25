# Conheca Farmacia — Portal de Educacao e Gestao Clinica

[![Security: Verified](https://img.shields.io/badge/Security-Security--First-green?style=flat-square)](#arquitetura-de-seguranca)
[![Database: Supabase](https://img.shields.io/badge/Database-Supabase-3ECF8E?style=flat-square&logo=supabase)](https://supabase.com)
[![Framework: Vite](https://img.shields.io/badge/Framework-Vite-646CFF?style=flat-square&logo=vite)](https://vitejs.dev)

O **Conheca Farmacia** e uma plataforma dedicada a promover o papel clinico do farmaceutico no ecossistema de saude. Artigos cientificos, eventos, lives, pesquisa global e suporte bilingue (PT/EN).

---

## Inicio Rapido

> **IMPORTANTE:** Este projeto usa Vite e **NAO** pode ser aberto diretamente no browser (file://). E necessario um servidor de desenvolvimento.

```bash
npm install
npm run dev
# Abre em http://localhost:5173

npm run build
npm run preview
```

---

## Stack Tecnologica

| Componente     | Tecnologia                                  | Proposito                       |
| -------------- | ------------------------------------------- | ------------------------------- |
| **Frontend**   | HTML5, Tailwind CSS v4, JavaScript (ES6+)   | Interface e logica de cliente   |
| **Bundler**    | Vite.js                                     | Performance otimizada e HMR     |
| **Backend**    | Supabase (PostgreSQL, Auth, Edge Functions) | Banco de dados e API serverless |
| **Seguranca**  | DOMPurify, RLS, CSP headers                 | Sanitizacao de XSS              |
| **Email**      | Resend                                      | Transacoes de email             |
| **Deployment** | Netlify                                     | Hospedagem estatica e CI/CD     |

---

## Funcionalidades

### Paginas Publicas (12)

| Pagina | Descricao |
|--------|-----------|
| `index.html` | Homepage com hero animado, artigos e eventos destaque |
| `pesquisa.html` | Pesquisa global (artigos, eventos, lives) com filtros e paginacao |
| `artigos.html` | Listagem de artigos com filtros por categoria |
| `artigo.html` | Detalhe de artigo individual (Markdown + DOMPurify) |
| `eventos.html` | Listagem de eventos com filtros por tipo |
| `evento.html` | Detalhe de evento com palestrantes e inscricao |
| `lives-list.html` | Listagem de lives e webinars |
| `lives.html` | Detalhe de live individual |
| `inscricao.html` | Formulario de inscricao com validacao dupla |
| `sobre.html` | Sobre a organizacao |
| `unsubscribe.html` | Cancelamento de newsletter |
| `404.html` | Pagina de erro |

### Recursos Transversais

- **Pesquisa global**: Input na utility bar (mobile redireciona para pesquisa.html), pesquisa por Enter/botao, 15 resultados/pagina com paginacao client-side, destaque de termos pesquisados
- **Dark mode**: Toggle no header e drawer mobile, persistencia em localStorage
- **i18n PT/EN**: Dropdown na utility bar com globo, persistencia em localStorage, atributos `data-i18n` nos elementos
- **Breadcrumbs**: Navegacao hierarquica nas paginas de detalhe
- **SEO completo**: Meta tags, Open Graph, Twitter Card, JSON-LD, canonical URLs, sitemap.xml
- **Analytics**: Tracking de page views com filtros temporais (Dia/Semana/Mes/6M/1A)

### CMS Admin

- **URL**: `/src/admin/index.html` (dev) ou `/admin/index.html` (producao)
- **Auth**: Supabase Auth + 2FA TOTP + gate de perguntas secretas
- **Funcionalidades**: CRUD artigos, eventos lives, dashboard analytics, gestao de newsletter, definicoes de perfil
- **Audit Logs**: Todas as acoes registadas em `audit_logs`
- **Image Upload**: Compressao automatica antes de upload para Supabase Storage

---

## Arquitetura de Seguranca

O projeto segue o paradigma **"Security-First"** com auditorias Red Team:

### RLS (Row Level Security)

Todas as tabelas usam RLS. Utilizadores anonimos tem permissao estrita apenas para INSERT em tabelas especificas.

### Sanitizacao Universal

`DOMPurify` limpa qualquer conteudo Markdown/HTML antes da renderizacao. `escapeHtml()` e `escapeAttr()` em `src/lib/security.js` para todos os innerHTML com dados externos.

### Anti-Spam

- Honeypot invisivel em formularios
- Rate limiting frontend (5s cooldown)
- Rate limiting backend (Edge Function: 5 requests/IP/minuto)

### Validacao em Duas Camadas

| Camada       | Validação                                                          |
| ------------ | ------------------------------------------------------------------ |
| **Frontend** | Regex (email RFC 5322, telefone Angola/Intl), maxLength, whitelist |
| **Backend**  | Edge Function revalida tudo + rate limiting + honeypot check       |
| **Database** | RLS Policies + CHECK constraints + UNIQUE constraints              |

### CSP Headers

Configurado no `netlify.toml`:
- `script-src 'self' https://cdn.jsdelivr.net https://unpkg.com`
- `style-src 'self' 'unsafe-inline' https://fonts.googleapis.com`
- Sem `unsafe-inline` para scripts (todos os scripts usam `type="module"` e `.addEventListener()`)

---

## Estrutura de Pastas

```
conheca-farmacia/
├── index.html                  # Homepage
├── pesquisa.html               # Pesquisa global
├── artigos.html / artigo.html  # Artigos (list + detail)
├── eventos.html / evento.html  # Eventos (list + detail)
├── lives-list.html / lives.html# Lives (list + detail)
├── inscricao.html              # Formulario de inscricao
├── sobre.html                  # Sobre
├── unsubscribe.html            # Newsletter unsubscribe
├── 404.html                    # Pagina de erro
│
├── main.js                     # Vite entry point
├── vite.config.js              # Vite config + rollupOptions
├── netlify.toml                # Deploy, redirects, headers
│
├── src/
│   ├── input.css               # Tailwind + CSS custom (@layer)
│   ├── config.js               # Supabase client
│   ├── script.js               # Nav, hamburger, search, lang dropdown
│   ├── dark-mode.js            # Theme toggle
│   ├── i18n.js                 # Translations (PT/EN)
│   ├── hero-animated.js        # Hero ticker animation
│   ├── pesquisa-logic.js       # Search page logic
│   ├── articles-logic.js       # Articles listing
│   ├── article-detail.js       # Article detail
│   ├── events-logic.js         # Events listing
│   ├── event-detail.js         # Event detail
│   ├── lives-logic.js          # Lives listing
│   ├── live-detail.js          # Live detail
│   │
│   ├── lib/                    # Shared modules
│   │   ├── api.js              # Supabase API layer
│   │   ├── search.js           # Global search
│   │   ├── security.js         # escapeHtml, escapeAttr, validateUrl
│   │   ├── seo.js              # SEO helpers
│   │   ├── analytics.js        # Page view tracking
│   │   ├── newsletter.js       # Newsletter subscription
│   │   ├── sitemap.js          # Sitemap generator
│   │   └── ...
│   │
│   └── admin/                  # CMS Admin panel
│       ├── index.html          # Login (split-screen)
│       ├── dashboard.html      # Stats + audit logs
│       ├── artigos/            # CRUD artigos
│       ├── eventos/            # CRUD eventos
│       ├── lives/              # CRUD lives
│       ├── definicoes.html     # Settings (2FA, profile)
│       └── newsletter.html     # Subscriber management
│
├── public/
│   ├── i18n/                   # pt.json, en.json
│   └── logo/                   # Logo variants
│
└── supabase/
    ├── migrations/             # Database migrations
    └── functions/              # Edge Functions
```

---

## Tabelas Supabase

| Tabela | Proposito | RLS |
|--------|-----------|-----|
| `articles` | Artigos publicados | Public read, admin write |
| `events` | Eventos e workshops | Public read, admin write |
| `lives` | Lives e webinars | Public read, admin write |
| `inscricoes` | Registros em eventos | Public insert, admin read |
| `admin_users` | Utilizadores admin | Admin only |
| `audit_logs` | Log de acoes admin | Admin only |
| `newsletter_subscribers` | Subscritores newsletter | Public insert, admin manage |
| `page_views` | Tracking de visitas | Public insert, admin read |

---

## Deploy (Netlify)

O deploy e automatico via GitHub:

1. Push para `main` → producao em `conhecafarmacia.netlify.app`
2. Pull requests → deploy previews
3. Build: `npm run build` (Vite + post-build admin relocate)
4. Sitemap gerado automaticamente com paginas do Supabase

Variaveis de ambiente necessarias no Netlify:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `RESEND_API_KEY` (para emails)

---

## Contacto

- **Email**: conhecerfarmacia@gmail.com
- **WhatsApp**: +244 925 696 002
- **Website**: conhecafarmacia.netlify.app

---

**Desenvolvido com excelencia para promover a pratica farmaceutica.**
