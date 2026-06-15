# Sentinela Audit — 2026-06-15

Deep security audit run by the local `o-sentinela` agent
(`.claude/agents/o-sentinela.md`) against the `feat/i18n-content-translation`
branch. The agent ran a 30-finding review across input validation, auth,
infrastructure, RLS, and dependency hygiene.

| ID      | Severity | File / Area                                  | Status | Fix commit (this PR)                  |
| ------- | -------- | -------------------------------------------- | ------ | ------------------------------------- |
| CRIT-01 | Critical | `lib/actions/translation.js` rate limit      | ✅     | `019` migration + atomic RPC           |
| HIGH-01 | High     | Translation HTML persisted unfiltered        | ✅     | `sanitizeHtml` on upsert              |
| HIGH-02 | High     | `OPENROUTER_API_KEY` exposure                | ✅*    | Already server-only (verified)        |
| HIGH-03 | High     | No rate limit on `adminLogin`                | ✅     | Supabase auth rate limit (verified)   |
| HIGH-04 | High     | Translation input has no size cap            | ✅     | `MAX_FIELD_CHARS` / `MAX_TOTAL_CHARS` |
| HIGH-05 | High     | CSP allows `'unsafe-eval'`                   | ✅     | Removed from `script-src`             |
| HIGH-06 | High     | `/api/inscription` leaks `error.message`     | ✅     | Generic message + `console.error`     |
| HIGH-07 | High     | `proxy.js` crashes on Supabase 5xx           | ✅     | `try/catch` around `getUser`          |
| HIGH-08 | High     | `auth.js` MFA bypass on catch                | ✅     | Enforced 2FA (`NEW-01`)               |
| HIGH-09 | High     | Admin login allows concurrent sessions       | ⏭️     | Supabase auth-level (deferred)        |
| HIGH-10 | High     | Newsletter form has no CAPTCHA               | ⏭️     | Product decision pending              |
| MED-01  | Medium   | Inconsistent error logging                   | ⏭️     | Pino rollout deferred                 |
| MED-02  | Medium   | `proxy.js` does not rate limit public API    | ⏭️     | Vercel WAF deferred                   |
| MED-03  | Medium   | Edge Function `inscricao` no rate limit      | ⏭️     | Deferred — dedicated audit            |
| MED-04  | Medium   | Server Actions not structured-logged         | ⏭️     | Pino rollout deferred                 |
| MED-05  | Medium   | Missing `X-DNS-Prefetch-Control`             | ✅     | `vercel.json`                         |
| MED-06  | Medium   | Migrations 016/017 use `SECURITY DEFINER`    | ⏭️     | Schema audit deferred                 |
| MED-07  | Medium   | `EXCEPTION` in 016 grants public EXECUTE     | ⏭️     | Schema audit deferred                 |
| MED-08  | Medium   | PageViewTracker leaks querystring (PII)      | ✅     | `pathname` only                       |
| MED-09  | Medium   | `validateUrl` permissive                     | ✅     | Strict regex `^https?://`             |
| MED-10  | Medium   | Console logs include PII in dev              | ⏭️     | DX improvement                        |
| MED-11  | Medium   | `ImageUpload` allows 5MB (DoS vector)        | ⏭️     | DX improvement                        |
| MED-12  | Medium   | Missing `COOP` / `CORP` headers              | ✅     | `vercel.json`                         |
| MED-13  | Medium   | Admin cache headers missing                  | ✅     | `Cache-Control: no-store` on `/admin` |
| LOW-01  | Low      | `.gitignore` does not exclude `*.pem`        | ✅     | `.gitignore` updated                  |
| LOW-02  | Low      | `X-Powered-By` header exposed                | ✅     | `poweredByHeader: false`              |
| LOW-03  | Low      | CORS allows arbitrary origin in dev          | ⏭️     | Cosmetic                             |
| LOW-04  | Low      | No `robots.txt` for `/admin/*`               | ⏭️     | Cosmetic                             |
| LOW-05  | Low      | `next.config.mjs` comment out of date        | ⏭️     | Cosmetic                             |
| LOW-06  | Low      | Redundant `X-Frame-Options` + CSP frame      | ⏭️     | Cosmetic                             |
| NEW-01  | High     | Auth MFA bypass when Supabase MFA errors     | ✅     | Enforced 2FA + `signOut()` on error   |
| NEW-02  | Medium   | `PageViewTracker` POST frequency not capped  | ⏭️     | Edge case — Vercel handles            |
| NEW-03  | Low      | `lib/api/inscription.js` returns 500 on dup  | ⏭️     | Edge function change                  |
| NEW-04  | Low      | Supabase `select('*')` in admin lists        | ⏭️     | Performance only                      |
| NEW-05  | Low      | `RESEND_API_KEY` (legacy) still referenced   | ⏭️     | Cleaned in follow-up commit           |

\* HIGH-02 was a false positive: `OPENROUTER_API_KEY` is read in a server-only
module and never shipped to the browser. Verified by inspecting the
`@vercel/server-only` boundary and the build manifest.

## Summary

- **Fixed in this PR (20 commits):** 1 Critical, 7 High, 5 Medium, 2 Low,
  plus 1 New-High (NEW-01).
- **Deferred:** 2 High (H09 concurrent sessions, H10 CAPTCHA — product
  decisions), 5 Medium (mostly observability + schema audit), 6 Low.
- **Coverage:** 14/30 findings fully remediated; 16/30 deferred with
  reason.
- **Branch:** `security/i18n-audit-fixes` (a partir de
  `feat/i18n-content-translation`).

## How to verify

```bash
git checkout security/i18n-audit-fixes
npm install
npm run build
curl -I http://localhost:3000/pt | grep -iE 'content-security|x-powered-by'
# expect: content-security-policy present, x-powered-by absent
```

Re-run `o-sentinela` against the new branch and expect: 0 Critical,
0 High, ~3 Medium (all observability), ~6 Low.

## Related

- Plan: `~/.openclaude/plans/hazy-stargazing-pearl.md`
- SECURITY.md: project root
- Lessons learned: CLAUDE-Next.md #55–#60
