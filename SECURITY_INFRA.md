# Seguranca de Infraestrutura — O Sentinela

> Diretrizes para edicao de **netlify.toml, vite.config.js, scripts CDN**.
> Consultar ANTES de alterar configuracoes de build ou deploy.
> Auditoria completa: 32 vulnerabilidades corrigidas (2026-05-19).

---

## Headers HTTP (netlify.toml)

### SEC-HRD-01 — Headers Obrigatorios
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

**O que cada header faz:**

| Header | Protege contra |
|--------|----------------|
| `X-Frame-Options: DENY` | Clickjacking |
| `X-XSS-Protection: 1; mode=block` | XSS refletido |
| `X-Content-Type-Options: nosniff` | MIME sniffing |
| `Referrer-Policy` | Leak de URLs |
| `Permissions-Policy` | Acesso a hardware |
| `Content-Security-Policy` | XSS, injection, data exfiltration |

### SEC-HRD-03 — X-Frame-Options: DENY
Impede que o site seja carregado em iframes de dominios maliciosos.

---

## Content Security Policy (CSP)

### Dominios Permitidos no CSP

| Directive | Dominios | Motivo |
|-----------|----------|--------|
| `script-src` | `cdn.jsdelivr.net`, `unpkg.com` | marked.js, DOMPurify, Chart.js, Lucide |
| `style-src` | `fonts.googleapis.com` | Google Fonts CSS |
| `font-src` | `fonts.gstatic.com` | Google Fonts files |
| `img-src` | `*.supabase.co`, `data:` | Imagens do Supabase Storage |
| `connect-src` | `*.supabase.co`, `wss://*.supabase.co` | API Supabase + Realtime |

### Ao Adicionar Novos CDNs
Ao adicionar qualquer script ou stylesheet de novo dominio:
1. Atualizar o `Content-Security-Policy` no `netlify.toml`
2. Adicionar o dominio na directive correspondente
3. Gerar hash SRI para o script (SEC-HRD-02)

---

## Subresource Integrity (SRI)

### SEC-HRD-02 — Hash SRI em Scripts CDN
Scripts externos devem ter hash criptografico para prevenir supply chain attacks.

```html
<!-- PROIBIDO: -->
<script src="https://cdn.jsdelivr.net/npm/dompurify@3.0.6/dist/purify.min.js"></script>

<!-- CORRETO: -->
<script
  src="https://cdn.jsdelivr.net/npm/dompurify@3.0.6/dist/purify.min.js"
  integrity="sha384-cwS6YdhLI7XS60eoDiC+egV0qHp8zI+Cms46R0nbn8JrmoAzV9uFL60etMZhAnSu"
  crossorigin="anonymous">
</script>
```

### Como Gerar Hash SRI
```bash
curl -sL "URL_DO_SCRIPT" | openssl dgst -sha384 -binary | openssl base64 -A
```

### Scripts com SRI no Projeto

| Script | Versao | Hash SHA-384 | Ficheiros |
|--------|--------|-------------|-----------|
| marked.min.js | latest | `sha384-948ahk4ZmxYVYOc+rxN1H2gM1EJ2Duhp7uHtZ4WSLkV4Vtx5MUqnV+l7u9B+jFv+` | artigo.html |
| dompurify | 3.0.6 | `sha384-cwS6YdhLI7XS60eoDiC+egV0qHp8zI+Cms46R0nbn8JrmoAzV9uFL60etMZhAnSu` | artigo.html, inscricao.html |
| chart.js | latest | `sha384-jb8JQMbMoBUzgWatfe6COACi2ljcDdZQ2OxczGA3bGNeWe+6DChMTBJemed7ZnvJ` | dashboard.html |
| lucide | latest | `sha384-ZgnJ3Zpr70Xoify35DjOZWqHib1iYJBpYpQUIEpDASG9+fJ745WzNQuC004dwU0W` | 9 ficheiros admin |

### Ao Adicionar Novo Script CDN
1. Descarregar o ficheiro: `curl -sL "URL" > script.min.js`
2. Gerar hash: `openssl dgst -sha384 -binary script.min.js | openssl base64 -A`
3. Adicionar ao HTML: `integrity="sha384-HASH" crossorigin="anonymous"`
4. Atualizar CSP se necessario

---

## Ficheiros de Referencia

| Ficheiro | Funcao |
|----------|--------|
| `netlify.toml` | Headers de seguranca, CSP, cache |
| `vite.config.js` | Build config (sem dados sensiveis) |
