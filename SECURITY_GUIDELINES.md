# Diretrizes de Seguranca — O Sentinela

> Referencia permanente para criacao e edicao de ficheiros no projeto Conheca Farmacia.
> Gerado apos auditoria completa (32 vulnerabilidades, 2026-05-19).
> **Leia ANTES de criar ou editar qualquer ficheiro.**

---

## 1. Identidade e Configuracao do Sistema

### SEC-AM-01 — Identidade do Projeto
O projeto **Conheca Farmacia** opera com anonimato tecnico. Nenhuma informacao de infraestrutura (IP, portas, stack) deve ser exposta em HTML ou respostas HTTP. As configuracoes residem em ficheiros locais protegidos por `.gitignore`.

### SEC-AM-02 — Estrutura de Configuracao
A aplicacao segue o padrao **MVC simplificado (Service Layer)**. Configuracoes sensíveis residem em ficheiros locais protegidos.

| Ambiente | Ficheiro | Status |
|----------|----------|--------|
| Producao | `.env` (Supabase + Vars) | Secreto/Local |
| Desenvolvimento | `vite.config.js` | Publico (sem dados sensiveis) |
| Administrativo | `src/admin/` | Exclusivo para `admin_users` |

**Ferramentas:** Supabase (BaaS), Vite (Build), Netlify (Hosting), Node.js LTS.

---

## 2. Gestao de Autenticacao e Sessoes

### SEC-ATH-01 — Persistencia de Sessao (Supabase)
Para evitar o ciclo infinito de login, o cliente Supabase no frontend **deve** ter `persistSession: true`.

```javascript
// src/config.js
const supabaseClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
  },
});
```

### SEC-ATH-02 — Controle de Acesso Administrativo (RLS)
O acesso ao painel (`/src/admin/`) deve ser verificado contra a tabela `admin_users`. Funcoes `checkAuth()` locais que apenas verificam sessao sao **PROIBIDAS**.

```javascript
// PROIBIDO: funcao local que nao verifica admin_users
async function checkAuth() {
  const { data: { session } } = await supabase.auth.getSession();
  return !!session;
}

// CORRETO: importar de auth.js (verifica sessao + admin_users)
import { checkAuth, logout, initIdleTimeout } from './lib/auth.js';
```

**Ficheiro centralizado:** `src/admin/lib/auth.js`

### SEC-ATH-03 — Timeout de Sessao por Inatividade
Para mitigar hijacking de sessao, aplicar inactividade forçada apos 30 minutos.

```javascript
// src/admin/lib/auth.js
const IDLE_TIMEOUT = 30 * 60 * 1000;
let idleTimer = null;

function resetIdleTimer() {
  clearTimeout(idleTimer);
  idleTimer = setTimeout(async () => { await logout(); }, IDLE_TIMEOUT);
}

export function initIdleTimeout() {
  ['click', 'keydown', 'mousemove', 'scroll', 'touchstart'].forEach(evt =>
    document.addEventListener(evt, resetIdleTimer, { passive: true })
  );
  resetIdleTimer();
}
```

**Ativo em:** Todas as 8 paginas admin (dashboard, artigos, eventos, lives — index, new, edit).

---

## 3. Seguranca no Cliente (OWASP Top 10)

### SEC-XSS-01 — Sanitizacao de innerHTML com escapeHtml()
Dados vindos do Supabase **NUNCA** devem ser injetados diretamente em `innerHTML`. Usar `escapeHtml()` em TODAS as interpolacoes de texto.

```javascript
import { escapeHtml } from './lib/security.js';

// PROIBIDO:
card.innerHTML = `<h3>${article.title}</h3><p>${article.excerpt}</p>`;

// CORRETO:
card.innerHTML = `<h3>${escapeHtml(article.title)}</h3><p>${escapeHtml(article.excerpt)}</p>`;
```

**Campos que SEMPRE precisam escapeHtml():**
- `title`, `titulo`, `name`
- `excerpt`, `resumo`, `description`
- `categoryLabel`, `categoriaLabel`
- `location`, `platform`, `plataforma`
- `host.name`, `host.role`, `host.organization`
- `time`, `endTime`, `hora`
- `ref` (referencias bibliograficas)
- Qualquer string vinda do Supabase

**Ficheiros aplicados:** `articles-logic.js`, `events-logic.js`, `lives-logic.js`, `home-events-logic.js`, `article-detail.js`, `event-detail.js`, `live-detail.js`, `dashboard.js`, `admin-articles.js`, `admin-events.js`, `admin-lives.js`, `preview.js`, `error-handler.js`.

