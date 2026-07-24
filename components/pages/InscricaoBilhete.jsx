'use client'

import { useState, useEffect } from 'react'

function formatEventDate(startAt, lang) {
  if (!startAt) return null
  const d = new Date(startAt)
  if (isNaN(d.getTime())) return null
  try {
    return new Intl.DateTimeFormat(lang === 'en' ? 'en-US' : 'pt-PT', {
      day: '2-digit',
      month: 'short',
      year: 'numeric',
    }).format(d)
  } catch {
    return d.toISOString().slice(0, 10)
  }
}

function formatEventTime(startAt, lang) {
  if (!startAt) return null
  const d = new Date(startAt)
  if (isNaN(d.getTime())) return null
  try {
    return new Intl.DateTimeFormat(lang === 'en' ? 'en-US' : 'pt-PT', {
      hour: '2-digit',
      minute: '2-digit',
      hour12: lang === 'en',
    }).format(d)
  } catch {
    return d.toISOString().slice(11, 16)
  }
}

function formatSubmittedAt(date, lang) {
  if (!date) return null
  const d = new Date(date)
  if (isNaN(d.getTime())) return null
  try {
    const dateStr = new Intl.DateTimeFormat(lang === 'en' ? 'en-US' : 'pt-PT', {
      day: '2-digit',
      month: 'short',
      year: 'numeric',
    }).format(d)
    const timeStr = new Intl.DateTimeFormat(lang === 'en' ? 'en-US' : 'pt-PT', {
      hour: '2-digit',
      minute: '2-digit',
      hour12: lang === 'en',
    }).format(d)
    return `${dateStr} · ${timeStr}`
  } catch {
    return d.toISOString().slice(0, 16).replace('T', ' ')
  }
}

function modalityLabel(modality, t) {
  if (!modality) return null
  const key = `inscricao_success.comprovativo_modalidade_${modality}`
  const translated = t(key)
  if (translated && translated !== key) return translated
  return modality
}

/**
 * InscricaoBilhete — estilo boarding pass horizontal
 * Renderiza um cartão A4 landscape (1 página) com:
 *   - Canhoto esquerdo (gradient verde-escuro): logo + ref + QR + tagline
 *   - Corpo direito (branco): badge + título + nome evento + meta (data/hora/local/modalidade) + grid dados + assinatura
 *
 * Reutilizado tanto no fluxo de inscrição (InscricaoPageClient) como no modal
 * de comprovativo do CMS (ComprovativoModal).
 */
