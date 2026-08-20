'use client'

import { useState, useEffect } from 'react'
import Link from 'next/link'
import { createClient } from '@/lib/supabase/client'
import { LogOut, User, Mail, Calendar, Trophy, BookOpen, Pill, ShieldAlert, ClipboardList, Atom, Loader2, Settings, School, Target, ChevronRight, Edit3, Save, X, BrainCircuit } from 'lucide-react'

export default function PerfilClient({ lang }) {
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)
  const [signingOut, setSigningOut] = useState(false)
  const [editingName, setEditingName] = useState(false)
  const [newName, setNewName] = useState('')
  const [saving, setSaving] = useState(false)
  const [saveMsg, setSaveMsg] = useState('')

  useEffect(() => {
    async function loadUser() {
      const supabase = createClient()
      const { data: { user }, error } = await supabase.auth.getUser()
      if (error || !user) {
        window.location.href = `/${lang}/entrar`
        return
      }
      setUser(user)
      setNewName(user.user_metadata?.full_name || user.user_metadata?.display_name || '')
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

  const handleSaveName = async () => {
    if (!newName.trim()) return
    setSaving(true)
    setSaveMsg('')
    try {
      const supabase = createClient()
      const { error } = await supabase.auth.updateUser({
        data: { full_name: newName.trim(), display_name: newName.trim() },
      })
      if (error) {
        setSaveMsg('Erro ao guardar: ' + error.message)
      } else {
        setUser((prev) => ({
          ...prev,
          user_metadata: { ...prev.user_metadata, full_name: newName.trim(), display_name: newName.trim() },
        }))
        setEditingName(false)
        setSaveMsg('Nome atualizado!')
      }
    } catch {
      setSaveMsg('Erro ao conectar ao servidor')
    } finally {
      setSaving(false)
    }
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

  const tools = [
    { href: `/${lang}/medicamentos`, label: 'Medicamentos', desc: 'Explora fármacos, mecanismos e perfis clínicos', icon: <Pill size={20} /> },
    { href: `/${lang}/interacoes`, label: 'Interações', desc: 'Verifica interações medicamentosas', icon: <ShieldAlert size={20} /> },
    { href: `/${lang}/competicao`, label: 'Competição', desc: 'Quiz competitivo entre escolas', icon: <Trophy size={20} /> },
    { href: `/${lang}/praticar`, label: 'Quiz', desc: 'Testa os teus conhecimentos', icon: <BrainCircuit size={20} /> },
    { href: `/${lang}/flashcards`, label: 'Flashcards', desc: 'Memoriza conceitos-chave', icon: <BookOpen size={20} /> },
    { href: `/${lang}/classes`, label: 'Classes Terapêuticas', desc: 'Explora classes ATC e exemplos', icon: <ClipboardList size={20} /> },
    { href: `/${lang}/alvos`, label: 'Alvos Moleculares', desc: 'Mecanismos de ação dos fármacos', icon: <Atom size={20} /> },
  ]

  return (
    <>
      <section className="articles-hero">
        <div className="container-center">
          <div className="text-center py-20 md:py-32">
            <User size={48} className="mx-auto mb-4 text-brand-accent" />
            <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-6">
              O Meu Perfil
            </h1>
            <p className="text-lg text-brand-deep/60 max-w-xl mx-auto">
              Geria a tua conta e explora todas as ferramentas do Conheça Farmácia.
            </p>
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
              <div className="flex-1 min-w-0">
                {editingName ? (
                  <div className="flex items-center gap-2">
                    <input
                      type="text"
                      value={newName}
                      onChange={(e) => setNewName(e.target.value)}
                      className="flex-1 px-3 py-1.5 rounded-lg border border-brand-accent bg-background text-brand-deep text-lg font-bold focus:outline-none focus:ring-2 focus:ring-brand-accent"
                      autoFocus
                    />
                    <button onClick={handleSaveName} disabled={saving} className="p-1.5 rounded-lg bg-brand-accent text-white hover:bg-brand-accent/90 transition-colors">
                      <Save size={16} />
                    </button>
                    <button onClick={() => { setEditingName(false); setNewName(user.user_metadata?.full_name || '') }} className="p-1.5 rounded-lg border border-brand-divider text-brand-deep/60 hover:bg-brand-deep/5 transition-colors">
                      <X size={16} />
                    </button>
                  </div>
                ) : (
                  <div className="flex items-center gap-2">
                    <h2 className="text-xl font-bold text-brand-deep truncate">{displayName}</h2>
                    <button onClick={() => setEditingName(true)} className="p-1 rounded-lg text-brand-deep/40 hover:text-brand-accent hover:bg-brand-accent/10 transition-colors">
                      <Edit3 size={14} />
                    </button>
                  </div>
                )}
                <div className="flex items-center gap-1 text-sm text-brand-deep/60 mt-1">
                  <Mail size={14} />
                  {user.email}
                </div>
              </div>
            </div>

            {saveMsg && <p className="text-sm text-center text-brand-accent mb-4">{saveMsg}</p>}

            <div className="grid grid-cols-3 gap-3">
              <div className="bg-background rounded-xl p-4 text-center">
                <div className="text-brand-accent mb-1"><Calendar size={18} className="mx-auto" /></div>
                <div className="text-xs text-brand-deep/50">Membro desde</div>
                <div className="font-medium text-brand-deep text-sm mt-1">{createdAt}</div>
              </div>
              <div className="bg-background rounded-xl p-4 text-center">
                <div className="text-brand-accent mb-1"><Target size={18} className="mx-auto" /></div>
                <div className="text-xs text-brand-deep/50">Provedor</div>
                <div className="font-medium text-brand-deep text-sm mt-1 capitalize">
                  {user.app_metadata?.provider === 'google' ? 'Google' : 'Email'}
                </div>
              </div>
              <div className="bg-background rounded-xl p-4 text-center">
                <div className="text-brand-accent mb-1"><School size={18} className="mx-auto" /></div>
                <div className="text-xs text-brand-deep/50">Escola</div>
                <div className="font-medium text-brand-deep text-sm mt-1">
                  {user.user_metadata?.school || '—'}
                </div>
              </div>
            </div>
          </div>

          {/* Quick Links */}
          <div className="bg-card rounded-2xl border border-brand-divider p-6">
            <h3 className="text-lg font-bold text-brand-deep mb-4">As Minhas Ferramentas</h3>
            <div className="space-y-1">
              {tools.map((tool) => (
                <Link key={tool.href} href={tool.href} className="flex items-center gap-3 p-3 rounded-xl hover:bg-brand-accent/5 transition-all group">
                  <div className="w-10 h-10 rounded-xl bg-brand-accent/10 flex items-center justify-center text-brand-accent flex-shrink-0">
                    {tool.icon}
                  </div>
                  <div className="flex-1 min-w-0">
                    <span className="font-medium text-brand-deep block">{tool.label}</span>
                    <span className="text-xs text-brand-deep/50 hidden sm:block">{tool.desc}</span>
                  </div>
                  <ChevronRight size={16} className="text-brand-deep/30 group-hover:text-brand-accent transition-colors" />
                </Link>
              ))}
            </div>
          </div>

          {/* Preferences hint */}
          <div className="bg-card rounded-2xl border border-brand-divider p-6">
            <h3 className="text-lg font-bold text-brand-deep mb-4">Preferências</h3>
            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <Settings size={18} className="text-brand-deep/50" />
                  <span className="text-sm text-brand-deep">Modo escuro/claro</span>
                </div>
                <span className="text-xs text-brand-deep/40">Header → Toggle</span>
              </div>
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <Mail size={18} className="text-brand-deep/50" />
                  <span className="text-sm text-brand-deep">Email</span>
                </div>
                <span className="text-xs text-brand-deep/40">{user.email}</span>
              </div>
            </div>
          </div>

          {/* Sign Out */}
          <button
            onClick={handleSignOut}
            disabled={signingOut}
            className="w-full py-3 rounded-xl border border-red-300 text-red-600 hover:bg-red-50 dark:hover:bg-red-900/10 transition-all flex items-center justify-center gap-2"
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