### SEC-XSS-02 — Escape de Atributos HTML com escapeAttr()
Valores dentro de atributos HTML (`value=""`, `href=""`, `alt=""`) devem usar `escapeAttr()` para prevenir quebra de contexto.

```javascript
import { escapeAttr } from './lib/security.js';

// PROIBIDO:
newRow.innerHTML = `<input value="${nameValue}">`;

// CORRETO:
newRow.innerHTML = `<input value="${escapeAttr(nameValue)}">`;
```

**Atributos que SEMPRE precisam escapeAttr():**
- `value=""` em inputs
- `alt=""` em imagens
- `title=""` em qualquer elemento
- `data-*` attributes com dados externos

**Ficheiros aplicados:** `eventos/new.html`, `eventos/edit.html`, `artigos/edit.html`.

### SEC-XSS-03 — Validacao de URLs com validateUrl()
URLs em `href` e `src` devem ser validadas para bloquear `javascript:`, `data:` e `vbscript:`.

```javascript
import { validateUrl } from './lib/security.js';

// PROIBIDO:
accessBtn.href = live.link_acesso;
li.innerHTML = `<a href="${material}">Link</a>`;

// CORRETO:
accessBtn.href = validateUrl(live.link_acesso);
li.innerHTML = `<a href="${validateUrl(material)}">Link</a>`;
```

**Ficheiros aplicados:** `live-detail.js`, `lives-logic.js`.

### SEC-XSS-04 — Codificacao de Slugs em href
Slugs usados em URLs devem ser codificados com `encodeURIComponent()` para prevenir injecao de atributos.

```javascript
// PROIBIDO:
`<a href="artigo.html?id=${article.slug}">`;

// CORRETO:
`<a href="artigo.html?id=${encodeURIComponent(article.slug)}">`;
```

### SEC-XSS-05 — Restricao de img src no DOMPurify
O DOMPurify deve restringir `img src` a dominios confiaveis (Supabase Storage + caminhos relativos).

```javascript
// src/article-detail.js
DOMPurify.addHook('afterSanitizeAttributes', function (node) {
  if (node.tagName === 'IMG') {
    const src = node.getAttribute('src');
    if (src && !src.startsWith('/') && !src.startsWith('./') && !src.startsWith('data:') && !src.includes('supabase.co')) {
      node.removeAttribute('src');
    }
  }
  if (node.tagName === 'A') {
    const href = node.getAttribute('href');
    if (href && (href.startsWith('javascript:') || href.startsWith('data:') || href.startsWith('vbscript:'))) {
      node.removeAttribute('href');
    }
  }
});
```

---

## 4. Gestao de Dados e Endpoints

### SEC-API-01 — Normalizacao e Tipagem de Dados
A funcao de resposta da API (`src/lib/api.js`) deve converter dados do backend (Supabase) para o formato camelCase padronizado.

```javascript
// Funcao de normalizacao (exemplo de artigos)
export function normalizeArticle(row) {
  return {
    id: row.id || row.slug,
    slug: row.slug,
    title: row.title,
    excerpt: row.excerpt,
    image: row.image_url,
    // ...
  };
}
```

### SEC-API-02 — Funcoes Delete com Verificacao de Sessao
Todas as funcoes de eliminacao devem verificar sessao antes de executar.

```javascript
export async function deleteArticle(id) {
  const { data: { session } } = await supabase.auth.getSession();
  if (!session) throw new Error('Unauthorized: login required');
  const { error } = await supabaseClient.from('articles').delete().eq('id', id);
  if (error) throw error;
}
```

### SEC-API-03 — Restricao de Colunas em SELECT Publico
Tabelas com campos sensiveis (senhas, meeting_ids) devem usar select explicito em vez de `select('*')`.

```javascript
// PROIBIDO:
select('*').from('lives').eq('status', 'published')

// CORRETO:
select('id, slug, title, excerpt, category, date, time, platform, status')
  .from('lives').eq('status', 'published')
```

### SEC-API-04 — Cliente Supabase Centralizado
Nunca criar clientes Supabase duplicados com fallback hardcoded. Usar sempre o modulo partilhado.

```javascript
// PROIBIDO:
import { createClient } from 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/+esm';
const supabase = createClient(url, key);

// CORRETO:
import { supabaseClient } from '../config.js';
```

---

## 5. Hardening de Infraestrutura

### SEC-HRD-01 — Headers HTTP Obrigatorios (Netlify)
Definir politicas de conteudo restritivas no `netlify.toml`.