export default function InscricaoBilhete({ lang, formData, profLabel, eventTitle, eventMeta, shortRef, inscriptionDate, logoSrc, t }) {
  const validationUrl = shortRef
    ? `https://conhecafarmacia.com/validar?ref=${shortRef}`
    : 'https://conhecafarmacia.com'
  const [qrDataUrl, setQrDataUrl] = useState(null)

  useEffect(() => {
    let cancelled = false
    if (!shortRef) { setQrDataUrl(null); return }
    import('qrcode').then(({ default: qrcode }) => {
      qrcode.toDataURL(validationUrl, {
        type: 'image/png',
        width: 200,
        margin: 0,
        errorCorrectionLevel: 'M',
        color: { dark: '#002a32', light: '#ffffff' },
      }).then((dataUrl) => {
        if (!cancelled) setQrDataUrl(dataUrl)
      }).catch((err) => {
        console.warn('[InscricaoBilhete] Falha ao gerar QR:', err)
      })
    })
    return () => { cancelled = true }
  }, [shortRef, validationUrl])

  const eventDate = formatEventDate(eventMeta?.startAt, lang)
  const eventTime = formatEventTime(eventMeta?.startAt, lang)
  const eventLocation = eventMeta?.location || null
  const eventModality = modalityLabel(eventMeta?.modality, t)
  const submittedAtStr = formatSubmittedAt(inscriptionDate, lang)

  return (
    <div
      id="comprovativo-bilhete"
      className="comprovativo-bilhete"
      role="document"
      aria-label={t ? t('inscricao_success.comprovativo') : 'Comprovativo de Inscrição'}
    >
      {/* CANHOTO — gradient verde-escuro */}
      <div className="comprovativo-stub">
        <div className="comprovativo-stub-brand">
          <img
            src={logoSrc}
            alt="Conheça Farmácia"
            className="comprovativo-stub-logo"
          />
        </div>
        <div className="comprovativo-stub-ref">
          <div className="comprovativo-stub-label">
            {t ? t('inscricao_success.comprovativo') : 'Comprovativo'}
          </div>
          <div className="comprovativo-stub-refcode">{shortRef || '—'}</div>
        </div>
        {qrDataUrl && (
          <div className="comprovativo-stub-qr">
            <img src={qrDataUrl} alt="QR code" />
          </div>
        )}
        <div className="comprovativo-stub-tagline">
          {t ? t('inscricao_success.comprovativo_stub_tagline') : 'Conheça Farmácia'}
        </div>
      </div>

      {/* CORPO — branco */}
      <div className="comprovativo-main">
        <div className="comprovativo-top">
          <span className="comprovativo-badge">
            {t ? t('inscricao_success.comprovativo_badge') : 'CONFIRMADO'}
          </span>
        </div>
        <h3 className="comprovativo-title">
          {t ? t('inscricao_success.comprovativo') : 'Comprovativo de Inscrição'}
        </h3>
        <p className="comprovativo-subtitle">
          {t ? t('inscricao_success.comprovativo_doc_sub') : 'Documento de confirmação de inscrição'}
        </p>

        {eventTitle && (
          <div className="comprovativo-event">
            <div className="comprovativo-label">
              {t ? t('inscricao_success.comprovativo_label_evento') : 'Evento'}
            </div>
            <div className="comprovativo-event-name">{eventTitle}</div>
          </div>
        )}

        {(eventDate || eventTime || eventLocation || eventModality) && (
          <div className="comprovativo-meta">
            {eventDate && (
              <div className="comprovativo-meta-cell">
                <div className="comprovativo-label">
                  {t ? t('inscricao_success.comprovativo_label_data') : 'Data'}
                </div>
                <div className="comprovativo-value">{eventDate}</div>
              </div>
            )}
            {eventTime && (
              <div className="comprovativo-meta-cell">
                <div className="comprovativo-label">
                  {t ? t('inscricao_success.comprovativo_label_hora') : 'Hora'}
                </div>
                <div className="comprovativo-value">{eventTime}</div>
              </div>
            )}
            {eventModality && (
              <div className="comprovativo-meta-cell">
                <div className="comprovativo-label">
                  {t ? t('inscricao_success.comprovativo_label_modalidade') : 'Modalidade'}
                </div>
                <div className="comprovativo-value">{eventModality}</div>
              </div>
            )}
            {eventLocation && (
              <div className="comprovativo-meta-cell comprovativo-meta-cell--full">
                <div className="comprovativo-label">
                  {t ? t('inscricao_success.comprovativo_label_local') : 'Local'}
                </div>
                <div className="comprovativo-value">{eventLocation}</div>
              </div>
            )}
          </div>
        )}

        <div className="comprovativo-divider" />

        <div className="comprovativo-data">
          <div className="comprovativo-field">
            <div className="comprovativo-label">
              {t ? t('inscricao_success.comprovativo_label_nome') : 'Nome'}
            </div>
            <div className="comprovativo-value">{formData.nome}</div>
          </div>
          <div className="comprovativo-field">
            <div className="comprovativo-label">
              {t ? t('inscricao_success.comprovativo_label_email') : 'Email'}
            </div>
            <div className="comprovativo-value">{formData.email}</div>
          </div>
          <div className="comprovativo-field">
            <div className="comprovativo-label">
              {t ? t('inscricao_success.comprovativo_label_telefone') : 'Telefone'}
            </div>
            <div className="comprovativo-value">{formData.telefone}</div>
          </div>
          {profLabel && (
            <div className="comprovativo-field">
              <div className="comprovativo-label">
                {t ? t('inscricao_success.comprovativo_label_profissao') : 'Profissão'}
              </div>
              <div className="comprovativo-value">{profLabel}</div>
            </div>
          )}
        </div>

        <div className="comprovativo-footer">
          {submittedAtStr && (
            <div className="comprovativo-issued">
              <div className="comprovativo-label">
                {t ? t('inscricao_success.comprovativo_label_inscricao') : 'Inscrição realizada em'}
              </div>
              <div className="comprovativo-value">{submittedAtStr}</div>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
