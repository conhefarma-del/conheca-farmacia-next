'use client'

import { useState, useEffect } from 'react'
import Link from 'next/link'
import { createClient } from '@/lib/supabase/client'
import { LogOut, User, Mail, Calendar, Trophy, BookOpen, Settings, Loader2 } from 'lucide-react'

export default function PerfilClient({ lang }) {
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)
  const [signingOut, setSigningOut] = useState(false)

  useEffect(() => {
    async function loadUser() {
      const supabase = createClient()
      const { data: { user }, error } = await supabase.auth.getUser()
      if (error || !user) {
        window.location.href = `/${lang}/entrar`
        return
      }
      setUser(user)
      setLoading(false)
    }
    loadUser()
  }, [lang])

  const handleSignOut = async () => {
    setSigningOut(true)
    const supabase = createClient()
    await supabase.auth.signOut()
    window.location.href = `/${lang}`
  }

  if (loading) {
    return (
      <section className="py-20 text-center">
        <Loader2 size={40} className="mx-auto mb-4 text-brand-accent animate-spin" />
      </section>
    )
  }

  if (!user) return null

  const displayName = user.user_metadata?.full_name || user.user_metadata?.display_name || user.email?.split('@')[0] || 'Utilizador'
  const avatarUrl = user.user_metadata?.avatar_url
  const createdAt = new Date(user.created_at).toLocaleDateString('pt-PT', { year: 'numeric', month: 'long', day: 'numeric' })

  return (
    <>
      <section className="articles-hero">
        <div className="container-center">
          <div className="text-center py-20 md:py-32">
            <User size={48} className="mx-auto mb-4 text-brand-accent" />
            <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-6">
              O Meu Perfil
            </h1>
          </div>
        </div>
      </section>

      <section className="py-16 bg-background">
        <div className="container-center max-w-2xl mx-auto px-4 space-y-6">
          {/* Profile Card */}
          <div className="bg-card rounded-2xl border border-brand-divider p-8">
            <div className="flex items-center gap-4 mb-6">
              {avatarUrl ? (
                <img src={avatarUrl} alt={displayName} className="w-16 h-16 rounded-full object-cover border-2 border-brand-accent" />
              ) : (
                <div className="w-16 h-16 rounded-full bg-brand-accent/10 flex items-center justify-center">
                  <User size={32} className="text-brand-accent" />
                </div>
              )}
              <div>
                <h2 className="text-xl font-bold text-brand-deep">{displayName}</h2>
                <div className="flex items-center gap-1 text-sm text-brand-deep/60">
                  <Mail size={14} />
                  {user.email}
                </div>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div className="bg-background rounded-xl p-4">
                <div className="flex items-center gap-2 text-brand-deep/60 text-sm mb-1">
                  <Calendar size={14} />
                  Membro desde
                </div>
                <div className="font-medium text-brand-deep">{createdAt}</div>
              </div>
              <div className="bg-background rounded-xl p-4">
                <div className="flex items-center gap-2 text-brand-deep/60 text-sm mb-1">
                  <Trophy size={14} />
                  Provedor
                </div>
                <div className="font-medium text-brand-deep capitalize">
                  {user.app_metadata?.provider || 'Email'}
                </div>
              </div>
            </div>
          </div>

          {/* Quick Links */}
          <div className="bg-card rounded-2xl border border-brand-divider p-6">
            <h3 className="text-lg font-bold text-brand-deep mb-4">As Minhas Ferramentas</h3>
            <div className="space-y-2">
              <Link href={`/${lang}/quiz`} className="flex items-center gap-3 p-3 rounded-xl hover:bg-brand-accent/5 transition-all">
                <Trophy size={20} className="text-brand-accent" />
                <span className="font-medium text-brand-deep">Quiz</span>
              </Link>
              <Link href={`/${lang}/flashcards`} className="flex items-center gap-3 p-3 rounded-xl hover:bg-brand-accent/5 transition-all">
                <BookOpen size={20} className="text-brand-accent" />
                <span className="font-medium text-brand-deep">Flashcards</span>
              </Link>
              <Link href={`/${lang}/medicamentos`} className="flex items-center gap-3 p-3 rounded-xl hover:bg-brand-accent/5 transition-all">
                <Settings size={20} className="text-brand-accent" />
                <span className="font-medium text-brand-deep">Medicamentos</span>
              </Link>
            </div>
          </div>

          {/* Sign Out */}
          <button
            onClick={handleSignOut}
            disabled={signingOut}
            className="w-full py-3 rounded-xl border border-red-300 text-red-600 hover:bg-red-50 transition-all flex items-center justify-center gap-2"
          >
            {signingOut ? (
              <Loader2 size={18} className="animate-spin" />
            ) : (
              <>
                <LogOut size={18} />
                Terminar Sessão
              </>
            )}
          </button>
        </div>
      </section>
    </>
  )
}
