# Security Policy — Conheça Farmácia

This document describes the security posture of the Conheça Farmácia
web platform, the policies in force, and how to report a vulnerability.

Last updated: 2026-06-15 (Sentinela audit remediation).

## Reporting a Vulnerability

Email `security@conhecafarmacia.com` with a description of the issue
and a proof of concept. We aim to acknowledge within 3 business days
and to provide a remediation timeline within 10 business days.

Please do **not** open a public GitHub issue for security findings.

## Threat Model

- Public content (articles, events, lives) is world-readable.
- Admin content is gated behind Supabase Auth + RLS + a tri-proxy
  guard (`proxy.js`).
- API mutations (newsletter subscribe, event inscription, contact
  form) are public endpoints; they are rate-limited and validated
  server-side.
- All sensitive data is stored in Supabase (Postgres + Auth + Storage
  + Edge Functions). No credentials are stored in the client bundle.

## Authentication

### User accounts (public)

- Email + password (Supabase Auth), or magic link.
- Sessions are HTTP-only cookies (`sb-*-auth-token`), refreshed on
  every request via the `proxy.js` Supabase SSR helper.
- 30-minute idle timeout in the admin panel.

### Admin accounts

- Email + password, then TOTP (RFC 6238) is **required**.
  See "Two-factor policy" below.
- Idle session expires after 30 minutes of inactivity.
- Admin routes are protected at three layers: `proxy.js` (cookie
  presence + `admin_users` check), `AuthGuard` component, and RLS on
  the `admin_users` table.

## Two-Factor Policy

As of 2026-06-15, **2FA is enforced on first admin login**.

- New admins cannot sign in until they have enrolled a TOTP factor
  (Google Authenticator, 1Password, Authy, etc.) from
  `/[lang]/admin/definicoes`.
- Existing admins (with valid password) are guided to enroll on
  their next login; the login attempt is rejected with
  `requiresTwoFactorEnrollment: true` until enrollment is complete.
- A TOTP factor is the only accepted second factor. SMS is not
  supported (NIST 800-63B §5.1.2 discourages it).

## Cryptography

- TLS 1.2+ (HSTS preload eligible, `max-age=63072000`).
- Cookies: HTTP-only + Secure + SameSite=Lax.
- Passwords: stored by Supabase Auth (bcrypt/argon2 family, never
  user-facing).
- TOTP secrets: stored in Supabase `mfa.factors`, encrypted at rest
  by the platform.
- All secrets in CI / Vercel are pulled from environment variables
  (see "Environment variables" below); no secret material is in the
  git tree.

## Content Security Policy

The active CSP is set in `vercel.json` and looks like:

```
default-src 'self';
script-src 'self' 'unsafe-inline' https://vercel.live;
style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
img-src 'self' data: blob: https://*.supabase.co https://vercel.live;
font-src 'self' https://fonts.gstatic.com;
connect-src 'self' https://*.supabase.co https://vercel.live;
frame-ancestors 'none';
object-src 'none';
base-uri 'self';
form-action 'self'
```

- `'unsafe-inline'` in `script-src` is required for the anti-FOUC
  script in `app/layout.js`. We deliberately do **not** allow
  `'unsafe-eval'`.
- `https://vercel.live` is the Vercel Toolbar/Analytics origin.

## Security Headers (active)

| Header                          | Value                                              |
| ------------------------------- | -------------------------------------------------- |
| `Strict-Transport-Security`     | `max-age=63072000; includeSubDomains; preload`     |
| `X-Frame-Options`               | `DENY`                                             |
| `X-Content-Type-Options`        | `nosniff`                                          |
| `Referrer-Policy`               | `strict-origin-when-cross-origin`                  |
| `X-Permitted-Cross-Domain-Policies` | `none`                                          |
| `Permissions-Policy`            | `camera=(), microphone=(), geolocation=()`         |
| `X-DNS-Prefetch-Control`        | `off`                                              |
| `Cross-Origin-Opener-Policy`    | `same-origin`                                      |
| `Cross-Origin-Resource-Policy`  | `same-origin`                                      |
| `Content-Security-Policy`       | (see above)                                        |
| `Cache-Control` (admin only)    | `no-store, max-age=0`                              |
| `X-Robots-Tag` (admin only)     | `noindex, nofollow`                                |
| `X-Powered-By`                  | (removed by `next.config.mjs` `poweredByHeader: false`) |

## Input Validation

- HTML bodies are sanitized with DOMPurify (`lib/sanitize.js`) before
  being persisted and before being rendered with
  `dangerouslySetInnerHTML`.
- Plain-text fields are HTML-escaped at render time
  (`lib/security.js:escapeHtml`).
- URLs are validated against `/^https?:\/\//i` (`lib/security.js:validateUrl`).
- All Server Actions that mutate data call `requireAdmin()`
  (`lib/actions/content.js`) before any DB write.
- Translation input is capped per-field (50 000 chars) and per-request
  (200 000 chars) before any external API call.

## Rate Limits

- Translation quota: a per-day atomic counter in
  `translation_quota` (Supabase) enforced by the
  `check_and_increment_translation_quota` SECURITY DEFINER RPC
  (migration 019).
- Edge functions (newsletter, inscription, contact) are rate-limited
  per IP at the Supabase gateway.
- Admin login: rate-limited at the Supabase auth layer.

## Environment Variables

| Variable                          | Risk   | Where set             |
| --------------------------------- | ------ | --------------------- |
| `NEXT_PUBLIC_SUPABASE_URL`        | 🟢     | Vercel, `.env.local`  |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY`   | 🟢     | Vercel, `.env.local`  |
| `SUPABASE_SERVICE_ROLE_KEY`       | 🔴     | Vercel **only**       |
| `OPENROUTER_API_KEY`              | 🔴     | Vercel **only**       |
| `RESEND_API_KEY` (legacy)         | 🔴     | Vercel **only**       |
| `SMTP_*` (AWS SES)                | 🔴     | Vercel **only**       |
| `NEXT_PUBLIC_SITE_URL`            | 🟢     | Vercel, `.env.local`  |

🟢 — public, safe to ship in the client bundle.
🔴 — server-only, must never appear in the browser bundle or in
git history. `.gitignore` excludes `.env*.local`, `*.pem`, `*.key`,
`*.p12`, `*.pfx` and the `.vercel/` directory.

## Dependency Hygiene

- CI runs `npm audit` on every push.
- Two moderate vulnerabilities are currently open in transitive
  `postcss` (advisory GHSA-qx2v-qp2m-jg93); see the most recent
  audit commit for the rationale on deferring the `npm audit fix`.
- Dependabot is configured for `npm` and `GitHub Actions`.

## Audit Trail

- `docs/security/audits/` — historical audit reports (Sentinela,
  future).
- Each audit lists findings by ID, severity, and remediation commit.

## Out-of-Band Processes

- Database migrations: every migration is reviewed before merge and
  applied via `supabase db push` (see
  `feedback/supabase-migrations-versioning-mismatch.md`).
- Privileged changes: protected branches require signed commits
  (when Vercel + GitHub keys are configured).
- Incident response: lead contact is the engineering lead; escalation
  is via the same `security@` address.
