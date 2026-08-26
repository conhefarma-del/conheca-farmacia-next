'use client'

import { useState, useEffect, useContext } from 'react'
import Link from 'next/link'
import { createClient } from '@/lib/supabase/client'
import { CheckCircle, Bookmark, PenLine, User, ArrowRight, Loader2 } from 'lucide-react'
import { LangContext } from '@/lib/contexts'

export default function ContaCriadaClient({ lang }) {
  const { t } = useContext(LangContext)
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)
  const [emailSent, setEmailSent] = useState(false)

  useEffect(() => {
    async function loadUser() {
      const supabase = createClient()
      const { data: { user }, error } = await supabase.auth.getUser()
      if (error || !user) {
        window.location.href = `/${lang}/entrar`
        return
      }
      setUser(user)

      // Send welcome email if new account (< 5 min)
      const sentKey = `cf_welcome_sent_${user.id}`
      if (!sessionStorage.getItem(sentKey)) {
        const createdAt = new Date(user.created_at)
        const ageMinutes = (Date.now() - createdAt.getTime()) / 60000
        if (ageMinutes < 5) {
          sessionStorage.setItem(sentKey, '1')
          const name = user.user_metadata?.full_name || user.user_metadata?.display_name || user.email?.split('@')[0] || ''
          try {
            const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
            await fetch(`${supabaseUrl}/functions/v1/send-newsletter-email`, {
              method: 'POST',
              headers: {
                'Content-Type': 'application/json',
                'apikey': process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
              },
              body: JSON.stringify({
                type: 'welcome-account',
                email: user.email,
                nome: name,
              }),
            })
            setEmailSent(true)
          } catch {
            // Silently fail
          }
        }
      }

      setLoading(false)
    }
    loadUser()
  }, [lang])

  const displayName = user?.user_metadata?.full_name || user?.user_metadata?.display_name || user?.email?.split('@')[0] || 'Utilizador'

  const features = [
    {
      icon: <Bookmark size={20} />,
      title: 'Guardados',
      description: 'Guarda medicamentos, artigos, alvos e interações para consultar depois. Acedes de qualquer dispositivo.',
    },
    {
      icon: <PenLine size={20} />,
      title: 'Anotações',
      description: 'Cria notas em qualquer página — medicamentos, alvos, artigos, interações. Uma nota contínua por item, sempre guardada.',
    },
    {
      icon: <User size={20} />,
      title: 'Perfil & Progresso',
      description: 'Acompanha o teu histórico de quiz, guardados e anotações no teu perfil pessoal.',
    },
  ]

  if (loading) {
    return (
      <section className="events-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <div className="w-20 h-20 rounded-full mx-auto mb-6" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite', opacity: 0.3 }} />
            <div className="h-10 w-80 mx-auto rounded-lg mb-4" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite', opacity: 0.3 }} />
            <div className="h-5 w-96 mx-auto rounded" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite', opacity: 0.2 }} />
          </div>
        </div>
      </section>
    )
  }

  return (
    <>
      {/* Hero — mesmo estilo que /cientificos */}
      <section className="events-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <div className="inline-flex items-center justify-center w-20 h-20 rounded-full bg-green-100 dark:bg-green-900/30 mb-6">
              <CheckCircle size={40} className="text-green-600 dark:text-green-400" />
            </div>
            <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-6">
              Conta Criada!
            </h1>
            <p className="hero-subtitle text-center">
              Bem-vindo, <strong className="text-brand-accent">{displayName}</strong>!
              <br />
              A tua conta foi criada com sucesso. Guarda, anota e estuda farmacologia num só sítio.
            </p>
          </div>
        </div>
      </section>

      {/* Conteúdo */}
      <section className="bg-background">
        <div className="max-w-3xl mx-auto px-6 py-12 md:py-16">
          {/* Email de boas-vindas */}
          {emailSent && (
            <div className="bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-2xl p-4 mb-8 text-center">
              <p className="text-sm text-green-700 dark:text-green-300">
                📧 Enviámos um email de boas-vindas para <strong>{user?.email}</strong>
              </p>
            </div>
          )}

          {/* Funcionalidades */}
          <div className="mb-10">
            <p className="text-xs font-semibold text-brand-accent uppercase tracking-widest mb-6 text-center">
              Novo na tua conta
            </p>
            <div className="space-y-4">
              {features.map((feature, i) => (
                <div
                  key={i}
                  className="flex items-start gap-4 p-5 rounded-2xl bg-brand-deep/[0.03] dark:bg-white/5"
                >
                  <div className="flex-shrink-0 w-10 h-10 rounded-xl bg-brand-accent/10 flex items-center justify-center text-brand-accent">
                    {feature.icon}
                  </div>
                  <div>
                    <h3 className="font-semibold text-brand-deep mb-1">{feature.title}</h3>
                    <p className="text-sm text-brand-deep/60 leading-relaxed">{feature.description}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Ferramentas */}
          <div className="mb-10">
            <p className="text-xs font-semibold text-brand-accent uppercase tracking-widest mb-6 text-center">
              Ferramentas para explorar
            </p>
            <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
              {[
                { label: 'Interações', href: `/${lang}/interacoes` },
                { label: 'Medicamentos', href: `/${lang}/medicamentos` },
                { label: 'Quiz', href: `/${lang}/praticar` },
                { label: 'Flashcards', href: `/${lang}/flashcards` },
                { label: 'Classes', href: `/${lang}/classes` },
                { label: 'Guias', href: `/${lang}/guias` },
              ].map((item) => (
                <Link
                  key={item.href}
                  href={item.href}
                  className="flex items-center justify-center gap-2 py-3 px-4 rounded-xl border border-brand-divider bg-card hover:bg-brand-deep/5 transition-all text-sm font-medium text-brand-deep"
                >
                  {item.label}
                </Link>
              ))}
            </div>
          </div>

          {/* CTA */}
          <div className="text-center">
            <Link
              href={`/${lang}/perfil`}
              className="inline-flex items-center gap-2 bg-brand-accent text-white px-8 py-3.5 rounded-xl font-semibold hover:bg-brand-accent/90 transition-all"
            >
              Ir para o Perfil
              <ArrowRight size={18} />
            </Link>
          </div>
        </div>
      </section>
    </>
  )
}