```toml
[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-XSS-Protection = "1; mode=block"
    X-Content-Type-Options = "nosniff"
    Referrer-Policy = "strict-origin-when-cross-origin"
    Permissions-Policy = "camera=(), microphone=(), geolocation=()"
    Content-Security-Policy = "default-src 'self'; script-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net https://unpkg.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; img-src 'self' data: https://*.supabase.co; connect-src 'self' https://*.supabase.co wss://*.supabase.co"
```

**Ao adicionar novos CDNs:** Atualizar o `Content-Security-Policy` no `netlify.toml`.

### SEC-HRD-02 — Subresource Integrity (SRI) em Scripts CDN
Scripts externos devem ter hash criptografico para prevenir supply chain attacks.

```html
<!-- PROIBIDO: -->
<script src="https://cdn.jsdelivr.net/npm/dompurify@3.0.6/dist/purify.min.js"></script>

<!-- CORRETO: -->
<script
  src="https://cdn.jsdelivr.net/npm/dompurify@3.0.6/dist/purify.min.js"
  integrity="sha384-HASH_AQUI"
  crossorigin="anonymous">
</script>
```

**Como gerar hash SRI:**
```bash
curl -sL "URL_DO_SCRIPT" | openssl dgst -sha384 -binary | openssl base64 -A
```

**Scripts com SRI no projeto:**
| Script | Hash | Ficheiros |
|--------|------|-----------|
| marked.min.js | `sha384-948ahk...` | artigo.html |
| dompurify@3.0.6 | `sha384-cwS6Yd...` | artigo.html, inscricao.html |
| chart.js | `sha384-jb8JQM...` | dashboard.html |
| lucide@latest | `sha384-ZgnJ3Z...` | 9 ficheiros admin |

### SEC-HRD-03 — Restricao de Insercao em Iframes
Definir `X-Frame-Options: DENY` para prevenir clickjacking.

---

## 6. Auditoria e Logging

### SEC-AUD-01 — Padrao de Colunas de Auditoria
Todas as tabelas de dados publicos devem conter metadados de gestao.

```sql
published_at TIMESTAMPTZ,
created_at TIMESTAMPTZ DEFAULT NOW(),
updated_at TIMESTAMPTZ DEFAULT NOW()
```

### SEC-AUD-02 — Nao Logar Dados Sensiveis
`console.log` com dados pessoais, queries, ou chaves e **PROIBIDO** em producao.

```javascript
// PROIBIDO:
console.log('Email:', data.email);
console.log('SUPABASE_URL:', SUPABASE_URL);

// CORRETO: logger condicional
if (import.meta.env.DEV) {
  console.log('Debug info');
}
```

### SEC-AUD-03 — Nunca Expor Chaves no Window Global
Variaveis `window.SUPABASE_URL`, `window.SUPABASE_ANON_KEY` e `window.debug*` sao **PROIBIDAS**.

```javascript
// PROIBIDO:
window.SUPABASE_URL = SUPABASE_URL;
window.debugInscriptions = async function(slug) { ... };
```

---

## 7. Seguranca no Upload e Ficheiros

### SEC-UPL-01 — Validacao de Upload de Imagens
Antes de enviar para o Supabase Storage, validar tipo MIME e tamanho.

```javascript
// src/admin/lib/image-compressor.js
const MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB
const ALLOWED_MIME_TYPES = ['image/jpeg', 'image/png', 'image/webp', 'image/gif'];

function validateImage(file) {
  if (!file) throw new Error('Nenhum ficheiro selecionado.');
  if (!ALLOWED_MIME_TYPES.includes(file.type)) {
    throw new Error('Tipo de ficheiro nao permitido. Use apenas JPEG, PNG, WebP ou GIF.');
  }
  if (file.size > MAX_FILE_SIZE) {
    throw new Error('O ficheiro e demasiado grande. Limite: 5MB.');
  }
  return true;
}
```

### SEC-UPL-02 — Sanitizacao de Nomes de Ficheiros
Nomes de ficheiros devem ser sanitizados para prevenir path traversal.

```javascript
const safeName = fileName.replace(/[^a-zA-Z0-9/._-]/g, '_');
```

---

## 8. Protecao de Formularios

### SEC-FRM-01 — Honeypot Anti-Spam
Todos os formularios publicos devem ter campo honeypot oculto.

```html
<form id="newsletter-form">
  <div style="position: absolute; left: -9999px;" aria-hidden="true">
    <input type="text" name="website" tabindex="-1" autocomplete="offline" />
  </div>
  <input type="email" id="newsletter-email" required />
  <button type="submit">Subscrever</button>
</form>
```

### SEC-FRM-02 — Inputs de Senha com type="password"
Campos de senha devem usar `type="password"`, nunca `type="text"`.

