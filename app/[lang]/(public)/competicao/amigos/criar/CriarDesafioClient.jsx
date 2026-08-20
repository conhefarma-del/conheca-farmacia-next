'use client'

import { useState, useContext, useCallback } from 'react'
import Link from 'next/link'
import { LangContext } from '@/lib/contexts'
import { createFriendChallenge, searchUsersForInvite, sendFriendInvite } from '@/lib/actions/competition'
import { Plus, Copy, Check, Search, UserPlus, Loader2, Settings, Users, Zap } from 'lucide-react'

const QUESTION_TYPES = [
  { value: 'pharmacology', label: 'Farmacologia' },
  { value: 'interaction', label: 'Interações' },
  { value: 'drug_class', label: 'Classes Terapêuticas' },
  { value: 'flashcard', label: 'Flashcards' },
  { value: 'protocol', label: 'Protocolos' },
]

export default function CriarDesafioClient({ lang }) {
  const { t } = useContext(LangContext)

  // Config
  const [name, setName] = useState('')
  const [questionsCount, setQuestionsCount] = useState(10)
  const [timePerQuestion, setTimePerQuestion] = useState(30)
  const [questionTypes, setQuestionTypes] = useState(['pharmacology', 'interaction', 'drug_class'])
  const [maxPlayers, setMaxPlayers] = useState(4)

  // Invite
  const [searchQuery, setSearchQuery] = useState('')
  const [searchResults, setSearchResults] = useState([])
  const [searching, setSearching] = useState(false)
  const [invitedIds, setInvitedIds] = useState(new Set())
  const [invitingId, setInvitingId] = useState(null)

  // Created
  const [created, setCreated] = useState(null)
  const [copied, setCopied] = useState(false)

  // General
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  const toggleType = (value) => {
    setQuestionTypes((prev) =>
      prev.includes(value) ? prev.filter((t) => t !== value) : [...prev, value]
    )
  }

  const handleSearch = useCallback(async (q) => {
    setSearchQuery(q)
    if (q.trim().length < 2) {
      setSearchResults([])
      return
    }
    setSearching(true)
    try {
      const results = await searchUsersForInvite(q)
      setSearchResults(results || [])
    } catch {} finally {
      setSearching(false)
    }
  }, [])

  const handleInvite = async (userId) => {
    if (!created) return
    setInvitingId(userId)
    try {
      const result = await sendFriendInvite(created.competitionId, userId)
      if (result.success) {
        setInvitedIds((prev) => new Set([...prev, userId]))
      } else {
        setError(result.error || 'Erro ao enviar convite')
      }
    } catch {
      setError('Erro ao enviar convite')
    } finally {
      setInvitingId(null)
    }
  }

  const handleCreate = async (e) => {
    e.preventDefault()
    if (!name.trim()) return
    if (questionTypes.length === 0) {
      setError('Seleciona pelo menos um tipo de pergunta')
      return
    }
    setLoading(true)
    setError('')
    try {
      const result = await createFriendChallenge({
        name: name.trim(),
        questionsCount,
        timePerQuestion,
        questionTypes,
        maxPlayers,
      })
      if (result.success) {
        setCreated(result)
      } else {
        setError(result.error || 'Erro ao criar desafio')
      }
    } catch {
      setError('Erro ao criar desafio')
    } finally {
      setLoading(false)
    }
  }

  const copyCode = () => {
    if (created?.accessCode) {
      navigator.clipboard.writeText(created.accessCode)
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
    }
  }

  // After creation — show invite panel
  if (created) {
    return (
      <>
        <section className="articles-hero">
          <div className="container-center text-center py-20 md:py-32">
            <Check size={48} className="mx-auto mb-4 text-green-500" />
            <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-6">
              Desafio Criado!
            </h1>
            <p className="text-lg text-brand-deep/60">Convida amigos para jogarem contigo</p>
          </div>
        </section>

        <section className="py-16 bg-background">
          <div className="container-center max-w-2xl mx-auto px-4 space-y-6">
            {error && (
              <div className="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-xl p-4 text-red-600 text-sm text-center">
                {error}
              </div>
            )}

            {/* Code card */}
            <div className="bg-card rounded-2xl border border-brand-divider p-6 text-center">
              <div className="text-sm text-brand-deep/50 mb-2">Código de convite</div>
              <div className="text-3xl font-mono font-bold text-brand-accent mb-4 tracking-wider">
                {created.accessCode}
              </div>
              <div className="flex gap-2 justify-center">
                <button
                  onClick={copyCode}
                  className="px-4 py-2 rounded-lg bg-brand-accent text-white text-sm font-semibold hover:bg-brand-accent/90 transition-all flex items-center gap-2"
                >
                  {copied ? <><Check size={16} /> Copiado!</> : <><Copy size={16} /> Copiar Código</>}
                </button>
                <a
                  href={`https://wa.me/?text=${encodeURIComponent(`Entra no desafio "${created.name}" com o código: ${created.accessCode}\nhttps://conhecafarmacia.com/${lang}/competicao/amigos`)}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="px-4 py-2 rounded-lg border border-brand-divider text-brand-deep text-sm font-medium hover:bg-brand-deep/5 transition-all"
                >
                  WhatsApp
                </a>
              </div>
            </div>

            {/* Search & invite */}
            <div className="bg-card rounded-2xl border border-brand-divider p-6">
              <h3 className="text-lg font-bold text-brand-deep mb-4 flex items-center gap-2">
                <UserPlus size={20} className="text-brand-accent" />
                Convidar Amigos
              </h3>
              <div className="relative mb-4">
                <Search size={18} className="absolute left-3 top-1/2 -translate-y-1/2 text-brand-deep/40" />
                <input
                  type="text"
                  value={searchQuery}
                  onChange={(e) => handleSearch(e.target.value)}
                  placeholder="Pesquisar por nome ou email..."
                  className="w-full pl-10 pr-4 py-3 rounded-xl border border-brand-divider bg-background text-brand-deep text-sm focus:outline-none focus:ring-2 focus:ring-brand-accent"
                />
                {searching && (
                  <Loader2 size={16} className="absolute right-3 top-1/2 -translate-y-1/2 text-brand-accent animate-spin" />
                )}
              </div>
              {searchResults.length > 0 && (
                <div className="space-y-2">
                  {searchResults.map((u) => (
                    <div key={u.id} className="flex items-center gap-3 p-3 rounded-xl bg-background">
                      {u.avatarUrl ? (
                        <img src={u.avatarUrl} alt="" className="w-8 h-8 rounded-full object-cover" />
                      ) : (
                        <div className="w-8 h-8 rounded-full bg-brand-accent/10 flex items-center justify-center text-brand-accent text-xs font-bold">
                          {u.name.charAt(0).toUpperCase()}
                        </div>
                      )}
                      <div className="flex-1 min-w-0">
                        <div className="text-sm font-medium text-brand-deep truncate">{u.name}</div>
                        <div className="text-xs text-brand-deep/40 truncate">{u.email}</div>
                      </div>
                      {invitedIds.has(u.id) ? (
                        <span className="text-xs text-green-600 font-medium flex items-center gap-1">
                          <Check size={14} /> Convidado
                        </span>
                      ) : (
                        <button
                          onClick={() => handleInvite(u.id)}
                          disabled={invitingId === u.id || created.maxPlayers <= 2}
                          className="px-3 py-1.5 rounded-lg bg-brand-accent text-white text-xs font-semibold hover:bg-brand-accent/90 transition-all disabled:opacity-50 flex items-center gap-1"
                        >
                          {invitingId === u.id ? <Loader2 size={12} className="animate-spin" /> : <UserPlus size={12} />}
                          Convidar
                        </button>
                      )}
                    </div>
                  ))}
                </div>
              )}
              {searchQuery.length >= 2 && !searching && searchResults.length === 0 && (
                <p className="text-sm text-brand-deep/40 text-center py-4">
                  Nenhum utilizador encontrado
                </p>
              )}
            </div>

            {/* Go to lobby */}
            <Link
              href={`/${lang}/competicao/amigos/${created.accessCode}`}
              className="block w-full py-3 rounded-xl bg-brand-accent text-white font-semibold text-center hover:bg-brand-accent/90 transition-all"
            >
              Entrar no Lobby →
            </Link>
          </div>
        </section>
      </>
    )
  }

  // Before creation — config form
  return (
    <>
      <section className="articles-hero">
        <div className="container-center text-center py-20 md:py-32">
          <Settings size={48} className="mx-auto mb-4 text-brand-accent" />
          <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-6">
            Criar Desafio
          </h1>
          <p className="text-lg text-brand-deep/60">Configura o teu quiz e convida amigos!</p>
        </div>
      </section>

      <section className="py-16 bg-background">
        <div className="container-center max-w-2xl mx-auto px-4 space-y-6">
          {error && (
            <div className="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-xl p-4 text-red-600 text-sm text-center">
              {error}
            </div>
          )}

          <form onSubmit={handleCreate} className="space-y-6">
            {/* Name */}
            <div className="bg-card rounded-2xl border border-brand-divider p-6">
              <label className="block text-sm font-medium text-brand-deep mb-2">Nome do desafio</label>
              <input
                type="text"
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="Ex: Quiz Farmacologia"
                className="w-full px-4 py-3 rounded-xl border border-brand-divider bg-background text-brand-deep text-sm focus:outline-none focus:ring-2 focus:ring-brand-accent"
                required
                maxLength={50}
              />
            </div>

            {/* Config */}
            <div className="bg-card rounded-2xl border border-brand-divider p-6 space-y-5">
              <h3 className="font-bold text-brand-deep flex items-center gap-2">
                <Zap size={18} className="text-brand-accent" /> Configuração
              </h3>

              {/* Questions count */}
              <div>
                <label className="block text-xs text-brand-deep/60 mb-2">Perguntas</label>
                <div className="flex gap-2">
                  {[5, 10, 15].map((n) => (
                    <button
                      key={n}
                      type="button"
                      onClick={() => setQuestionsCount(n)}
                      className={`flex-1 py-2 rounded-lg text-sm font-medium transition-all ${
                        questionsCount === n
                          ? 'bg-brand-accent text-white'
                          : 'bg-background border border-brand-divider text-brand-deep hover:border-brand-accent'
                      }`}
                    >
                      {n}
                    </button>
                  ))}
                </div>
              </div>

              {/* Time per question */}
              <div>
                <label className="block text-xs text-brand-deep/60 mb-2">Tempo por pergunta</label>
                <div className="flex gap-2">
                  {[15, 30, 45].map((s) => (
                    <button
                      key={s}
                      type="button"
                      onClick={() => setTimePerQuestion(s)}
                      className={`flex-1 py-2 rounded-lg text-sm font-medium transition-all ${
                        timePerQuestion === s
                          ? 'bg-brand-accent text-white'
                          : 'bg-background border border-brand-divider text-brand-deep hover:border-brand-accent'
                      }`}
                    >
                      {s}s
                    </button>
                  ))}
                </div>
              </div>

              {/* Max players */}
              <div>
                <label className="block text-xs text-brand-deep/60 mb-2">Máximo de jogadores</label>
                <div className="flex gap-2">
                  {[2, 3, 4].map((n) => (
                    <button
                      key={n}
                      type="button"
                      onClick={() => setMaxPlayers(n)}
                      className={`flex-1 py-2 rounded-lg text-sm font-medium transition-all ${
                        maxPlayers === n
                          ? 'bg-brand-accent text-white'
                          : 'bg-background border border-brand-divider text-brand-deep hover:border-brand-accent'
                      }`}
                    >
                      {n}
                    </button>
                  ))}
                </div>
              </div>

              {/* Question types */}
              <div>
                <label className="block text-xs text-brand-deep/60 mb-2">Tipos de perguntas</label>
                <div className="flex flex-wrap gap-2">
                  {QUESTION_TYPES.map((qt) => (
                    <button
                      key={qt.value}
                      type="button"
                      onClick={() => toggleType(qt.value)}
                      className={`px-3 py-1.5 rounded-lg text-xs font-medium transition-all ${
                        questionTypes.includes(qt.value)
                          ? 'bg-brand-accent text-white'
                          : 'bg-background border border-brand-divider text-brand-deep hover:border-brand-accent'
                      }`}
                    >
                      {qt.label}
                    </button>
                  ))}
                </div>
                {questionTypes.length === 0 && (
                  <p className="text-xs text-red-500 mt-1">Seleciona pelo menos um tipo</p>
                )}
              </div>
            </div>

            {/* Submit */}
            <button
              type="submit"
              disabled={loading || !name.trim() || questionTypes.length === 0}
              className="w-full py-3 rounded-xl bg-brand-accent text-white font-semibold hover:bg-brand-accent/90 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
            >
              {loading ? (
                <Loader2 size={18} className="animate-spin" />
              ) : (
                <><Plus size={18} /> Criar Desafio</>
              )}
            </button>
          </form>
        </div>
      </section>
    </>
  )
}
