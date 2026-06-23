// GET /api/comprovativo/[id]/pdf
//
// The server-side PDF generation pipeline (Satori + resvg-js + pdf-lib)
// has been retired. Direct download is replaced by a print-friendly
// page that the user can save as PDF via the browser's Print dialog.
//
// To get a PDF of the registration receipt:
//   1. After submitting the registration form, you land on the success
//      page, which already shows the receipt on screen.
//   2. Click the "Imprimir / Guardar como PDF" button.
//   3. In the print dialog, choose "Guardar como PDF" (Chrome/Edge) or
//      "Save as PDF" (Firefox/Safari) as the destination.
//   4. The receipt renders identically to what you see on screen.
//
// This route is kept so old links, QR codes, and bookmarked URLs do not
// break — they now redirect to the success page where the receipt can be
// printed.

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i
const INT_RE = /^\d{1,18}$/

export const runtime = 'nodejs'
export const dynamic = 'force-dynamic' // never cache

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
  const url = new URL(request.url)
  const lang = url.searchParams.get('lang') === 'en' ? 'en' : 'pt'
  return new Response(html({ id, lang }), {
    status: 200,
    headers: { 'content-type': 'text/html; charset=utf-8' },
  })
}
