'use client'

import { Trophy, Medal, Crown, School } from 'lucide-react'

const MEDAL_COLORS = {
  0: { bg: 'bg-amber-100 dark:bg-amber-900/30', text: 'text-amber-600 dark:text-amber-400', icon: <Crown size={18} /> },
  1: { bg: 'bg-gray-100 dark:bg-gray-800/30', text: 'text-gray-500 dark:text-gray-400', icon: <Medal size={18} /> },
  2: { bg: 'bg-orange-100 dark:bg-orange-900/30', text: 'text-orange-600 dark:text-orange-400', icon: <Medal size={18} /> },
}

export default function CompetitionLeaderboard({ entries = [], currentStudentName = '', compact = false, lang = 'pt' }) {
  if (!entries || entries.length === 0) {
    return (
      <div className="text-center py-8 text-brand-deep/40">
        <Trophy size={32} className="mx-auto mb-2 opacity-40" />
        <p className="text-sm">Aguarda participantes...</p>
      </div>
    )
  }

  return (
    <div className={`space-y-2 ${compact ? 'max-h-64 overflow-y-auto' : ''}`}>
      {entries.map((entry, i) => {
        const isCurrentUser = entry.student_name === currentStudentName
        const medal = MEDAL_COLORS[i] || null

        return (
          <div
            key={entry.id || i}
            className={`flex items-center gap-3 p-3 rounded-xl transition-all ${
              isCurrentUser
                ? 'bg-brand-accent/10 border border-brand-accent/20'
                : medal
                  ? `${medal.bg} border border-transparent`
                  : 'bg-background border border-brand-divider/50'
            }`}
          >
            {/* Position */}
            <span className={`w-8 text-center font-bold ${medal ? medal.text : 'text-brand-deep/60'}`}>
              {medal ? medal.icon : <span>{entry.position || i + 1}</span>}
            </span>

            {/* Name + School */}
            <div className="flex-1 min-w-0">
              <div className={`font-medium truncate ${isCurrentUser ? 'text-brand-accent' : 'text-brand-deep'}`}>
                {entry.student_name}
                {isCurrentUser && <span className="text-xs ml-1 opacity-60">(tu)</span>}
              </div>
              {(entry.school_name || entry.class_name) && (
                <div className="text-xs text-brand-deep/50 flex items-center gap-1">
                  <School size={10} />
                  {entry.school_name}{entry.class_name ? ` — ${entry.class_name}` : ''}
                </div>
              )}
            </div>

            {/* Score + Stats */}
            <div className="text-right shrink-0">
              <div className="font-bold text-brand-accent">{entry.total_score} pts</div>
              {!compact && (
                <div className="text-xs text-brand-deep/50">
                  {entry.correct_count}/{entry.total_answered}
                  {entry.max_streak > 0 && (
                    <span className="ml-1 text-amber-500">
                      🔥{entry.max_streak}
                    </span>
                  )}
                </div>
              )}
            </div>
          </div>
        )
      })}
    </div>
  )
}
