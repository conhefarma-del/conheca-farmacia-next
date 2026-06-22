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
const INT_RE = /^\d{1,18}$/

export async function GET(request, { params }) {
  try {
    const { id } = await params
    // Accept both UUID and int8 (inscricoes.id is int8; the user-facing
    // inscription number is the int8, not a UUID).
    if (!id || (!UUID_RE.test(id) && !INT_RE.test(id))) {
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
    // NOTE: column names mirror the actual Supabase schema:
    //   inscricoes: id, nome, email, evento_id, evento_slug, created_at, ...
    //   events:     id, slug, title, date, time, location, type, capacity, ...
    const { data: inscription, error } = await supabase
      .from('inscricoes')
      .select(`
        id,
        nome,
        email,
        evento_slug,
        created_at,
        events:evento_id(id, slug, title, date, time, location, type, capacity)
      `)
      .eq('id', id)
      .single()

    if (error || !inscription) {
      return new Response('Inscription not found', { status: 404 })
    }

    // shortRef is the inscription's int8 id, zero-padded to 6 digits for
    // display (e.g. 85 -> "000085"). Padded so QR codes and filename
    // look consistent across single/double/triple digit numbers.
    const shortRef = String(inscription.id).padStart(6, '0')

    // Resolve event title (handle EN translation if needed)
    let eventTitle = inscription.events?.title || ''
    if (lang === 'en' && inscription.evento_id) {
      const { data: tr } = await supabase
        .from('event_translations')
        .select('title')
        .eq('evento_id', inscription.evento_id)
        .eq('lang', 'en')
        .single()
      if (tr?.title) eventTitle = tr.title
    }

    // Resolve modality label (events.type is freeform: 'presencial' | 'online' | etc.)
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
    const modalityLabel = inscription.events?.type
      ? modalityLabels[inscription.events.type] || inscription.events.type
      : ''

    // Format date (e.g. "21 jun 2026")
    const dateFmt = new Intl.DateTimeFormat(
      lang === 'en' ? 'en-GB' : 'pt-PT',
      { day: 'numeric', month: 'short', year: 'numeric' }
    )
    const inscriptionDate = inscription.created_at
      ? dateFmt.format(new Date(inscription.created_at))
      : ''
    const eventDate = inscription.events?.date
      ? dateFmt.format(new Date(inscription.events.date))
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
        eventLocation={inscription.events?.location || ''}
        modality={inscription.events?.type}
        modalityLabel={modalityLabel}
        attendeeName={inscription.nome}
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
  } catch (err) {
    // Surface the actual error so preview-pdf.mjs can show it.
    // Temporary diagnostic — narrow back to generic 500 once stable.
    return new Response(
      `Error: ${err?.message || String(err)}\n\n${err?.stack || ''}`,
      {
        status: 500,
        headers: { 'content-type': 'text/plain; charset=utf-8' },
      }
    )
  }
}
