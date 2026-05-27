'use client'

import { useState, useEffect, useCallback } from 'react'
import { useRouter, useParams } from 'next/navigation'
import { Lock, ShieldCheck } from 'lucide-react'
import {
  adminLogin,
  verifyMFA,
  getGateQuestions,
  verifyGateAnswers,
} from '@/lib/actions/auth'

/**
 * Admin Login Page — Split-Screen (Gate + Login + MFA)
 *
 * SEM sidebar — herda apenas root layout (html/body).
 * 3 estados controlados por useState: gate → login → mfa.
 *
 * SEC-ATH-02: Server Actions verificam admin_users.
 * SEC-FRM-02: Password fields com type="password".
 */

const GATE_STATE = 'gate'
const LOGIN_STATE = 'login'
const MFA_STATE = 'mfa'

export default function AdminLoginPage() {
  const router = useRouter()
  const params = useParams()
  const lang = params.lang || 'pt'

  // Estado da máquina de estados: gate → login → mfa
  const [authState, setAuthState] = useState(GATE_STATE)

  // Gate state
  const [gateQuestions, setGateQuestions] = useState([])
  const [gateAnswers, setGateAnswers] = useState({ q1: '', q2: '' })
  const [gateError, setGateError] = useState('')
  const [gateLoading, setGateLoading] = useState(false)

  // Login state
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [loginError, setLoginError] = useState('')
  const [loginLoading, setLoginLoading] = useState(false)

  // MFA state
  const [totpCode, setTotpCode] = useState('')
  const [mfaFactorId, setMfaFactorId] = useState('')
  const [mfaError, setMfaError] = useState('')
  const [mfaLoading, setMfaLoading] = useState(false)

  // Carregar perguntas do gate ao montar
  useEffect(() => {
    const loadQuestions = async () => {
      const result = await getGateQuestions()
      if (result.success && result.questions) {
        setGateQuestions(result.questions)
      } else {
        // Se não há gate configurado, saltar direto para login
        setAuthState(LOGIN_STATE)
      }
    }
    loadQuestions()
  }, [])

  // Gate: verificar respostas
  const handleGateSubmit = useCallback(async (e) => {
    e.preventDefault()
    setGateError('')
    setGateLoading(true)

    try {
      if (!gateQuestions.length) {
        setAuthState(LOGIN_STATE)
        return
      }

      const answers = gateQuestions.map((q, i) => ({
        question_id: q.id,
        answer: i === 0 ? gateAnswers.q1 : gateAnswers.q2,
      }))

      const result = await verifyGateAnswers(answers)

      if (result.success) {
        setAuthState(LOGIN_STATE)
      } else {
        setGateError(result.error || 'Respostas incorretas.')
      }
    } catch {
      setGateError('Erro ao verificar respostas.')
    } finally {
      setGateLoading(false)
    }
  }, [gateQuestions, gateAnswers])

  // Login: email + password
  const handleLoginSubmit = useCallback(async (e) => {
    e.preventDefault()
    setLoginError('')
    setLoginLoading(true)

    try {
      const result = await adminLogin(email, password)

      if (result.success) {
        if (result.needsMFA) {
          setMfaFactorId(result.factorId)
          setAuthState(MFA_STATE)
        } else {
          router.push(`/${lang}/admin/dashboard`)
        }
      } else {
        setLoginError(result.error || 'Erro ao fazer login.')
      }
    } catch {
      setLoginError('Erro ao fazer login.')
    } finally {
      setLoginLoading(false)
    }
  }, [email, password, router, lang])

  // MFA: código TOTP
  const handleMFASubmit = useCallback(async (e) => {
    e.preventDefault()
    setMfaError('')
    setMfaLoading(true)

    try {
      const result = await verifyMFA(mfaFactorId, totpCode)

      if (result.success) {
        router.push(`/${lang}/admin/dashboard`)
      } else {
        setMfaError(result.error || 'Código inválido.')
      }
    } catch {
      setMfaError('Erro ao verificar código.')
    } finally {
      setMfaLoading(false)
    }
  }, [mfaFactorId, totpCode, router, lang])

  return (
    <>
      {/* Gate Section — fullscreen overlay */}
      {authState === GATE_STATE && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center"
          style={{
            background: 'linear-gradient(160deg, #002a32 0%, #00493a 40%, #006171 100%)',
            fontFamily: "'DM Sans', -apple-system, sans-serif",
          }}
        >
          <div
            className="w-full max-w-md mx-4 p-10 rounded-2xl text-center"
            style={{
              background: 'rgba(255, 255, 255, 0.05)',
              backdropFilter: 'blur(20px)',
              border: '1px solid rgba(255, 255, 255, 0.1)',
            }}
          >
            <div
              className="mx-auto mb-5 w-16 h-16 rounded-full flex items-center justify-center"
              style={{ background: 'rgba(10, 132, 79, 0.2)' }}
            >
              <Lock size={32} className="text-white" />
            </div>

            <h1
              className="text-white mb-2"
              style={{ fontSize: 28, fontWeight: 700, fontFamily: "'Fraunces', serif" }}
            >
              Acesso Restrito
            </h1>
            <p className="mb-8" style={{ color: 'rgba(255,255,255,0.6)', fontSize: 14 }}>
              Responda às perguntas de segurança para aceder ao painel.
            </p>

            <form onSubmit={handleGateSubmit} className="space-y-5 text-left">
              {gateQuestions.length > 0 && (
                <>
                  <div>
                    <label
                      htmlFor="gate-a1"
                      className="block mb-1.5 text-sm font-medium text-white"
                    >
                      {gateQuestions[0]?.question || 'Pergunta 1'}
                    </label>
                    <input
                      id="gate-a1"
                      type="text"
                      value={gateAnswers.q1}
                      onChange={(e) => setGateAnswers((prev) => ({ ...prev, q1: e.target.value }))}
                      required
                      autoComplete="off"
                      placeholder="A sua resposta"
                      className="w-full px-4 py-3 rounded-xl text-sm"
                      style={{
                        background: 'rgba(255, 255, 255, 0.08)',
                        border: '1px solid rgba(255, 255, 255, 0.15)',
                        color: 'white',
                        outline: 'none',
                      }}
                    />
                  </div>

                  {gateQuestions.length > 1 && (
                    <div>
                      <label
                        htmlFor="gate-a2"
                        className="block mb-1.5 text-sm font-medium text-white"
                      >
                        {gateQuestions[1]?.question || 'Pergunta 2'}
                      </label>
                      <input
                        id="gate-a2"
                        type="text"
                        value={gateAnswers.q2}
                        onChange={(e) => setGateAnswers((prev) => ({ ...prev, q2: e.target.value }))}
                        required
                        autoComplete="off"
                        placeholder="A sua resposta"
                        className="w-full px-4 py-3 rounded-xl text-sm"
                        style={{
                          background: 'rgba(255, 255, 255, 0.08)',
                          border: '1px solid rgba(255, 255, 255, 0.15)',
                          color: 'white',
                          outline: 'none',
                        }}
                      />
                    </div>
                  )}
                </>
              )}

              {gateError && (
                <div
                  className="py-2.5 px-4 rounded-lg text-sm"
                  style={{ background: 'rgba(239, 68, 68, 0.15)', color: '#fca5a5' }}
                >
                  {gateError}
                </div>
              )}

              <button
                type="submit"
                disabled={gateLoading}
                className="w-full py-3.5 rounded-xl text-white font-semibold text-sm transition-all duration-200"
                style={{
                  background: 'linear-gradient(135deg, #00493a 0%, #0a844f 100%)',
                  opacity: gateLoading ? 0.7 : 1,
                }}
              >
                {gateLoading ? 'A verificar...' : 'Verificar'}
              </button>
            </form>
          </div>
        </div>
      )}

      {/* Login Page — split-screen */}
      {(authState === LOGIN_STATE || authState === MFA_STATE) && (
        <div
          className="flex overflow-hidden"
          style={{
            minHeight: '100vh',
            fontFamily: "'DM Sans', -apple-system, sans-serif",
            background: '#fafbfa',
          }}
        >
          {/* Left: Brand Panel */}
          <div
            className="hidden lg:flex flex-col justify-between relative overflow-hidden"
            style={{
              flex: 1,
              background: 'linear-gradient(160deg, #002a32 0%, #00493a 40%, #006171 100%)',
              padding: 48,
            }}
          >
            {/* Decorative shapes */}
            <div className="absolute inset-0 pointer-events-none overflow-hidden">
              <div
                className="absolute opacity-8 rounded-full"
                style={{
                  width: 200, height: 60, top: '15%', right: '10%',
                  transform: 'rotate(-25deg)',
                  background: 'rgba(255,255,255,0.08)',
                  borderRadius: 100,
                  animation: 'floatShape 8s ease-in-out infinite',
                }}
              />
              <div
                className="absolute opacity-8 rounded-full"
                style={{
                  width: 120, height: 40, top: '45%', right: '25%',
                  transform: 'rotate(15deg)',
                  background: 'rgba(255,255,255,0.08)',
                  borderRadius: 100,
                  animation: 'floatShape 10s ease-in-out infinite 2s',
                }}
              />
              <div
                className="absolute opacity-8"
                style={{
                  width: 80, height: 80, bottom: '20%', left: '15%',
                  borderRadius: '50%',
                  background: 'rgba(255,255,255,0.08)',
                  animation: 'floatShape 12s ease-in-out infinite 4s',
                }}
              />
              <div
                className="absolute opacity-8 rounded-full"
                style={{
                  width: 150, height: 45, top: '65%', left: '60%',
                  transform: 'rotate(-10deg)',
                  background: 'rgba(255,255,255,0.08)',
                  borderRadius: 100,
                  animation: 'floatShape 9s ease-in-out infinite 1s',
                }}
              />
              <div
                className="absolute opacity-8"
                style={{
                  width: 40, height: 40, top: '30%', left: '40%',
                  borderRadius: '50%',
                  background: 'rgba(255,255,255,0.08)',
                  animation: 'floatShape 11s ease-in-out infinite 3s',
                }}
              />
            </div>

            {/* Radial gradients */}
            <div
              className="absolute pointer-events-none"
              style={{
                top: '-20%', right: '-15%', width: 600, height: 600,
                borderRadius: '50%',
                background: 'radial-gradient(circle, rgba(10, 132, 79, 0.25) 0%, transparent 70%)',
              }}
            />
            <div
              className="absolute pointer-events-none"
              style={{
                bottom: '-10%', left: '-10%', width: 400, height: 400,
                borderRadius: '50%',
                background: 'radial-gradient(circle, rgba(0, 97, 113, 0.3) 0%, transparent 70%)',
              }}
            />

            {/* Logo */}
            <div className="relative z-10">
              <img
                src="/logo/logo-principal-branco.svg"
                alt="Conheça Farmácia"
                style={{ width: '80%', maxWidth: 240 }}
              />
            </div>

            {/* Content */}
            <div className="relative z-10" style={{ maxWidth: 400 }}>
              <h2
                className="text-white mb-4"
                style={{ fontSize: 32, fontWeight: 300, fontFamily: "'Fraunces', serif", lineHeight: 1.3 }}
              >
                Painel de gestão do{' '}
                <em style={{ fontStyle: 'italic', fontWeight: 500 }}>Conheça Farmácia</em>
              </h2>
              <p style={{ color: 'rgba(255,255,255,0.7)', fontSize: 15, lineHeight: 1.6 }}>
                Painel de administração para publicar artigos, eventos e lives.
              </p>
            </div>

            {/* Badge */}
            <div className="relative z-10">
              <div
                className="inline-flex items-center gap-2 py-2 px-4 rounded-full"
                style={{
                  background: 'rgba(255, 255, 255, 0.08)',
                  border: '1px solid rgba(255, 255, 255, 0.1)',
                  color: 'rgba(255, 255, 255, 0.7)',
                  fontSize: 13,
                }}
              >
                <span
                  className="w-2 h-2 rounded-full inline-block"
                  style={{ background: '#0a844f' }}
                />
                Sistema seguro e encriptado
              </div>
            </div>
          </div>

          {/* Right: Form Panel */}
          <div
            className="flex items-center justify-center flex-1 p-8"
            style={{ maxWidth: 560 }}
          >
            <div className="w-full" style={{ maxWidth: 380 }}>
              {/* Login Section */}
              {authState === LOGIN_STATE && (
                <div>
                  <div className="mb-8">
                    <h1
                      className="mb-2"
                      style={{
                        fontSize: 28, fontWeight: 700, color: '#002a32',
                        fontFamily: "'Fraunces', serif",
                      }}
                    >
                      Bem-vindo de volta
                    </h1>
                    <p style={{ color: '#6b7280', fontSize: 14 }}>
                      Introduza as suas credenciais para aceder ao painel.
                    </p>
                  </div>

                  <form onSubmit={handleLoginSubmit} className="space-y-5">
                    <div>
                      <label
                        htmlFor="email"
                        className="block mb-1.5 text-sm font-medium"
                        style={{ color: '#374151' }}
                      >
                        Email
                      </label>
                      <input
                        id="email"
                        type="email"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        required
                        placeholder="admin@exemplo.com"
                        autoComplete="email"
                        className="w-full px-4 py-3 rounded-xl text-sm transition-all duration-200"
                        style={{
                          background: '#f9fafb',
                          border: '1.5px solid #e5e7eb',
                          color: '#002a32',
                          outline: 'none',
                        }}
                      />
                    </div>

                    <div>
                      <label
                        htmlFor="password"
                        className="block mb-1.5 text-sm font-medium"
                        style={{ color: '#374151' }}
                      >
                        Palavra-passe
                      </label>
                      <input
                        id="password"
                        type="password"
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        required
                        placeholder="••••••••"
                        autoComplete="current-password"
                        className="w-full px-4 py-3 rounded-xl text-sm transition-all duration-200"
                        style={{
                          background: '#f9fafb',
                          border: '1.5px solid #e5e7eb',
                          color: '#002a32',
                          outline: 'none',
                        }}
                      />
                    </div>

                    {loginError && (
                      <div
                        className="py-2.5 px-4 rounded-lg text-sm"
                        style={{ background: '#fee2e2', color: '#dc2626' }}
                      >
                        {loginError}
                      </div>
                    )}

                    <button
                      type="submit"
                      disabled={loginLoading}
                      className="w-full py-3.5 rounded-xl text-white font-semibold text-sm transition-all duration-200"
                      style={{
                        background: 'linear-gradient(135deg, #00493a 0%, #0a844f 100%)',
                        opacity: loginLoading ? 0.7 : 1,
                      }}
                    >
                      {loginLoading ? 'A entrar...' : 'Entrar no painel'}
                    </button>
                  </form>

                  <p
                    className="text-center mt-8"
                    style={{ color: '#9ca3af', fontSize: 12 }}
                  >
                    Acesso restrito a administradores autorizados
                  </p>
                </div>
              )}

              {/* MFA Section */}
              {authState === MFA_STATE && (
                <div className="text-center">
                  <div
                    className="mx-auto mb-5 w-16 h-16 rounded-full flex items-center justify-center"
                    style={{ background: '#e6f4ea' }}
                  >
                    <ShieldCheck size={32} style={{ color: '#0a844f' }} />
                  </div>

                  <h2
                    className="mb-2"
                    style={{
                      fontSize: 24, fontWeight: 700, color: '#002a32',
                      fontFamily: "'Fraunces', serif",
                    }}
                  >
                    Verificação de Segurança
                  </h2>
                  <p className="mb-8" style={{ color: '#6b7280', fontSize: 14 }}>
                    Introduza o código de 6 dígitos da sua aplicação autenticadora.
                  </p>

                  <form onSubmit={handleMFASubmit} className="space-y-5 text-left">
                    <div>
                      <label
                        htmlFor="totp-code"
                        className="block mb-1.5 text-sm font-medium"
                        style={{ color: '#374151' }}
                      >
                        Código de verificação
                      </label>
                      <input
                        id="totp-code"
                        type="text"
                        inputMode="numeric"
                        pattern="[0-9]{6}"
                        maxLength={6}
                        autoComplete="one-time-code"
                        value={totpCode}
                        onChange={(e) => setTotpCode(e.target.value.replace(/\D/g, ''))}
                        required
                        placeholder="000000"
                        className="w-full px-4 py-3 rounded-xl text-center transition-all duration-200"
                        style={{
                          background: '#f9fafb',
                          border: '1.5px solid #e5e7eb',
                          color: '#002a32',
                          outline: 'none',
                          fontSize: 24,
                          fontFamily: "'JetBrains Mono', monospace",
                          letterSpacing: '0.5em',
                        }}
                      />
                    </div>

                    {mfaError && (
                      <div
                        className="py-2.5 px-4 rounded-lg text-sm"
                        style={{ background: '#fee2e2', color: '#dc2626' }}
                      >
                        {mfaError}
                      </div>
                    )}

                    <button
                      type="submit"
                      disabled={mfaLoading}
                      className="w-full py-3.5 rounded-xl text-white font-semibold text-sm transition-all duration-200"
                      style={{
                        background: 'linear-gradient(135deg, #00493a 0%, #0a844f 100%)',
                        opacity: mfaLoading ? 0.7 : 1,
                      }}
                    >
                      {mfaLoading ? 'A verificar...' : 'Verificar'}
                    </button>
                  </form>

                  <p className="mt-6" style={{ color: '#9ca3af', fontSize: 12 }}>
                    Não consegue aceder à app autenticadora? Contacte o administrador.
                  </p>
                </div>
              )}
            </div>
          </div>
        </div>
      )}

      {/* Floating shapes animation */}
      <style>{`
        @keyframes floatShape {
          0%, 100% { transform: translateY(0) rotate(var(--rotate, 0deg)); }
          50% { transform: translateY(-15px) rotate(var(--rotate, 0deg)); }
        }

        input:focus {
          border-color: #00493a !important;
          box-shadow: 0 0 0 3px rgba(0, 73, 58, 0.1);
        }
      `}</style>
    </>
  )
}
