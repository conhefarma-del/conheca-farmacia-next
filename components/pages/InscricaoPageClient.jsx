'use client'

import { useState, useRef, useContext, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { LangContext } from '@/lib/contexts'
import { validateField, submitInscription } from '@/lib/api/inscription'
import Breadcrumb from '@/components/ui/Breadcrumb'

const RATE_LIMIT_MS = 5000

export default function InscricaoPageClient({ lang, eventoSlug, eventTitle }) {
  const { t } = useContext(LangContext)
  const router = useRouter()
  const lastSubmitRef = useRef(0)
  const honeypotRef = useRef('')

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

  const breadcrumbItems = [
    { label: t('nav.inicio'), href: `/${lang}` },
    { label: t('nav.eventos'), href: `/${lang}/eventos` },
    ...(eventoSlug && eventTitle ? [{ label: eventTitle, href: `/${lang}/eventos/${eventoSlug}` }] : []),
    { label: t('inscricao.title') },
  ]

  // Auto-redirect after success
  useEffect(() => {
    if (status !== 'success') return
    if (countdown <= 0) {
      const url = eventoSlug ? `/${lang}/eventos/${eventoSlug}` : `/${lang}/eventos`
      router.push(url)
      return
    }
    const timer = setTimeout(() => setCountdown(c => c - 1), 1000)
    return () => clearTimeout(timer)
  }, [status, countdown, eventoSlug, lang, router])

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
      await submitInscription(form, eventoSlug)
      setStatus('success')
    } catch (err) {
      if (err.message === 'duplicate') {
        setStatus('duplicate')
        setErrorMsg(t('inscricao_error.duplicate'))
      } else {
        setStatus('error')
        setErrorMsg(err.message || t('inscricao.error_default'))
      }
    }
  }

  const renderError = (name) => {
    if (!touched[name] || !errors[name]) return null
    return <p className="error-message visible">{errors[name]}</p>
  }

  // No evento slug — show error
  if (!eventoSlug) {
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
                  <div className="success-icon">✓</div>
                  <h2 className="success-title">{t('inscricao_success.title')}</h2>
                  <p className="success-message">{t('inscricao_success.message')}</p>
                  <div className="success-details">
                    <p>Foi-lhe enviado um email de confirmação com os detalhes da inscrição.</p>
                  </div>
                  <p className="text-sm text-brand-deep/50 mt-4">
                    A redirecionar em {countdown}...
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
                <h1 className="inscription-title" data-i18n="inscricao.title">{t('inscricao.title')}</h1>
                <p className="inscription-subtitle" data-i18n="inscricao.subtitle">{t('inscricao.subtitle')}</p>
              </div>

              {/* Error/Warning banner */}
              {(status === 'error' || status === 'duplicate') && (
                <div id="error-container" className="inscription-error mb-8">
                  <div className="error-icon">⚠</div>
                  <h2 className="error-title" data-i18n="inscricao_error.title">{t('inscricao_error.title')}</h2>
                  <p className="error-message" id="error-message">{errorMsg}</p>
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

              <form id="inscription-form" className="inscription-form" onSubmit={handleSubmit} noValidate>
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
                <input type="hidden" name="evento_slug" value={eventoSlug || ''} />

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
                  <label htmlFor="origem_evento" className="form-label" data-i18n="inscricao.origem_evento_label">
                    {t('inscricao.origem_evento_label')}
                  </label>
                  <select
                    id="origem_evento"
                    name="origem_evento"
                    className="form-input form-select"
                    value={form.origem_evento}
                    onChange={(e) => handleChange('origem_evento', e.target.value)}
                  >
                    <option value="">{t('inscricao.origem_evento_select')}</option>
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
                  className={`btn btn-primary inscription-btn w-full ${status === 'submitting' ? 'btn-loading' : ''}`}
                  disabled={status === 'submitting'}
                >
                  <span id="btn-text" data-i18n="inscricao.submit">
                    {status === 'submitting' ? t('inscricao.submitting') || 'A verificar...' : t('inscricao.submit')}
                  </span>
                </button>
              </form>
            </div>
          </div>
        </div>
      </section>
    </>
  )
}