```html
<!-- PROIBIDO: -->
<input type="text" id="password" name="password">

<!-- CORRETO: -->
<input type="password" id="password" name="password">
```

### SEC-FRM-03 — Links com target="_blank"
Todos os links com `target="_blank"` devem ter `rel="noopener noreferrer"`.

```html
<!-- PROIBIDO: -->
<a href="https://exemplo.com" target="_blank">Link</a>

<!-- CORRETO: -->
<a href="https://exemplo.com" target="_blank" rel="noopener noreferrer">Link</a>
```

### SEC-FRM-04 — Redirecionamento sem Contexto
Formularios que dependem de parametros de URL devem redirecionar quando o parametro falta.

```javascript
// inscricao.html — se falta ?evento=, mostrar mensagem e link para /eventos.html
if (!eventoSlug) {
  formContainer.innerHTML = `
    <div style="text-align:center; padding: 3rem 1rem;">
      <h2>Evento nao especificado</h2>
      <p>Selecione um evento antes de se inscrever.</p>
      <a href="/eventos.html" class="btn btn-primary">Ver Eventos</a>
    </div>
  `;
}
```

---

## 9. Seguranca em localStorage

### SEC-STR-01 — try/catch obrigatorio
Todas as operacoes `localStorage` devem ter try/catch para lidar com quota excedida ou modo privado.

```javascript
// PROIBIDO:
localStorage.setItem(key, value);

// CORRETO:
try {
  localStorage.setItem(key, value);
} catch {
  // localStorage indisponivel
}
```

---

## 10. Regras SQL (Supabase)

### SEC-SQL-01 — RLS Nunca USING (true) para Dados Pessoais
Tabelas com dados pessoais devem restringir SELECT a admins.

```sql
-- PROIBIDO:
CREATE POLICY "public_select" ON inscricoes
  FOR SELECT USING (true);

-- CORRETO:
CREATE POLICY "Admins can read inscricoes" ON inscricoes
  FOR SELECT
  USING (EXISTS (SELECT 1 FROM admin_users WHERE admin_users.user_id = auth.uid()));
```

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

### SEC-SQL-03 — Constraints NOT NULL e CHECK
Colunas obrigatorias devem ter NOT NULL. Colunas com valores fixos devem ter CHECK.

```sql
ALTER TABLE articles ALTER COLUMN status SET NOT NULL;
ALTER TABLE admin_users ADD CONSTRAINT admin_users_role_check
  CHECK (role IN ('editor', 'admin', 'superadmin'));
```

### SEC-SQL-04 — INSERT Anonimo com Validacao
Politicas de INSERT devem validar formato de email, telefone e slug.

```sql
CREATE POLICY "Allow valid inscricoes" ON inscricoes
  FOR INSERT
  WITH CHECK (
    nome IS NOT NULL AND length(nome) >= 3
    AND email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
    AND telefone IS NOT NULL AND length(telefone) <= 20
    AND evento_slug ~* '^[a-zA-Z0-9\-_]+$'
  );
```

---

## 11. Seguranca em CSS

### SEC-CSS-01 — Sem Injecao Dinamica
Nunca injetar `<style>` via innerHTML. Usar variaveis CSS.

```javascript
// PROIBIDO:
element.innerHTML = `<style>.card { background: ${userColor} }</style>`;

// CORRETO:
element.style.setProperty('--card-bg', userColor);
```

### SEC-CSS-02 — Variaveis CSS para Temas
Usar variaveis CSS para cores e espacamentos, nunca valores hardcoded.

```css
:root {
  --admin-bg: #f8fafc;
  --admin-text: #1e293b;
}
html.dark {
  --admin-bg: #0f172a;
  --admin-text: #e2e8f0;
}
```

---

## 12. Seguranca em JSON

### SEC-JSON-01 — Nunca Incluir Credenciais em Fallbacks
Ficheiros JSON publicos nao devem conter senhas, meeting_ids ou credenciais.

```json
// PROIBIDO:
{ "id_reuniao": "123 456 7890", "senha": "abc123" }

// CORRETO:
{ "id_reuniao": null, "senha": null }
```

### SEC-JSON-02 — Validar JSON antes de Commit
```bash
node -e "JSON.parse(require('fs').readFileSync('package.json'))"
```

---

## Checklist Pre-Commit

Antes de commitar qualquer alteracao, verificar:

