'use client'

import { useState, useEffect, useRef, useCallback } from 'react'
import { qrcodeLib } from '@/lib/qrcodeClient'
import { escapeHtml } from '@/lib/security'

/**
 * Certificado de Participação — slide panel da direita.
 * Mostra preview do certificado A4 paisagem em escala reduzida.
 * O PDF é gerado via window.print() numa janela nova.
 * Animação slideIn + overlay com backdrop-filter.
 */
export default function CertificadoParticipacao({ inscricao, evento, certificadoToken, onClose }) {
  const [open, setOpen] = useState(false)
  const cor = evento?.certificado_cor || '#00493A'
  const texto = evento?.certificado_texto || 'Certificamos que o participante concluiu com aproveitamento.'
  const carga = evento?.certificado_carga_horaria || ''
  const dataEvento = evento?.date
    ? new Intl.DateTimeFormat('pt-PT', { day: '2-digit', month: 'long', year: 'numeric' }).format(new Date(evento.date))
    : ''
  const refCode = `CF-CERT-${String(inscricao.id).padStart(6, '0')}/${new Date(inscricao.created_at).getFullYear()}`
  const url = `https://conhecafarmacia.com/certificado/${certificadoToken}`
  const qrRef = useRef(null)
  const emitidoEm = new Intl.DateTimeFormat('pt-PT', { day: '2-digit', month: '2-digit', year: 'numeric' }).format(
    new Date(inscricao.certificado_emitido_at || inscricao.created_at)
  )

  const [qr, setQr] = useState(null)
  const [qrReady, setQrReady] = useState(false)

  useEffect(() => {
    let cancelled = false
    setQrReady(false)
    qrcodeLib(url).then((d) => { if (!cancelled) { setQr(d); setQrReady(true) } }).catch(() => { setQrReady(true) })
    return () => { cancelled = true }
  }, [url])

  useEffect(() => { qrRef.current = qr }, [qr])

  // Trigger entrada animada no mount
  useEffect(() => {
    requestAnimationFrame(() => setOpen(true))
  }, [])

  // Fechar com animação
  const handleClose = useCallback(() => {
    setOpen(false)
    setTimeout(onClose, 250)
  }, [onClose])

  // Escape key
  useEffect(() => {
    const onKey = (e) => { if (e.key === 'Escape') handleClose() }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [handleClose])

  function handlePrint() {
    if (!qrReady) return
    const assinante2 = evento?.certificado_assinante_2_nome
    const certHtml = buildCertHtml({
      cor, texto, carga, dataEvento, refCode, url,
      evento, inscricao, assinante2, emitidoEm, qr: qrRef.current,
    })

    const printWindow = window.open('', '_blank', 'width=900,height=600')
    if (!printWindow) return

    printWindow.document.write(certHtml)
    printWindow.document.close()
    printWindow.focus()

    printWindow.onload = () => {
      setTimeout(() => {
        printWindow.print()
        printWindow.close()
      }, 500)
    }
  }

  return (
    <>
      {/* Overlay */}
      <div
        onClick={handleClose}
        style={{
          position: 'fixed',
          inset: 0,
          zIndex: 999,
          background: open ? 'rgba(0, 42, 50, 0.45)' : 'rgba(0, 42, 50, 0)',
          backdropFilter: open ? 'blur(4px)' : 'blur(0px)',
          WebkitBackdropFilter: open ? 'blur(4px)' : 'blur(0px)',
          transition: 'all 250ms ease-out',
        }}
      />

      {/* Panel */}
      <div
        role="dialog"
        aria-modal="true"
        aria-label="Certificado de Participação"
        style={{
          position: 'fixed',
          top: 0,
          right: 0,
          bottom: 0,
          zIndex: 1000,
          width: '100%',
          maxWidth: 680,
          background: '#fff',
          boxShadow: open
            ? '-8px 0 40px rgba(0, 42, 50, 0.15)'
            : '-8px 0 40px rgba(0, 42, 50, 0)',
          transform: open ? 'translateX(0)' : 'translateX(100%)',
          transition: 'transform 250ms cubic-bezier(0.16, 1, 0.3, 1), box-shadow 250ms ease-out',
          display: 'flex',
          flexDirection: 'column',
          overflow: 'hidden',
        }}
      >
        {/* Header */}
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            padding: '20px 28px',
            borderBottom: '1px solid #e5e7eb',
            flexShrink: 0,
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
            <div
              style={{
                width: 10,
                height: 10,
                borderRadius: '50%',
                background: cor,
                flexShrink: 0,
              }}
            />
            <h2
              style={{
                margin: 0,
                fontSize: 18,
                fontWeight: 600,
                color: '#002a32',
                fontFamily: 'Inter, sans-serif',
              }}
            >
              Certificado de Participação
            </h2>
          </div>
          <button
            type="button"
            onClick={handleClose}
            aria-label="Fechar"
            style={{
              background: 'none',
              border: 'none',
              cursor: 'pointer',
              width: 36,
              height: 36,
              borderRadius: 8,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: '#6b7280',
              fontSize: 20,
              fontWeight: 300,
              lineHeight: 1,
              transition: 'all 0.15s ease',
            }}
            onMouseEnter={(e) => {
              e.currentTarget.style.background = '#f3f4f6'
              e.currentTarget.style.color = '#002a32'
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.background = 'none'
              e.currentTarget.style.color = '#6b7280'
            }}
          >
            ✕
          </button>
        </div>

        {/* Content — preview do certificado + info */}
        <div
          style={{
            flex: 1,
            overflowY: 'auto',
            padding: '28px 28px 8px',
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            gap: 24,
          }}
        >
          {/* Badge informativo */}
          <div
            style={{
              display: 'inline-flex',
              alignItems: 'center',
              gap: 8,
              padding: '8px 16px',
              borderRadius: 8,
              background: '#f0fdf4',
              color: '#065f46',
              fontSize: 13,
              fontWeight: 500,
              fontFamily: 'Inter, sans-serif',
              width: '100%',
              boxSizing: 'border-box',
            }}
          >
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <circle cx="12" cy="12" r="10"/><path d="M12 16v-4M12 8h.01"/>
            </svg>
            <span>O certificado é gerado com base no template definido no evento.</span>
          </div>

          {/* Preview do certificado */}
          <div
            style={{
              background: '#fff',
              borderRadius: 12,
              overflow: 'hidden',
              boxShadow: '0 2px 16px rgba(0, 42, 50, 0.1)',
              border: '1px solid #e5e7eb',
              transform: 'scale(0.65)',
              transformOrigin: 'top center',
              width: '100%',
              maxWidth: 540,
              minHeight: 382,
            }}
          >
            <CertificadoPreview
              cor={cor} texto={texto} carga={carga} dataEvento={dataEvento}
              refCode={refCode} evento={evento} inscricao={inscricao}
              emitidoEm={emitidoEm} qr={qr}
            />
          </div>

          {/* Info do certificado */}
          <div
            style={{
              width: '100%',
              maxWidth: 540,
              display: 'flex',
              flexDirection: 'column',
              gap: 10,
              padding: '0 4px',
            }}
          >
            <InfoRow label="Participante" value={inscricao.nome} />
            <InfoRow label="Evento" value={evento?.title || '—'} />
            <InfoRow label="Código" value={refCode} />
            {carga && <InfoRow label="Carga horária" value={carga} />}
            <InfoRow
              label="Estado"
              value={qrReady ? '✓ Certificado pronto para imprimir' : '⏳ A gerar QR code...'}
              valueColor={qrReady ? '#065f46' : '#b45309'}
            />
          </div>
        </div>

        {/* Footer */}
        <div
          style={{
            display: 'flex',
            gap: 12,
            justifyContent: 'flex-end',
            alignItems: 'center',
            padding: '16px 28px',
            borderTop: '1px solid #e5e7eb',
            background: '#f9fafb',
            flexShrink: 0,
          }}
        >
          <button
            type="button"
            onClick={handleClose}
            style={{
              padding: '10px 20px',
              borderRadius: 8,
              border: '2px solid #00493a',
              background: 'transparent',
              color: '#00493a',
              fontSize: 14,
              fontWeight: 500,
              fontFamily: 'Inter, sans-serif',
              cursor: 'pointer',
              transition: 'all 0.15s ease',
            }}
            onMouseEnter={(e) => {
              e.currentTarget.style.background = 'rgba(0, 73, 58, 0.06)'
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.background = 'transparent'
            }}
          >
            Fechar
          </button>
          <button
            type="button"
            onClick={handlePrint}
            disabled={!qrReady}
            style={{
              padding: '10px 24px',
              borderRadius: 8,
              border: 'none',
              background: !qrReady ? '#9ca3af' : cor,
              color: '#fff',
              fontSize: 14,
              fontWeight: 600,
              fontFamily: 'Inter, sans-serif',
              cursor: !qrReady ? 'not-allowed' : 'pointer',
              transition: 'all 0.15s ease',
              opacity: !qrReady ? 0.7 : 1,
            }}
            onMouseEnter={(e) => {
              if (qrReady) {
                e.currentTarget.style.background = '#005c4a'
                e.currentTarget.style.transform = 'scale(1.02)'
              }
            }}
            onMouseLeave={(e) => {
              if (qrReady) {
                e.currentTarget.style.background = cor
                e.currentTarget.style.transform = 'scale(1)'
              }
            }}
          >
            {qrReady ? 'Imprimir / Guardar PDF' : 'A preparar certificado...'}
          </button>
        </div>
      </div>
    </>
  )
}

// ============================================
// Componentes auxiliares
// ============================================

function InfoRow({ label, value, valueColor }) {
  return (
    <div
      style={{
        display: 'flex',
        justifyContent: 'space-between',
        gap: 12,
        padding: '8px 0',
        borderBottom: '1px solid #f3f4f6',
        fontFamily: 'Inter, sans-serif',
        fontSize: 13,
      }}
    >
      <span style={{ color: '#6b7280', fontWeight: 500, flexShrink: 0 }}>{label}</span>
      <span style={{ color: valueColor || '#002a32', fontWeight: 600, textAlign: 'right' }}>{value}</span>
    </div>
  )
}

// ============================================
// Preview inline (escala reduzida no painel)
// ============================================
function CertificadoPreview({ cor, texto, carga, dataEvento, refCode, evento, inscricao, emitidoEm, qr }) {
  const assinante2 = evento?.certificado_assinante_2_nome

  return (
    <div
      style={{
        width: '100%',
        aspectRatio: '297 / 210',
        position: 'relative',
        overflow: 'hidden',
        background: '#fff',
        fontFamily: "'Segoe UI', Tahoma, sans-serif",
      }}
    >
      {/* Gradientes superior e inferior */}
      <div style={{ position: 'absolute', top: 0, left: 0, right: 0, height: 18, background: `linear-gradient(90deg, ${cor}, ${cor}88, ${cor})` }} />
      <div style={{ position: 'absolute', bottom: 0, left: 0, right: 0, height: 18, background: `linear-gradient(90deg, ${cor}, ${cor}88, ${cor})` }} />
      {/* Frame */}
      <div style={{ position: 'absolute', top: 25, left: 22, right: 22, bottom: 25, border: `1mm solid ${cor}` }} />
      {/* Conteúdo */}
      <div style={{ position: 'absolute', top: 25, left: 22, right: 22, bottom: 25, padding: '22px 32px', display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center' }}>
        {evento?.certificado_logo_url && (
          <img src={evento.certificado_logo_url} alt="" style={{ height: 24, marginBottom: 10, maxWidth: 180 }} />
        )}
        <div style={{ fontSize: 10, letterSpacing: '0.25em', color: '#6b6b6b', textTransform: 'uppercase', marginBottom: 5 }}>Certificado de Participação</div>
        <div style={{ fontSize: 26, fontWeight: 700, color: cor, marginBottom: 14, letterSpacing: '0.02em' }}>{evento?.title}</div>
        <div style={{ fontSize: 11, color: '#444', marginBottom: 6 }}>Certificamos que</div>
        <div style={{ fontSize: 22, fontWeight: 600, color: '#1a1a1a', borderBottom: `0.4mm solid ${cor}`, padding: '0 18mm 4mm 18mm', marginBottom: 14, minWidth: 200 }}>{inscricao.nome}</div>
        <div style={{ fontSize: '11.5pt', color: '#333', lineHeight: 1.7, maxWidth: 300, marginBottom: 'auto' }}>
          {texto} participou como <b>participante</b> em <b>{evento?.title}</b>, promovido pela <b>Conheça Farmácia</b>, realizado em <b>{evento?.location || '—'}</b> nos dias <b>{dataEvento}</b>
          {carga ? <>, com uma carga horária de <b>{carga}</b>.</> : '.'}
        </div>
        {/* Footer */}
        <div style={{ width: '100%', display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end', marginTop: 18 }}>
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', width: 80 }}>
            {qr ? <img src={qr} alt="QR" style={{ width: 36, height: 36, marginBottom: 3 }} /> : <div style={{ width: 36, height: 36, border: '0.4mm solid #999', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '6.5pt', color: '#999', marginBottom: 3 }}>QR</div>}
            <div style={{ fontSize: '7.5pt', color: '#888' }}>Ref: {refCode}</div>
          </div>
          <div style={{ display: 'flex', gap: assinante2 ? 28 : 0, alignItems: 'flex-end', justifyContent: assinante2 ? 'flex-start' : 'center' }}>
            <div style={{ width: 100, textAlign: 'center' }}>
              <div style={{ borderTop: '0.35mm solid #333', paddingTop: 3, marginTop: 22 }}>
                <div style={{ fontSize: '9.5pt', fontWeight: 600, color: cor }}>{evento?.certificado_assinante_1_nome}</div>
                <div style={{ fontSize: '8pt', color: '#777' }}>{evento?.certificado_assinante_1_cargo}</div>
              </div>
            </div>
            {assinante2 && (
              <div style={{ width: 100, textAlign: 'center' }}>
                <div style={{ borderTop: '0.35mm solid #333', paddingTop: 3, marginTop: 22 }}>
                  <div style={{ fontSize: '9.5pt', fontWeight: 600, color: cor }}>{assinante2}</div>
                  <div style={{ fontSize: '8pt', color: '#777' }}>{evento?.certificado_assinante_2_cargo}</div>
                </div>
              </div>
            )}
          </div>
          <div style={{ fontSize: '7.5pt', color: '#888', textAlign: 'center' }}>Emitido em<br />{emitidoEm}</div>
        </div>
      </div>
    </div>
  )
}

// ============================================
// HTML completo para impressão (nova janela)
// ============================================
function buildCertHtml({ cor, texto, carga, dataEvento, refCode, evento, inscricao, assinante2, emitidoEm, qr }) {
  const safe = (v) => escapeHtml(String(v ?? ''))
  const safeEvento = evento?.title ? safe(evento.title) : ''
  const safeNome = safe(inscricao.nome)
  const safeLocation = evento?.location ? safe(evento.location) : '—'
  const safeTexto = safe(texto)
  const safeAss1Nome = safe(evento?.certificado_assinante_1_nome || '')
  const safeAss1Cargo = safe(evento?.certificado_assinante_1_cargo || '')
  const safeAss2Nome = assinante2 ? safe(assinante2) : ''
  const safeAss2Cargo = evento?.certificado_assinante_2_cargo ? safe(evento.certificado_assinante_2_cargo) : ''
  const safeCarga = safe(carga)
  const logoHtml = evento?.certificado_logo_url
    ? `<img src="${evento.certificado_logo_url}" alt="" style="height:13mm;margin-bottom:6mm;max-width:200px"/>`
    : ''

  const qrHtml = qr
    ? `<img src="${qr}" alt="QR" style="width:20mm;height:20mm;margin-bottom:2mm"/>`
    : `<div style="width:20mm;height:20mm;border:0.4mm solid #999;display:flex;align-items:center;justify-content:center;font-size:6.5pt;color:#999;margin-bottom:2mm">QR</div>`

  const assinaturasHtml = assinante2
    ? `<div class="sig-block"><div class="sig-line"><div class="sig-name">${safeAss1Nome}</div><div class="sig-role">${safeAss1Cargo}</div></div></div>
       <div class="sig-block"><div class="sig-line"><div class="sig-name">${safeAss2Nome}</div><div class="sig-role">${safeAss2Cargo}</div></div></div>`
    : `<div class="sig-block" style="margin:0 auto"><div class="sig-line"><div class="sig-name">${safeAss1Nome}</div><div class="sig-role">${safeAss1Cargo}</div></div></div>`

  return `<!DOCTYPE html>
<html lang="pt">
<head>
<meta charset="UTF-8">
<style>
  @page { size: 297mm 210mm landscape; margin: 0; }
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { width: 297mm; height: 210mm; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #fff; position: relative; }
  .gradient-top { position: absolute; top: 0; left: 0; right: 0; height: 10mm; background: linear-gradient(90deg, ${cor} 0%, ${cor}88 55%, ${cor} 100%); }
  .gradient-bottom { position: absolute; bottom: 0; left: 0; right: 0; height: 10mm; background: linear-gradient(90deg, ${cor} 0%, ${cor}88 55%, ${cor} 100%); }
  .frame { position: absolute; top: 14mm; left: 12mm; right: 12mm; bottom: 14mm; border: 0.6mm solid ${cor}; }
  .content { position: absolute; top: 14mm; left: 12mm; right: 12mm; bottom: 14mm; padding: 12mm 18mm; display: flex; flex-direction: column; align-items: center; text-align: center; }
  .kicker { font-size: 10pt; letter-spacing: 0.25em; color: #6b6b6b; text-transform: uppercase; margin-bottom: 3mm; }
  .title { font-size: 26pt; font-weight: 700; color: ${cor}; margin-bottom: 8mm; letter-spacing: 0.02em; }
  .intro { font-size: 11pt; color: #444; margin-bottom: 4mm; }
  .recipient { font-size: 24pt; font-weight: 600; color: #1a1a1a; border-bottom: 0.4mm solid ${cor}; padding: 0 10mm 3mm 10mm; margin-bottom: 8mm; min-width: 140mm; }
  .description { font-size: 11.5pt; color: #333; line-height: 1.7; max-width: 190mm; margin-bottom: auto; }
  .description strong { color: ${cor}; }
  .footer-row { width: 100%; display: flex; justify-content: space-between; align-items: flex-end; margin-top: 10mm; }
  .qr-block { display: flex; flex-direction: column; align-items: center; width: 45mm; }
  .ref-code { font-size: 7.5pt; color: #888; }
  .signatures { display: flex; gap: ${assinante2 ? '16mm' : '0'}; align-items: flex-end; justify-content: ${assinante2 ? 'flex-start' : 'center'}; }
  .sig-block { width: 55mm; text-align: center; }
  .sig-line { border-top: 0.35mm solid #333; padding-top: 2mm; margin-top: 12mm; }
  .sig-name { font-size: 9.5pt; font-weight: 600; color: ${cor}; }
  .sig-role { font-size: 8pt; color: #777; }
  .emitido { font-size: 7.5pt; color: #888; text-align: center; }
</style>
</head>
<body>
  <div class="gradient-top"></div>
  <div class="gradient-bottom"></div>
  <div class="frame"></div>
  <div class="content">
    ${logoHtml}
    <div class="kicker">Certificado de Participação</div>
    <div class="title">${safeEvento}</div>
    <div class="intro">Certificamos que</div>
    <div class="recipient">${safeNome}</div>
    <div class="description">
      ${safeTexto} participou como <strong>participante</strong> em <strong>${safeEvento}</strong>,
      promovido pela <strong>Conheça Farmácia</strong>, realizado em <strong>${safeLocation}</strong>
      nos dias <strong>${dataEvento}</strong>${carga ? `, com uma carga horária de <strong>${safeCarga}</strong>.` : '.'}
    </div>
    <div class="footer-row">
      <div class="qr-block">${qrHtml}<div class="ref-code">Ref: ${refCode}</div></div>
      <div class="signatures">${assinaturasHtml}</div>
      <div class="emitido">Emitido em<br/>${emitidoEm}</div>
    </div>
  </div>
</body>
</html>`
}
