'use client'

import { AlertTriangle, BarChart3, BrainCircuit, Database, Percent, Trophy, Target } from 'lucide-react'

const MODE_LABELS = { deck: 'Por deck', tipo: 'Por tipo', rapido: 'Modo rápido', nivel: 'Por nível' }
const SOURCE_LABELS = {
  flashcard: 'Flashcards',
  pharmacology: 'Farmacologia',
  interaction: 'Interações',
  protocol: 'Protocolos',
  mixed: 'Misto',
}
function sourceLabel(key) {
  if (!key) return '—'
  if (key.startsWith('nivel:')) {
    const level = key.slice(6)
    const names = { facil: 'Fácil', medio: 'Médio', dificil: 'Difícil' }
    return `Nível: ${names[level] || level}`
  }
  return SOURCE_LABELS[key] || key
}

// Pools que alimentam as perguntas + mínimo saudável p/ avisar escassez
const POOL_CONFIG = [
  { key: 'cards', label: 'Cartões de flashcards', hint: 'fontes de perguntas de memória', min: 30 },
  { key: 'drugs', label: 'Fármacos (farmacologia)', hint: 'classe/mecanismo/meia-vida', min: 10 },
  { key: 'interactions', label: 'Interações fármaco-fármaco', hint: 'perguntas do nível difícil', min: 10 },
  { key: 'food', label: 'Interações alimento/bebida', hint: 'perguntas dos níveis médio/difícil', min: 10 },
  { key: 'disease', label: 'Interações doença/condição', hint: 'perguntas dos níveis médio/difícil', min: 10 },
  { key: 'protocols', label: 'Quizzes de protocolo', hint: 'perguntas curadas do nível difícil', min: 5 },
]

