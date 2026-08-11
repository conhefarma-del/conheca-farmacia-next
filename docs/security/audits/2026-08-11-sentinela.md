# Sentinela Audit — 2026-08-11

Vistoria de segurança executada pelo agente local `o-sentinela`
(`o-sentinela/SKILL.md`) contra a branch `security/i18n-audit-fixes`.
Método: revisão de código + testes empíricos contra a BD de produção
(anon key vs service role).

**Estado global: 8/8 findings corrigidos** (implementados; no working
tree a aguardar commit — último commit `4a2fef9`).

| ID  | Severity | Área / Ficheiro                                    | Estado | Correção |
| --- | -------- | -------------------------------------------------- | ------ | -------- |
| 1   | 🟠 ALTO  | Edge Functions de email (`send-newsletter-email`, `send-inscription-email`) invocáveis com a chave anónima, sem rate limit | ✅ | Fix #1 |
| 2   | 🟠 ALTO  | Subscrição da newsletter via RPC `subscribe_newsletter` direto do browser (vetor de flood) | ✅ | Fix #2 |
| 3   | 🟠 ALTO  | RLS ativo em produção mas nunca versionado (10 tabelas críticas) — `db reset` = exposição total via anon key | ✅ | Fix #3 |
| 4   | 🟡 MÉDIO | `lib/api/analytics.js` sem validação de input nem rate limit (8 actions: page views, reading time, shares, …) | ✅ | Fix #4 |
| 5   | 🟡 MÉDIO | Credenciais de reunião (`meeting_id` + `password`) públicas nas páginas de lives | ✅ | Fix #5 |
| 6   | 🟡 MÉDIO | Rate limits in-memory em serverless (feedback + welcome email) — efetivos ≈ N_instâncias × limite | ✅ | Fix #6 |
| 7   | 🟡 MÉDIO | CSP duplicado (`next.config.mjs` com `'unsafe-inline'`/`'unsafe-eval'` anulava o nonce do `proxy.js`) + `SECURITY.md` desatualizado | ✅ | Fix #7 |
| 8   | 🔵 BAIXO | `createArticle`/`updateArticle` gravavam HTML sem sanitização server-side | ✅ | Fix #8 |

---

## O que está sólido (verificado, não assumido)

- **RLS funcional na BD de produção** — testado com a anon key:
  `admin_users`, `email_logs`, `audit_logs`, `page_views`, `inscricoes`,
  `newsletter`, `drug_feedback`, `auth_attempts` → 0 linhas para anon;
  conteúdo público só `status='published' AND is_archived=false`; sem
  `USING (true)`; policies admin usam `is_current_user_admin()` com
  `WITH CHECK`.
- **Storage**: upload/delete só admin (policy 049); buckets validam MIME + 5MB.
- **2FA TOTP obrigatório**, login com rate-limit DB-backed (5/5min),
  mensagens genéricas (sem enumeração), logout invalida a sessão no
  servidor, idle timeout 30min.
- **Sem segredos no git**; só 2 vars `NEXT_PUBLIC_` (URL + ANON — públicas
  por definição).
- **33 funções SECURITY DEFINER** com `SET search_path` fixo.
- **Sanitização a dois níveis** (save + render), Zod no backend, CORS
  whitelist nas Edge Functions.

---

## Finding 1 — 🟠 ALTO: canal de email explorável com a chave pública

**Problema:** `send-newsletter-email` tinha o rate limiter removido
(`// rate-limiter removed to restore original behavior`) e
`send-inscription-email` nunca teve. Ambas respondiam a
`Authorization: Bearer <ANON_KEY>` — chave presente no bundle do browser.

**Prova empírica (produção):**
```
send-newsletter-email with anon:  400 {"error":"Email and type are required"}   ← chegou ao código
send-newsletter-email sem JWT:    401                                          ← só o gateway barra sem JWT
send-inscription-email with anon: 400 {"error":"Campos obrigatórios: ..."}     ← chegou ao código
```

**Cenário:** extrair a anon key do bundle e disparar emails ilimitados a
destinatários arbitrários com sender `newsletter@conhecafarmacia.com` /
`info@conhecafarmacia.com` (fraude de marca + custo de quota Brevo).

