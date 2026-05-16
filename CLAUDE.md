# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 📋 Common Development Commands

### Development Server

```bash
# Start development server with hot-reload
npm run dev
# Opens at http://localhost:5173
```

### Production Build

```bash
# Build for production
npm run build
# Preview production build
npm run preview
```

### Code Formatting

```bash
# Format code with Prettier
npm run format
```

### Dependencies

```bash
# Install dependencies
npm install
```

## 🏗️ Project Architecture & Structure

### Core Technologies

- **Framework**: Vite (ES modules, hot module replacement)
- **Styling**: Tailwind CSS v4 (via `@tailwindcss/vite` plugin)
- **Backend**: Supabase (PostgreSQL, Auth, RLS, Edge Functions)
- **CMS**: Painel admin interno (src/admin/) para gerir artigos, eventos, lives
- **State Management**: Vanilla JavaScript (no framework)

### Key Directories & Files

```
├── index.html # Main HTML entry
├── main.js # Vite entry point
├── vite.config.js # Vite configuration
├── src/
│ ├── input.css # Tailwind CSS directives
│ ├── script.js # Global navigation, DOM utilities
│ ├── config.js # Supabase client (persistSession: true para admin)
│ ├── lib/
│ │ ├── api.js # API layer: getArticles(), getEvents(), getLives()
│ │ ├── fallback-data.js # Fallback para JSON local
│ │ ├── capacity-cache.js # Cache de capacidade (15s)
│ │ ├── polling.js # Polling de vagas (cleanup, visibility detection)
│ │ └── supabaseClient.js # Cliente Supabase partilhado
│ ├── admin/ # CMS Admin (gerir conteúdo)
│ │ ├── index.html # Login page
│ │ ├── dashboard.html # Stats e activity
│ │ ├── artigos/ # CRUD artigos
│ │ ├── eventos/ # CRUD eventos
│ │ ├── lives/ # CRUD lives
│ │ ├── lib/
│ │ │ ├── auth.js # Auth Supabase
│ │ │ ├── image-compressor.js # Compressão de imagens
│ │ │ └── audit-logger.js # Logging de ações
│ │ └── styles/ # CSS exclusivo do admin
│ ├── content/ # JSON catalogs (fallback)
│ │ ├── articles-catalog.json
│ │ ├── events-catalog.json
│ │ ├── lives-catalog.json
│ │ └── ARTICLE_GUIDELINES.md
│ ├── migrations/ # Backup e migrations de dados
│ └── detail-pages/
│     ├── article-detail.js # Renderização de artigo
│     ├── event-detail.js # Renderização de evento
│     └── live-detail.js # Renderização de live
├── public/ # Static assets
└── dist/ # Production build
```

### Data Flow (CMS + Supabase)

1. **Content Sources**: Supabase (primary) + JSON fallback (src/content/)
2. **API Layer**: `src/lib/api.js` normaliza dados (snake_case → camelCase)
3. **Rendering**: Detail pages usam `getEventBySlug()`, `getArticleBySlug()`, etc.
4. **Admin CMS**: Cria/edita conteúdo → Supabase → Site público (leitura)
5. **Fallback**: Se Supabase falhar, usa JSON local

### Supabase Integration

- **Configuration**: `src/config.js` (client-side), `src/lib/supabaseClient.js` (shared)
- **Tables**: `articles`, `events`, `lives`, `inscricoes`, `admin_users`, `audit_logs`
- **RLS**: Ativo em todas as tabelas (apenas admins escrevem, público lê publicado)
- **Edge Functions**: Validação de inscrições, email transacional
- **Auth**: Admins autenticados via Supabase Auth (persistSession: true obrigatório)

### Admin CMS

- **Acesso**: `/src/admin/index.html` — apenas utilizadores em `admin_users`
- **Funcionalidades**: CRUD completo para artigos, eventos, lives
- **Audit Logs**: Todas as ações registadas em `audit_logs`
- **Image Upload**: Compressão automática antes de upload para Supabase Storage

## ⚠️ Lições Aprendidas (Erros a Evitar)

### 1. Edição de Ficheiros JavaScript

**Problema**: Quando editar funções em ficheiros JS, garantir que:
- Todas as chaves de abertura têm correspondente de fecho
- Não deixar código incompleto no final do ficheiro
- Validar sintaxe com `node --check` antes de testar no browser

**Solução**: 
```bash
node --check src/event-detail.js  # Deve retornar vazio (sem erros)
```

### 2. Substituição de Funções em Ficheiros Existentes

**Problema**: Ao substituir funções inteiras, o padrão de busca pode não ser exato devido a:
- Diferenças de whitespace (espaços vs tabs)
- Linhas em branco a mais ou a menos
- Comentários adjacentes

**Solução**:
1. Ler o ficheiro completo primeiro
2. Identificar marcadores únicos (comentários JSDoc, assinaturas de função)
3. Usar Python para substituições complexas em vez de Edit tool
4. Validar com `node --check` após edição

### 3. Gerir Estado em Funções de Renderização

**Problema**: Adicionar botões "Show More/Show Less" requer:
- Referências a variáveis de estado (limite mobile/desktop)
- Event listeners que persistem após re-renderização
- Cuidado com resize handlers que podem quebrar estado

**Solução**:
- Evitar resize handlers que re-renderizam — pode quebrar estado de botões
- Se necessário, usar debounce e limpar estado antes de re-renderizar
- Manter referência a dados originais para re-renderização

### 4. Validação de Sintaxe Após Edição de Ficheiros JavaScript

**Problema**: Durante a implementação do botão "Show More" para palestrantes (2026-05-16), o ficheiro `src/event-detail.js` tinha um erro de sintaxe — faltava um fechamento `});` para o bloco `DOMContentLoaded`. O Vite falhava com erro `Expected '}' but found 'EOF'` e o build não compilava.

**Sintoma**: Erro no Vite: `[PARSE_ERROR] Error: Expected '}' but found 'EOF'` em `src/event-detail.js`

**Solução**:
1. Após qualquer edição em ficheiros JavaScript, validar sintaxe ANTES de testar no browser:
```bash
node --check src/event-detail.js  # Deve retornar vazio (sem erros)
```
2. Se houver erro, contar chaves `{` vs `}` para identificar blocos em falta:
```bash
python3 -c "content=open('src/event-detail.js').read(); print(f'Abertas: {content.count(\"{\")}, Fechadas: {content.count(\"}\")}')"
```
3. Adicionar fechamentos em falta no final do ficheiro
4. Validar novamente com `node --check`

**Prevenção**: Ao editar funções ou adicionar código, sempre:
- Contar blocos abertos vs fechados
- Validar sintaxe com `node --check` antes de fazer commit
- Verificar se `DOMContentLoaded` e `try/catch` estão devidamente fechados

### 5. Configuração de Auth para Admin

**Problema**: Ciclo infinito de login no admin se `persistSession: false`

**Solução**: `config.js` deve ter `persistSession: true` para admin CMS. Ver `memory:cms-admin-auth-fix.md`.

### Important Notes

- **Development**: Must use `npm run dev` — direct file:// opening fails (ES modules)
- **CSS Injection**: Tailwind CSS injected via JavaScript during Vite dev
- **Routing**: Client-side via hash/fragment + programmatic navigation
- **Security**: DOMPurify for Markdown; RLS policies; no secrets in frontend
- **Admin Auth**: `persistSession: true` obrigatório em `config.js` para admin
