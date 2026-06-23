// GET /api/comprovativo/[id]/pdf
//
// The server-side PDF generation pipeline (Satori + resvg-js + pdf-lib)
// has been retired. Direct download is replaced by a print-friendly
// page that the user can save as PDF via the browser's Print dialog.
//
// This route is kept so old links, QR codes, and bookmarked URLs do not
// break — they now redirect to the success page where the receipt can be
// printed.
//
// Security:
//   - id and lang are sanitised before being interpolated into the HTML
//     response (defence in depth — even though the regex below already
//     restricts id to UUID/INT shapes and lang to 'en'/'pt').
//   - Rate-limit 30 req/min/IP per process instance (in-memory; same
//     trade-off as inscription.js — sufficient for casual scraping, not
//     a substitute for edge-level WAF).

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i
const INT_RE = /^\d{1,18}$/

const COMP_LIMIT = { max: 30, windowMs: 60_000 }
const _rateMap = new Map()

function getClientIp(headersList) {
  const xff = headersList.get('x-forwarded-for')
  if (xff) return xff.split(',')[0].trim()
  return headersList.get('x-real-ip') || 'unknown'
}

function checkRate(ip) {
  const now = Date.now()
  const entry = _rateMap.get(ip)
  if (!entry || entry.resetAt < now) {
    _rateMap.set(ip, { count: 1, resetAt: now + COMP_LIMIT.windowMs })
    return true
  }
  if (entry.count >= COMP_LIMIT.max) return false
  entry.count += 1
  return true
}

export const runtime = 'nodejs'
export const dynamic = 'force-dynamic' // never cache

// Strip everything outside [a-zA-Z0-9-] from a string. Used as the last
// line of defence before interpolating user-controlled values into HTML.
function safeForHtml(s) {
  return String(s || '').replace(/[^a-zA-Z0-9-]/g, '')
}

const html = ({ id, lang }) => {
  const pt = lang === 'en'
  return `<!DOCTYPE html>
<html lang="${pt ? 'en' : 'pt-PT'}">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>${pt ? 'Registration receipt' : 'Comprovativo de inscrição'}</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
           max-width: 560px; margin: 60px auto; padding: 0 20px; color: #002a32;
           line-height: 1.6; }
    h1 { color: #00493a; font-size: 28px; margin-bottom: 8px; }
    p { margin: 12px 0; }
    ol { padding-left: 24px; }
    li { margin: 8px 0; }
    .cta { display: inline-block; background: #00493a; color: white;
           padding: 14px 24px; border-radius: 8px; text-decoration: none;
           font-weight: 600; margin-top: 24px; }
    .cta:hover { background: #003a30; }
    .ref { background: #f4efe6; padding: 12px 16px; border-radius: 6px;
           font-family: ui-monospace, 'Courier New', monospace;
           font-size: 18px; margin: 16px 0; }
  </style>
</head>
<body>
  <h1>${pt ? 'How to save your receipt' : 'Como guardar o seu comprovativo'}</h1>
  <p>${pt
    ? 'Direct PDF download is no longer available. To save your registration receipt:'
    : 'O download directo do PDF já não está disponível. Para guardar o seu comprovativo de inscrição:'}</p>
  <ol>
    <li>${pt
      ? 'Open the registration success page (use the button below).'
      : 'Abra a página de sucesso da inscrição (use o botão abaixo).'}</li>
    <li>${pt
      ? 'Click "Print / Save as PDF".'
      : 'Clique em "Imprimir / Guardar como PDF".'}</li>
    <li>${pt
      ? 'In the print dialog, choose "Save as PDF" as the destination.'
      : 'Na janela de impressão, escolha "Guardar como PDF" como destino.'}</li>
    <li>${pt
      ? 'Save the file. The receipt will look exactly like what you saw on screen.'
      : 'Guarde o ficheiro. O comprovativo fica exactamente como viu no ecrã.'}</li>
  </ol>
  <p>${pt ? 'Registration reference' : 'Referência da inscrição'}:</p>
  <div class="ref">${id}</div>
  <a class="cta" href="/${pt ? 'en' : 'pt'}/inscricao/sucesso?id=${encodeURIComponent(id)}">
    ${pt ? 'Open receipt →' : 'Abrir comprovativo →'}
  </a>
</body>
</html>`
}

export async function GET(request, { params }) {
  const { id } = await params
  if (!id || (!UUID_RE.test(id) && !INT_RE.test(id))) {
    return new Response('Invalid id', { status: 400 })
  }

  // Rate limit (after validation, before any other work)
  const ip = getClientIp(request.headers)
  if (!checkRate(ip)) {
    return new Response('Too many requests', { status: 429 })
  }

  const url = new URL(request.url)
  const rawLang = url.searchParams.get('lang') === 'en' ? 'en' : 'pt'
  // Sanitise values that go into HTML. id is already constrained by the
  // regex above; lang is constrained to a 2-char allowlist. Both passes
  // are belt-and-braces — if a future change broadens either, this still
  // refuses to emit HTML-breaking characters.
  const safeId = safeForHtml(id)
  const safeLang = rawLang === 'en' ? 'en' : 'pt'

  return new Response(html({ id: safeId, lang: safeLang }), {
    status: 200,
    headers: {
      'content-type': 'text/html; charset=utf-8',
      'cache-control': 'no-store',
      'x-content-type-options': 'nosniff',
    },
  })
}
