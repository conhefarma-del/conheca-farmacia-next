# Diretrizes de Seguranca — O Sentinela

> Referencia permanente para criacao e edicao de ficheiros no projeto Conheca Farmacia.
> Atualizado para **Next.js 16 App Router + Supabase + Vercel** (2026-06-02).
> **Leia ANTES de criar ou editar qualquer ficheiro.**

---

## 1. Identidade e Configuracao do Sistema

### SEC-AM-01 — Identidade do Projeto
O projeto **Conheca Farmacia** opera com anonimato tecnico. Nenhuma informacao de infraestrutura (IP, portas, stack) deve ser exposta em HTML ou respostas HTTP. As configuracoes residem em ficheiros locais protegidos por `.gitignore`.

### SEC-AM-02 — Estrutura de Configuracao (Next.js App Router)
A aplicacao segue o padrao **App Router + Server Components + Server Actions**. Configuracoes sensiveis residem em environment variables.

| Ambiente | Ficheiro/Recurso | Status |
|----------|------------------|--------|
| Producao | Vercel Environment Variables | Secreto/Remoto |
| Desenvolvimento | `.env.local` | Secreto/Local |
| Administrativo | `app/[lang]/(admin)/` | Exclusivo para `admin_users` |
| Build/Deploy | `next.config.mjs` + `vercel.json` | Publico (sem dados sensiveis) |

**Ferramentas:** Supabase (BaaS), Next.js 16 (Framework), Vercel (Hosting), Tailwind CSS v4.

---

## 2. Gestao de Autenticacao e Sessoes

### SEC-ATH-01 — Clientes Supabase SSR (3 Scopes)
O projeto usa 3 clientes Supabase com scopes distintos. **NUNCA** criar clientes duplicados.

```javascript
// lib/supabase/server.js — Server Components + Server Actions
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'
// Usa cookieStore.getAll() / setAll() — NUNCA persistSession:false

// lib/supabase/client.js — Client Components (browser)
import { createBrowserClient } from '@supabase/ssr'
// Usar createBrowserClient() — automaticamente gerencia sessao

// lib/supabase/middleware.js — Proxy (middleware)
// Usado APENAS no proxy.js para refresh de sessao
```

**PROIBIDO:** Criar `createClient()` fora destes 3 ficheiros.

### SEC-ATH-02 — Controle de Acesso Administrativo (Proxy + RLS)
O acesso admin tem **3 camadas** de protecao, por ordem de prioridade:

1. **Proxy (proxy.js)** — Barreira PRIMARIA. Verifica sessao + `admin_users` ANTES de servir a pagina. Sem bypass.
2. **AuthGuard (Client Component)** — Barreira SECUNDARIA. Redirect no cliente se o proxy falhar.
3. **Server Actions** — Cada acao admin chama `requireAdmin()` internamente.

```javascript
// PROIBIDO: AuthGuard como unica barreira
// O proxy DEVE verificar todas as rotas admin antes de servir HTML

// proxy.js — pattern correto:
if (pathname.match(/\/(pt|en)\/admin(\/|$)/)) {
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return NextResponse.redirect(loginUrl)
  const { data } = await supabase.from('admin_users')
    .select('user_id').eq('user_id', user.id).single()
  if (!data) return NextResponse.redirect(loginUrl)
}
```

### SEC-ATH-03 — Timeout de Sessao por Inatividade
Para mitigar hijacking de sessao, aplicar inactividade forcada apos 30 minutos.

```javascript
// components/admin/AuthGuard.jsx
const IDLE_TIMEOUT = 30 * 60 * 1000;
// Iniciar idle timeout em TODAS as paginas admin
```

**Ativo em:** Todas as paginas admin (dashboard, artigos, eventos, lives, newsletter, definicoes).

### SEC-ATH-04 — RLS SELECT Restrito em Tabelas Admin
Tabelas com dados administrativos (`admin_users`, `email_logs`) **NUNCA** devem ter `USING (true)` ou `qual: true` no SELECT para `authenticated`. Apenas admins podem ler.

