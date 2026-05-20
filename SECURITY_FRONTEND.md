# Seguranca Frontend — O Sentinela

> Diretrizes para edicao de ficheiros **HTML, JavaScript, CSS, JSON**.
> Consultar ANTES de criar ou editar qualquer ficheiro nestas linguagens.
> Auditoria completa: 32 vulnerabilidades corrigidas (2026-05-19).

---

## Autenticacao e Sessoes

### SEC-ATH-01 — Persistencia de Sessao (Supabase)
O cliente Supabase **deve** ter `persistSession: true` para evitar ciclo infinito de login.

```javascript
// src/config.js
const supabaseClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: { persistSession: true, autoRefreshToken: true },
});
```

### SEC-ATH-02 — checkAuth() Centralizado
Funcoes `checkAuth()` locais que apenas verificam sessao sao **PROIBIDAS**. Usar sempre `auth.js`.

```javascript
// PROIBIDO:
async function checkAuth() {
  const { data: { session } } = await supabase.auth.getSession();
  return !!session; // NAO VERIFICA admin_users!
}

// CORRETO:
import { checkAuth, logout, initIdleTimeout } from './lib/auth.js';
```

**Ficheiro:** `src/admin/lib/auth.js`

### SEC-ATH-03 — Timeout 30min por Inatividade
Logout automatico apos 30 minutos sem interacao. Ativo em todas as 8 paginas admin.

```javascript
import { initIdleTimeout } from './lib/auth.js';
// Chamar apos checkAuth():
initIdleTimeout();
```

---

## Sanitizacao (OWASP Top 10)

### SEC-XSS-01 — escapeHtml() em innerHTML
Dados do Supabase **NUNCA** em innerHTML sem escape.

```javascript
import { escapeHtml } from './lib/security.js';

// PROIBIDO:
card.innerHTML = `<h3>${article.title}</h3>`;

// CORRETO:
card.innerHTML = `<h3>${escapeHtml(article.title)}</h3>`;
```

**Campos que SEMPRE precisam escapeHtml():**
`title`, `titulo`, `name`, `excerpt`, `resumo`, `description`, `categoryLabel`, `categoriaLabel`, `location`, `platform`, `plataforma`, `host.name`, `host.role`, `host.organization`, `time`, `endTime`, `hora`, `ref` — Qualquer string vinda do Supabase.

### SEC-XSS-02 — escapeAttr() em Atributos HTML
Valores em atributos HTML devem usar `escapeAttr()`.

```javascript
import { escapeAttr } from './lib/security.js';

// PROIBIDO:
newRow.innerHTML = `<input value="${nameValue}">`;

// CORRETO:
newRow.innerHTML = `<input value="${escapeAttr(nameValue)}">`;
```

**Atributos:** `value=""`, `alt=""`, `title=""`, `data-*` com dados externos.

### SEC-XSS-03 — validateUrl() em href/src
URLs devem ser validadas para bloquear `javascript:`, `data:`, `vbscript:`.

```javascript
import { validateUrl } from './lib/security.js';

// PROIBIDO:
accessBtn.href = live.link_acesso;

// CORRETO:
accessBtn.href = validateUrl(live.link_acesso);
```

### SEC-XSS-04 — encodeURIComponent() em Slugs
Slugs em URLs devem ser codificados.

```javascript
// PROIBIDO:
`<a href="artigo.html?id=${article.slug}">`;

// CORRETO:
`<a href="artigo.html?id=${encodeURIComponent(article.slug)}">`;
```

### SEC-XSS-05 — DOMPurify img src Restrito
Restringir `img src` a Supabase Storage + caminhos relativos.

```javascript
DOMPurify.addHook('afterSanitizeAttributes', function (node) {
  if (node.tagName === 'IMG') {
    const src = node.getAttribute('src');
    if (src && !src.startsWith('/') && !src.startsWith('./') && !src.startsWith('data:') && !src.includes('supabase.co')) {
      node.removeAttribute('src');
    }
  }
});
```

---

## Auditoria e Logging

### SEC-AUD-02 — Sem console.log Sensiveis
`console.log` com dados pessoais, queries ou chaves e **PROIBIDO** em producao.

```javascript
// PROIBIDO:
console.log('Email:', data.email);

// CORRETO:
if (import.meta.env.DEV) console.log('Debug info');
```

### SEC-AUD-03 — Sem window.* com Chaves
`window.SUPABASE_URL`, `window.SUPABASE_ANON_KEY`, `window.debug*` sao **PROIBIDOS**.

---

## Upload de Ficheiros

### SEC-UPL-01 — Validacao MIME + 5MB
Validar tipo e tamanho antes de enviar para Supabase Storage.

```javascript
const MAX_FILE_SIZE = 5 * 1024 * 1024;
const ALLOWED_MIME_TYPES = ['image/jpeg', 'image/png', 'image/webp', 'image/gif'];

function validateImage(file) {
  if (!file) throw new Error('Nenhum ficheiro selecionado.');
  if (!ALLOWED_MIME_TYPES.includes(file.type)) {
    throw new Error('Tipo nao permitido. Use JPEG, PNG, WebP ou GIF.');
  }
  if (file.size > MAX_FILE_SIZE) {
    throw new Error('Limite: 5MB.');
  }
  return true;
}
```

