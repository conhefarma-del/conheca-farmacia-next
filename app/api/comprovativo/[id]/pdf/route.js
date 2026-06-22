// GET /api/comprovativo/[id]/pdf
//
// Generates the PDF receipt for a given inscription. Server-side, no
// browser, no html2canvas — uses Satori + resvg-js + pdf-lib for a
// vector-quality PDF that renders identically on every device.
//
// The route uses Node runtime (not Edge) because:
//   - pdf-lib uses Node `Buffer` and async fs APIs
//   - resvg-js has a native binary that needs the Node runtime
//   - We need read access to public/logo/logo-principal-branco.png
//
// The PDF is generated fresh per request (~150-250ms cold, ~80ms warm).
// If load grows, we can add a Vercel KV cache layer here later.
//
// Security: the inscription ID is treated as a public reference (it's
// already embedded in QR codes, emails, and the success page). No PII
// leaks beyond what was already in the email.

import { createClient } from '@supabase/supabase-js'
import { getLogoDataUrl } from '@/lib/pdf/logo'
import { getQrDataUrl } from '@/lib/pdf/qr'
import { buildComprovativoPdf } from '@/lib/pdf/buildPdf'
import ComprovativoSatori from '@/lib/pdf/ComprovativoSatori'
import { loadTranslations } from '@/lib/i18n'

export const runtime = 'nodejs'
export const dynamic = 'force-dynamic' // never cache

// Sanitize filename for Content-Disposition header (Windows-safe).
function sanitizeFilename(s) {
  if (!s) return ''
  return String(s)
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[\\/:*?"<>|]/g, '')
    .replace(/\s+/g, '_')
    .replace(/_+/g, '_')
    .replace(/^_|_$/g, '')
    .slice(0, 60)
}

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

export async function GET(request, { params }) {
  const { id } = await params
  if (!id || !UUID_RE.test(id)) {
    return new Response('Invalid id', { status: 400 })
  }

  // Accept ?lang=pt|en (defaults to pt)
  const url = new URL(request.url)
  const lang = url.searchParams.get('lang') === 'en' ? 'en' : 'pt'

  // Service Role client — server-only, never exposed to browser
  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL,
    process.env.SUPABASE_SERVICE_ROLE_KEY
  )

  // Fetch inscription + event
  const { data: inscription, error } = await supabase
    .from('inscricoes')
    .select(`
      id,
      nome_completo,
      email,
      especialidade,
      numero_inscricao,
      modalidade,
      created_at,
      evento_id,
      evento:eventos(id, title, slug, data_evento, localizacao, capacidade)
    `)
    .eq('id', id)
    .single()

  if (error || !inscription) {
    return new Response('Inscription not found', { status: 404 })
  }

  const shortRef = inscription.numero_inscricao ||
    inscription.id.slice(-8).toUpperCase()

  // Resolve event title (handle EN translation if needed)
  let eventTitle = inscription.evento?.title || ''
  if (lang === 'en') {
    const { data: tr } = await supabase
      .from('event_translations')
      .select('title')
      .eq('evento_id', inscription.evento_id)
      .eq('lang', 'en')
      .single()
    if (tr?.title) eventTitle = tr.title
  }

  // Resolve modality label
  const translations = await loadTranslations(lang)
  const t = (path) => {
    const keys = path.split('.')
    let cur = translations
    for (const k of keys) cur = cur?.[k]
    return cur || path
  }

  const modalityLabels = {
    presencial: t('evento.modalidade.presencial'),
    online: t('evento.modalidade.online'),
    hibrido: t('evento.modalidade.hibrido'),
  }
  const modalityLabel = inscription.modalidade
    ? modalityLabels[inscription.modalidade]
    : ''

  // Format date (e.g. "21 jun 2026")
  const dateFmt = new Intl.DateTimeFormat(
    lang === 'en' ? 'en-GB' : 'pt-PT',
    { day: 'numeric', month: 'short', year: 'numeric' }
  )
  const inscriptionDate = inscription.created_at
    ? dateFmt.format(new Date(inscription.created_at))
    : ''
  const eventDate = inscription.evento?.data_evento
    ? dateFmt.format(new Date(inscription.evento.data_evento))
    : ''

  // Generate QR (validation URL)
  const validationUrl = `https://conhecafarmacia.com/validar/${shortRef}`
  const [logoDataUrl, qrDataUrl] = await Promise.all([
    Promise.resolve(getLogoDataUrl()),
    getQrDataUrl(validationUrl, 240),
  ])

  // Build the JSX
  const jsx = (
    <ComprovativoSatori
      logoDataUrl={logoDataUrl}
      qrDataUrl={qrDataUrl}
      shortRef={shortRef}
      eventTitle={eventTitle}
      eventDate={eventDate}
      eventLocation={inscription.evento?.localizacao || ''}
      modality={inscription.modalidade}
      modalityLabel={modalityLabel}
      attendeeName={inscription.nome_completo}
      attendeeEmail={inscription.email}
      attestationCode={lang === 'pt' ? 'Inscrição confirmada' : 'Registration confirmed'}
      inscriptionDate={inscriptionDate}
      eventBadge={lang === 'pt' ? 'Comprovativo oficial' : 'Official receipt'}
      docSubtitle={lang === 'pt'
        ? 'Documento de confirmação de inscrição no evento'
        : 'Event registration confirmation document'}
      stubTagline={lang === 'pt'
        ? 'A sua presença faz a diferença.'
        : 'Your presence makes the difference.'}
      lang={lang}
    />
  )

  const pdfBytes = await buildComprovativoPdf(jsx)

  const titlePart = sanitizeFilename(eventTitle) || 'Evento'
  const filename = `Inscricao_${titlePart}_${shortRef}.pdf`

  return new Response(pdfBytes, {
    status: 200,
    headers: {
      'content-type': 'application/pdf',
      'content-disposition': `attachment; filename="${filename}"`,
      'cache-control': 'private, no-store',
    },
  })
}
