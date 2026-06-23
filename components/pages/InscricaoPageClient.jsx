'use client'

import { useState, useRef, useContext, useEffect, useCallback, useMemo } from 'react'
import { useRouter } from 'next/navigation'
import { LangContext } from '@/lib/contexts'
import { validateField, submitInscription, checkDuplicate } from '@/lib/api/inscription'
import { useCapacityPolling } from '@/hooks/useCapacityPolling'
import Breadcrumb from '@/components/ui/Breadcrumb'
import { AlertCircle, Printer, CheckCircle2 } from 'lucide-react'

const RATE_LIMIT_MS = 5000

export default function InscricaoPageClient({ lang, eventoId, eventoSlug, eventTitle, capacity, initialInscriptionCount = 0 }) {
  const { t } = useContext(LangContext)
  const router = useRouter()
  const lastSubmitRef = useRef(0)
  const honeypotRef = useRef('')

  // Verificar capacidade em tempo real (polling via Server Action → Service Role)
  const { inscriptionCount } = useCapacityPolling(eventoId, initialInscriptionCount)
  const isEventFull = capacity && inscriptionCount >= capacity

  const [form, setForm] = useState({
    nome: '',
    email: '',
    telefone: '',
    genero: '',
    faixa_etaria: '',
    profissao: '',
    nivel_escolaridade: '',
    origem_evento: '',
  })
  const [errors, setErrors] = useState({})
  const [touched, setTouched] = useState({})
  const [status, setStatus] = useState('idle') // idle | submitting | success | error | duplicate
  const [errorMsg, setErrorMsg] = useState('')
  const [countdown, setCountdown] = useState(3)
  const [emailSent, setEmailSent] = useState(true)
  const [inscriptionId, setInscriptionId] = useState(null)
  // shortRef: zero-padded inscription int8 id, e.g. 85 -> "000085".
  // inscricoes.id is int8 (not UUID), so slice(-8) of "85" = "85" not useful.
  // Use the int8 directly, padded to 6 digits for consistent display.
  const shortRef = useMemo(
    () => (inscriptionId ? String(inscriptionId).padStart(6, '0') : null),
    [inscriptionId]
  )

  const breadcrumbItems = [
    { label: t('nav.inicio'), href: `/${lang}` },
    { label: t('nav.eventos'), href: `/${lang}/eventos` },
    ...(eventoSlug && eventTitle ? [{ label: eventTitle, href: `/${lang}/eventos/${eventoSlug}` }] : []),
    { label: t('inscricao.title') },
  ]

  // Show redirect button after delay (gives fire-and-forget fetch time to complete)
  useEffect(() => {
    if (status !== 'success') return
    const timer = setTimeout(() => setCountdown(0), 3000)
    return () => clearTimeout(timer)
  }, [status])

  // Validate a single field on blur
  const handleBlur = (name) => {
    setTouched(prev => ({ ...prev, [name]: true }))
    const required = ['nome', 'email', 'telefone', 'profissao'].includes(name)
    const error = validateField(name, form[name], required)
    setErrors(prev => ({ ...prev, [name]: error }))
  }

  // Update form value
  const handleChange = (name, value) => {
    setForm(prev => ({ ...prev, [name]: value }))
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: null }))
    }
  }

  // Validate all fields
  const validateAll = () => {
    const newErrors = {}
    const requiredFields = ['nome', 'email', 'telefone', 'profissao']
    let valid = true

    for (const key of Object.keys(form)) {
      const error = validateField(key, form[key], requiredFields.includes(key))
      if (error) {
        newErrors[key] = error
        valid = false
      }
    }

    setErrors(newErrors)
    setTouched(Object.fromEntries(Object.keys(form).map(k => [k, true])))
    return valid
  }

  // Gera o PDF do comprovativo via o diálogo de impressão do browser.
  // O user escolhe "Guardar como PDF" como destino para guardar o ficheiro.
  // Vantagens:
  //   - Zero dependências server-side para PDF (sem Satori, sem resvg-js)
  //   - O que vês é exactamente o que imprimes (mesmo HTML, mesmas CSS)
  //   - Não há regressões de fontes, layouts, ou gradientes

  const handleSubmit = async (e) => {
    e.preventDefault()

    // Honeypot check
    if (honeypotRef.current) return

    // Rate limit
    const now = Date.now()
    if (now - lastSubmitRef.current < RATE_LIMIT_MS) return
    lastSubmitRef.current = now

    if (!validateAll()) return

    setStatus('submitting')
    setErrorMsg('')

    try {
      // Optimização UX (2026-06-22): pré-validar duplicate para resposta
      // imediata no caso mais frequente, sem esperar pelo RPC. Falha
      // silenciosa do checkDuplicate (isDuplicate=false) deixa o submit
      // validar como fallback.
      const dupCheck = await checkDuplicate(eventoId, form.email)
      if (dupCheck?.isDuplicate) {
        setStatus('duplicate')
        setErrorMsg(t('inscricao_error.codes.duplicate') || t('inscricao_error.duplicate'))
        return
      }

      const result = await submitInscription(form, eventoId, eventoSlug, lang)
      if (result?.success) {
        setEmailSent(!!result.emailSent)
        setInscriptionId(result.inscriptionId)
        setStatus('success')
        return
      }

      // Erro de negócio (return-based contract).
      const code = result?.code || null
      if (code === 'duplicate') {
        setStatus('duplicate')
        setErrorMsg(t('inscricao_error.codes.duplicate') || t('inscricao_error.duplicate'))
      } else if (code) {
        setStatus('error')
        setErrorMsg(t(`inscricao_error.codes.${code}`) || t('inscricao_error.message'))
      } else {
        setStatus('error')
        setErrorMsg(t('inscricao_error.message'))
      }
    } catch (err) {
      // Throw residual (infra: Server Action aborted, network). Não esperamos
      // mensagem útil — fallback genérico com WhatsApp CTA.
      console.error('[Inscricao] submit unexpected throw:', err)
      setStatus('error')
      setErrorMsg(t('inscricao_error.message'))
    }
  }

  const renderError = (name) => {
    if (!touched[name] || !errors[name]) return null
    return <p className="error-message visible">{errors[name]}</p>
  }

  // No evento slug — show error
  if (!eventoId) {
    return (
      <>
        <nav id="breadcrumb" aria-label="Breadcrumb">
          <Breadcrumb items={breadcrumbItems} />
        </nav>
        <section className="inscription-section bg-brand-bg-alt">
          <div className="container-center">
            <div className="inscription-container">
              <div className="inscription-form-wrapper text-center">
                <div className="error-icon">⚠️</div>
                <h2 className="error-title">{t('inscricao_error.title')}</h2>
                <p className="text-lg text-brand-deep/70 mt-4">
                  Nenhum evento selecionado. Por favor, aceda a partir de um evento.
                </p>
                <a href={`/${lang}/eventos`} className="btn btn-primary inscription-btn mt-8">
                  {t('inscricao.back_to_events')}
                </a>
              </div>
            </div>
          </div>
        </section>
      </>
    )
  }

  // Success state
  if (status === 'success') {
    const profKey = form.profissao === 'estudante-saude' ? 'estudante' : form.profissao === 'tecnico-medio-saude' ? 'tecnico_medio' : form.profissao === 'tecnico-radiologia' ? 'tecnico_radio' : form.profissao === 'tecnico-analises-clinicas' ? 'tecnico_analises' : form.profissao === 'medico-dentista' ? 'dentista' : form.profissao === 'biologo-analista' ? 'biologo' : form.profissao
    const profLabel = form.profissao ? t('inscricao.prof_' + profKey) : ''
    const backUrl = eventoSlug ? '/' + lang + '/eventos/' + eventoSlug : '/' + lang + '/eventos'
    const submittedAt = new Date()
    // eventMeta é derivado (defaults vazios se schema não tem colunas) — render condicional no InscricaoBilhete
    const eventMeta = { startAt: null, location: null, modality: null }

    return (
      <>
        <nav id="breadcrumb" aria-label="Breadcrumb">
          <Breadcrumb items={breadcrumbItems} />
        </nav>
        <section className="inscription-section bg-brand-bg-alt">
          <div className="container-center">
            <div className="inscription-container">
              <div className="inscription-form-wrapper">
                <div className="inscription-success">
                  <h2 className="success-title">{t('inscricao_success.title')}</h2>
                  <p className="success-message">{t('inscricao_success.message')}</p>
                  <div className="success-details">
                    <p style={{ color: emailSent ? 'inherit' : '#b45309' }}>
                      {emailSent
                        ? t('inscricao_success.email_sent')
                        : t('inscricao_success.email_failed')
                      }
                    </p>
                  </div>

                  {/* Comprovativo (estilo boarding pass) — wrapper branco isolado */}
                  <div
                    style={{
                      background: '#ffffff',
                      borderRadius: 16,
                      padding: 16,
                      marginTop: 8,
                      marginBottom: 8,
                    }}
                  >
                    <InscricaoBilhete
                      lang={lang}
                      formData={form}
                      profLabel={profLabel}
                      eventTitle={eventTitle}
                      eventMeta={eventMeta}
                      shortRef={shortRef}
                      inscriptionDate={submittedAt}
                      logoSrc="/logo/logo-principal-branco.svg"
                      t={t}
                    />
                  </div>

                  {/* Actions */}
                  <div className="comprovativo-actions" data-pdf-hide style={{ display: 'flex', gap: 12, marginTop: 24, justifyContent: 'center', flexWrap: 'wrap' }}>
                    {countdown === 0 && (
                      <a
                        href={backUrl}
                        className="btn btn-primary"
                      >
                        {t('inscricao_success.voltar_evento')}
                      </a>
                    )}
                    <button
                      type="button"
                      className="btn btn-secondary"
                      onClick={() => window.print()}
                      data-pdf-hide
                      style={{ cursor: 'pointer' }}
                    >
                      <Printer size={18} style={{ marginRight: 8, verticalAlign: 'middle' }} />
                      {t('inscricao_success.print')}
                    </button>
                  </div>
                  <p
                    data-pdf-hide
                    style={{
                      maxWidth: 480,
                      margin: '16px auto 0',
                      fontSize: 14,
                      color: '#5a5650',
                      lineHeight: 1.5,
                      textAlign: 'center',
                    }}
                  >
                    {lang === 'en'
                      ? 'In the print dialog, choose "Save as PDF" as the destination to save the receipt to your device.'
                      : 'Na janela de impressão, escolha "Guardar como PDF" como destino para guardar o comprovativo no seu dispositivo.'}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </section>
      </>
    )
  }

  // Main form
  return (
    <>
      <nav id="breadcrumb" aria-label="Breadcrumb">
        <div className="max-w-7xl mx-auto px-4">
          <Breadcrumb items={breadcrumbItems} />
        </div>
      </nav>

      <section className="inscription-section bg-brand-bg-alt">
        <div className="container-center">
          <div className="inscription-container">
            <div id="form-container" className="inscription-form-wrapper">
              {/* Header */}
              <div className="inscription-header mb-12">
                <h1 className="inscription-title" data-i18n="inscricao.heading">{t('inscricao.heading')}</h1>
                {eventTitle && (
                  <p className="inscription-event-name" aria-label={t('inscricao.event_label')}>
                    {t('inscricao.event_label')}: <strong>{eventTitle}</strong>
                  </p>
                )}
                <p className="inscription-subtitle" data-i18n="inscricao.subtitle">{t('inscricao.subtitle')}</p>
              </div>

              {/* Evento completo — aviso */}
              {isEventFull && (
                <div style={{
                  display: 'flex', alignItems: 'center', gap: 12, padding: '16px 20px',
                  borderRadius: 10, marginBottom: 24,
                  background: 'rgba(220, 38, 38, 0.08)', border: '1px solid rgba(220, 38, 38, 0.2)',
                  color: '#dc2626', fontSize: 15, fontWeight: 500,
                }}>
                  <AlertCircle size={20} />
                  <span>Evento completo — sem vagas disponíveis</span>
                </div>
              )}

              <form
                id="inscription-form"
                className="inscription-form"
                onSubmit={handleSubmit}
                noValidate
                style={isEventFull ? { opacity: 0.5, pointerEvents: 'none' } : undefined}
              >
                {/* Honeypot */}
                <input
                  type="text"
                  id="honeypot"
                  name="honeypot"
                  tabIndex={-1}
                  autoComplete="off"
                  aria-hidden="true"
                  style={{ position: 'absolute', left: '-9999px', top: '-9999px', width: '1px', height: '1px', opacity: 0, pointerEvents: 'none', visibility: 'hidden' }}
                  onChange={(e) => { honeypotRef.current = e.target.value }}
                />

                {/* Hidden evento_slug */}
                <input type="hidden" name="evento_id" value={eventoId || ''} />

                {/* Section: Identidade */}
                <div className="form-section-label" data-i18n="inscricao.identidade">
                  {t('inscricao.identidade')}
                </div>

                <div className="form-group">
                  <label htmlFor="nome" className="form-label" data-i18n="inscricao.nome_label">
                    {t('inscricao.nome_label')}
                  </label>
                  <input
                    id="nome"
                    type="text"
                    name="nome"
                    className={`form-input ${errors.nome && touched.nome ? 'error' : ''}`}
                    placeholder={t('inscricao.nome_placeholder')}
                    value={form.nome}
                    onChange={(e) => handleChange('nome', e.target.value)}
                    onBlur={() => handleBlur('nome')}
                    required
                    maxLength={255}
                    minLength={3}
                    data-validate="true"
                  />
                  {renderError('nome')}
                </div>

                <div className="form-group">
                  <label htmlFor="genero" className="form-label" data-i18n="inscricao.genero_label">
                    {t('inscricao.genero_label')}
                  </label>
                  <select
                    id="genero"
                    name="genero"
                    className={`form-input form-select ${errors.genero && touched.genero ? 'error' : ''}`}
                    value={form.genero}
                    onChange={(e) => handleChange('genero', e.target.value)}
                    onBlur={() => handleBlur('genero')}
                  >
                    <option value="">{t('inscricao.genero_select')}</option>
                    <option value="masculino">{t('inscricao.genero_masc')}</option>
                    <option value="feminino">{t('inscricao.genero_fem')}</option>
                  </select>
                  {renderError('genero')}
                </div>

                <div className="form-group">
                  <label htmlFor="faixa_etaria" className="form-label" data-i18n="inscricao.faixa_etaria_label">
                    {t('inscricao.faixa_etaria_label')}
                  </label>
                  <select
                    id="faixa_etaria"
                    name="faixa_etaria"
                    className={`form-input form-select ${errors.faixa_etaria && touched.faixa_etaria ? 'error' : ''}`}
                    value={form.faixa_etaria}
                    onChange={(e) => handleChange('faixa_etaria', e.target.value)}
                    onBlur={() => handleBlur('faixa_etaria')}
                  >
                    <option value="">{t('inscricao.faixa_etaria_select')}</option>
                    <option value="18-24">{t('inscricao.faixa_18_24')}</option>
                    <option value="25-34">{t('inscricao.faixa_25_34')}</option>
                    <option value="35-44">{t('inscricao.faixa_35_44')}</option>
                    <option value="45-54">{t('inscricao.faixa_45_54')}</option>
                    <option value="55+">{t('inscricao.faixa_55_plus')}</option>
                  </select>
                  {renderError('faixa_etaria')}
                </div>

                {/* Section: Contacto */}
                <div className="form-section-label" data-i18n="inscricao.contacto">
                  {t('inscricao.contacto')}
                </div>

                <div className="form-group">
                  <label htmlFor="email" className="form-label" data-i18n="inscricao.email_label">
                    {t('inscricao.email_label')}
                  </label>
                  <input
                    id="email"
                    type="email"
                    name="email"
                    className={`form-input ${errors.email && touched.email ? 'error' : ''}`}
                    placeholder={t('inscricao.email_placeholder')}
                    value={form.email}
                    onChange={(e) => handleChange('email', e.target.value)}
                    onBlur={() => handleBlur('email')}
                    required
                    maxLength={255}
                    data-validate="true"
                  />
                  {renderError('email')}
                </div>

                <div className="form-group">
                  <label htmlFor="telefone" className="form-label" data-i18n="inscricao.telefone_label">
                    {t('inscricao.telefone_label')} *
                  </label>
                  <input
                    id="telefone"
                    type="tel"
                    name="telefone"
                    className={`form-input ${errors.telefone && touched.telefone ? 'error' : ''}`}
                    placeholder={t('inscricao.telefone_placeholder')}
                    value={form.telefone}
                    onChange={(e) => handleChange('telefone', e.target.value)}
                    onBlur={() => handleBlur('telefone')}
                    required
                    maxLength={20}
                    data-validate="true"
                  />
                  {renderError('telefone')}
                </div>

                {/* Section: Qualificação Profissional */}
                <div className="form-section-label" data-i18n="inscricao.qualificacao">
                  {t('inscricao.qualificacao')}
                </div>

                <div className="form-group">
                  <label htmlFor="profissao" className="form-label" data-i18n="inscricao.profissao_label">
                    {t('inscricao.profissao_label')} *
                  </label>
                  <select
                    id="profissao"
                    name="profissao"
                    className={`form-input form-select ${errors.profissao && touched.profissao ? 'error' : ''}`}
                    value={form.profissao}
                    onChange={(e) => handleChange('profissao', e.target.value)}
                    onBlur={() => handleBlur('profissao')}
                    required
                  >
                    <option value="">{t('inscricao.profissao_select')}</option>
                    <option value="enfermeiro">{t('inscricao.prof_enfermeiro')}</option>
                    <option value="medico">{t('inscricao.prof_medico')}</option>
                    <option value="farmaceutico">{t('inscricao.prof_farmaceutico')}</option>
                    <option value="estudante-saude">{t('inscricao.prof_estudante')}</option>
                    <option value="tecnico-medio-saude">{t('inscricao.prof_tecnico_medio')}</option>
                    <option value="tecnico-radiologia">{t('inscricao.prof_tecnico_radio')}</option>
                    <option value="tecnico-analises-clinicas">{t('inscricao.prof_tecnico_analises')}</option>
                    <option value="medico-dentista">{t('inscricao.prof_dentista')}</option>
                    <option value="biologo-analista">{t('inscricao.prof_biologo')}</option>
                    <option value="psicologo">{t('inscricao.prof_psicologo')}</option>
                    <option value="nutricionista">{t('inscricao.prof_nutricionista')}</option>
                    <option value="fisioterapeuta">{t('inscricao.prof_fisioterapeuta')}</option>
                    <option value="outro">{t('inscricao.prof_outro')}</option>
                  </select>
                  {renderError('profissao')}
                </div>

                <div className="form-group">
                  <label htmlFor="nivel_escolaridade" className="form-label" data-i18n="inscricao.escolaridade_label">
                    {t('inscricao.escolaridade_label')}
                  </label>
                  <select
                    id="nivel_escolaridade"
                    name="nivel_escolaridade"
                    className={`form-input form-select ${errors.nivel_escolaridade && touched.nivel_escolaridade ? 'error' : ''}`}
                    value={form.nivel_escolaridade}
                    onChange={(e) => handleChange('nivel_escolaridade', e.target.value)}
                    onBlur={() => handleBlur('nivel_escolaridade')}
                  >
                    <option value="">{t('inscricao.escolaridade_select')}</option>
                    <option value="tecnico-profissional">{t('inscricao.esc_tecnico')}</option>
                    <option value="licenciatura">{t('inscricao.esc_licenciatura')}</option>
                    <option value="pos-graduacao-mestrado">{t('inscricao.esc_mestrado')}</option>
                    <option value="doutoramento">{t('inscricao.esc_doutoramento')}</option>
                  </select>
                  {renderError('nivel_escolaridade')}
                </div>

                {/* Section: Origem */}
                <div className="form-section-label" data-i18n="inscricao.origem_label">
                  {t('inscricao.origem_label')}
                </div>

                <div className="form-group">
                  <label htmlFor="origem_evento" className="form-label" data-i18n="inscricao.como_conheceu_label">
                    {t('inscricao.como_conheceu_label')}
                  </label>
                  <select
                    id="origem_evento"
                    name="origem_evento"
                    className="form-input form-select"
                    value={form.origem_evento}
                    onChange={(e) => handleChange('origem_evento', e.target.value)}
                  >
                    <option value="">{t('inscricao.como_conheceu_select')}</option>
                    <option value="instagram">{t('inscricao.como_instagram')}</option>
                    <option value="whatsapp">{t('inscricao.como_whatsapp')}</option>
                    <option value="facebook">{t('inscricao.como_facebook')}</option>
                    <option value="tiktok">{t('inscricao.como_tiktok')}</option>
                    <option value="linkedin">{t('inscricao.como_linkedin')}</option>
                    <option value="amigo-indicacao">{t('inscricao.como_amigo')}</option>
                    <option value="outro">{t('inscricao.como_outro')}</option>
                  </select>
                </div>

                {/* Submit */}
                <p className="form-note" data-i18n="inscricao.campo_obrigatorio">
                  {t('inscricao.campo_obrigatorio')}
                </p>

                <button
                  id="submit-btn"
                  type="submit"
                  className={`btn btn-primary inscription-btn w-full ${isEventFull ? 'btn-disabled' : ''} ${status === 'submitting' ? 'btn-loading' : ''}`}
                  disabled={status === 'submitting' || isEventFull}
                >
                  <span id="btn-text" data-i18n="inscricao.submit">
                    {isEventFull
                      ? 'Evento completo'
                      : status === 'submitting'
                        ? t('inscricao.submitting') || 'A verificar...'
                        : t('inscricao.submit')
                    }
                  </span>
                </button>

                {/* Error/Warning banner — below submit button */}
                {(status === 'error' || status === 'duplicate') && (
                  <div id="error-container" className="inscription-error mt-8">
                    <div className="error-icon">⚠</div>
                    <h2 className="error-title" data-i18n="inscricao_error.title">{t('inscricao_error.title')}</h2>
                    <p className="error-message" id="error-message">
                      {errorMsg}
                      {errorMsg && (
                        <>
                          {' '}
                          {t('inscricao_error.whatsapp_cta')}{' '}
                          <a
                            href={`https://wa.me/244925696002?text=${encodeURIComponent(`Olá, estou com dificuldades no processo da inscrição do evento ${eventTitle || ''}`)}`}
                            target="_blank"
                            rel="noopener noreferrer"
                            style={{ color: 'inherit', textDecoration: 'underline', fontWeight: 600 }}
                          >
                            WhatsApp (+244 925 696 002)
                          </a>
                          {' '}para resolver.
                        </>
                      )}
                    </p>
                    <button
                      type="button"
                      className="btn btn-primary inscription-btn mt-6"
                      data-i18n="inscricao.try_again"
                      onClick={() => { setStatus('idle'); setErrorMsg('') }}
                    >
                      {t('inscricao.try_again')}
                    </button>
                  </div>
                )}
              </form>
            </div>
          </div>
        </div>
      </section>
    </>
  )
}