```sql
-- PROIBIDO:
CREATE POLICY "Admin users can read admin_users" ON admin_users
  FOR SELECT TO authenticated USING (true);

-- CORRETO:
CREATE POLICY "Admin users can read admin_users" ON admin_users
  FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM admin_users au WHERE au.user_id = auth.uid()));
```

**Tabelas afetadas:** `admin_users`, `email_logs`, `inscricoes`, `audit_logs`.

---

## 3. Seguranca no Cliente (OWASP Top 10)

### SEC-XSS-01 — Sanitizacao com escapeHtml() em JSX
React escapa automaticamente `{expressoes}` em JSX. No entanto, `dangerouslySetInnerHTML` **REQUER** sanitizacao com DOMPurify.

```jsx
// SEGURO: JSX normal (React escapa automaticamente)
<h3>{article.title}</h3>
<p>{article.excerpt}</p>

// PROIBIDO sem DOMPurify:
<div dangerouslySetInnerHTML={{ __html: content }} />

// CORRETO:
import DOMPurify from 'dompurify'
const sanitized = DOMPurify.sanitize(content, {
  ALLOWED_TAGS: ['h1','h2','h3','h4','p','a','ul','ol','li','blockquote',
                  'code','pre','strong','em','img','br','hr','table',
                  'thead','tbody','tr','th','td'],
  ALLOWED_ATTR: ['href','src','alt','class','id','target','rel'],
})
<div dangerouslySetInnerHTML={{ __html: sanitized }} />
```

**Ficheiros que usam dangerouslySetInnerHTML:** `ArticleContent.jsx`, `PesquisaPageClient.jsx` (highlight).

### SEC-XSS-02 — Sanitizacao em Highlight de Pesquisa
A funcao `highlightText` em `PesquisaPageClient.jsx` usa `dangerouslySetInnerHTML` para destacar termos. O termo de pesquisa (user input) **DEVE** ser escapado antes de criar tags `<mark>`.

```jsx
import DOMPurify from 'dompurify'
import { escapeHtml } from '@/lib/security'

function highlightText(text, query) {
  if (!query) return escapeHtml(text)
  const escaped = escapeHtml(text)
  const escapedQuery = escapeHtml(query)
  const regex = new RegExp(
    `(${escapedQuery.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')})`, 'gi'
  )
  const highlighted = escaped.replace(regex, '<mark>$1</mark>')
  return DOMPurify.sanitize(highlighted, { ALLOWED_TAGS: ['mark'], ALLOWED_ATTR: [] })
}
```

### SEC-XSS-03 — Validacao de URLs com validateUrl()
URLs em `href` e `src` devem ser validadas para bloquear `javascript:`, `data:` e `vbscript:`.

```javascript
import { validateUrl } from '@/lib/security'
// Usar validateUrl() em todos os links dinamicos
```

**Ficheiros aplicados:** `LiveCard.jsx`, `LiveDetailPage`, componentes com links externos.

### SEC-XSS-04 — Codificacao de Slugs em href
Slugs usados em URLs devem ser codificados com `encodeURIComponent()`.

```jsx
// PROIBIDO:
<a href={`/eventos/${event.slug}`}>

// CORRETO:
<a href={`/eventos/${encodeURIComponent(event.slug)}`}>
```

### SEC-XSS-05 — DOMPurify em Todo dangerouslySetInnerHTML
QUALQUER uso de `dangerouslySetInnerHTML` no projeto **DEVE** ser precedido por `DOMPurify.sanitize()`. Sem excecoes.

```bash
# Verificar antes de commit:
grep -r "dangerouslySetInnerHTML" components/ app/
# Cada resultado DEVE ter DOMPurify.sanitize() no codigo proximo
```

---

## 4. Gestao de Dados e Endpoints

### SEC-API-01 — Restricao de Colunas em SELECT Publico
Tabelas com campos sensiveis (senhas, meeting_ids, access_links) devem usar select explicito em vez de `select('*')`.

```javascript
// PROIBIDO:
supabase.from('lives').select('*').eq('status', 'published')

