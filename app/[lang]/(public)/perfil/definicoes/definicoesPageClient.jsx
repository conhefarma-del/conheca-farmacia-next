'use client'

import { useState, useEffect, useContext, useCallback, useRef } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import {
  ArrowLeft, Lock, School, ClipboardList, Loader2, Check, X, Search, Eye, EyeOff
} from 'lucide-react'
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
    const pulse = { background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }
    return (
      <>
        <section className="articles-hero">
          <div className="container-center">
            <div className="text-center py-12 md:py-16">
              <div className="h-10 w-48 mx-auto rounded-2xl mb-3" style={{ ...pulse, opacity: 0.5 }} />
            </div>
          </div>
        </section>
        <section className="max-w-2xl mx-auto px-4 py-8">
          <div className="space-y-4">
            {Array.from({ length: 3 }).map((_, i) => (
              <div key={i} className="profile-card-v2" style={{ minHeight: 120 }}>
                <div className="h-5 w-32 rounded mb-4" style={{ ...pulse, opacity: 0.4 }} />
                <div className="h-10 w-full rounded-lg" style={{ ...pulse, opacity: 0.2 }} />
              </div>
            ))}
          </div>
        </section>
      </>
    )
  }

  return (
    <>
      {/* Hero */}
      <section className="articles-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <button
              onClick={() => router.push(`/${lang}/perfil`)}
              className="inline-flex items-center gap-2 text-sm mb-4 opacity-60 hover:opacity-100 transition-opacity"
              style={{ color: 'var(--color-brand-deep)' }}
            >
              <ArrowLeft size={16} />
              {t('settings.back_to_profile')}
            </button>
            <h1 className="text-4xl md:text-5xl font-bold text-brand-deep mb-3">
              {t('settings.page_title')}
            </h1>
            <p className="hero-subtitle text-center">
              {t('settings.page_description')}
            </p>
          </div>
        </div>
      </section>

      {/* Content */}
      <section className="max-w-2xl mx-auto px-4 py-8">
        {/* Success/Error message */}
        {saveMsg && (
          <div
            className={`rounded-xl p-3 text-sm text-center mb-6 ${
              saveMsgType === 'success'
                ? 'bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 text-green-600'
                : 'bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 text-red-600'
            }`}
          >
            {saveMsg}
          </div>
        )}

        <div className="space-y-4">
          {/* Password Card */}
          <div className="profile-card-v2">
            <div className="profile-card-header">
              <div className="profile-card-dot" />
              <Lock size={16} />
              {t('settings.change_password')}
            </div>
            <div className="space-y-3">
              <div>
                <label className="block text-xs font-medium mb-1" style={{ color: 'var(--color-brand-deep)', opacity: 0.6 }}>
                  {t('settings.new_password')}
                </label>
                <div className="relative">
                  <input
                    type={showPassword ? 'text' : 'password'}
                    value={newPassword}
                    onChange={(e) => { setNewPassword(e.target.value); setPasswordError('') }}
                    className="w-full px-4 py-2.5 pr-10 rounded-lg border focus:outline-none focus:ring-2 focus:ring-[var(--color-brand-accent)]"
                    style={{
                      borderColor: 'var(--color-brand-divider)',
                      background: 'var(--color-brand-bg)',
                      color: 'var(--color-brand-deep)',
                    }}
                    placeholder={t('settings.password_placeholder')}
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 opacity-40 hover:opacity-100"
                    style={{ color: 'var(--color-brand-deep)' }}
                  >
                    {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                  </button>
                </div>
              </div>
              <div>
                <label className="block text-xs font-medium mb-1" style={{ color: 'var(--color-brand-deep)', opacity: 0.6 }}>
                  {t('settings.confirm_password')}
                </label>
                <input
                  type={showPassword ? 'text' : 'password'}
                  value={confirmPassword}
                  onChange={(e) => { setConfirmPassword(e.target.value); setPasswordError('') }}
                  className="w-full px-4 py-2.5 rounded-lg border focus:outline-none focus:ring-2 focus:ring-[var(--color-brand-accent)]"
                  style={{
                    borderColor: 'var(--color-brand-divider)',
                    background: 'var(--color-brand-bg)',
                    color: 'var(--color-brand-deep)',
                  }}
                  placeholder={t('settings.confirm_password_placeholder')}
                />
              </div>
              {passwordError && (
                <p className="text-xs text-red-500">{passwordError}</p>
              )}
              <button
                onClick={handleSavePassword}
                disabled={saving || !newPassword}
                className="w-full py-2.5 rounded-lg text-sm font-medium transition-all disabled:opacity-40"
                style={{
                  background: 'var(--color-brand-accent)',
                  color: 'white',
                }}
              >
                {saving ? <Loader2 size={16} className="animate-spin mx-auto" /> : t('settings.save_password')}
              </button>
            </div>
          </div>

          {/* School Card */}
          <div className="profile-card-v2">
            <div className="profile-card-header">
              <div className="profile-card-dot" />
              <School size={16} />
              {t('settings.school')}
            </div>
            <div className="space-y-3">
              <div ref={schoolDropdownRef} className="relative">
                <label className="block text-xs font-medium mb-1" style={{ color: 'var(--color-brand-deep)', opacity: 0.6 }}>
                  {t('settings.school_name')}
                </label>
                <div className="relative">
                  <Search size={14} className="absolute left-3 top-1/2 -translate-y-1/2 opacity-40" style={{ color: 'var(--color-brand-deep)' }} />
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
                    className="w-full pl-9 pr-4 py-2.5 rounded-lg border focus:outline-none focus:ring-2 focus:ring-[var(--color-brand-accent)]"
                    style={{
                      borderColor: 'var(--color-brand-divider)',
                      background: 'var(--color-brand-bg)',
                      color: 'var(--color-brand-deep)',
                    }}
                    placeholder={t('settings.school_placeholder')}
                  />
                  {schoolSearching && (
                    <Loader2 size={14} className="absolute right-3 top-1/2 -translate-y-1/2 animate-spin opacity-40" style={{ color: 'var(--color-brand-deep)' }} />
                  )}
                </div>
                {/* Dropdown */}
                {showSchoolDropdown && schoolResults.length > 0 && (
                  <div
                    className="absolute z-50 w-full mt-1 rounded-lg border shadow-lg max-h-48 overflow-y-auto"
                    style={{
                      background: 'var(--color-brand-card)',
                      borderColor: 'var(--color-brand-divider)',
                    }}
                  >
                    {schoolResults.map((school) => (
                      <button
                        key={school.id}
                        type="button"
                        onClick={() => selectSchool(school.name)}
                        className="w-full px-4 py-2.5 text-left text-sm hover:bg-[rgba(10,132,79,0.05)] transition-colors"
                        style={{ color: 'var(--color-brand-deep)' }}
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
                className="w-full py-2.5 rounded-lg text-sm font-medium transition-all disabled:opacity-40"
                style={{
                  background: 'var(--color-brand-accent)',
                  color: 'white',
                }}
              >
                {saving ? <Loader2 size={16} className="animate-spin mx-auto" /> : t('settings.save_school')}
              </button>
            </div>
          </div>

          {/* Class Card */}
          <div className="profile-card-v2">
            <div className="profile-card-header">
              <div className="profile-card-dot" />
              <ClipboardList size={16} />
              {t('settings.class_name')}
            </div>
            <div className="space-y-3">
              <div>
                <label className="block text-xs font-medium mb-1" style={{ color: 'var(--color-brand-deep)', opacity: 0.6 }}>
                  {t('settings.class_label')}
                </label>
                <input
                  type="text"
                  value={className_}
                  onChange={(e) => setClassName(e.target.value)}
                  className="w-full px-4 py-2.5 rounded-lg border focus:outline-none focus:ring-2 focus:ring-[var(--color-brand-accent)]"
                  style={{
                    borderColor: 'var(--color-brand-divider)',
                    background: 'var(--color-brand-bg)',
                    color: 'var(--color-brand-deep)',
                  }}
                  placeholder={t('settings.class_placeholder')}
                />
              </div>
              <button
                onClick={handleSaveClass}
                disabled={saving || !className_.trim()}
                className="w-full py-2.5 rounded-lg text-sm font-medium transition-all disabled:opacity-40"
                style={{
                  background: 'var(--color-brand-accent)',
                  color: 'white',
                }}
              >
                {saving ? <Loader2 size={16} className="animate-spin mx-auto" /> : t('settings.save_class')}
              </button>
            </div>
          </div>
        </div>
      </section>
    </>
  )
}
