// Comprovativo (boarding pass style) rendered to PDF via Satori.
//
// This is a server-only React component (no 'use client', no hooks, no
// context) consumed by `lib/pdf/buildPdf.js`. It receives all strings
// already translated — Satori does not run inside Next.js's i18n layer.
//
// Layout: 1100x450 (2.44:1) — matches the proportions of A4 landscape
// (297x210mm). The page rectangle is set to that size in buildPdf.js; the
// full image is drawn into it with `cover` fit.
//
// Design notes vs the on-screen InscricaoBilhete:
//   - `::after` perforated edge is replaced with a simple dashed border
//     (Satori does not support pseudo-elements)
//   - flexbox is used the same way; Satori has good support
//   - linear-gradient on the canhoto (left stub) is supported by Satori
//   - no images served via URL — logo and QR are passed as data URLs

export default function ComprovativoSatori({
  logoDataUrl,
  qrDataUrl,
  shortRef,
  eventTitle,
  eventDate,
  eventLocation,
  modality,        // 'presential' | 'online' | 'hybrid'
  modalityLabel,   // i18n string
  attendeeName,
  attendeeEmail,
  attestationCode, // e.g. "1 de 1" / "Slot confirmado"
  inscriptionDate, // e.g. "21 jun 2026"
  eventBadge,      // i18n string for the badge
  docSubtitle,     // i18n string for the subtitle
  stubTagline,     // i18n string for the stub footer
  lang,            // 'pt' | 'en'
}) {
  return (
    <div
      style={{
        width: 1300,
        height: 920,
        display: 'flex',
        flexDirection: 'row',
        backgroundColor: '#ffffff',
        fontFamily: 'Inter',
        color: '#002a32',
      }}
    >
      {/* LEFT: Canhoto (stub) */}
      <div
        style={{
          width: 380,
          height: 920,
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'space-between',
          padding: 48,
          backgroundColor: '#00493a',
          color: '#ffffff',
          // dashed right border (Satori equivalent of perforated edge)
          borderRight: '3px dashed rgba(255,255,255,0.35)',
        }}
      >
        {/* Logo */}
        <div style={{ display: 'flex' }}>
          <img
            src={logoDataUrl}
            width={220}
            height={72}
            style={{ objectFit: 'contain' }}
          />
        </div>

        {/* Reference */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          <div
            style={{
              fontSize: 18,
              letterSpacing: '0.18em',
              textTransform: 'uppercase',
              opacity: 0.7,
              fontWeight: 500,
            }}
          >
            {lang === 'pt' ? 'Comprovativo' : 'Receipt'}
          </div>
          <div
            style={{
              fontFamily: 'Courier New, monospace',
              fontSize: 56,
              fontWeight: 700,
              letterSpacing: '0.04em',
            }}
          >
            {shortRef}
          </div>
        </div>

        {/* QR */}
        <div
          style={{
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            gap: 14,
          }}
        >
          <div
            style={{
              width: 220,
              height: 220,
              backgroundColor: '#ffffff',
              padding: 10,
              display: 'flex',
            }}
          >
            <img
              src={qrDataUrl}
              width={200}
              height={200}
              style={{ objectFit: 'contain' }}
            />
          </div>
          <div
            style={{
              fontSize: 14,
              letterSpacing: '0.16em',
              textTransform: 'uppercase',
              opacity: 0.7,
              textAlign: 'center',
            }}
          >
            {lang === 'pt' ? 'Validar online' : 'Validate online'}
          </div>
        </div>

        {/* Tagline */}
        <div
          style={{
            fontSize: 14,
            fontStyle: 'italic',
            opacity: 0.65,
            lineHeight: 1.4,
          }}
        >
          {stubTagline}
        </div>
      </div>

      {/* RIGHT: Main panel */}
      <div
        style={{
          flex: 1,
          height: 920,
          display: 'flex',
          flexDirection: 'column',
          padding: '64px 72px',
        }}
      >
        {/* Top: badge + attestation */}
        <div
          style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            marginBottom: 24,
          }}
        >
          <div
            style={{
              display: 'flex',
              padding: '10px 18px',
              backgroundColor: '#e6f0ed',
              color: '#00493a',
              fontSize: 16,
              fontWeight: 600,
              letterSpacing: '0.14em',
              textTransform: 'uppercase',
            }}
          >
            {eventBadge}
          </div>
          <div
            style={{
              fontSize: 16,
              color: '#5a5650',
              letterSpacing: '0.06em',
            }}
          >
            {attestationCode}
          </div>
        </div>

        {/* Title */}
        <div
          style={{
            fontFamily: 'Fraunces',
            fontSize: 72,
            fontWeight: 700,
            lineHeight: 1.05,
            marginBottom: 12,
            color: '#002a32',
          }}
        >
          {lang === 'pt' ? 'Comprovativo' : 'Receipt'}
        </div>
        <div
          style={{
            fontSize: 22,
            color: '#5a5650',
            marginBottom: 36,
          }}
        >
          {docSubtitle}
        </div>

        {/* Event block */}
        <div
          style={{
            display: 'flex',
            flexDirection: 'column',
            gap: 8,
            paddingBottom: 28,
            borderBottom: '2px solid #e0dcd4',
            marginBottom: 28,
          }}
        >
          <div
            style={{
              fontSize: 16,
              letterSpacing: '0.18em',
              textTransform: 'uppercase',
              color: '#5a5650',
              fontWeight: 500,
            }}
          >
            {lang === 'pt' ? 'Evento' : 'Event'}
          </div>
          <div
            style={{
              fontFamily: 'Fraunces',
              fontSize: 44,
              fontWeight: 600,
              lineHeight: 1.15,
              color: '#002a32',
            }}
          >
            {eventTitle}
          </div>
          <div
            style={{
              display: 'flex',
              gap: 28,
              fontSize: 20,
              color: '#5a5650',
              marginTop: 8,
            }}
          >
            {eventDate && <div>📅 {eventDate}</div>}
            {eventLocation && <div>📍 {eventLocation}</div>}
            {modalityLabel && <div>• {modalityLabel}</div>}
          </div>
        </div>

        {/* Attendee */}
        <div
          style={{
            display: 'flex',
            flexDirection: 'column',
            gap: 8,
            flex: 1,
          }}
        >
          <div
            style={{
              fontSize: 16,
              letterSpacing: '0.18em',
              textTransform: 'uppercase',
              color: '#5a5650',
              fontWeight: 500,
            }}
          >
            {lang === 'pt' ? 'Inscrito' : 'Attendee'}
          </div>
          <div
            style={{
              fontSize: 32,
              fontWeight: 600,
              color: '#002a32',
              lineHeight: 1.2,
            }}
          >
            {attendeeName}
          </div>
          <div style={{ fontSize: 18, color: '#5a5650' }}>{attendeeEmail}</div>
        </div>

        {/* Footer line */}
        <div
          style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            paddingTop: 24,
            borderTop: '2px solid #e0dcd4',
            fontSize: 14,
            color: '#5a5650',
            letterSpacing: '0.06em',
          }}
        >
          <div>
            {lang === 'pt' ? 'Emitido em' : 'Issued on'} {inscriptionDate}
          </div>
          <div>conhecafarmacia.com</div>
        </div>
      </div>
    </div>
  )
}