// CORRETO:
supabase.from('lives')
  .select('id, slug, title, excerpt, category, date, time, platform, status')
  .eq('status', 'published')
```

### SEC-API-02 — Server Actions com requireAdmin()
Todas as Server Actions admin devem chamar `requireAdmin()` para verificar autorizacao.

```javascript
// lib/actions/content.js
async function requireAdmin() {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) throw new Error('Unauthorized')
  const { data } = await supabase.from('admin_users')
    .select('user_id').eq('user_id', user.id).single()
  if (!data) throw new Error('Forbidden')
}
```

### SEC-API-03 — Mensagens de Erro Genericas em Server Actions
**NUNCA** expor `error.message` do Supabase/PostgreSQL ao cliente. Estas mensagens podem conter nomes de colunas, tabelas e estrutura interna da base de dados.

```javascript
// PROIBIDO:
return { success: false, error: `Erro ao criar artigo: ${error.message}` }

// CORRETO:
console.error('Supabase error on createArticle:', error.code, error.message) // Log interno
return { success: false, error: 'Erro ao criar artigo. Tente novamente.' } // Mensagem generica
```

**Ficheiros afetados:** `lib/actions/content.js`, `lib/actions/settings.js`, todas as Server Actions.

### SEC-API-04 — CORS Whitelist em Edge Functions
Edge Functions **NUNCA** devem usar `Access-Control-Allow-Origin: *`. Sempre validar a origem contra uma whitelist.

```typescript
// PROIBIDO:
'Access-Control-Allow-Origin': '*'

// CORRETO:
const allowedOrigins = [
  'https://conheca-farmacia-next.vercel.app',
  'https://conhecafarmacia.com',
  'http://localhost:3000' // dev only
]
const origin = req.headers.get('origin') || ''
const corsOrigin = allowedOrigins.includes(origin) ? origin : allowedOrigins[0]
const headers = {
  'Access-Control-Allow-Origin': corsOrigin,
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  'Access-Control-Max-Age': '86400',
}
```

**Edge Functions afetadas:** `send-inscription-email`, `send-newsletter-email`, `validate-inscription`.

---

## 5. Hardening de Infraestrutura

### SEC-HRD-01 — Headers HTTP Obrigatorios (Vercel)
Definir politicas de conteudo restritivas no `vercel.json` (primario) e `next.config.mjs` (fallback).

```json
// vercel.json
{
  "headers": [{
    "source": "/(.*)",
    "headers": [
      { "key": "X-Frame-Options", "value": "DENY" },
      { "key": "X-XSS-Protection", "value": "1; mode=block" },
      { "key": "X-Content-Type-Options", "value": "nosniff" },
      { "key": "Referrer-Policy", "value": "strict-origin-when-cross-origin" },
      { "key": "Permissions-Policy", "value": "camera=(), microphone=(), geolocation=()" }
    ]
  }]
}
```

**Ao adicionar novos CDNs:** Atualizar o `Content-Security-Policy` no `vercel.json` e `next.config.mjs`.

### SEC-HRD-02 — Subresource Integrity (SRI) em Scripts CDN
Scripts externos devem ter hash criptografico para prevenir supply chain attacks.

```html
<!-- PROIBIDO: -->
<script src="https://cdn.jsdelivr.net/npm/dompurify@3/dist/purify.min.js"></script>

<!-- CORRETO: -->
<script
  src="https://cdn.jsdelivr.net/npm/dompurify@3/dist/purify.min.js"
  integrity="sha384-HASH_AQUI"
  crossorigin="anonymous">
</script>
```

**Como gerar hash SRI:**
```bash
curl -sL "URL_DO_SCRIPT" | openssl dgst -sha384 -binary | openssl base64 -A
```

### SEC-HRD-03 — X-Frame-Options: DENY
Definir `X-Frame-Options: DENY` para prevenir clickjacking. Ativo em `vercel.json`.

### SEC-HRD-04 — Script Anti-FOUC e CSP
O script inline anti-FOUC em `app/layout.js` usa `dangerouslySetInnerHTML`. Embora o conteudo seja hardcoded e seguro, deve ser migrado para ficheiro externo quando a CSP bloquear `unsafe-inline`.

```jsx
// ATUAL (aceitavel enquanto CSP permite unsafe-inline):
<script dangerouslySetInnerHTML={{ __html: `(...)theme init(...)` }} />