// =============================================
// InscricaoBilhete — estilo boarding pass horizontal
// Renderiza um cartão A4 landscape (1 página) com:
//   - Canhoto esquerdo (gradient verde-escuro): logo + ref + QR + tagline
//   - Corpo direito (branco): badge + título + nome evento + meta (data/hora/local/modalidade) + grid dados + assinatura
// O id="comprovativo-bilhete" é capturado pelo html2canvas para gerar o PDF.
// =============================================
function formatEventDate(startAt, lang) {
  if (!startAt) return null
  const d = new Date(startAt)
  if (isNaN(d.getTime())) return null
  // PT: 15 jul 2026 · EN: Jul 15, 2026
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
  try {
    const dateStr = new Intl.DateTimeFormat(lang === 'en' ? 'en-US' : 'pt-PT', {
      day: '2-digit',
      month: 'short',
      year: 'numeric',
    }).format(date)
    const timeStr = new Intl.DateTimeFormat(lang === 'en' ? 'en-US' : 'pt-PT', {
      hour: '2-digit',
      minute: '2-digit',
      hour12: lang === 'en',
    }).format(date)
    return `${dateStr} · ${timeStr}`
  } catch {
    return date.toISOString().slice(0, 16).replace('T', ' ')
  }
}

function modalityLabel(modality, t) {
  if (!modality) return null
  const key = `inscricao_success.comprovativo_modalidade_${modality}`
  const translated = t(key)
  // t() devolve a própria key se não encontrar; nesse caso fallback
  if (translated && translated !== key) return translated
  return modality
}