function formatDate(dateStr) {
  if (!dateStr) return '—'
  const d = new Date(dateStr)
  if (isNaN(d.getTime())) return '—'
  return d.toLocaleDateString('pt-PT', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' })
}

/**
 * QuizStatsPage — estatísticas das tentativas de quiz (admin) + contagens
 * reais dos pools que geram as perguntas (para detetar tipos escassos).
 */
export default function QuizStatsPage({ stats, poolCounts }) {
  const total = stats?.attempts || 0
  const avg = stats?.avgAccuracy ?? 0
  const byMode = stats?.byMode || []
  const bySource = stats?.bySource || []
  const recent = stats?.recent || []
  const pools = poolCounts || {}
  const lowPools = POOL_CONFIG.filter((p) => (pools[p.key] ?? 0) < p.min)

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-2xl font-bold text-brand-deep">Quiz — Estatísticas</h1>
        <p className="text-sm text-brand-deep/60 mt-1">
          Tentativas guardadas (só com sessão; o modo &ldquo;sem registo&rdquo; não guarda).
        </p>
      </div>

      {/* Pools de perguntas (dados reais) */}
      <div className="rounded-2xl border border-brand-divider bg-brand-card p-5">
        <div className="flex items-center gap-2 text-brand-deep/70 mb-1">
          <Database size={18} />
          <span className="text-sm font-semibold">Pools de perguntas (dados reais)</span>
        </div>
        <p className="text-xs text-brand-deep/50 mb-4">
          Registos publicados que alimentam o Quiz. Se algum tipo estiver abaixo do mínimo, o nível
          correspondente perde variedade (o motor faz backfill com outros tipos).
        </p>
        {!poolCounts ? (
          <p className="text-sm text-brand-deep/50">Sem acesso aos pools.</p>
        ) : (
          <>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
              {POOL_CONFIG.map((p) => {
                const val = pools[p.key]
                const isLow = (val ?? 0) < p.min
                return (
                  <div
                    key={p.key}
                    className={`rounded-xl border p-4 ${isLow ? 'border-amber-400/60 bg-amber-50 dark:bg-amber-900/10' : 'border-brand-divider bg-brand-bg-alt'}`}
                  >
                    <div className="flex items-center justify-between gap-2">
                      <span className="text-sm font-semibold text-brand-deep">{p.label}</span>
                      {isLow && (
                        <span className="inline-flex items-center gap-1 text-[11px] font-bold text-amber-700 dark:text-amber-400">
                          <AlertTriangle size={12} /> baixo
                        </span>
                      )}
                    </div>
                    <div className="mt-1 text-2xl font-extrabold text-brand-deep">{val ?? '—'}</div>
                    <div className="text-[11px] text-brand-deep/50">{p.hint} · min. {p.min}</div>
                  </div>
                )
              })}
            </div>
            {lowPools.length > 0 && (
              <p className="mt-3 text-xs text-amber-700 dark:text-amber-400 font-semibold">
                {lowPools.map((p) => p.label).join(' · ')} — abaixo do mínimo.
              </p>
            )}
          </>
        )}
      </div>

      {/* Cards principais */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div className="rounded-2xl border border-brand-divider bg-brand-card p-5">
          <div className="flex items-center gap-2 text-brand-accent mb-2">
            <Target size={18} />
            <span className="text-xs font-semibold uppercase tracking-wide">Tentativas</span>
          </div>
          <div className="text-3xl font-extrabold text-brand-deep">{total}</div>
        </div>
        <div className="rounded-2xl border border-brand-divider bg-brand-card p-5">
          <div className="flex items-center gap-2 text-brand-accent mb-2">
            <Percent size={18} />
            <span className="text-xs font-semibold uppercase tracking-wide">Média de acerto</span>
          </div>
          <div className="text-3xl font-extrabold text-brand-deep">{avg}%</div>
        </div>
        <div className="rounded-2xl border border-brand-divider bg-brand-card p-5">
          <div className="flex items-center gap-2 text-brand-accent mb-2">
            <Trophy size={18} />
            <span className="text-xs font-semibold uppercase tracking-wide">Modo mais usado</span>
          </div>
          <div className="text-3xl font-extrabold text-brand-deep">
            {byMode.length ? MODE_LABELS[byMode.sort((a, b) => b.count - a.count)[0].key] || '—' : '—'}
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Por modo */}
        <div className="rounded-2xl border border-brand-divider bg-brand-card p-5">
          <div className="flex items-center gap-2 text-brand-deep/70 mb-4">
            <BrainCircuit size={18} />
            <span className="text-sm font-semibold">Por modo</span>
          </div>
          {byMode.length === 0 ? (
            <p className="text-sm text-brand-deep/50">Sem tentativas ainda.</p>
          ) : (
            <ul className="space-y-2">
              {byMode.map((m) => (
                <li key={m.key} className="flex items-center justify-between text-sm">
                  <span className="text-brand-deep/80">{MODE_LABELS[m.key] || m.key}</span>
                  <span className="font-semibold text-brand-deep">{m.count}</span>
                </li>
              ))}
            </ul>
          )}
        </div>

        {/* Por fonte */}
        <div className="rounded-2xl border border-brand-divider bg-brand-card p-5">
          <div className="flex items-center gap-2 text-brand-deep/70 mb-4">
            <BarChart3 size={18} />
            <span className="text-sm font-semibold">Por fonte de perguntas</span>
          </div>
          {bySource.length === 0 ? (
            <p className="text-sm text-brand-deep/50">Sem tentativas ainda.</p>
          ) : (
            <ul className="space-y-2">
              {bySource.map((s) => (
                <li key={s.key} className="flex items-center justify-between text-sm">
                  <span className="text-brand-deep/80">{sourceLabel(s.key)}</span>
                  <span className="font-semibold text-brand-deep">{s.count}</span>
                </li>
              ))}
            </ul>
          )}
        </div>
      </div>

      {/* Recentes */}
      <div className="rounded-2xl border border-brand-divider bg-brand-card p-5">
        <h2 className="text-sm font-semibold text-brand-deep/70 mb-4">Tentativas recentes</h2>
        {recent.length === 0 ? (
          <p className="text-sm text-brand-deep/50">Sem tentativas ainda.</p>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="text-left text-xs uppercase tracking-wide text-brand-deep/50 border-b border-brand-divider">
                  <th className="py-2 pr-4">Data</th>
                  <th className="py-2 pr-4">Modo</th>
                  <th className="py-2 pr-4">Fonte</th>
                  <th className="py-2 pr-4">Acerto</th>
                </tr>
              </thead>
              <tbody>
                {recent.map((r) => (
                  <tr key={r.id} className="border-b border-brand-divider/60 last:border-0">
                    <td className="py-2 pr-4 text-brand-deep/70">{formatDate(r.finishedAt)}</td>
                    <td className="py-2 pr-4">{MODE_LABELS[r.mode] || r.mode}</td>
                    <td className="py-2 pr-4">{sourceLabel(r.source)}</td>
                    <td className="py-2 pr-4 font-semibold">
                      {r.correct}/{r.total}
                      {r.total > 0 ? ` (${Math.round((r.correct / r.total) * 100)}%)` : ''}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  )
}