// FUTURO (quando CSP remover unsafe-inline):
<script src="/scripts/theme-init.js" />
```

---

## 6. Protecao de Formularios

### SEC-FRM-01 — Honeypot Anti-Spam
Todos os formularios publicos devem ter campo honeypot oculto.

```jsx
<div style={{ position: 'absolute', left: '-9999px' }} aria-hidden="true">
  <input type="text" name="website" tabIndex={-1} autoComplete="off" />
</div>
```

### SEC-FRM-02 — Inputs de Senha com type="password"
Campos de senha devem usar `type="password"`, nunca `type="text"`.

### SEC-FRM-03 — Links com target="_blank"
Todos os links com `target="_blank"` devem ter `rel="noopener noreferrer"`.

```jsx
// PROIBIDO:
<a href="https://exemplo.com" target="_blank">Link</a>

// CORRETO:
<a href="https://exemplo.com" target="_blank" rel="noopener noreferrer">Link</a>
```

### SEC-FRM-04 — Validacao de Input com maxLength
Todos os campos de formulario publico **DEVEM** ter `maxLength` para prevenir insercao de dados gigantes (DoS).

```jsx
// PROIBIDO:
<input type="text" name="name" required />

// CORRETO:
<input type="text" name="name" required maxLength={200} />
<input type="email" name="email" required maxLength={254} />
<input type="tel" name="phone" maxLength={20} />
```

**Limites obrigatorios:**
| Campo | maxLength | Justificacao |
|-------|-----------|-------------|
| name/nome | 200 | RFC 5321 + razoavel |
| email | 254 | RFC 5321 max |
| phone/telefone | 20 | Internacional + formato |
| nif | 20 | NIF empresarial |
| organizacao | 200 | Razao social |

### SEC-FRM-05 — CAPTCHA/Turnstile Anti-Bot (Recomendado)
O honeypot e trivialmente contornavel por bots sofisticados. Implementar Cloudflare Turnstile (gratuito e privacy-friendly) como segunda camada.

```jsx
// Futuro: adicionar Turnstile nos formularios publicos
import { Turnstile } from '@marsidev/react-turnstile'
<Turnstile siteKey={process.env.NEXT_PUBLIC_TURNSTILE_SITE_KEY}
  onVerify={(token) => setTurnstileToken(token)} />
```

**Prioridade:** Medio. Implementar quando houver evidencia de abuso por bots.

### SEC-FRM-06 — Sanitizacao de Input no Cliente
Campos de texto livre (name, organizacao) **DEVEM** ser sanitizados com `escapeHtml()` antes de enviar para o backend.

```javascript
import { escapeHtml } from '@/lib/security'
const name = escapeHtml(formData.get('name')?.toString().trim() || '')
```

---

## 7. Regras SQL (Supabase)

### SEC-SQL-01 — RLS Nunca USING (true) para Dados Pessoais
Tabelas com dados pessoais devem restringir SELECT a admins. NUNCA usar `USING (true)` ou `qual: true` para `authenticated`.

```sql
-- PROIBIDO:
CREATE POLICY "public_select" ON inscricoes
  FOR SELECT USING (true);

-- CORRETO:
CREATE POLICY "Admins can read inscricoes" ON inscricoes
  FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM admin_users WHERE admin_users.user_id = auth.uid()));
```

**Tabelas com dados pessoais:** `inscricoes`, `newsletter`, `admin_users`, `email_logs`.

### SEC-SQL-02 — RPC SECURITY DEFINER com Validacao
Funcoes RPC devem validar input e so atualizar conteudo publicado.

```sql
CREATE FUNCTION increment_view_count(article_slug TEXT)
RETURNS VOID AS $$
BEGIN
  IF article_slug IS NULL OR length(trim(article_slug)) = 0 THEN
    RAISE EXCEPTION 'Invalid slug';
  END IF;
  UPDATE articles SET view_count = view_count + 1
  WHERE slug = article_slug AND status = 'published';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### SEC-SQL-03 — CHECK Constraints de Comprimento em Tabelas Publicas
