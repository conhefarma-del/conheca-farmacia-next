'use client'

import { useContext, useState } from 'react'
import { Loader2, SlidersHorizontal } from 'lucide-react'
import { guardarPreferencias } from '@/lib/actions/account'
import { useTheme } from '@/components/providers/ThemeProvider'
import { LangContext } from '@/lib/contexts'

/**
 * Preferências da conta (idioma, aparência, contacto).
 *
 * A aparência aplica-se no clique (`setMode`), antes de guardar — quem muda de
 * tema quer ver a mudança, não esperar por um pedido ao servidor. O mesmo
 * botão de guardar persiste tudo na conta, e é essa preferência que um
 * aparelho novo recebe em vez de recomeçar na aparência do sistema.
 *
 * O telefone e o município não são decorativos: o Localizador pré-preenche a
 * reserva com eles (o que estiver no formulário continua a mandar — a reserva
 * grava o que a pessoa escreveu, não o perfil).
 */

const IDIOMAS = [
  { value: 'pt', key: 'account.preferences.portuguese' },
  { value: 'en', key: 'account.preferences.english' },
]

const APARENCIAS = [
  { value: 'light', key: 'account.preferences.light' },
  { value: 'dark', key: 'account.preferences.dark' },
  { value: 'system', key: 'account.preferences.system' },
]

const ERROS = {
  SEM_SESSAO: 'account.preferences.errors.session',
  TELEFONE: 'account.preferences.errors.phone',
  INVALIDO: 'account.preferences.errors.invalid',
  FALHOU: 'account.preferences.errors.failed',
}

function Segmented({ label, options, value, onChange, t }) {
  return (
    <div>
      <span className="conta-label">{label}</span>
      <div
        role="group"
        aria-label={label}
        style={{ display: 'flex', flexWrap: 'wrap', gap: '0.4rem', marginTop: '0.25rem' }}
      >
        {options.map((option) => (
          <button
            key={option.value}
            type="button"
            onClick={() => onChange(option.value)}
            aria-pressed={value === option.value}
            className={`conta-btn conta-btn--sm ${
              value === option.value ? 'conta-btn--primary' : 'conta-btn--ghost'
            }`}
          >
            {t(option.key)}
          </button>
        ))}
      </div>
    </div>
  )
}

export default function PreferenciasPanel({ lang, theme, phone, municipality }) {
  const { t } = useContext(LangContext)
  const { setMode } = useTheme()
  const [idioma, setIdioma] = useState(lang === 'en' ? 'en' : 'pt')
  const [aparencia, setAparencia] = useState(
    APARENCIAS.some((item) => item.value === theme) ? theme : 'system',
  )
  const [telefone, setTelefone] = useState(phone || '')
  const [municipio, setMunicipio] = useState(municipality || '')
  const [saving, setSaving] = useState(false)
  const [message, setMessage] = useState('')
  const [error, setError] = useState('')

  function chooseAparencia(value) {
    setAparencia(value)
    setMode(value)
  }

  async function handleSubmit(event) {
    event.preventDefault()
    setSaving(true)
    setError('')
    setMessage('')
    try {
      const result = await guardarPreferencias({
        lang: idioma,
        theme: aparencia,
        phone: telefone,
        municipality: municipio,
      })
      if (result?.ok) {
        setMessage(t('account.preferences.saved'))
      } else {
        setError(t(ERROS[result?.error] || 'account.preferences.errors.failed'))
      }
    } catch {
      setError(t('account.preferences.errors.failed'))
    } finally {
      setSaving(false)
    }
  }

  return (
    <section className="conta-panel" aria-labelledby="conta-preferencias">
      <div className="conta-panel-head">
        <h2 id="conta-preferencias" className="conta-panel-title">
          <SlidersHorizontal size={14} aria-hidden="true" />
          {t('account.preferences.panel')}
        </h2>
      </div>
      <div className="conta-panel-body">
        <form onSubmit={handleSubmit} className="conta-form-row" style={{ marginTop: 0 }}>
          <Segmented
            t={t}
            label={t('account.preferences.language')}
            options={IDIOMAS}
            value={idioma}
            onChange={setIdioma}
          />
          <Segmented
            t={t}
            label={t('account.preferences.appearance')}
            options={APARENCIAS}
            value={aparencia}
            onChange={chooseAparencia}
          />

          <label>
            <span className="conta-label">{t('account.preferences.phone')}</span>
            <input
              type="tel"
              inputMode="tel"
              value={telefone}
              onChange={(event) => setTelefone(event.target.value)}
              className="conta-field"
              placeholder="923 114 500"
              autoComplete="tel"
            />
          </label>
          <p className="conta-hint">{t('account.preferences.phoneHint')}</p>

          <label>
            <span className="conta-label">{t('account.preferences.municipality')}</span>
            <input
              type="text"
              value={municipio}
              onChange={(event) => setMunicipio(event.target.value)}
              className="conta-field"
              placeholder="Luanda"
              autoComplete="address-level2"
            />
          </label>

          {error && (
            <p className="conta-hint" style={{ color: '#a3231f' }} role="alert">
              {error}
            </p>
          )}
          {message && <p className="conta-hint">{message}</p>}

          <button
            type="submit"
            disabled={saving}
            className="conta-btn conta-btn--primary"
            style={{ width: '100%' }}
          >
            {saving ? <Loader2 size={15} className="animate-spin" /> : null}
            {t('account.preferences.save')}
          </button>
        </form>
      </div>
    </section>
  )
}