### SEC-UPL-02 — Sanitizacao de Nomes
```javascript
const safeName = fileName.replace(/[^a-zA-Z0-9/._-]/g, '_');
```

---

## Formularios

### SEC-FRM-01 — Honeypot Anti-Spam
Todos os formularios publicos devem ter campo honeypot.

```html
<div style="position: absolute; left: -9999px;" aria-hidden="true">
  <input type="text" name="website" tabindex="-1" autocomplete="off" />
</div>
```

### SEC-FRM-02 — Senhas com type="password"
```html
<!-- PROIBIDO: --> <input type="text" id="password">
<!-- CORRETO: -->   <input type="password" id="password">
```

### SEC-FRM-03 — target="_blank" com rel="noopener"
```html
<!-- PROIBIDO: --> <a href="..." target="_blank">Link</a>
<!-- CORRETO: -->   <a href="..." target="_blank" rel="noopener noreferrer">Link</a>
```

### SEC-FRM-04 — Redirecionamento sem Contexto
Formularios que dependem de parametros de URL devem redirecionar quando o parametro falta.

```javascript
if (!eventoSlug) {
  formContainer.innerHTML = `<p>Evento nao especificado. <a href="/eventos.html">Ver Eventos</a></p>`;
}
```

---

## localStorage

### SEC-STR-01 — try/catch Obrigatorio
```javascript
// PROIBIDO:
localStorage.setItem(key, value);

// CORRETO:
try {
  localStorage.setItem(key, value);
} catch { /* quota excedida, modo privado */ }
```

---

## CSS

### SEC-CSS-01 — Sem Injecao Dinamica
Nunca injetar `<style>` via innerHTML. Usar variaveis CSS.

```javascript
// PROIBIDO:
element.innerHTML = `<style>.card { background: ${userColor} }</style>`;

// CORRETO:
element.style.setProperty('--card-bg', userColor);
```

### SEC-CSS-02 — Variaveis CSS para Temas
```css
:root { --admin-bg: #f8fafc; --admin-text: #1e293b; }
html.dark { --admin-bg: #0f172a; --admin-text: #e2e8f0; }
```

---

## JSON

### SEC-JSON-01 — Sem Credenciais em Fallbacks
Ficheiros JSON publicos nao devem conter senhas ou meeting_ids.

```json
// PROIBIDO: { "senha": "abc123" }
// CORRETO:   { "senha": null }
```

### SEC-JSON-02 — Validar antes de Commit
```bash
node -e "JSON.parse(require('fs').readFileSync('package.json'))"
```

---

## Checklist Frontend

- [ ] innerHTML usa `escapeHtml()`? (SEC-XSS-01)
- [ ] Atributos usam `escapeAttr()`? (SEC-XSS-02)
- [ ] URLs usam `validateUrl()`? (SEC-XSS-03)
- [ ] Slugs usam `encodeURIComponent()`? (SEC-XSS-04)
- [ ] Links `target="_blank"` tem `rel="noopener"`? (SEC-FRM-03)
- [ ] Nenhuma chave em `window.*`? (SEC-AUD-03)
- [ ] Sem `console.log` sensiveis? (SEC-AUD-02)
- [ ] Auth usa `checkAuth()` centralizado? (SEC-ATH-02)
- [ ] localStorage com try/catch? (SEC-STR-01)
- [ ] Upload com validacao MIME+5MB? (SEC-UPL-01)
- [ ] Formularios com honeypot? (SEC-FRM-01)
- [ ] Senhas com type="password"? (SEC-FRM-02)

---

## Matriz Normativa — Frontend

| ID | Area | Descricao |
|----|------|-----------|
| SEC-ATH-01 | Auth | persistSession: true obrigatorio |
| SEC-ATH-02 | Auth | checkAuth() centralizado via auth.js |
| SEC-ATH-03 | Auth | Timeout 30min por inatividade |
| SEC-XSS-01 | XSS | escapeHtml() em innerHTML |
| SEC-XSS-02 | XSS | escapeAttr() em atributos HTML |
| SEC-XSS-03 | XSS | validateUrl() em href/src |
| SEC-XSS-04 | XSS | encodeURIComponent() em slugs |
| SEC-XSS-05 | XSS | DOMPurify img src restrito a supabase.co |
| SEC-AUD-02 | Auditoria | Sem console.log sensiveis |
| SEC-AUD-03 | Auditoria | Sem window.* com chaves |
| SEC-UPL-01 | Upload | Validacao MIME + 5MB max |
| SEC-UPL-02 | Upload | Sanitizacao de nomes de ficheiros |
| SEC-FRM-01 | Forms | Honeypot anti-spam |
| SEC-FRM-02 | Forms | type="password" em senhas |
| SEC-FRM-03 | Forms | rel="noopener" em target="_blank" |
| SEC-FRM-04 | Forms | Redirecionamento sem contexto |
| SEC-STR-01 | Storage | try/catch em localStorage |
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
