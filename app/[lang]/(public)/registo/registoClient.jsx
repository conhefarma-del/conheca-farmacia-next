'use client'

import { useState } from 'react'
import Link from 'next/link'
import { createClient } from '@/lib/supabase/client'
import { Mail, Lock, UserPlus, Eye, EyeOff } from 'lucide-react'

export default function RegistoClient({ lang }) {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')

  const handleEmailRegister = async (e) => {
    e.preventDefault()
    if (!email || !password) return
    if (password !== confirmPassword) {
      setError('As passwords não coincidem')
      return
    }
    if (password.length < 8) {
      setError('A password deve ter pelo menos 8 caracteres')
      return
    }
    setLoading(true)
    setError('')
    setSuccess('')

    try {
      const supabase = createClient()
      const { data, error: signUpError } = await supabase.auth.signUp({
        email,
        password,
        options: {
          emailRedirectTo: `${window.location.origin}/${lang}/perfil`,
          data: {
            display_name: email.split('@')[0],
          },
        },
      })

      if (signUpError) {
        setError(signUpError.message || 'Erro ao criar conta')
        setLoading(false)
        return
      }

      if (data.user) {
        setSuccess('Conta criada! Verifica o teu email para confirmar a conta.')
      }
    } catch {
      setError('Erro ao conectar ao servidor')
    } finally {
      setLoading(false)
    }
  }

  const handleGoogleRegister = async () => {
    setLoading(true)
    setError('')
    try {
      const supabase = createClient()
      const { error: oauthError } = await supabase.auth.signInWithOAuth({
        provider: 'google',
        options: {
          redirectTo: `${window.location.origin}/${lang}/conta-criada`,
        },
      })
      if (oauthError) {
        setError(oauthError.message || 'Erro ao criar conta com Google')
        setLoading(false)
      }
    } catch {
      setError('Erro ao conectar ao servidor')
      setLoading(false)
    }
  }

  return (
    <section className="py-20 bg-background">
      <div className="container-center max-w-md mx-auto px-4">
        <div className="text-center mb-8">
          <UserPlus size={40} className="mx-auto mb-4 text-brand-accent" />
          <h1 className="text-3xl font-bold text-brand-deep mb-2">Criar Conta</h1>
          <p className="text-brand-deep/60">Junta-te à comunidade Conheça Farmácia</p>
        </div>

        {/* Google Register */}
        <button
          onClick={handleGoogleRegister}
          disabled={loading}
          className="w-full py-3 px-4 rounded-xl border border-brand-divider bg-card hover:bg-brand-deep/5 transition-all flex items-center justify-center gap-3 font-medium text-brand-deep mb-6"
        >
          <svg width="20" height="20" viewBox="0 0 24 24">
            <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92a5.06 5.06 0 01-2.2 3.32v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.1z" fill="#4285F4"/>
            <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
            <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05"/>
            <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/>
          </svg>
          Criar conta com Google
        </button>

        <div className="relative my-6">
          <div className="absolute inset-0 flex items-center">
            <div className="w-full border-t border-brand-divider" />
          </div>
          <div className="relative flex justify-center text-sm">
            <span className="bg-background px-4 text-brand-deep/40">ou</span>
          </div>
        </div>

        {/* Email/Password Register */}
        <form onSubmit={handleEmailRegister} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-brand-deep mb-2">Email</label>
            <div className="relative">
              <Mail size={18} className="absolute left-3 top-1/2 -translate-y-1/2 text-brand-deep/40" />
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="teu@email.com"
                className="w-full pl-10 pr-4 py-3 rounded-xl border border-brand-divider focus:ring-2 focus:ring-brand-accent focus:outline-none transition-all text-brand-deep"
                required
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-brand-deep mb-2">Password</label>
            <div className="relative">
              <Lock size={18} className="absolute left-3 top-1/2 -translate-y-1/2 text-brand-deep/40" />
              <input
                type={showPassword ? 'text' : 'password'}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Mínimo 8 caracteres"
                className="w-full pl-10 pr-12 py-3 rounded-xl border border-brand-divider focus:ring-2 focus:ring-brand-accent focus:outline-none transition-all text-brand-deep"
                required
                minLength={8}
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
            <label className="block text-sm font-medium text-brand-deep mb-2">Confirmar Password</label>
            <div className="relative">
              <Lock size={18} className="absolute left-3 top-1/2 -translate-y-1/2 text-brand-deep/40" />
              <input
                type={showPassword ? 'text' : 'password'}
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                placeholder="Repete a password"
                className="w-full pl-10 pr-4 py-3 rounded-xl border border-brand-divider focus:ring-2 focus:ring-brand-accent focus:outline-none transition-all text-brand-deep"
                required
                minLength={8}
              />
            </div>
          </div>

          {error && <p className="text-red-600 text-sm text-center">{error}</p>}
          {success && <p className="text-green-600 text-sm text-center">{success}</p>}

          <button
            type="submit"
            disabled={loading || !email || !password}
            className="w-full py-3 rounded-xl bg-brand-accent text-white font-semibold hover:bg-brand-accent/90 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
          >
            {loading ? (
              <span className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
            ) : (
              <>
                <UserPlus size={18} />
                Criar Conta
              </>
            )}
          </button>
        </form>

        <p className="text-center text-sm text-brand-deep/60 mt-6">
          Já tens conta?{' '}
          <Link href={`/${lang}/entrar`} className="text-brand-accent hover:underline">
            Entrar
          </Link>
        </p>
      </div>
    </section>
  )
}