function InscricaoBilhete({ lang, formData, profLabel, eventTitle, eventMeta, shortRef, inscriptionDate, logoSrc, t }) {
  const validationUrl = shortRef
    ? `https://conhecafarmacia.com/validar?ref=${shortRef}`
    : 'https://conhecafarmacia.com'
  // QR gerado localmente via package `qrcode` (zero requests externos, sem CORS,
  // funciona offline). Foi um external service (api.qrserver.com) que
  // falhava intermitentemente e bloqueava o bilhete em alguns ambientes.
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
      aria-label={t('inscricao_success.comprovativo')}
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
          <div className="comprovativo-stub-label">{t('inscricao_success.comprovativo')}</div>
          <div className="comprovativo-stub-refcode">{shortRef || '—'}</div>
        </div>
        {qrDataUrl && (
          <div className="comprovativo-stub-qr">
            <img src={qrDataUrl} alt="QR code" />
          </div>
        )}
        <div className="comprovativo-stub-tagline">{t('inscricao_success.comprovativo_stub_tagline')}</div>
      </div>

      {/* CORPO — branco */}
      <div className="comprovativo-main">
        <div className="comprovativo-top">
          <span className="comprovativo-badge">{t('inscricao_success.comprovativo_badge')}</span>
        </div>
        <h3 className="comprovativo-title">{t('inscricao_success.comprovativo')}</h3>
        <p className="comprovativo-subtitle">{t('inscricao_success.comprovativo_doc_sub')}</p>

        {eventTitle && (
          <div className="comprovativo-event">
            <div className="comprovativo-label">{t('inscricao_success.comprovativo_label_evento')}</div>
            <div className="comprovativo-event-name">{eventTitle}</div>
          </div>
        )}

        {(eventDate || eventTime || eventLocation || eventModality) && (
          <div className="comprovativo-meta">
            {eventDate && (
              <div className="comprovativo-meta-cell">
                <div className="comprovativo-label">{t('inscricao_success.comprovativo_label_data')}</div>
                <div className="comprovativo-value">{eventDate}</div>
              </div>
            )}
            {eventTime && (
              <div className="comprovativo-meta-cell">
                <div className="comprovativo-label">{t('inscricao_success.comprovativo_label_hora')}</div>
                <div className="comprovativo-value">{eventTime}</div>
              </div>
            )}
            {eventModality && (
              <div className="comprovativo-meta-cell">
                <div className="comprovativo-label">{t('inscricao_success.comprovativo_label_modalidade')}</div>
                <div className="comprovativo-value">{eventModality}</div>
              </div>
            )}
            {eventLocation && (
              <div className="comprovativo-meta-cell comprovativo-meta-cell--full">
                <div className="comprovativo-label">{t('inscricao_success.comprovativo_label_local')}</div>
                <div className="comprovativo-value">{eventLocation}</div>
              </div>
            )}
          </div>
        )}

        <div className="comprovativo-divider" />

        <div className="comprovativo-data">
          <div className="comprovativo-field">
            <div className="comprovativo-label">{t('inscricao_success.comprovativo_label_nome')}</div>
            <div className="comprovativo-value">{formData.nome}</div>
          </div>
          <div className="comprovativo-field">
            <div className="comprovativo-label">{t('inscricao_success.comprovativo_label_email')}</div>
            <div className="comprovativo-value">{formData.email}</div>
          </div>
          <div className="comprovativo-field">
            <div className="comprovativo-label">{t('inscricao_success.comprovativo_label_telefone')}</div>
            <div className="comprovativo-value">{formData.telefone}</div>
          </div>
          {profLabel && (
            <div className="comprovativo-field">
              <div className="comprovativo-label">{t('inscricao_success.comprovativo_label_profissao')}</div>
              <div className="comprovativo-value">{profLabel}</div>
            </div>
          )}
        </div>

        <div className="comprovativo-footer">
          {submittedAtStr && (
            <div className="comprovativo-issued">
              <div className="comprovativo-label">{t('inscricao_success.comprovativo_label_inscricao')}</div>
              <div className="comprovativo-value">{submittedAtStr}</div>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