Tabelas que aceitam INSERTs anonimos **DEVEM** ter CHECK constraints de comprimento para prevenir DoS por dados gigantes.

```sql
-- inscricoes: campos de texto livre
ALTER TABLE public.inscricoes
  ADD CONSTRAINT inscricoes_name_length_check CHECK (length(name) <= 200),
  ADD CONSTRAINT inscricoes_email_length_check CHECK (length(email) <= 254);

-- page_views: campos de tracking
ALTER TABLE public.page_views
  ADD CONSTRAINT page_views_path_length_check CHECK (length(page_path) <= 500),
  ADD CONSTRAINT page_views_title_length_check CHECK (length(page_title) <= 500),
  ADD CONSTRAINT page_views_referrer_length_check CHECK (length(referrer) <= 2000);

-- newsletter: campo email
ALTER TABLE public.newsletter
  ADD CONSTRAINT newsletter_email_length_check CHECK (length(email) <= 254);
```

**Regra:** Toda tabela com `INSERT TO anon` ou `INSERT TO public` DEVE ter CHECK de comprimento em todos os campos `text`.

### SEC-SQL-04 — INSERT Anonimo com Validacao na Policy
Politicas de INSERT para roles publicos DEVEM validar formato e comprimento, nao apenas `WITH_CHECK: true`.

```sql
-- PROIBIDO:
CREATE POLICY "Allow anonymous inserts" ON inscricoes
  FOR INSERT TO anon WITH CHECK (true);

-- CORRETO:
CREATE POLICY "Allow valid inscricoes" ON inscricoes
  FOR INSERT TO anon
  WITH CHECK (
    name IS NOT NULL AND length(name) <= 200
    AND email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
    AND length(email) <= 254
  );
```

### SEC-SQL-05 — Sem Policies Duplicadas
Nunca criar duas policies para o mesmo role na mesma operacao. Se existe policy para `anon` e `public` no mesmo INSERT, a policy `public` e redundante e abre vetor para utilizadores autenticados contornarem validacoes.

```sql
-- PROIBIDO: ter DUAS policies INSERT em inscricoes
-- uma para anon e outra para public (ambas WITH_CHECK: true)

-- CORRETO: uma unica policy para anon com validacao real
CREATE POLICY "Anon can insert inscricoes" ON public.inscricoes
  FOR INSERT TO anon WITH CHECK ( /* validacoes */ );
```

### SEC-SQL-06 — Retencao de Audit Logs
A tabela `audit_logs` cresce indefinidamente. Implementar retencao (ex: 90 dias).

```sql
CREATE OR REPLACE FUNCTION clean_old_audit_logs()
RETURNS void AS $$
BEGIN
  DELETE FROM public.audit_logs WHERE created_at < now() - interval '90 days';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

Executar via cron ou Edge Function periodica.

---

## 8. Seguranca no Upload e Ficheiros

### SEC-UPL-01 — Validacao de Upload de Imagens
Antes de enviar para o Supabase Storage, validar tipo MIME e tamanho.

```javascript
// components/admin/ImageUpload.jsx
const MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB
const ALLOWED_MIME_TYPES = ['image/jpeg', 'image/png', 'image/webp', 'image/gif'];
```

### SEC-UPL-02 — Sanitizacao de Nomes de Ficheiros
Nomes de ficheiros devem ser sanitizados para prevenir path traversal.

```javascript
const safeName = fileName.replace(/[^a-zA-Z0-9/._-]/g, '_');
```

---

## 9. Auditoria e Logging

### SEC-AUD-01 — Padrao de Colunas de Auditoria
Todas as tabelas de dados publicos devem conter metadados de gestao.

```sql
published_at TIMESTAMPTZ,
created_at TIMESTAMPTZ DEFAULT NOW(),
updated_at TIMESTAMPTZ DEFAULT NOW()
```

### SEC-AUD-02 — Sem console.log em Producao
`console.log` em producao e **PROIBIDO**. Server Components podem usar `console.error` no servidor. Client Components **NUNCA** devem logar dados sensiveis.

```javascript
// PROIBIDO em Client Components:
console.log('User data:', user.email)

