'use client'

import { useState, useEffect } from 'react'
import Link from 'next/link'
import { createClient } from '@/lib/supabase/client'
import { Lock, Eye, EyeOff, CheckCircle, ArrowLeft, Loader2 } from 'lucide-react'

export default function ReporClient({ lang }) {
  const [password, setPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState(false)
  const [checking, setChecking] = useState(true)
  const [validSession, setValidSession] = useState(false)

  useEffect(() => {
    // Supabase processes the token from the URL hash automatically.
    // We just need to verify the user has a valid session.
    async function checkSession() {
      const supabase = createClient()
      const { data: { user }, error } = await supabase.auth.getUser()
      if (error || !user) {
        setValidSession(false)
      } else {
        setValidSession(true)
      }
      setChecking(false)
    }
    checkSession()
  }, [])

  const handleSubmit = async (e) => {
    e.preventDefault()
    if (!password || !confirmPassword) return

    if (password !== confirmPassword) {
      setError('As passwords não coincidem')
      return
    }
    if (password.length < 6) {
      setError('A password deve ter pelo menos 6 caracteres')
      return
    }

    setLoading(true)
    setError('')

    try {
      const supabase = createClient()
      const { error: updateError } = await supabase.auth.updateUser({
        password: password,
      })

      if (updateError) {
        setError(updateError.message || 'Erro ao atualizar password')
        setLoading(false)
        return
      }

      setSuccess(true)
    } catch {
      setError('Erro ao conectar ao servidor')
    } finally {
      setLoading(false)
    }
  }

  // Loading state while checking session
  if (checking) {
    return (
      <section className="py-20 bg-background">
        <div className="container-center max-w-md mx-auto px-4 text-center">
          <Loader2 size={32} className="mx-auto mb-4 text-brand-accent animate-spin" />
          <p className="text-brand-deep/60">A verificar ligação...</p>
        </div>
      </section>
    )
  }

  // Invalid session (link expired or already used)
  if (!validSession) {
    return (
      <section className="py-20 bg-background">
        <div className="container-center max-w-md mx-auto px-4 text-center">
          <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-red-100 dark:bg-red-900/30 mb-6">
            <Lock size={32} className="text-red-600 dark:text-red-400" />
          </div>
          <h1 className="text-2xl font-bold text-brand-deep mb-3">Ligação inválida</h1>
          <p className="text-brand-deep/60 mb-8">
            Este link de reposição expirou ou já foi utilizado. Solicita um novo link.
          </p>
          <Link
            href={`/${lang}/esqueci-palavra-passe`}
            className="inline-flex items-center gap-2 bg-brand-accent text-white px-6 py-3 rounded-xl font-semibold hover:bg-brand-accent/90 transition-all"
          >
            Solicitar novo link
          </Link>
        </div>
      </section>
    )
  }

  // Success state
  if (success) {
    return (
      <section className="py-20 bg-background">
        <div className="container-center max-w-md mx-auto px-4 text-center">
          <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-green-100 dark:bg-green-900/30 mb-6">
            <CheckCircle size={32} className="text-green-600 dark:text-green-400" />
          </div>
          <h1 className="text-2xl font-bold text-brand-deep mb-3">Password atualizada!</h1>
          <p className="text-brand-deep/60 mb-8">
            A tua palavra-passe foi alterada com sucesso. Ya podes entrar com a nova password.
          </p>
          <Link
            href={`/${lang}/entrar`}
            className="inline-flex items-center gap-2 bg-brand-accent text-white px-6 py-3 rounded-xl font-semibold hover:bg-brand-accent/90 transition-all"
          >
            Entrar na conta
          </Link>
        </div>
      </section>
    )
  }

  // Reset form
  return (
    <section className="py-20 bg-background">
      <div className="container-center max-w-md mx-auto px-4">
        <div className="text-center mb-8">
          <Lock size={40} className="mx-auto mb-4 text-brand-accent" />
          <h1 className="text-3xl font-bold text-brand-deep mb-2">Nova palavra-passe</h1>
          <p className="text-brand-deep/60">
            Escolhe uma nova palavra-passe para a tua conta.
          </p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-brand-deep mb-2">Nova password</label>
            <div className="relative">
              <Lock size={18} className="absolute left-3 top-1/2 -translate-y-1/2 text-brand-deep/40" />
              <input
                type={showPassword ? 'text' : 'password'}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Mínimo 6 caracteres"
                className="w-full pl-10 pr-12 py-3 rounded-xl border border-brand-divider focus:ring-2 focus:ring-brand-accent focus:outline-none transition-all text-brand-deep"
                required
                minLength={6}
                autoFocus
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-brand-deep/40 hover:text-brand-deep transition-colors"
              >
                {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
              </button>
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-brand-deep mb-2">Confirmar password</label>
            <div className="relative">
              <Lock size={18} className="absolute left-3 top-1/2 -translate-y-1/2 text-brand-deep/40" />
              <input
                type={showPassword ? 'text' : 'password'}
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                placeholder="Repete a password"
                className="w-full pl-10 pr-4 py-3 rounded-xl border border-brand-divider focus:ring-2 focus:ring-brand-accent focus:outline-none transition-all text-brand-deep"
                required
                minLength={6}
              />
            </div>
          </div>

          {error && <p className="text-red-600 text-sm text-center">{error}</p>}

          <button
            type="submit"
            disabled={loading || !password || !confirmPassword}
            className="w-full py-3 rounded-xl bg-brand-accent text-white font-semibold hover:bg-brand-accent/90 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
          >
            {loading ? (
              <span className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
            ) : (
              <>
                <Lock size={18} />
                Atualizar password
              </>
            )}
          </button>
        </form>

        <p className="text-center text-sm text-brand-deep/60 mt-6">
          <Link href={`/${lang}/entrar`} className="inline-flex items-center gap-1 text-brand-accent hover:underline">
            <ArrowLeft size={14} />
            Voltar ao login
          </Link>
        </p>
      </div>
    </section>
  )
}