**Correção (Fix #1):**
- `supabase/functions/send-newsletter-email/index.ts` e
  `send-inscription-email/index.ts`: exigem o header `x-internal-key`
  com o segredo partilhado `EDGE_INTERNAL_KEY` (401 sem ele) + rate
  limit por destinatário (3 emails/hora) como defesa em profundidade.
- `lib/actions/newsletter.js` (`sendWelcomeEmail`, `sendContentAlert`) e
  `lib/actions/inscription.js`: os fetches passam a enviar `x-internal-key`.

**Deploy requerido:** gerar segredo (`openssl rand -hex 32`) e configurá-lo
em `.env.local` + Vercel + Supabase secrets; redeploy das Edges. Sem isso,
as Edges respondem 401 (fail-closed).

---

## Finding 2 — 🟠 ALTO: subscrição da newsletter sem rate limit

**Problema:** `NewsletterSection.jsx` chamava `supabase.rpc('subscribe_newsletter')`
diretamente do browser — qualquer visitante podia inundar a tabela
`newsletter` e disparar os emails de boas-vindas sem limite partilhado.

**Correção (Fix #2):**
- Nova `subscribeNewsletterAction(email)` em `lib/actions/newsletter.js`:
  `check_rate_limit` DB-backed (5 por 5min por IP+email) → RPC
  `subscribe_newsletter` → devolve `{ success, unsubscribeToken, exists }`.
- `NewsletterSection.jsx` usa a Server Action (o RPC deixou de ser
  invocável pelo browser).
- **Bug encontrado no caminho:** `check_rate_limit` conta linhas em
  `auth_attempts` — a action registava o limite mas nunca as tentativas,
  logo o contador nunca subia. Adicionado `log_auth_attempt('newsletter')`
  (padrão do `inscription.js`).

---

## Finding 3 — 🟠 ALTO: RLS não versionado (10 tabelas críticas)

**Problema:** `articles`, `events`, `lives`, `inscricoes`, `admin_users`,
`page_views`, `email_logs`, `audit_logs`, `admin_access_questions` e
`auth_attempts` tinham RLS **ativo em produção mas ausente das migrações**
— um `db reset` recriava as tabelas com RLS desligado → exposição total
via anon key. Colunas e RPCs de analytics também eram drift.

**Correção (Fix #3) — migração `141_rls_versionar_tabelas_criticas.sql`:**
- `ENABLE ROW LEVEL SECURITY` nas 10 tabelas.
- 24 policies (24 `DROP IF EXISTS` + 2 drops de legacy), com fonte
  documentada por bloco: exatas das migrações 014/015/020/031 e
  reconstruídas do comportamento observado (verificado empiricamente).
- **2 hardenings:** removidas as policies legacy de `inscricoes`
  ("Permitir leitura para autenticados" deixava qualquer autenticado ler
  toda a tabela — PII; e "Permitir inscrições de qualquer um" com
  `WITH CHECK (true)`).
- `GRANT EXECUTE` de `check_rate_limit`/`log_auth_attempt` (também drift —
  sem eles, um reset quebrava todo o rate limiting DB-backed).

**Nota de transparência:** sem password da BD no pooler-url não foi
possível ler o `pg_policies` real; as policies reconstruídas espelham o
comportamento observado e o cabeçalho da migração lista os deltas.
Sugestão documentada: comparar com
`SELECT ... FROM pg_policies WHERE tablename IN (...)` antes de aplicar.

---

## Finding 4 — 🟡 MÉDIO: analytics sem validação nem rate limit

**Problema:** as 8 actions de `lib/api/analytics.js` (page views, reading
time, shares, downloads, access counts) aceitavam qualquer input sem
validação server-side e sem limite partilhado (só in-memory).

**Correção (Fix #4) — `lib/api/analytics.js` reescrito:**
- Validação server-side de todos os inputs: `trackPageView` (path 1–500
  chars sem controlo/HTML, referrer ≤500, sessionId UUID), slugs, UUIDs,
  `seconds` 1–3600.
- Rate limit DB-backed: 120 pedidos/5min por IP (`check_rate_limit` +
  `log_auth_attempt`, attempt `'analytics'`) em todas as 8 actions —
  partilhado entre instâncias.
- Assinaturas dos callers inalteradas.

---

## Finding 5 — 🟡 MÉDIO: credenciais de reunião públicas nas lives

**Problema:** `meeting_id` + `password` das reuniões eram servidos no HTML
público das páginas de lives (scraping em massa).

**Correção (Fix #5) — `app/[lang]/(public)/lives/[slug]/page.js`:**
- O bloco com `meeting_id` + `password` só é renderizado para sessão
  **autenticada** (verificação no servidor).
- O link de acesso continua público — os links Zoom/Google Meet embutem a
  password no URL (`?pwd=`), pelo que os participantes anónimos entram
  pelo link. Nota de produto documentada: se alguma live tiver
  `access_link` que não embuta a password, colar o link completo no admin.
- Decisão suportada por dados: existem apenas 2 utilizadores auth (os 2
  admins) — "sessão autenticada" = admins.

---

## Finding 6 — 🟡 MÉDIO: rate limits in-memory em serverless

**Problema:** o único limite do `submitDrugFeedback` (5/min) era um `Map`
em memória por instância — na Vercel o efetivo era ≈ N_instâncias × 5/min.

**Correção (Fix #6):**
- `lib/actions/feedback.js`: `Map` in-memory removido; `check_rate_limit`
  + `log_auth_attempt` (attempt `'feedback'`, 10 pedidos/5min por IP).
  Honeypot (`fb-company`) e policy `WITH CHECK` (135) mantidos.
- `lib/actions/newsletter.js` (`sendWelcomeEmail`): idem (attempt
  `'welcome_email'`, 10/5min por IP+email hash).
- Ambos fail-open por erro de RPC, como o padrão auth/inscription.

---

## Finding 7 — 🟡 MÉDIO: CSP duplicado

**Problema:** `next.config.mjs` definia CSP com `'unsafe-inline'` +
`'unsafe-eval'`. Headers de `next.config` sobrepõem-se aos do middleware
para o mesmo header — o CSP permissivo anulava o nonce do `proxy.js` em
produção.

**Correção (Fix #7):**
- `next.config.mjs`: CSP removido do `headers()` — o nonce CSP do
  `proxy.js` é a fonte única. Restantes headers (HSTS/XFO/nosniff/etc.)
  mantidos, comentário atualizado.
- `SECURITY.md`: secção CSP reescrita (nonce por pedido como fonte única)
  e tabela de env vars atualizada — adicionadas `EDGE_INTERNAL_KEY` /
  `BREVO_API_KEY`, removidas as legacy RESEND/SMTP.
- `.env.local.example`: bloco `EDGE_INTERNAL_KEY` documentado.

---

## Finding 8 — 🔵 BAIXO: sanitização server-side em falta

**Problema:** `createArticle`/`updateArticle` gravavam `content` sem
sanitizar no servidor (o render-time com DOMPurify protegia os leitores,
mas não os admins no preview; o cliente é contornável).

**Correção (Fix #8) — `lib/actions/content.js`:**
- `content: sanitizeHtml(formData.content || '')` em `createArticle` e
  `updateArticle` — espelha o padrão de `translation.js`/`legalContent.js`.
- Verificado: markdown preservado; `<script>` removido; `javascript:` em
  `img src` neutralizado.
- `guides.js`/`protocolos.js` verificados fora de âmbito (campos de
  leitura, sem renderização HTML).

---

## Resumo

- **8/8 findings corrigidos** (fixes #1–#8, ~13 ficheiros + migração 141).
- **Fora de alcance documentado:** versionar colunas + RPCs de analytics
  (`increment_view_count`, `add_reading_time`, …) — colunas ainda drift;
  e `validate-inscription` (não é Edge de email; pode receber o mesmo
  header interno num follow-up).
- **Deploy pendente (não é commit de código):** aplicar a migração 141;
  configurar `EDGE_INTERNAL_KEY` em `.env.local` + Vercel + Supabase
  secrets; redeploy das Edges; deploy do código na Vercel.

## Como verificar

```bash
# RLS versionado (após aplicar a 141)
SELECT tablename, rowsecurity FROM pg_tables
WHERE tablename IN ('articles','events','lives','inscricoes','admin_users',
  'page_views','email_logs','audit_logs','admin_access_questions','auth_attempts');

# Edge Functions blindadas (após configurar EDGE_INTERNAL_KEY)
curl -s -X POST https://<proj>.supabase.co/functions/v1/send-newsletter-email \
  -H "Authorization: Bearer $ANON" -H "Content-Type: application/json" \
  -d '{"type":"welcome","email":"test@example.com"}'
# → 401 sem x-internal-key

# CSP fonte única
curl -I https://conhecafarmacia.com/pt | grep -i content-security-policy
# → header presente (nonce do proxy), sem 'unsafe-inline'
```

## Relacionados

- Skill: `o-sentinela/SKILL.md`
- Audit anterior: `docs/security/audits/2026-06-15-sentinela.md`
- SECURITY.md (raiz do projeto) — secções CSP e env vars atualizadas
- Migração: `supabase/migrations/141_rls_versionar_tabelas_criticas.sql`