- [ ] innerHTML com dados Supabase usa `escapeHtml()`? (SEC-XSS-01)
- [ ] Atributos HTML com dados externos usam `escapeAttr()`? (SEC-XSS-02)
- [ ] URLs em href/src usam `validateUrl()`? (SEC-XSS-03)
- [ ] Scripts CDN tem `integrity` + `crossorigin`? (SEC-HRD-02)
- [ ] Links `target="_blank"` tem `rel="noopener noreferrer"`? (SEC-FRM-03)
- [ ] Nenhuma chave exposta em `window.*`? (SEC-AUD-03)
- [ ] Nenhum `console.log` com dados sensiveis? (SEC-AUD-02)
- [ ] Auth usa `checkAuth()` centralizado? (SEC-ATH-02)
- [ ] localStorage com try/catch? (SEC-STR-01)
- [ ] RLS sem `USING (true)` em dados pessoais? (SEC-SQL-01)
- [ ] Upload com validacao de tipo/tamanho? (SEC-UPL-01)
- [ ] Formularios com honeypot? (SEC-FRM-01)
- [ ] Inputs de senha com type="password"? (SEC-FRM-02)

---

## Matriz Normativa de IDs

| ID | Area | Descricao |
|----|------|-----------|
| SEC-AM-01 | Identidade | Anonimato tecnico, sem exposicao de infraestrutura |
| SEC-AM-02 | Configuracao | MVC simplificado, configs em ficheiros locais |
| SEC-ATH-01 | Auth | persistSession: true obrigatorio |
| SEC-ATH-02 | Auth | checkAuth() centralizado via auth.js |
| SEC-ATH-03 | Auth | Timeout 30min por inatividade |
| SEC-XSS-01 | XSS | escapeHtml() em innerHTML |
| SEC-XSS-02 | XSS | escapeAttr() em atributos HTML |
| SEC-XSS-03 | XSS | validateUrl() em href/src |
| SEC-XSS-04 | XSS | encodeURIComponent() em slugs |
| SEC-XSS-05 | XSS | DOMPurify img src restrito a supabase.co |
| SEC-API-01 | API | Normalizacao camelCase |
| SEC-API-02 | API | Delete com verificacao de sessao |
| SEC-API-03 | API | SELECT explicito sem colunas sensiveis |
| SEC-API-04 | API | Cliente Supabase centralizado |
| SEC-HRD-01 | Infra | Headers HTTP obrigatorios (CSP, X-Frame, etc.) |
| SEC-HRD-02 | Infra | SRI em scripts CDN |
| SEC-HRD-03 | Infra | X-Frame-Options: DENY |
| SEC-AUD-01 | Auditoria | Colunas published_at, created_at, updated_at |
| SEC-AUD-02 | Auditoria | Sem console.log sensiveis |
| SEC-AUD-03 | Auditoria | Sem window.* com chaves |
| SEC-UPL-01 | Upload | Validacao MIME + 5MB max |
| SEC-UPL-02 | Upload | Sanitizacao de nomes de ficheiros |
| SEC-FRM-01 | Forms | Honeypot anti-spam |
| SEC-FRM-02 | Forms | type="password" em senhas |
| SEC-FRM-03 | Forms | rel="noopener" em target="_blank" |
| SEC-FRM-04 | Forms | Redirecionamento sem contexto |
| SEC-STR-01 | Storage | try/catch em localStorage |
| SEC-SQL-01 | SQL | RLS sem USING (true) em dados pessoais |
| SEC-SQL-02 | SQL | RPC SECURITY DEFINER com validacao |
| SEC-SQL-03 | SQL | NOT NULL + CHECK constraints |
| SEC-SQL-04 | SQL | INSERT com validacao de formato |
| SEC-CSS-01 | CSS | Sem injecao dinamica de style |
| SEC-CSS-02 | CSS | Variaveis CSS para temas |
| SEC-JSON-01 | JSON | Sem credenciais em fallbacks |
| SEC-JSON-02 | JSON | Validar JSON antes de commit |

---

## Ficheiros de Referencia

| Ficheiro | Funcao |
|----------|--------|
| `src/lib/security.js` | escapeHtml, escapeAttr, validateUrl |
| `src/admin/lib/auth.js` | checkAuth, logout, initIdleTimeout |
| `src/admin/lib/image-compressor.js` | validateImage (MIME + 5MB) |
| `src/config.js` | supabaseClient (unico ponto de acesso) |
| `netlify.toml` | Headers de seguranca (CSP, X-Frame-Options) |
| `src/migrations/010-fix-rls-policies-security.sql` | Padrao RLS correto |
| `src/migrations/011-fix-rpc-functions-security.sql` | Padrao RPC correto |
| `src/migrations/012-add-constraints-security.sql` | CHECK e NOT NULL constraints |
