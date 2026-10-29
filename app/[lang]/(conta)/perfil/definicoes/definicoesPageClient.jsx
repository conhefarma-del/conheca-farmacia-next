'use client'

import { useState, useEffect, useContext, useCallback, useRef } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { Lock, School, ClipboardList, Loader2, Search, Eye, EyeOff } from 'lucide-react'
import { LangContext } from '@/lib/contexts'

export default function DefinicoesPageClient({ lang }) {
  const { t } = useContext(LangContext)
  const router = useRouter()

  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [saveMsg, setSaveMsg] = useState('')
  const [saveMsgType, setSaveMsgType] = useState('success') // success | error

  // Password
  const [newPassword, setNewPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [passwordError, setPasswordError] = useState('')

  // School
  const [schoolName, setSchoolName] = useState('')
  const [schoolSearch, setSchoolSearch] = useState('')
  const [schoolResults, setSchoolResults] = useState([])
  const [schoolSearching, setSchoolSearching] = useState(false)
  const [showSchoolDropdown, setShowSchoolDropdown] = useState(false)
  const schoolDropdownRef = useRef(null)
  const schoolSearchTimeout = useRef(null)

  // Class
  const [className_, setClassName] = useState('')

  // Load user
  useEffect(() => {
    async function loadUser() {
      const supabase = createClient()
      const { data: { user }, error } = await supabase.auth.getUser()
      if (error || !user) {
        router.push(`/${lang}/entrar`)
        return
      }
      setUser(user)
      setSchoolName(user.user_metadata?.school || '')
      setClassName(user.user_metadata?.class_name || '')
      setLoading(false)
    }
    loadUser()
  }, [lang, router])

  // Close school dropdown on outside click
  useEffect(() => {
    function handleClick(e) {
      if (schoolDropdownRef.current && !schoolDropdownRef.current.contains(e.target)) {
        setShowSchoolDropdown(false)
      }
    }
    document.addEventListener('mousedown', handleClick)
    return () => document.removeEventListener('mousedown', handleClick)
  }, [])

  // School search with debounce
  const searchSchools = useCallback((query) => {
    setSchoolSearch(query)
    if (schoolSearchTimeout.current) clearTimeout(schoolSearchTimeout.current)

    if (!query.trim() || query.trim().length < 2) {
      setSchoolResults([])
      setShowSchoolDropdown(false)
      return
    }

    schoolSearchTimeout.current = setTimeout(async () => {
      setSchoolSearching(true)
      try {
        const supabase = createClient()
        const { data } = await supabase
          .from('schools')
          .select('id, name')
          .ilike('name', `%${query.trim()}%`)
          .eq('status', 'published')
          .eq('is_archived', false)
          .limit(10)
        setSchoolResults(data || [])
        setShowSchoolDropdown(true)
      } catch {
        setSchoolResults([])
      } finally {
        setSchoolSearching(false)
      }
    }, 300)
  }, [])

  const selectSchool = (name) => {
    setSchoolName(name)
    setSchoolSearch('')
    setSchoolResults([])
    setShowSchoolDropdown(false)
  }

  // Save password
  const handleSavePassword = async () => {
    setPasswordError('')
    if (!newPassword) {
      setPasswordError('Insere a nova palavra-passe')
      return
    }
    if (newPassword.length < 6) {
      setPasswordError('Mínimo de 6 caracteres')
      return
    }
    if (newPassword !== confirmPassword) {
      setPasswordError('As palavras-passe não coincidem')
      return
    }

    setSaving(true)
    setSaveMsg('')
    try {
      const supabase = createClient()
      const { error } = await supabase.auth.updateUser({ password: newPassword })
      if (error) {
        setPasswordError(error.message)
        setSaveMsgType('error')
      } else {
        setSaveMsg('Palavra-passe atualizada!')
        setSaveMsgType('success')
        setNewPassword('')
        setConfirmPassword('')
      }
    } catch {
      setPasswordError('Erro ao conectar ao servidor')
      setSaveMsgType('error')
    } finally {
      setSaving(false)
    }
  }

  // Save school
  const handleSaveSchool = async () => {
    setSaving(true)
    setSaveMsg('')
    try {
      const supabase = createClient()
      const { error } = await supabase.auth.updateUser({
        data: { school: schoolName.trim() },
      })
      if (error) {
        setSaveMsg('Erro ao guardar escola')
        setSaveMsgType('error')
      } else {
        setUser((prev) => ({
          ...prev,
          user_metadata: { ...prev.user_metadata, school: schoolName.trim() },
        }))
        setSaveMsg('Escola atualizada!')
        setSaveMsgType('success')
      }
    } catch {
      setSaveMsg('Erro ao conectar ao servidor')
      setSaveMsgType('error')
    } finally {
      setSaving(false)
    }
  }

  // Save class
  const handleSaveClass = async () => {
    setSaving(true)
    setSaveMsg('')
    try {
      const supabase = createClient()
      const { error } = await supabase.auth.updateUser({
        data: { class_name: className_.trim() },
      })
      if (error) {
        setSaveMsg('Erro ao guardar turma')
        setSaveMsgType('error')
      } else {
        setUser((prev) => ({
          ...prev,
          user_metadata: { ...prev.user_metadata, class_name: className_.trim() },
        }))
        setSaveMsg('Turma atualizada!')
        setSaveMsgType('success')
      }
    } catch {
      setSaveMsg('Erro ao conectar ao servidor')
      setSaveMsgType('error')
    } finally {
      setSaving(false)
    }
  }

  if (loading) {
    return (
      <main className="conta-page">
        <div className="conta-panel" style={{ height: 108, opacity: 0.35 }} />
        <div className="conta-panel" style={{ height: 180, marginTop: '1rem', opacity: 0.22 }} />
        <div className="conta-panel" style={{ height: 180, marginTop: '1rem', opacity: 0.18 }} />
      </main>
    )
  }

  return (
    <main className="conta-page">
      <header className="conta-page-head">
        <div>
          <p className="conta-kicker">Perfil de estudante</p>
          <h1 className="conta-title">{t('settings.page_title')}</h1>
          <p className="conta-sub">{t('settings.page_description')}</p>
        </div>
      </header>

      {saveMsg && (
        <p
          className={`conta-alert${saveMsgType === 'success' ? ' conta-alert--ok' : ' conta-alert--bad'}`}
          role="status"
        >
          {saveMsg}
        </p>
      )}

      <div className="conta-grid2">
        <div>
          {/* Password */}
          <section className="conta-panel" aria-labelledby="def-palavra-passe">
            <div className="conta-panel-head">
              <h2 id="def-palavra-passe" className="conta-panel-title">
                <Lock size={14} />
                {t('settings.change_password')}
              </h2>
            </div>
            <div className="conta-panel-body">
              <div className="conta-form-row">
                <label>
                  <span className="conta-label">{t('settings.new_password')}</span>
                  <div style={{ position: 'relative' }}>
                    <input
                      type={showPassword ? 'text' : 'password'}
                      value={newPassword}
                      onChange={(e) => {
                        setNewPassword(e.target.value)
                        setPasswordError('')
                      }}
                      className="conta-field"
                      style={{ paddingRight: '2.5rem' }}
                      placeholder={t('settings.password_placeholder')}
                    />
                    <button
                      type="button"
                      onClick={() => setShowPassword(!showPassword)}
                      style={{
                        position: 'absolute',
                        right: '0.65rem',
                        top: '50%',
                        transform: 'translateY(-50%)',
                        color: 'var(--conta-ink-45)',
                        background: 'none',
                        border: 0,
                        cursor: 'pointer',
                      }}
                      aria-label={showPassword ? 'Esconder palavra-passe' : 'Mostrar palavra-passe'}
                    >
                      {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                    </button>
                  </div>
                </label>

                <label>
                  <span className="conta-label">{t('settings.confirm_password')}</span>
                  <input
                    type={showPassword ? 'text' : 'password'}
                    value={confirmPassword}
                    onChange={(e) => {
                      setConfirmPassword(e.target.value)
                      setPasswordError('')
                    }}
                    className="conta-field"
                    placeholder={t('settings.confirm_password_placeholder')}
                  />
                </label>

                {passwordError && (
                  <p className="conta-hint" style={{ color: '#a3231f' }} role="alert">
                    {passwordError}
                  </p>
                )}

                <button
                  onClick={handleSavePassword}
                  disabled={saving || !newPassword}
                  className="conta-btn conta-btn--primary"
                  style={{ width: '100%' }}
                >
                  {saving ? <Loader2 size={15} className="animate-spin" /> : t('settings.save_password')}
                </button>
              </div>
            </div>
          </section>

          {/* School */}
          <section className="conta-panel" aria-labelledby="def-escola">
            <div className="conta-panel-head">
              <h2 id="def-escola" className="conta-panel-title">
                <School size={14} />
                {t('settings.school')}
              </h2>
            </div>
            <div className="conta-panel-body">
              <div className="conta-form-row">
                <div ref={schoolDropdownRef} style={{ position: 'relative' }}>
                  <label>
                    <span className="conta-label">{t('settings.school_name')}</span>
                    <div style={{ position: 'relative' }}>
                      <Search
                        size={14}
                        style={{
                          position: 'absolute',
                          left: '0.7rem',
                          top: '50%',
                          transform: 'translateY(-50%)',
                          color: 'var(--conta-ink-45)',
                        }}
                      />
                      <input
                        type="text"
                        value={schoolSearch || schoolName}
                        onChange={(e) => {
                          setSchoolName(e.target.value)
                          searchSchools(e.target.value)
                        }}
                        onFocus={() => {
                          if (schoolResults.length > 0) setShowSchoolDropdown(true)
                        }}
                        className="conta-field"
                        style={{ paddingLeft: '2.1rem' }}
                        placeholder={t('settings.school_placeholder')}
                      />
                      {schoolSearching && (
                        <Loader2
                          size={14}
                          className="animate-spin"
                          style={{
                            position: 'absolute',
                            right: '0.7rem',
                            top: '50%',
                            transform: 'translateY(-50%)',
                            color: 'var(--conta-ink-45)',
                          }}
                        />
                      )}
                    </div>
                  </label>

                  {showSchoolDropdown && schoolResults.length > 0 && (
                    <div
                      className="conta-panel"
                      style={{
                        position: 'absolute',
                        zIndex: 50,
                        width: '100%',
                        marginTop: '0.25rem',
                        maxHeight: '12rem',
                        overflowY: 'auto',
                      }}
                    >
                      {schoolResults.map((school) => (
                        <button
                          key={school.id}
                          type="button"
                          onClick={() => selectSchool(school.name)}
                          className="conta-row"
                          style={{
                            width: '100%',
                            textAlign: 'left',
                            background: 'none',
                            border: 0,
                            borderBottom: '1px solid var(--color-brand-divider)',
                            cursor: 'pointer',
                            fontSize: '0.8125rem',
                            color: 'var(--color-brand-deep)',
                          }}
                        >
                          {school.name}
                        </button>
                      ))}
                    </div>
                  )}
                </div>

                <button
                  onClick={handleSaveSchool}
                  disabled={saving || !schoolName.trim()}
                  className="conta-btn conta-btn--primary"
                  style={{ width: '100%' }}
                >
                  {saving ? <Loader2 size={15} className="animate-spin" /> : t('settings.save_school')}
                </button>
              </div>
            </div>
          </section>

          {/* Class */}
          <section className="conta-panel" aria-labelledby="def-turma">
            <div className="conta-panel-head">
              <h2 id="def-turma" className="conta-panel-title">
                <ClipboardList size={14} />
                {t('settings.class_name')}
              </h2>
            </div>
            <div className="conta-panel-body">
              <div className="conta-form-row">
                <label>
                  <span className="conta-label">{t('settings.class_label')}</span>
                  <input
                    type="text"
                    value={className_}
                    onChange={(e) => setClassName(e.target.value)}
                    className="conta-field"
                    placeholder={t('settings.class_placeholder')}
                  />
                </label>
                <button
                  onClick={handleSaveClass}
                  disabled={saving || !className_.trim()}
                  className="conta-btn conta-btn--primary"
                  style={{ width: '100%' }}
                >
                  {saving ? <Loader2 size={15} className="animate-spin" /> : t('settings.save_class')}
                </button>
              </div>
            </div>
          </section>
        </div>

        <aside>
          <section className="conta-panel" aria-labelledby="def-conta">
            <div className="conta-panel-head">
              <h2 id="def-conta" className="conta-panel-title">
                A mesma conta em todo o lado
              </h2>
            </div>
            <div className="conta-panel-body">
              <p className="conta-hint" style={{ marginTop: 0 }}>
                A escola e a turma são do perfil de estudante. O nome, a fotografia e o e-mail
                vivem em A minha conta, e servem também o Localizador.
              </p>
              <button
                type="button"
                onClick={() => router.push(`/${lang}/perfil`)}
                className="conta-btn conta-btn--ghost"
                style={{ width: '100%', marginTop: '0.75rem' }}
              >
                Voltar ao perfil
              </button>
            </div>
          </section>
        </aside>
      </div>
    </main>
  )
}