// CORRETO: logger condicional
const isDev = process.env.NODE_ENV === 'development'
if (isDev) console.log('Debug info')
```

**Ficheiros a limpar:** `lib/actions/lists.js`, `app/[lang]/(public)/eventos/[slug]/page.js`, `app/[lang]/(public)/lives/[slug]/page.js`, `app/[lang]/(public)/artigos/[slug]/page.js`.

### SEC-AUD-03 — Nunca Expor Chaves no Window Global
Variaveis `window.SUPABASE_URL`, `window.SUPABASE_ANON_KEY` e `window.debug*` sao **PROIBIDAS**. Em Next.js, usar `process.env.NEXT_PUBLIC_*` apenas.

### SEC-AUD-04 — MarkdownEditor Paste Sanitizacao
O editor Markdown deve sanitizar conteudo colado (paste) para prevenir injecao de HTML.

```javascript
// components/admin/MarkdownEditor.jsx
editor.addEventListener('paste', (e) => {
  e.preventDefault()
  const text = e.clipboardData.getData('text/plain')
  document.execCommand('insertText', false, text)
})
```

---

## 10. Seguranca em JSON e i18n

### SEC-JSON-01 — Nunca Incluir Credenciais em JSON Publico
Ficheiros JSON publicos (`public/i18n/*.json`) nao devem conter senhas, meeting_ids ou credenciais.

### SEC-JSON-02 — Validar JSON antes de Commit
```bash
node -e "JSON.parse(require('fs').readFileSync('public/i18n/pt.json'))"
```

---

## Checklist Pre-Commit

Antes de commitar qualquer alteracao, verificar:

- [ ] `dangerouslySetInnerHTML` usa `DOMPurify.sanitize()`? (SEC-XSS-01, SEC-XSS-05)
- [ ] Highlight de pesquisa escapa query antes de criar `<mark>`? (SEC-XSS-02)
- [ ] URLs em href/src usam `validateUrl()`? (SEC-XSS-03)
- [ ] Links `target="_blank"` tem `rel="noopener noreferrer"`? (SEC-FRM-03)
- [ ] Inputs publicos tem `maxLength`? (SEC-FRM-04)
- [ ] Nenhuma chave exposta em `window.*`? (SEC-AUD-03)
- [ ] Nenhum `console.log` em Client Components? (SEC-AUD-02)
- [ ] Server Actions usam `requireAdmin()`? (SEC-ATH-02, SEC-API-02)
- [ ] Server Actions NAO expoem `error.message`? (SEC-API-03)
- [ ] Edge Functions usam CORS whitelist (nao `*`)? (SEC-API-04)
- [ ] Proxy verifica TODAS as rotas admin? (SEC-ATH-02)
- [ ] RLS sem `USING (true)` em dados pessoais? (SEC-SQL-01, SEC-ATH-04)
- [ ] RLS INSERT anonimo tem validacao real (nao `WITH_CHECK: true`)? (SEC-SQL-04)
- [ ] Tabelas com INSERT anonimo tem CHECK constraints de comprimento? (SEC-SQL-03)
- [ ] Sem policies RLS duplicadas para mesmo role+operacao? (SEC-SQL-05)
- [ ] Upload com validacao de tipo/tamanho? (SEC-UPL-01)
- [ ] Formularios com honeypot? (SEC-FRM-01)
- [ ] Scripts CDN tem `integrity` + `crossorigin`? (SEC-HRD-02)

---

## Matriz Normativa de IDs

| ID | Area | Descricao |
|----|------|-----------|
| SEC-AM-01 | Identidade | Anonimato tecnico, sem exposicao de infraestrutura |
| SEC-AM-02 | Configuracao | App Router + Server Components, env vars no Vercel |
| SEC-ATH-01 | Auth | 3 clientes Supabase SSR (server/client/middleware) |
| SEC-ATH-02 | Auth | Proxy como barreira primaria + AuthGuard + requireAdmin() |
| SEC-ATH-03 | Auth | Timeout 30min por inatividade |
| SEC-ATH-04 | Auth | RLS SELECT restrito a admins em tabelas admin |
| SEC-XSS-01 | XSS | DOMPurify em dangerouslySetInnerHTML |
| SEC-XSS-02 | XSS | Sanitizacao em highlight de pesquisa |
| SEC-XSS-03 | XSS | validateUrl() em href/src |
| SEC-XSS-04 | XSS | encodeURIComponent() em slugs |
| SEC-XSS-05 | XSS | Todo dangerouslySetInnerHTML requer DOMPurify |
| SEC-API-01 | API | SELECT explicito sem colunas sensiveis |
| SEC-API-02 | API | Server Actions com requireAdmin() |
| SEC-API-03 | API | Mensagens de erro genericas (nunca error.message) |
| SEC-API-04 | API | CORS whitelist em Edge Functions (nunca *) |
| SEC-HRD-01 | Infra | Headers HTTP obrigatorios (vercel.json + next.config.mjs) |
| SEC-HRD-02 | Infra | SRI em scripts CDN |
| SEC-HRD-03 | Infra | X-Frame-Options: DENY |
| SEC-HRD-04 | Infra | Script anti-FOUC deve migrar para ficheiro externo |
| SEC-AUD-01 | Auditoria | Colunas published_at, created_at, updated_at |
| SEC-AUD-02 | Auditoria | Sem console.log em producao |
| SEC-AUD-03 | Auditoria | Sem window.* com chaves |
| SEC-AUD-04 | Auditoria | MarkdownEditor paste sanitizacao |
| SEC-UPL-01 | Upload | Validacao MIME + 5MB max |
| SEC-UPL-02 | Upload | Sanitizacao de nomes de ficheiros |
| SEC-FRM-01 | Forms | Honeypot anti-spam |
| SEC-FRM-02 | Forms | type="password" em senhas |
| SEC-FRM-03 | Forms | rel="noopener" em target="_blank" |
| SEC-FRM-04 | Forms | maxLength em todos os inputs publicos |
| SEC-FRM-05 | Forms | CAPTCHA/Turnstile anti-bot (recomendado) |
| SEC-FRM-06 | Forms | escapeHtml() em inputs de texto livre |
| SEC-SQL-01 | SQL | RLS sem USING (true) em dados pessoais |
| SEC-SQL-02 | SQL | RPC SECURITY DEFINER com validacao |
| SEC-SQL-03 | SQL | CHECK constraints de comprimento em tabelas publicas |
| SEC-SQL-04 | SQL | INSERT anonimo com validacao real na policy |
| SEC-SQL-05 | SQL | Sem policies RLS duplicadas |
| SEC-SQL-06 | SQL | Retencao de audit_logs (90 dias) |
| SEC-JSON-01 | JSON | Sem credenciais em JSON publico |
| SEC-JSON-02 | JSON | Validar JSON antes de commit |

---

## Ficheiros de Referencia (Next.js App Router)

| Ficheiro | Funcao |
|----------|--------|
| `lib/security.js` | escapeHtml, escapeAttr, validateUrl |
| `lib/supabase/server.js` | createClient() para Server Components |
| `lib/supabase/client.js` | createBrowserClient() para Client Components |
| `lib/supabase/middleware.js` | updateSession() para proxy |
| `proxy.js` | Auth redirect, admin protection, i18n redirect |
| `components/admin/AuthGuard.jsx` | Idle timeout + redirect client-side |
| `components/admin/ImageUpload.jsx` | validateImage (MIME + 5MB) |
| `vercel.json` | Headers de seguranca (CSP, X-Frame-Options) |
| `next.config.mjs` | Headers fallback + config Next.js |
| `lib/actions/content.js` | Server Actions CRUD (artigos, eventos, lives) |
| `lib/actions/settings.js` | Server Actions (perfil, password, 2FA) |
| `supabase/functions/` | Edge Functions (validate-inscription, send-*) |
